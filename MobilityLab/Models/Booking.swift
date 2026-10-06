import Foundation
import Observation

/// What the customer is booking: an offer for some rental days, with a payment option and a mileage package.
/// Made on the offer details. Protection and add-ons come next.
@Observable
final class Booking {
    /// One line of the price: the rental, or an option that costs extra. Titles are in title case.
    struct Charge: Identifiable {
        let title: String
        /// In US dollars, for all rental days.
        let price: Double

        var id: String { title }
    }

    let offer: Offer
    let rentalDays: Int
    var paymentOption: PaymentOption
    var mileagePackage: MileagePackage

    /// Starts with the payment option and mileage package that cost nothing extra.
    init(offer: Offer, rentalDays: Int, catalog: OfferCatalog = MockData.offers) {
        self.offer = offer
        self.rentalDays = rentalDays
        paymentOption = catalog.paymentOptions.first { $0.dailySurchargeRate == 0 } ?? catalog.paymentOptions[0]
        mileagePackage = catalog.mileagePackages(for: offer)[0]
    }

    /// The rental days, then each picked option that costs extra. Surcharges are a share of the daily price.
    var charges: [Charge] {
        let days = Double(rentalDays)
        var charges = [
            Charge(
                title: String(AttributedString(localized: "^[\(rentalDays) Rental Day](inflect: true)").characters),
                price: offer.pricePerDay * days
            )
        ]
        if paymentOption.dailySurchargeRate > 0 {
            charges.append(Charge(title: paymentOption.chargeTitle, price: paymentOption.dailySurchargeRate * offer.pricePerDay * days))
        }
        if mileagePackage.dailySurchargeRate > 0 {
            charges.append(Charge(title: "Mileage Package: \(mileagePackage.title)", price: mileagePackage.dailySurchargeRate * offer.pricePerDay * days))
        }
        return charges
    }

    /// What the rental costs. With nothing extra picked, it's the total on the offer card.
    var total: Double {
        charges.map(\.price).reduce(0, +)
    }
}
