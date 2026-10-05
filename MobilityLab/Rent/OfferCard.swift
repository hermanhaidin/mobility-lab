import SwiftUI

/// An offer in the offer list: the vehicle, its specs, the included kilometers, and the price in the currency
/// picked in Settings. The card is always dark, like the studio photo behind it.
struct OfferCard: View {
    let offer: Offer
    let rentalDays: Int

    @AppStorage(SettingsKey.currencyCode) private var currencyCode = "USD"

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 10) {
                Text(offer.name)
                    .font(.title2)
                    .bold()
                specs
            }
            .padding([.top, .horizontal])

            // Figma's photo frame. Car photos are 752 × 500, so they fit it. Truck photos are 1050 × 600, so their empty
            // sides are cut off, like in Figma.
            RemoteImage(url: offer.imageURL)
                .aspectRatio(752 / 500, contentMode: .fit)
                .clipped()

            VStack(alignment: .leading, spacing: 8) {
                Label {
                    Text(mileage)
                } icon: {
                    Image(systemName: "checkmark")
                        .foregroundStyle(.green)
                }
                .font(.footnote)

                HStack(alignment: .firstTextBaseline, spacing: 12) {
                    Text(dailyPrice)
                    Text("\(currency.format(offer.pricePerDay * Double(rentalDays))) total")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            OfferBackdrop(offer: offer)
        }
        .clipShape(.rect(cornerRadius: 20))
        .environment(\.colorScheme, .dark)
    }

    // MARK: - Specs

    /// Cars: model, seats, suitcases, transmission, and range. Trucks: model, range, gross weight, payload, and license.
    /// The offer details show the rest.
    private var specs: some View {
        FlowLayout(spacing: 8) {
            ModelLabelButton(model: offer.model)
            switch offer.vehicleType {
            case .cars:
                if let seats = offer.seats {
                    spec("\(seats)", systemImage: "person.fill")
                        .accessibilityLabel("\(seats) seats")
                }
                if let suitcases = offer.suitcases {
                    spec("\(suitcases)", systemImage: "suitcase.rolling.and.suitcase.fill")
                        .accessibilityLabel("\(suitcases) suitcases")
                }
                spec(offer.transmission.title, systemImage: "gearshift.layout.sixspeed")
                fuel
            case .trucks:
                fuel
                if let grossWeightKg = offer.grossWeightKg {
                    spec(weight(grossWeightKg), systemImage: "scalemass.fill")
                        .accessibilityLabel("Gross weight \(weight(grossWeightKg))")
                }
                if let payloadKg = offer.payloadKg {
                    spec(weight(payloadKg), systemImage: "truck.box.fill")
                        .accessibilityLabel("Payload \(weight(payloadKg))")
                }
                if let licenseClass = offer.licenseClass {
                    spec(licenseClass, systemImage: "person.text.rectangle.fill")
                        .accessibilityLabel("Driver's license class \(licenseClass)")
                }
            }
        }
    }

    /// The range of an electric vehicle, or "Hybrid".
    @ViewBuilder
    private var fuel: some View {
        switch offer.fuel {
        case .electric:
            spec(offer.rangeKm.map { distance($0, width: .abbreviated) } ?? "Electric", systemImage: "battery.100percent.bolt")
                .accessibilityLabel(offer.rangeKm.map { "Electric, \(distance($0, width: .wide)) range" } ?? "Electric")
        case .hybrid:
            spec("Hybrid", systemImage: "leaf.fill")
        case nil:
            EmptyView()
        }
    }

    private func spec(_ text: String, systemImage: String) -> some View {
        Label(text, systemImage: systemImage)
            .font(.footnote)
            .fontWeight(.semibold)
            .padding(.horizontal, 10)
            .frame(minHeight: 28)
            .glassEffect(in: .capsule)
    }

    // MARK: - Text

    private var mileage: String {
        guard let includedKilometers = offer.includedKilometers else { return "Unlimited kilometers" }
        return "\(distance(includedKilometers, width: .wide)) included"
    }

    private func distance(_ kilometers: Int, width: Measurement<UnitLength>.FormatStyle.UnitWidth) -> String {
        Measurement(value: Double(kilometers), unit: UnitLength.kilometers)
            .formatted(.measurement(width: width, usage: .asProvided))
    }

    private func weight(_ kilograms: Int) -> String {
        Measurement(value: Double(kilograms), unit: UnitMass.kilograms)
            .formatted(.measurement(width: .abbreviated, usage: .asProvided))
    }

    // MARK: - Price

    private var currency: Currency {
        MockData.currency(code: currencyCode)
    }

    /// The daily price with its whole number drawn larger, like "$123.45 / day" in the Figma design.
    private var dailyPrice: AttributedString {
        var text = (offer.pricePerDay * currency.rate).formatted(.currency(code: currency.code).attributed)
        for run in text.runs {
            text[run.range].font = run.numberPart == .integer ? .title3.weight(.semibold) : .footnote.weight(.semibold)
        }
        var suffix = AttributedString(" / day")
        suffix.font = .footnote.weight(.semibold)
        return text + suffix
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 16) {
            ForEach(["bmw-3-series-touring", "vw-golf-automatic", "porsche-taycan"], id: \.self) { id in
                OfferCard(offer: MockData.offers.cars.first { $0.id == id }!, rentalDays: 3)
            }
            ForEach(["maxus-edeliver-3", "citroen-berlingo"], id: \.self) { id in
                OfferCard(offer: MockData.offers.trucks.first { $0.id == id }!, rentalDays: 3)
            }
        }
        .padding()
    }
}
