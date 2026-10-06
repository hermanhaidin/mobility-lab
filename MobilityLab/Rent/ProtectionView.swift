import SwiftUI

/// The protection packages to pick from, and what the booking includes so far. Nothing is picked first, so Continue
/// stays off until the customer picks a package or "No extra protection". Pushed from the offer details.
struct ProtectionView: View {
    let booking: Booking

    @AppStorage(SettingsKey.currencyCode) private var currencyCode = "USD"
    @State private var isShowingHelp = false
    /// The booking overview's open rows: included protection by title, then "payment", "mileage", and "protection",
    /// which stays open when the package changes.
    @State private var expandedRows: Set<String> = []

    private let catalog = MockData.protection

    var body: some View {
        List {
            Section {
                ForEach(catalog.packages) { package in
                    card(for: package)
                        // Half the 12 points between cards above and below each one. The cell clips its first and
                        // last rows to its own corners, which would cut into the cards' smaller ones without it.
                        .listRowInsets(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 0))
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                }
            } header: {
                HStack(alignment: .firstTextBaseline) {
                    Text("Choose your package")
                    Spacer()
                    Button {
                        isShowingHelp = true
                    } label: {
                        Text("Need help?")
                            .underline()
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                }
            }
            .headerProminence(.increased)

            Section("Your booking overview") {
                ForEach(catalog.included, id: \.self) { item in
                    BookingOverviewRow(title: item.title, isExpanded: isExpanded(item.title)) {
                        Text(item.details)
                    }
                }
                BookingOverviewRow(title: "Payment Option: \(booking.paymentOption.chargeTitle)", isExpanded: isExpanded("payment")) {
                    Text(booking.paymentOption.subtitle)
                }
                BookingOverviewRow(title: "Mileage Package: \(booking.mileagePackage.title)", isExpanded: isExpanded("mileage")) {
                    Text(MockData.offers.mileageDescription(of: booking.mileagePackage, for: booking.offer, in: currency))
                }
                // One row for whichever package is picked, so switching packages updates it in place.
                if let protection = booking.protection, protection.dailySurchargeRate > 0 {
                    BookingOverviewRow(title: protection.title, isExpanded: isExpanded("protection")) {
                        BulletList(items: protection.coverage, spacing: 0)
                    }
                }
            }
            .headerProminence(.increased)
            // Gray rows on a white page, like Figma: the grouped look inverted.
            .listRowBackground(Color(.secondarySystemBackground))
        }
        .listSectionSpacing(.compact)
        .scrollContentBackground(.hidden)
        .background(Color(.systemBackground))
        .navigationTitle("Protection")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                TotalPriceButton(booking: booking)
            }
        }
        .safeAreaBar(edge: .bottom) {
            ContinueButton {
                PlaceholderView(title: "Add-ons", systemImage: "plus.square.on.square")
            }
            .disabled(booking.protection == nil)
        }
        .sheet(isPresented: $isShowingHelp) {
            HelpArticleView(article: MockData.protectionHelp)
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
            // Not in `withAnimation`: the list would animate its whole update, so an unpicked card's fill would fade
            // to gray while its checkmark draws off. The overview's row just appears.
            booking.protection = package
        } accessory: {
            stars(package.stars)
        } details: {
            if !package.coverage.isEmpty {
                Divider()
                // Not a Label: in a list, its icon takes the tint and sits in a wide column.
                ForEach(package.coverage, id: \.self) { line in
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Image(systemName: "checkmark")
                            .fontWeight(.semibold)
                        Text(line)
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

    private func isExpanded(_ row: String) -> Binding<Bool> {
        Binding($expandedRows, contains: row)
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
