import Foundation

/// Every car and truck in the prototype. Loaded from `offers.json`.
nonisolated struct OfferCatalog: Codable {
    /// The studio photo behind every offer card. Until there's a URL, the cards are plain dark gray.
    let cardBackdropURL: URL?
    /// What each model label means, shown from the info button on an offer card.
    let modelDescriptions: [Offer.Model: String]
    let cars: [Offer]
    let trucks: [Offer]

    func offers(for vehicleType: VehicleType) -> [Offer] {
        switch vehicleType {
        case .cars: cars
        case .trucks: trucks
        }
    }

    /// The offers a station shows, picked like in the p100 prototype: walks the catalog in order
    /// and takes each offer while its category is still under the station profile's quota.
    func offers(for vehicleType: VehicleType, profile: StationProfile) -> [Offer] {
        var quotas = profile.quotas(for: vehicleType)
        return offers(for: vehicleType).filter { offer in
            guard let quota = quotas[offer.category], quota > 0 else { return false }
            quotas[offer.category] = quota - 1
            return true
        }
    }
}
