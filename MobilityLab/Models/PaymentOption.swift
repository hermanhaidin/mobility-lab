import Foundation

/// How freely the customer can cancel and rebook, like "Our best price" or "Stay flexible". Picked on the offer
/// details. Loaded from `offers.json`.
nonisolated struct PaymentOption: Codable, Hashable, Identifiable {
    let id: String
    let title: String
    /// The option's line in the price details, in title case like every charge there: "Stay Flexible".
    let chargeTitle: String
    let subtitle: String
    /// What the option adds to the daily price, as a share of it: 0.05 adds 5%. 0 means it's included.
    let dailySurchargeRate: Double
    /// The explanation behind "Need help?" on the offer details.
    let details: String
    /// Bullet points under the explanation. Leave it out for none.
    let detailBullets: [String]?
}
