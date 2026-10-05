import Foundation

/// A car or truck a station offers. Prices are in US dollars. Loaded from `offers.json`.
nonisolated struct Offer: Codable, Hashable, Identifiable {
    /// Whether the customer gets exactly this model, one from a premium brand, or any similar model.
    enum Model: String, Codable, CodingKeyRepresentable, CaseIterable {
        case orSimilar, premiumBrand, guaranteed

        var title: String {
            switch self {
            case .orSimilar: "Or similar model"
            case .premiumBrand: "Premium brand"
            case .guaranteed: "Guaranteed model"
            }
        }
    }

    enum Transmission: String, Codable {
        case automatic, manual

        var title: String {
            switch self {
            case .automatic: "Automatic"
            case .manual: "Manual"
            }
        }
    }

    enum Fuel: String, Codable {
        case electric, hybrid
    }

    enum Equipment: String, Codable {
        case tachograph, trailerHitch, tailLift, chargingCable

        var title: String {
            switch self {
            case .tachograph: "Tachograph"
            case .trailerHitch: "Trailer hitch"
            case .tailLift: "Tail lift"
            case .chargingCable: "Cables included"
            }
        }

        var symbol: String {
            switch self {
            case .tachograph: "tachometer"
            case .trailerHitch: "tow.hitch.fill"
            case .tailLift: "arrow.up.and.down.square.fill"
            case .chargingCable: "powerplug.fill"
            }
        }
    }

    let id: String
    /// What station profiles count, like "midsize-suv". See `station-profiles.json`.
    let category: String
    /// Leave it out for mystery cars, which have no fixed body style.
    let bodyStyle: BodyStyle?
    let name: String
    /// A side view on a transparent background.
    let imageURL: URL?
    let model: Model
    let transmission: Transmission
    let fuel: Fuel?
    /// Electric range in kilometers.
    let rangeKm: Int?
    let seats: Int?
    let suitcases: Int?
    /// Trucks only.
    let grossWeightKg: Int?
    /// Trucks only.
    let payloadKg: Int?
    /// Trucks only: the driver's license class needed, like "B" or "C1".
    let licenseClass: String?
    let equipment: [Equipment]?
    let pricePerDay: Double
    /// Leave it out for unlimited kilometers.
    let includedKilometers: Int?
    let minDriverAge: Int

    /// Cars or trucks, from the body style. Mystery cars have none.
    var vehicleType: VehicleType {
        bodyStyle?.vehicleType ?? .cars
    }
}
