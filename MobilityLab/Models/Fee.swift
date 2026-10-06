import Foundation

/// A tax or fee on top of the rental, like "Premium Location Fee". Listed under Taxes and fees in the price details.
/// Loaded from `offers.json`.
nonisolated struct Fee: Codable, Hashable {
    /// In title case, like every charge in the price details.
    let title: String
    /// What the fee adds, as a share of the rental days' price: 0.2 adds 20%.
    let rate: Double
    /// The station profiles that charge it, like "mega-airport". Leave it out for every station.
    let stationProfileIDs: [String]?
}
