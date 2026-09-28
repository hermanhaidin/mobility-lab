import Foundation

/// The filters on the offer list. The defaults let every offer through, except cars with fewer than 4 seats.
nonisolated struct OfferFilter: Equatable {
    /// The smallest minimum number of seats. Like in the SIXT app, there's no choice for any number of seats.
    static let fewestSeats = 4

    var bodyStyles: Set<BodyStyle> = []
    var features: Set<OfferFeature> = []
    /// Offers without a seat count, like trucks, aren't filtered by seats.
    var minimumSeats = fewestSeats

    var isEmpty: Bool {
        self == OfferFilter()
    }

    /// How many filters differ from the defaults.
    var count: Int {
        bodyStyles.count + features.count + (minimumSeats == Self.fewestSeats ? 0 : 1)
    }

    /// Combined like in the p100 prototype: an offer matches if it has any of the selected body styles and model labels,
    /// since it has only one of each, and all of the other selected features. The driver's age comes from the search.
    func matches(_ offer: Offer, driverAge: Int) -> Bool {
        if !bodyStyles.isEmpty {
            guard let bodyStyle = offer.bodyStyle, bodyStyles.contains(bodyStyle) else { return false }
        }
        let modelLabels = features.filter(\.isModelLabel)
        if !modelLabels.isEmpty && !modelLabels.contains(where: { $0.matches(offer) }) {
            return false
        }
        if let seats = offer.seats, seats < minimumSeats {
            return false
        }
        return features.subtracting(modelLabels).allSatisfy { $0.matches(offer) } && offer.minDriverAge <= driverAge
    }
}
