import Foundation

/// How freely the customer can cancel and rebook, like "Our best price" or "Stay flexible". Picked on the offer
/// details. Loaded from `offers.json`; "Need help?" explains them from `payment-option-help.json`.
nonisolated struct PaymentOption: Codable, Hashable, Identifiable {
    let id: String
    let title: String
    /// The option's line in the price details, in title case like every charge there: "Stay Flexible".
    let chargeTitle: String
    let subtitle: String
    /// What the option adds to the daily price, as a share of it: 0.05 adds 5%. 0 means it's included.
    let dailySurchargeRate: Double
}
