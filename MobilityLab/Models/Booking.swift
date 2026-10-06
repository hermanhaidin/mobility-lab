import Foundation
import Observation

/// What the customer is booking: an offer for some rental days at a station, with a payment option and a mileage
/// package. Made on the offer details. Protection and add-ons come next.
@Observable
final class Booking {
    /// One line of the price: the rental, an option that costs extra, or a tax or fee. Titles are in title case.
    struct Charge: Identifiable {
        let title: String
        /// In US dollars, for all rental days.
        let price: Double

        var id: String { title }
    }

    let offer: Offer
    let rentalDays: Int
    /// The taxes and fees the pick-up station charges.
    let fees: [Fee]
    var paymentOption: PaymentOption
    var mileagePackage: MileagePackage

    /// Starts with the payment option and mileage package that cost nothing extra.
    init(offer: Offer, rentalDays: Int, station: Station, catalog: OfferCatalog = MockData.offers) {
        self.offer = offer
        self.rentalDays = rentalDays
        fees = catalog.fees(at: station)
        paymentOption = catalog.paymentOptions.first { $0.dailySurchargeRate == 0 } ?? catalog.paymentOptions[0]
        mileagePackage = catalog.mileagePackages(for: offer)[0]
    }

    /// The rental days, then each picked option that costs extra. Surcharges are a share of the daily price.
    var charges: [Charge] {
        let days = Double(rentalDays)
        var charges = [
            Charge(
                title: String(AttributedString(localized: "^[\(rentalDays) Rental Day](inflect: true)").characters),
                price: rentalPrice
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

    /// The station's taxes and fees, each a share of the rental days' price. Options don't add to them.
    var taxesAndFees: [Charge] {
        fees.map { Charge(title: $0.title, price: $0.rate * rentalPrice) }
    }

    /// What the rental costs, with taxes and fees. With nothing extra picked, it's the total on the offer card plus
    /// taxes and fees.
    var total: Double {
        (charges + taxesAndFees).map(\.price).reduce(0, +)
    }

    /// The rental days' price, before options, taxes, and fees.
    private var rentalPrice: Double {
        offer.pricePerDay * Double(rentalDays)
    }
}
