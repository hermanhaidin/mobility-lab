import SwiftUI

/// An add-on to pick on the add-ons screen: its symbol on a black tile, like the icons in Settings, its title and
/// price, and "Show details" for what it is. One that's picked or not has a selection circle and picks with a tap
/// anywhere on the card; one that's counted, like additional drivers, has a stepper instead. A picked card has the
/// thicker accent border of a picked `ChoiceCard`.
struct AddOnCard: View {
    let addOn: AddOn
    /// For one of it, formatted, like "$10.91".
    let price: String
    @Binding var quantity: Int

    @State private var isShowingDetails = false
    /// Figma's 28 points, grown with the text.
    @ScaledMetric(relativeTo: .subheadline) private var tileSize = 28

    var body: some View {
        Group {
            if addOn.maxQuantity == nil {
                Button {
                    quantity = isSelected ? 0 : 1
                } label: {
                    content
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(isSelected ? .isSelected : [])
            } else {
                content
            }
        }
        .overlay {
            // ChoiceCard's border.
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(isSelected ? Color(.accent) : Color(.systemGray2), lineWidth: isSelected ? 2 : 1)
        }
    }

    private var isSelected: Bool {
        quantity > 0
    }

    private var content: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: addOn.systemImage)
                .font(.subheadline)
                .foregroundStyle(.white)
                .frame(width: tileSize, height: tileSize)
                // Figma's Grays/Black: a fixed color, like the tiles in Settings, in dark mode too.
                .background(.black, in: .rect(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 8) {
                if let maxQuantity = addOn.maxQuantity {
                    HStack(alignment: .top, spacing: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            title
                            priceLine
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        Stepper(addOn.title, value: $quantity, in: 0...maxQuantity)
                            .labelsHidden()
                    }
                } else {
                    HStack(spacing: 12) {
                        title
                            .frame(maxWidth: .infinity, alignment: .leading)
                        SelectionCircle(isSelected: isSelected)
                    }
                    priceLine
                }

                Divider()

                // Stays open, like the booking overview's rows.
                if isShowingDetails {
                    Text(addOn.details)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                } else {
                    Button {
                        withAnimation(.snappy(duration: 0.3)) {
                            isShowingDetails = true
                        }
                    } label: {
                        Text("Show details")
                            .underline()
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                }
            }
        }
        .multilineTextAlignment(.leading)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        // ChoiceCard's background.
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 20))
        .contentShape(.rect(cornerRadius: 20))
    }

    private var title: some View {
        Text(addOn.title(quantity: quantity))
            .font(.headline)
    }

    private var priceLine: some View {
        Text("\(price) \(addOn.billing.suffix)")
            .font(.footnote)
            .fontWeight(.semibold)
    }
}

#Preview {
    @Previewable @State var drivers = 1
    @Previewable @State var carPlay = 0

    VStack(spacing: 12) {
        AddOnCard(addOn: MockData.addOns[0], price: "$10.91", quantity: $drivers)
        AddOnCard(addOn: MockData.addOns[1], price: "$10.91", quantity: $carPlay)
    }
    .padding()
}
