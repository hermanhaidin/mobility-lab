import Foundation

/// A SIXT branch where a rental starts or ends. Loaded from `stations.json`.
nonisolated struct Station: Codable, Hashable, Identifiable {
    enum Kind: String, Codable, CaseIterable {
        case airport, trainStation, downtown

        var symbol: String {
            switch self {
            case .airport: "airplane.up.right"
            case .trainStation: "tram.fill"
            case .downtown: "storefront.fill"
            }
        }

        var sectionTitle: String {
            switch self {
            case .airport: "Airports"
            case .trainStation: "Train stations"
            case .downtown: "Downtown stations"
            }
        }
    }

    /// One line of opening hours, like "Mon - Fri" and "07:00 AM - 07:00 PM".
    struct OpeningHours: Codable, Hashable {
        let days: String
        let hours: String
    }

    let id: String
    let name: String
    let address: String
    /// The city in English, used to group stations in search ("Munich (8 stations)").
    let city: String
    let countryCode: String
    let kind: Kind
    let openingHours: [OpeningHours]
}
