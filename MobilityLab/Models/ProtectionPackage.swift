import Foundation

/// How much of the damage the customer is covered for, like "Smart Protection" or "No extra protection". Picked on
/// the protection screen. Loaded from `protection.json`.
nonisolated struct ProtectionPackage: Codable, Hashable, Identifiable {
    let id: String
    /// In title case, since it's also the package's line in the price details. "No extra protection" is never charged.
    let title: String
    /// Out of 3, shown next to the title. 0 shows none.
    let stars: Int
    /// The most the customer pays for damage, in US dollars: 0 for none. Leave it out for the full vehicle value.
    let deductible: Double?
    /// What the package adds to the daily price, as a share of it: 0.15 adds 15%. 0 for no extra protection.
    let dailySurchargeRate: Double
    /// What the package covers, one line each.
    let coverage: [String]
}
