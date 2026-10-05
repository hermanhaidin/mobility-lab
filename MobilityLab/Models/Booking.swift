import Foundation
import Observation

/// What the customer is booking: an offer for some rental days, with a payment option and a mileage package.
/// Made on the offer details. Protection and add-ons come next.
@Observable
final class Booking {
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
}
