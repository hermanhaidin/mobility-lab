import Foundation

/// How many offers of each category a kind of station shows, like "midsize-suv": 3.
/// Each station points to one in `stations.json`. Loaded from `station-profiles.json`.
nonisolated struct StationProfile: Codable {
    let cars: [String: Int]
    let trucks: [String: Int]

    func quotas(for vehicleType: VehicleType) -> [String: Int] {
        switch vehicleType {
        case .cars: cars
        case .trucks: trucks
        }
    }
}
