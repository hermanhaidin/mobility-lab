import Foundation

/// A yes-or-no filter on the offer list, like Electric or Automatic.
nonisolated enum OfferFeature: String, CaseIterable, Identifiable {
    case premiumBrand, guaranteedModel, electric, automatic, tachograph, trailerHitch

    /// The features in the filter sheet and the quick filters above the offers, in order.
    static func filters(for vehicleType: VehicleType) -> [OfferFeature] {
        switch vehicleType {
        case .cars: [.premiumBrand, .guaranteedModel, .electric, .automatic]
        case .trucks: [.electric, .automatic, .tachograph, .trailerHitch]
        }
    }

    /// Those of the features that at least one of the offers has, so no filter leads to an empty list.
    static func filters(for vehicleType: VehicleType, in offers: [Offer]) -> [OfferFeature] {
        filters(for: vehicleType).filter { feature in offers.contains(where: feature.matches) }
    }

    var id: Self { self }

    var title: String {
        switch self {
        case .premiumBrand: "Premium brand"
        case .guaranteedModel: "Guaranteed model"
        case .electric: "Electric"
        case .automatic: "Automatic"
        case .tachograph: "Tachograph"
        case .trailerHitch: "Trailer hitch"
        }
    }

    /// The shorter title on the quick filter.
    var quickFilterTitle: String {
        switch self {
        case .premiumBrand: "Premium"
        case .guaranteedModel: "Guaranteed"
        default: title
        }
    }

    var symbol: String {
        switch self {
        case .premiumBrand: "crown.fill"
        case .guaranteedModel: "checkmark.seal.fill"
        case .electric: "bolt.fill"
        case .automatic: "gearshift.layout.sixspeed"
        case .tachograph: "tachometer"
        case .trailerHitch: "tow.hitch.fill"
        }
    }

    /// Premium brand and guaranteed model. An offer has only one model label, so these match if any selected one does.
    var isModelLabel: Bool {
        self == .premiumBrand || self == .guaranteedModel
    }

    func matches(_ offer: Offer) -> Bool {
        switch self {
        case .premiumBrand: offer.model == .premiumBrand
        case .guaranteedModel: offer.model == .guaranteed
        case .electric: offer.fuel == .electric
        case .automatic: offer.transmission == .automatic
        case .tachograph: offer.equipment?.contains(.tachograph) == true
        case .trailerHitch: offer.equipment?.contains(.trailerHitch) == true
        }
    }
}
