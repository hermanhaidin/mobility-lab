import Foundation

/// The prototype's fake backend: the JSON files in the `MockData` folder, each loaded once, the first time it's needed.
enum MockData {
    static let stations: StationCatalog = loadOrCrash("stations")
    static let stationGuide: StationGuide = loadOrCrash("station-details")
    static let rentHome: RentHome = loadOrCrash("rent-home")
    /// ISO country codes for the country picker in Settings. Names and flags come from the system.
    static let countryCodes: [String] = loadOrCrash("countries")
    static let currencies: [Currency] = loadOrCrash("currencies")
    static let offers: OfferCatalog = loadOrCrash("offers")
    static let stationProfiles: [String: StationProfile] = loadOrCrash("station-profiles")
    static let paymentOptionHelp: HelpArticle = loadOrCrash("payment-option-help")
    static let protectionHelp: HelpArticle = loadOrCrash("protection-help")

    /// The currency with this code, like the one picked in Settings. US dollars if `currencies.json` doesn't have it.
    static func currency(code: String) -> Currency {
        currencies.first { $0.code == code } ?? Currency(code: "USD", rate: 1)
    }

    /// The cars or trucks a station has, picked by the station's profile.
    static func offers(at station: Station, for vehicleType: VehicleType) -> [Offer] {
        guard let profile = stationProfiles[station.profileID] else {
            fatalError("stations.json gives \(station.name) the profile \"\(station.profileID)\", which isn't in station-profiles.json.")
        }
        return offers.offers(for: vehicleType, profile: profile)
    }

    /// Decodes `<name>.json` from the app bundle.
    static func load<T: Decodable>(_ name: String) throws -> T {
        guard let url = Bundle.main.url(forResource: name, withExtension: "json") else {
            throw CocoaError(.fileReadNoSuchFile, userInfo: [NSFilePathErrorKey: "\(name).json"])
        }
        return try JSONDecoder().decode(T.self, from: Data(contentsOf: url))
    }

    private static func loadOrCrash<T: Decodable>(_ name: String) -> T {
        do {
            return try load(name)
        } catch {
            fatalError("Couldn't load \(name).json: \(error)")
        }
    }
}
