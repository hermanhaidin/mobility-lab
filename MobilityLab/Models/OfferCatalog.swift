import Foundation

/// Every car and truck in the prototype, and the options the offer details add to them. Loaded from `offers.json`.
nonisolated struct OfferCatalog: Codable {
    /// More kilometers for an offer with a limit, on top of the ones it includes.
    struct MileageUpgrade: Codable {
        /// Leave it out for unlimited kilometers.
        let extraKilometers: Int?
        /// What the upgrade adds to the daily price, as a share of it: 0.1 adds 10%.
        let dailySurchargeRate: Double
    }

    /// The mileage upgrades for cars and for trucks, from fewest to most kilometers.
    struct MileageUpgrades: Codable {
        let cars: [MileageUpgrade]
        let trucks: [MileageUpgrade]

        func upgrades(for vehicleType: VehicleType) -> [MileageUpgrade] {
            switch vehicleType {
            case .cars: cars
            case .trucks: trucks
            }
        }
    }

    /// The studio photo behind every offer card. Until there's a URL, the cards are plain dark gray.
    let cardBackdropURL: URL?
    /// What each model label means, shown from its info button. "{name}" stands for the offer's name.
    let modelDescriptions: [Offer.Model: String]
    /// The payment options on the offer details. The one without a surcharge is picked first.
    let paymentOptions: [PaymentOption]
    /// The price of each kilometer driven beyond a mileage package, as a share of the daily price.
    let extraKilometerRate: Double
    let mileageUpgrades: MileageUpgrades
    /// The taxes and fees on top of the rental, in the order the price details list them.
    let fees: [Fee]
    /// The note under the mileage packages of trucks with a combustion engine.
    let adBlueNotice: String
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

    /// What an offer's model label means, like "A Porsche 911 Carrera will be reserved exclusively for you."
    func modelDescription(for offer: Offer) -> String {
        (modelDescriptions[offer.model] ?? "").replacing("{name}", with: offer.name)
    }

    /// The mileage packages to pick from: the kilometers the offer includes, then one package per upgrade.
    /// An offer with unlimited kilometers has only that one.
    func mileagePackages(for offer: Offer) -> [MileagePackage] {
        let included = MileagePackage(kilometers: offer.includedKilometers, dailySurchargeRate: 0)
        guard let includedKilometers = offer.includedKilometers else { return [included] }
        return [included] + mileageUpgrades.upgrades(for: offer.vehicleType).map { upgrade in
            MileagePackage(
                kilometers: upgrade.extraKilometers.map { includedKilometers + $0 },
                dailySurchargeRate: upgrade.dailySurchargeRate
            )
        }
    }

    /// What a mileage package means for an offer: "All kilometers are included in the price." or what each kilometer
    /// beyond it costs, like "+$0.54 for every additional km." On the offer details and in the protection's overview.
    func mileageDescription(of package: MileagePackage, for offer: Offer, in currency: Currency) -> String {
        guard package.kilometers != nil else { return "All kilometers are included in the price." }
        return "+\(currency.format(extraKilometerRate * offer.pricePerDay)) for every additional km."
    }

    /// Whether an offer has a kilometer limit that an upgrade lifts, like the 600 km of every car.
    func canUpgradeToUnlimited(_ offer: Offer) -> Bool {
        mileagePackages(for: offer).contains { $0.kilometers == nil && $0.dailySurchargeRate > 0 }
    }

    /// The taxes and fees a station charges.
    func fees(at station: Station) -> [Fee] {
        fees.filter { $0.stationProfileIDs?.contains(station.profileID) ?? true }
    }
}
