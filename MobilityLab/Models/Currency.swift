import Foundation

/// A currency customers can pick in Settings. Names and symbols come from the system; only the rate is ours.
nonisolated struct Currency: Codable, Identifiable {
    let code: String
    /// Units of this currency per US dollar. Prices are stored in US dollars and converted for display.
    let rate: Double

    var id: String { code }

    /// A price stored in US dollars, converted to this currency and formatted, like "€12.34".
    func format(_ usd: Double) -> String {
        (usd * rate).formatted(.currency(code: code))
    }
}
