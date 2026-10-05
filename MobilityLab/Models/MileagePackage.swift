import Foundation

/// The kilometers a rental includes, and what they add to the daily price. Picked on the offer details.
/// Built by `OfferCatalog.mileagePackages(for:)` from an offer's included kilometers and the upgrades in `offers.json`.
nonisolated struct MileagePackage: Hashable {
    /// `nil` for unlimited kilometers.
    let kilometers: Int?
    /// What the package adds to the daily price, as a share of it. 0 for the kilometers the offer includes.
    let dailySurchargeRate: Double

    /// "1,200 km" or "Unlimited km".
    var title: String {
        guard let kilometers else { return "Unlimited km" }
        return Measurement(value: Double(kilometers), unit: UnitLength.kilometers)
            .formatted(.measurement(width: .abbreviated, usage: .asProvided))
    }
}
