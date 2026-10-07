import Foundation
import Observation

/// What the customer is booking: an offer for some rental days at a station, with a payment option and a mileage
/// package, picked on the offer details, a protection package, picked on the protection screen, and add-ons.
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
    /// `nil` until the customer picks a package or "No extra protection", which nothing is picked for first.
    var protection: ProtectionPackage?
    /// The add-ons the offer can have, in the order the add-ons screen shows them.
    let addOns: [AddOn]
    /// How many of each add-on the customer picked, by ID. None at first.
    var addOnQuantities: [AddOn.ID: Int] = [:]

    /// Starts with the payment option and mileage package that cost nothing extra, so the total matches the offer card's.
    init(offer: Offer, rentalDays: Int, station: Station, catalog: OfferCatalog = MockData.offers, addOns: [AddOn] = MockData.addOns) {
        self.offer = offer
        self.rentalDays = rentalDays
        fees = catalog.fees(at: station)
        paymentOption = catalog.paymentOptions.first { $0.dailySurchargeRate == 0 } ?? catalog.paymentOptions[0]
        mileagePackage = catalog.mileagePackages(for: offer)[0]
        self.addOns = addOns.filter { $0.isOffered(with: offer) }
    }

    /// The add-ons picked at least once, in the order the add-ons screen shows them.
    var pickedAddOns: [(addOn: AddOn, quantity: Int)] {
        addOns.compactMap { addOn in
            let quantity = addOnQuantities[addOn.id, default: 0]
            return quantity > 0 ? (addOn, quantity) : nil
        }
    }

    /// The rental days, then each picked option that costs extra, then the add-ons. Surcharges are a share of the daily
    /// price; add-ons have their own price, for each day or once.
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
        if let protection, protection.dailySurchargeRate > 0 {
            charges.append(Charge(title: protection.title, price: protection.dailySurchargeRate * offer.pricePerDay * days))
        }
        for (addOn, quantity) in pickedAddOns {
            let price = addOn.price * Double(quantity)
            charges.append(Charge(title: addOn.title(quantity: quantity), price: addOn.billing == .perDay ? price * days : price))
        }
        return charges
    }

    /// The station's taxes and fees, each a share of the rental days' price. Options and add-ons don't add to them.
    var taxesAndFees: [Charge] {
        fees.map { Charge(title: $0.title, price: $0.rate * rentalPrice) }
    }

    /// What the rental costs, with taxes and fees. With nothing extra picked, it's the total on the offer card.
    var total: Double {
        (charges + taxesAndFees).map(\.price).reduce(0, +)
    }

    /// The rental days' price, before options, taxes, and fees.
    private var rentalPrice: Double {
        offer.pricePerDay * Double(rentalDays)
    }
}
