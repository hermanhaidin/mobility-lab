import SwiftUI

/// One option to pick from, like a payment option, a mileage package, or a protection package: a title, a subtitle,
/// and a price line, with a selection circle like the kit's Edit Button. An accessory can follow the title, like a
/// protection package's stars, and details can run under the price, like what it covers. The picked card has a
/// thicker border in the accent color. iOS has no stock control like it.
struct ChoiceCard<Accessory: View, Details: View>: View {
    let title: String
    /// Footnote and secondary unless the text sets its own style, like a protection package's colored deductible.
    let subtitle: Text
    let price: String
    let isSelected: Bool
    let action: () -> Void
    let accessory: Accessory
    let details: Details

    /// Follows `isSelected`, a moment late when the card is unpicked: the circle turns gray first, so the checkmark
    /// draws off in the unpicked color rather than the accent.
    @State private var showsCheckmark: Bool

    init(
        title: String,
        subtitle: Text,
        price: String,
        isSelected: Bool,
        action: @escaping () -> Void,
        @ViewBuilder accessory: () -> Accessory,
        @ViewBuilder details: () -> Details
    ) {
        self.title = title
        self.subtitle = subtitle
        self.price = price
        self.isSelected = isSelected
        self.action = action
        self.accessory = accessory()
        self.details = details()
        _showsCheckmark = State(initialValue: isSelected)
    }

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 8) {
                        VStack(alignment: .leading, spacing: 2) {
                            HStack(spacing: 12) {
                                Text(title)
                                    .font(.headline)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                accessory
                            }
                            subtitle
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                        Text(price)
                            .font(.footnote)
                            .fontWeight(.semibold)
                    }

                    // One image, so picking the card replaces the circle and draws the checkmark on, like the
                    // Light and Dark choices in Settings › Display & Brightness. The replace keeps the outgoing symbol's
                    // colors, so the fill goes gray before the checkmark draws off.
                    Image(systemName: showsCheckmark ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(
                            showsCheckmark ? AnyShapeStyle(.white) : AnyShapeStyle(.tertiary),
                            isSelected ? AnyShapeStyle(Color(.accent)) : AnyShapeStyle(.tertiary)
                        )
                        .contentTransition(.symbolEffect(.replace))
                        .font(.title2)
                        .onChange(of: isSelected) { _, isSelected in
                            if isSelected {
                                showsCheckmark = true
                            } else {
                                // After the gray fill is on screen.
                                Task { showsCheckmark = false }
                            }
                        }
                }

                // Under the circle too, across the whole card.
                details
            }
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 20))
            .contentShape(.rect(cornerRadius: 20))
        }
        .buttonStyle(.plain)
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                // The separator colors are too faint for a card's edge on a white page; gray 2 is the next step up.
                .strokeBorder(isSelected ? Color(.accent) : Color(.systemGray2), lineWidth: isSelected ? 2 : 1)
        }
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

extension ChoiceCard where Accessory == EmptyView, Details == EmptyView {
    /// A card with a title, a subtitle, and a price line only.
    init(title: String, subtitle: Text, price: String, isSelected: Bool, action: @escaping () -> Void) {
        self.init(title: title, subtitle: subtitle, price: price, isSelected: isSelected, action: action) {
            EmptyView()
        } details: {
            EmptyView()
        }
    }
}

#Preview {
    @Previewable @State var isFlexible = false

    VStack(spacing: 12) {
        ChoiceCard(
            title: "Our best price",
            subtitle: Text("Free cancellation and rebooking within 24h."),
            price: "Included",
            isSelected: !isFlexible
        ) {
            isFlexible = false
        }
        ChoiceCard(
            title: "Stay flexible",
            subtitle: Text("Free cancellation and rebooking any time before pickup."),
            price: "+$5.38 / day",
            isSelected: isFlexible
        ) {
            isFlexible = true
        }
    }
    .padding()
}
