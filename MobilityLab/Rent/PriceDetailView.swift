import SwiftUI

/// What a booking costs, line by line: the rental charges, the pick-up station's taxes and fees, and the total.
/// Opened from the total in the offer details' toolbar.
struct PriceDetailView: View {
    let booking: Booking

    @Environment(\.dismiss) private var dismiss
    @AppStorage(SettingsKey.currencyCode) private var currencyCode = "USD"

    var body: some View {
        let currency = MockData.currency(code: currencyCode)

        NavigationStack {
            List {
                Section("Rental charges") {
                    ForEach(booking.charges) { charge in
                        LabeledContent(charge.title, value: currency.format(charge.price))
                    }
                }

                if !booking.taxesAndFees.isEmpty {
                    Section("Taxes and fees") {
                        ForEach(booking.taxesAndFees) { charge in
                            LabeledContent(charge.title, value: currency.format(charge.price))
                        }
                    }
                }

                Section {
                    LabeledContent {
                        Text(currency.format(booking.total))
                            .foregroundStyle(.primary)
                    } label: {
                        Text("Total (incl. tax)")
                    }
                    .fontWeight(.semibold)
                }
            }
            .navigationTitle("Price details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .close) {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    let booking = Booking(offer: MockData.offers.cars.first { $0.id == "bmw-m340-touring" }!, rentalDays: 3, station: RentSearch().pickUpStation)
    booking.paymentOption = MockData.offers.paymentOptions.last!
    booking.mileagePackage = MockData.offers.mileagePackages(for: booking.offer).last!
    return PriceDetailView(booking: booking)
}
