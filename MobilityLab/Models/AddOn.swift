import Foundation

/// An optional extra for the rental, like an additional driver or a child seat. Picked on the add-ons screen.
/// Loaded from `add-ons.json`.
nonisolated struct AddOn: Codable, Hashable, Identifiable {
    /// Whether the price is charged for every rental day or once.
    enum Billing: String, Codable {
        case perDay, oneTime

        /// Follows the price: "$10.91 / day".
        var suffix: String {
            switch self {
            case .perDay: "/ day"
            case .oneTime: "/ one-time"
            }
        }
    }

    let id: String
    /// In title case, since it's also the add-on's line in the price details.
    let title: String
    let systemImage: String
    /// In US dollars, for one of it.
    let price: Double
    let billing: Billing
    /// How many a booking can have, picked with a stepper. Leave it out for an add-on that's picked or not.
    let maxQuantity: Int?
    /// Shown under "Show details" and in the booking overview.
    let details: String
    /// Vehicles with this fuel don't offer it, like a diesel engine on an electric car.
    let notForFuel: Offer.Fuel?
    /// Vehicles that come with this equipment don't offer it, like a trailer coupling on a truck with a trailer hitch.
    let notWithEquipment: Offer.Equipment?

    func isOffered(with offer: Offer) -> Bool {
        if let notForFuel, offer.fuel == notForFuel {
            return false
        }
        if let notWithEquipment, offer.equipment?.contains(notWithEquipment) == true {
            return false
        }
        return true
    }

    /// "1 Additional Driver" or "2 Additional Drivers" for an add-on with a stepper once one is picked, otherwise the
    /// title.
    func title(quantity: Int) -> String {
        guard maxQuantity != nil, quantity > 0 else { return title }
        return String(AttributedString(localized: "^[\(quantity) \(title)](inflect: true)").characters)
    }
}
