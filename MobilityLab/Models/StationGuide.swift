import Foundation

/// The station details text every station shares, so `stations.json` stays short. Loaded from `station-details.json`.
nonisolated struct StationGuide: Codable {
    let wayToSixt: String
    let diamondLounge: String
    let returnInformation: String
}
