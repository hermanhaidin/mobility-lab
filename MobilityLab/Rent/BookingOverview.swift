import SwiftUI

/// What the booking includes so far, under the cards on the protection screen. Each row opens to its details.
struct BookingOverview: View {
    let booking: Booking

    @AppStorage(SettingsKey.currencyCode) private var currencyCode = "USD"

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader("Your booking overview")
            RowGroup {
                ForEach(MockData.protection.included, id: \.self) { item in
                    BookingOverviewRow(title: item.title) {
                        Text(item.details)
                    }
                }
                BookingOverviewRow(title: "Payment Option: \(booking.paymentOption.chargeTitle)") {
                    Text(booking.paymentOption.subtitle)
                }
                BookingOverviewRow(title: "Mileage Package: \(booking.mileagePackage.title)") {
                    Text(MockData.offers.mileageDescription(of: booking.mileagePackage, for: booking.offer, in: MockData.currency(code: currencyCode)))
                }
                // One row for whichever package is picked, so it stays open when the package changes.
                if let protection = booking.protection, protection.dailySurchargeRate > 0 {
                    BookingOverviewRow(title: protection.title) {
                        BulletList(items: protection.coverage, spacing: 0)
                    }
                }
            }
            // The picked package's row slides in and out. Only here: an animated pick would fade the unpicked card's
            // fill to gray while its checkmark draws off, where it should turn gray at once.
            .animation(.default, value: booking.protection)
        }
    }
}

#Preview {
    let booking = Booking(offer: MockData.offers.cars.first { $0.id == "bmw-m340-touring" }!, rentalDays: 3, station: RentSearch().pickUpStation)
    booking.protection = MockData.protection.packages.first
    return ScrollView {
        BookingOverview(booking: booking)
            .padding()
    }
}
