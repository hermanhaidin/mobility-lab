import SwiftUI

/// An offer's vehicle and specs, with a payment option and a mileage package to pick. Opened from its card in the
/// offer list. The top is always dark, like the offer cards. Continue goes on to protection.
struct OfferDetailView: View {
    @State private var booking: Booking
    @AppStorage(SettingsKey.currencyCode) private var currencyCode = "USD"

    /// The status bar and toolbar, which the hero runs under.
    @State private var topInset = 0.0
    @State private var photoHeight = 0.0
    /// Whether the photo is still behind the toolbar, which then shows a white title and no soft edge.
    @State private var isPhotoUnderToolbar = true
    @State private var isShowingPriceDetails = false
    @State private var isShowingPaymentHelp = false

    private let catalog = MockData.offers

    init(offer: Offer, rentalDays: Int) {
        _booking = State(initialValue: Booking(offer: offer, rentalDays: rentalDays))
    }

    private var offer: Offer {
        booking.offer
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                hero
                if canUpgradeToUnlimited {
                    unlimitedNudge
                }
                VStack(alignment: .leading, spacing: 16) {
                    paymentOptions
                    mileagePackages
                }
                .padding()
            }
        }
        // The hero starts at the top of the screen, so its backdrop runs under the toolbar. A background inside
        // the scroll content can't reach into the safe area.
        .ignoresSafeArea(edges: .top)
        .onGeometryChange(for: Double.self) { $0.safeAreaInsets.top } action: { topInset = $0 }
        .onScrollGeometryChange(for: Bool.self) { geometry in
            geometry.contentOffset.y + geometry.contentInsets.top < photoHeight
        } action: { _, isUnder in
            isPhotoUnderToolbar = isUnder
        }
        // Over the photo, the soft edge would fog the backdrop white. Once the specs scroll up, the toolbar is the
        // standard one, so they don't run into the title.
        .scrollEdgeEffectHidden(isPhotoUnderToolbar, for: .top)
        .navigationTitle(offer.name)
        // Centered when it fits; a long name moves next to the back button and is cut off before the price.
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(isPhotoUnderToolbar ? .dark : nil, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isShowingPriceDetails = true
                } label: {
                    // The digits roll to the new total when an option changes it.
                    Text(currency.format(booking.total))
                        .contentTransition(.numericText(value: booking.total))
                        .animation(.default, value: booking.total)
                }
                .accessibilityHint("Shows the price details")
            }
        }
        .safeAreaBar(edge: .bottom) {
            NavigationLink {
                PlaceholderView(title: "Protection", systemImage: "shield.lefthalf.filled")
            } label: {
                Text("Continue")
            }
            .buttonStyle(.glassProminent)
            .buttonSizing(.flexible)
            .controlSize(.large)
            .fontWeight(.medium)
            // 36 points in from the screen's edges, so the capsule's ends follow the curve of the display corners.
            // Below it, the 34-point home indicator inset and 2 more make 36 too.
            .padding(.horizontal, 36)
            .padding(.top, 8)
            .padding(.bottom, 2)
        }
        .sheet(isPresented: $isShowingPriceDetails) {
            PriceDetailView(booking: booking)
        }
        .sheet(isPresented: $isShowingPaymentHelp) {
            PaymentOptionDetailView()
        }
    }

    // MARK: - Hero

    /// The photo on the studio backdrop, the model label, and the specs. The backdrop runs up under the toolbar.
    private var hero: some View {
        VStack(spacing: 0) {
            // The offer cards' photo frame: car photos are 752 × 500, and the empty sides of 1050 × 600 truck photos
            // are cut off.
            RemoteImage(url: offer.imageURL)
                .aspectRatio(752 / 500, contentMode: .fit)
                .clipped()
                .onGeometryChange(for: Double.self) { $0.size.height } action: { photoHeight = $0 }
                .padding(.top, topInset)

            VStack(spacing: 12) {
                HStack(spacing: 8) {
                    ModelLabelButton(offer: offer)
                    if offer.fuel == .electric {
                        SpecChip(title: "Electric", systemImage: "bolt.fill")
                    }
                }

                FlowLayout(alignment: .center, spacing: 12) {
                    specs
                }
                .font(.footnote)
                .fontWeight(.semibold)

                if offer.vehicleType == .trucks {
                    NavigationLink {
                        PlaceholderView(title: "Vehicle dimensions", systemImage: "ruler")
                    } label: {
                        Text("Show vehicle dimensions")
                            .underline()
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                }
            }
            .padding([.horizontal, .bottom])
        }
        .frame(maxWidth: .infinity)
        .background {
            OfferBackdrop(offer: offer)
                // Pulling down past the top grows the backdrop up to the screen's edge, so no white shows above it.
                .visualEffect { content, proxy in
                    let pull = max(0, proxy.frame(in: .scrollView).minY)
                    return content.scaleEffect(1 + pull / max(proxy.size.height, 1), anchor: .bottom)
                }
        }
        .environment(\.colorScheme, .dark)
    }

    /// Everything the offer data has. Cars: seats, doors, suitcases, transmission, and range. Trucks: payload, gross weight,
    /// license, transmission, range, and equipment. Both end with the cables of electric vehicles and the minimum driver age.
    @ViewBuilder
    private var specs: some View {
        switch offer.vehicleType {
        case .cars:
            if let seats = offer.seats {
                Label("\(seats) People", systemImage: "person.fill")
            }
            if let doors = offer.doors {
                Label("\(doors) Doors", systemImage: "car.window.right")
            }
            if let suitcases = offer.suitcases {
                Label("\(suitcases) Large bags", systemImage: "suitcase.rolling.and.suitcase.fill")
            }
            Label(offer.transmission.title, systemImage: "gearshift.layout.sixspeed")
            fuel
        case .trucks:
            if let payloadKg = offer.payloadKg {
                Label(weight(payloadKg), systemImage: "truck.box.fill")
                    .accessibilityLabel("Payload \(weight(payloadKg))")
            }
            if let grossWeightKg = offer.grossWeightKg {
                Label(weight(grossWeightKg), systemImage: "scalemass.fill")
                    .accessibilityLabel("Gross weight \(weight(grossWeightKg))")
            }
            if let licenseClass = offer.licenseClass {
                Label("License \(licenseClass)", systemImage: "person.text.rectangle.fill")
            }
            Label(offer.transmission.title, systemImage: "gearshift.layout.sixspeed")
            fuel
            ForEach((offer.equipment ?? []).filter { $0 != .chargingCable }, id: \.self) { equipment in
                Label(equipment.title, systemImage: equipment.symbol)
            }
        }
        // Every electric vehicle comes with cables.
        if offer.equipment?.contains(.chargingCable) == true {
            Label(Offer.Equipment.chargingCable.title, systemImage: Offer.Equipment.chargingCable.symbol)
        }
        Label("Age of the youngest driver: \(offer.minDriverAge)", systemImage: "person.text.rectangle.fill")
    }

    /// The range of an electric vehicle, or "Hybrid". "Electric" itself sits next to the model label.
    @ViewBuilder
    private var fuel: some View {
        switch offer.fuel {
        case .electric:
            if let rangeKm = offer.rangeKm {
                Label("\(distance(rangeKm)) range", systemImage: "battery.100percent.bolt")
            }
        case .hybrid:
            Label("Hybrid", systemImage: "leaf.fill")
        case nil:
            EmptyView()
        }
    }

    // MARK: - Options

    private var paymentOptions: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader("Payment option") {
                Button {
                    isShowingPaymentHelp = true
                } label: {
                    Text("Need help?")
                        .underline()
                }
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.primary)
            }
            VStack(spacing: 12) {
                ForEach(catalog.paymentOptions) { option in
                    ChoiceCard(
                        title: option.title,
                        subtitle: option.subtitle,
                        price: surcharge(option.dailySurchargeRate),
                        isSelected: booking.paymentOption == option
                    ) {
                        booking.paymentOption = option
                    }
                }
            }
        }
    }

    private var mileagePackages: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader("Mileage package")
            VStack(spacing: 12) {
                ForEach(catalog.mileagePackages(for: offer), id: \.self) { package in
                    ChoiceCard(
                        title: package.title,
                        subtitle: package.kilometers == nil
                            ? "All kilometers are included in the price."
                            : "+\(currency.format(catalog.extraKilometerRate * offer.pricePerDay)) for every additional km.",
                        price: surcharge(package.dailySurchargeRate),
                        isSelected: booking.mileagePackage == package
                    ) {
                        booking.mileagePackage = package
                    }
                }
            }
            // Electric trucks have no AdBlue tank.
            if offer.vehicleType == .trucks && offer.fuel != .electric {
                Text(catalog.adBlueNotice)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
            }
        }
    }

    /// Like a prominent list header: bold, in sentence case, lined up with the text in the cards, with an optional
    /// button at the trailing edge.
    private func sectionHeader<Accessory: View>(
        _ title: String,
        @ViewBuilder accessory: () -> Accessory = { EmptyView() }
    ) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(.title3)
                .fontWeight(.semibold)
            Spacer()
            accessory()
        }
        .padding(.horizontal)
        .padding(.top, 14)
    }

    // MARK: - Mileage

    /// Whether the offer has a kilometer limit that an upgrade lifts.
    private var canUpgradeToUnlimited: Bool {
        catalog.mileagePackages(for: offer).contains { $0.kilometers == nil && $0.dailySurchargeRate > 0 }
    }

    private var unlimitedNudge: some View {
        Label("Unlimited kilometers available", systemImage: "checkmark")
            .font(.footnote)
            .fontWeight(.semibold)
            .foregroundStyle(.white)
            .padding(.vertical, 5)
            .frame(maxWidth: .infinity)
            .background(.green)
    }

    // MARK: - Text

    private var currency: Currency {
        MockData.currency(code: currencyCode)
    }

    /// "Included", or what an option adds per day, like "+$5.38 / day".
    private func surcharge(_ dailySurchargeRate: Double) -> String {
        guard dailySurchargeRate > 0 else { return "Included" }
        return "+\(currency.format(dailySurchargeRate * offer.pricePerDay)) / day"
    }

    private func distance(_ kilometers: Int) -> String {
        Measurement(value: Double(kilometers), unit: UnitLength.kilometers)
            .formatted(.measurement(width: .abbreviated, usage: .asProvided))
    }

    private func weight(_ kilograms: Int) -> String {
        Measurement(value: Double(kilograms), unit: UnitMass.kilograms)
            .formatted(.measurement(width: .abbreviated, usage: .asProvided))
    }
}

#Preview("Car") {
    NavigationStack {
        OfferDetailView(offer: MockData.offers.cars.first { $0.id == "bmw-m340-touring" }!, rentalDays: 3)
    }
}

#Preview("Truck") {
    NavigationStack {
        OfferDetailView(offer: MockData.offers.trucks.first { $0.id == "vw-crafter-long" }!, rentalDays: 3)
    }
}
