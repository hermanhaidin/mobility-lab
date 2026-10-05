import SwiftUI

/// An offer's vehicle and specs, opened from its card in the offer list. The top is always dark, like the offer
/// cards. Continue goes on to protection.
struct OfferDetailView: View {
    let offer: Offer
    let rentalDays: Int

    /// The status bar and toolbar, which the hero runs under.
    @State private var topInset = 0.0
    @State private var photoHeight = 0.0
    /// Whether the photo is still behind the toolbar, which then shows a white title and no soft edge.
    @State private var isPhotoUnderToolbar = true

    private let catalog = MockData.offers

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                hero
                if canUpgradeToUnlimited {
                    unlimitedNudge
                }
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
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(isPhotoUnderToolbar ? .dark : nil, for: .navigationBar)
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
    }

    // MARK: - Hero

    /// The photo on the studio backdrop, the model label, and the specs. The backdrop runs up under the toolbar.
    private var hero: some View {
        VStack(spacing: 0) {
            // The offer cards' photo frame, which cuts off the empty sides of the 1050 × 600 photos.
            RemoteImage(url: offer.imageURL)
                .aspectRatio(752 / 500, contentMode: .fit)
                .clipped()
                .onGeometryChange(for: Double.self) { $0.size.height } action: { photoHeight = $0 }
                .padding(.top, topInset)

            VStack(spacing: 12) {
                ModelLabelButton(model: offer.model)

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

    /// Everything the offer data has. Cars: seats, suitcases, transmission, and range. Trucks: payload, gross weight,
    /// license, transmission, range, and equipment. Both end with the minimum driver age.
    @ViewBuilder
    private var specs: some View {
        switch offer.vehicleType {
        case .cars:
            if let seats = offer.seats {
                Label("\(seats) People", systemImage: "person.fill")
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
            ForEach(offer.equipment ?? [], id: \.self) { equipment in
                Label(equipment.title, systemImage: equipment.symbol)
            }
        }
        Label("Age of the youngest driver: \(offer.minDriverAge)", systemImage: "person.text.rectangle.fill")
    }

    /// The range of an electric vehicle, or "Hybrid".
    @ViewBuilder
    private var fuel: some View {
        switch offer.fuel {
        case .electric:
            if let rangeKm = offer.rangeKm {
                Label("\(distance(rangeKm)) range", systemImage: "battery.100percent.bolt")
            } else {
                Label("Electric", systemImage: "battery.100percent.bolt")
            }
        case .hybrid:
            Label("Hybrid", systemImage: "leaf.fill")
        case nil:
            EmptyView()
        }
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
