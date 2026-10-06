import SwiftUI

/// A booking's total in the toolbar, in the currency picked in Settings. Opens the price details. Its digits roll to
/// a new total when an option changes it.
struct TotalPriceButton: View {
    let booking: Booking

    @AppStorage(SettingsKey.currencyCode) private var currencyCode = "USD"
    @State private var isShowingPriceDetails = false

    var body: some View {
        Button {
            isShowingPriceDetails = true
        } label: {
            Text(MockData.currency(code: currencyCode).format(booking.total))
                .contentTransition(.numericText(value: booking.total))
                .animation(.default, value: booking.total)
        }
        .accessibilityHint("Shows the price details")
        .sheet(isPresented: $isShowingPriceDetails) {
            PriceDetailView(booking: booking)
        }
    }
}

#Preview {
    NavigationStack {
        Color.clear
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    TotalPriceButton(booking: Booking(offer: MockData.offers.cars[0], rentalDays: 3, station: RentSearch().pickUpStation))
                }
            }
    }
}
