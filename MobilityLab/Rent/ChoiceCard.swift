import SwiftUI

/// One option to pick from, like a payment option or a mileage package: a title, a subtitle, and a price line, with
/// a selection circle like the kit's Edit Button. The picked card has a thicker border in the accent color.
/// iOS has no stock control like it.
struct ChoiceCard: View {
    let title: String
    let subtitle: String
    let price: String
    let isSelected: Bool
    let action: () -> Void

    /// Follows `isSelected`, a moment late when the card is unpicked: the circle turns gray first, so the checkmark
    /// draws off in the unpicked color rather than the accent.
    @State private var showsCheckmark: Bool

    init(title: String, subtitle: String, price: String, isSelected: Bool, action: @escaping () -> Void) {
        self.title = title
        self.subtitle = subtitle
        self.price = price
        self.isSelected = isSelected
        self.action = action
        _showsCheckmark = State(initialValue: isSelected)
    }

    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(.headline)
                        Text(subtitle)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    Text(price)
                        .font(.footnote)
                        .fontWeight(.semibold)
                }
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)

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

#Preview {
    @Previewable @State var isFlexible = false

    VStack(spacing: 12) {
        ChoiceCard(
            title: "Our best price",
            subtitle: "Free cancellation and rebooking within 24h.",
            price: "Included",
            isSelected: !isFlexible
        ) {
            isFlexible = false
        }
        ChoiceCard(
            title: "Stay flexible",
            subtitle: "Free cancellation and rebooking any time before pickup.",
            price: "+$5.38 / day",
            isSelected: isFlexible
        ) {
            isFlexible = true
        }
    }
    .padding()
}
