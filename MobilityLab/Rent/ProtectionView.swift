import SwiftUI

/// The protection packages to pick from, and what the booking includes so far. Nothing is picked first, so Continue
/// stays off until the customer picks a package or "No extra protection", then goes on to the add-ons. Pushed from the
/// offer details.
struct ProtectionView: View {
    let booking: Booking

    @AppStorage(SettingsKey.currencyCode) private var currencyCode = "USD"
    @State private var isShowingHelp = false

    private let catalog = MockData.protection

    var body: some View {
        // A scroll view like the offer details, not a list: the cards are the offer details' cards, and a list
        // clipped their corners, faded their picks, and snapped the overview's rows open.
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                packages
                BookingOverview(booking: booking)
            }
            // The first header's own top padding is enough under the large title, like Figma.
            .padding([.horizontal, .bottom])
        }
        .navigationTitle("Protection")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                TotalPriceButton(booking: booking)
            }
        }
        .safeAreaBar(edge: .bottom) {
            ContinueButton {
                AddOnsView(booking: booking)
            }
            .disabled(booking.protection == nil)
        }
        .sheet(isPresented: $isShowingHelp) {
            HelpArticleView(article: MockData.protectionHelp)
        }
    }

    private var packages: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader("Choose your package") {
                isShowingHelp = true
            }
            VStack(spacing: 12) {
                ForEach(catalog.packages) { package in
                    card(for: package)
                }
            }
        }
    }

    // MARK: - Packages

    private func card(for package: ProtectionPackage) -> some View {
        ChoiceCard(
            title: package.title,
            subtitle: deductible(of: package),
            price: package.dailySurchargeRate > 0
                ? "\(currency.format(package.dailySurchargeRate * booking.offer.pricePerDay)) / day"
                : "Included",
            isSelected: booking.protection == package
        ) {
            booking.protection = package
        } accessory: {
            stars(package.stars)
        } details: {
            if !package.coverage.isEmpty {
                Divider()
                ForEach(package.coverage, id: \.self) { line in
                    Label {
                        Text(line)
                    } icon: {
                        Image(systemName: "checkmark")
                            .fontWeight(.semibold)
                    }
                    .font(.footnote)
                }
            }
        }
    }

    /// "No deductible" in green, an amount in the label color, or the full vehicle value in red.
    private func deductible(of package: ProtectionPackage) -> Text {
        let text: Text
        switch package.deductible {
        case nil:
            text = Text("Deductible: up to full vehicle value").foregroundStyle(.red)
        case 0?:
            text = Text("No deductible").foregroundStyle(.green)
        case let amount?:
            text = Text("Deductible: up to \(currency.format(amount))").foregroundStyle(.primary)
        }
        return text.fontWeight(.semibold)
    }

    /// Filled stars for the package's rating, out of 3, in the accent color. None for 0.
    @ViewBuilder
    private func stars(_ count: Int) -> some View {
        if count > 0 {
            HStack(spacing: 0) {
                ForEach(0..<3, id: \.self) { index in
                    Image(systemName: index < count ? "star.fill" : "star")
                }
            }
            .font(.footnote)
            .foregroundStyle(.tint)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(count) of 3 stars")
        }
    }

    private var currency: Currency {
        MockData.currency(code: currencyCode)
    }
}

#Preview {
    NavigationStack {
        ProtectionView(booking: Booking(offer: MockData.offers.cars.first { $0.id == "bmw-m340-touring" }!, rentalDays: 3, station: RentSearch().pickUpStation))
    }
}
