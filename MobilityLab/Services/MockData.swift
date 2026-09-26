import Foundation

/// The prototype's fake backend: the JSON files in the `MockData` folder, each loaded once.
enum MockData {
    static let stations: StationCatalog = loadOrCrash("stations")
    static let stationGuide: StationGuide = loadOrCrash("station-details")
    static let rentHome: RentHome = loadOrCrash("rent-home")
    /// ISO country codes for the country picker in Settings. Names and flags come from the system.
    static let countryCodes: [String] = loadOrCrash("countries")
    static let currencies: [Currency] = loadOrCrash("currencies")

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
