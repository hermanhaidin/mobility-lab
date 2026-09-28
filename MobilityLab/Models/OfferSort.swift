import Foundation

/// The order of the offer list, picked from the Sort menu.
nonisolated enum OfferSort: String, CaseIterable, Identifiable {
    case lowestPrice, highestPrice

    var id: Self { self }

    var title: String {
        switch self {
        case .lowestPrice: "Lowest price"
        case .highestPrice: "Highest price"
        }
    }

    func sorted(_ offers: [Offer]) -> [Offer] {
        switch self {
        case .lowestPrice: offers.sorted { $0.pricePerDay < $1.pricePerDay }
        case .highestPrice: offers.sorted { $0.pricePerDay > $1.pricePerDay }
        }
    }
}
