import SwiftUI

/// The add-ons to pick from, and what the booking includes so far. Every add-on is optional, so nothing is picked
/// first and Continue is on from the start. Pushed from the protection screen.
struct AddOnsView: View {
    let booking: Booking

    @AppStorage(SettingsKey.currencyCode) private var currencyCode = "USD"

    var body: some View {
        // A scroll view like protection: mostly cards.
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    SectionHeader("Select what works for you")
                    VStack(spacing: 12) {
                        ForEach(booking.addOns) { addOn in
                            AddOnCard(
                                addOn: addOn,
                                price: MockData.currency(code: currencyCode).format(addOn.price),
                                quantity: quantity(of: addOn)
                            )
                        }
                    }
                }
                BookingOverview(booking: booking)
            }
            // The first header's own top padding is enough under the large title, like Figma.
            .padding([.horizontal, .bottom])
        }
        .navigationTitle("Add-ons")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                TotalPriceButton(booking: booking)
            }
        }
        .safeAreaBar(edge: .bottom) {
            ContinueButton {
                PlaceholderView(title: "Review and book", systemImage: "list.bullet.clipboard")
            }
        }
    }

    /// How many of the add-on the booking has, 0 if none.
    private func quantity(of addOn: AddOn) -> Binding<Int> {
        Binding {
            booking.addOnQuantities[addOn.id, default: 0]
        } set: { quantity in
            booking.addOnQuantities[addOn.id] = quantity
        }
    }
}

#Preview {
    let booking = Booking(offer: MockData.offers.cars.first { $0.id == "bmw-m340-touring" }!, rentalDays: 3, station: RentSearch().pickUpStation)
    booking.protection = MockData.protection.packages.first
    return NavigationStack {
        AddOnsView(booking: booking)
    }
}
