import SwiftUI

/// The circle on a card that can be picked, like the kit's Edit Button: empty, or an accent-filled checkmark once
/// picked. On `ChoiceCard`.
struct SelectionCircle: View {
    let isSelected: Bool

    /// Follows `isSelected`, a moment late when the card is unpicked: the circle turns gray first, so the checkmark
    /// draws off in the unpicked color rather than the accent.
    @State private var showsCheckmark: Bool

    init(isSelected: Bool) {
        self.isSelected = isSelected
        _showsCheckmark = State(initialValue: isSelected)
    }

    var body: some View {
        // One image, so picking the card replaces the circle and draws the checkmark on, like the Light and Dark
        // choices in Settings › Display & Brightness. The replace keeps the outgoing symbol's colors, so the fill goes
        // gray before the checkmark draws off.
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
}

#Preview {
    @Previewable @State var isSelected = false

    Button {
        isSelected.toggle()
    } label: {
        SelectionCircle(isSelected: isSelected)
    }
    .buttonStyle(.plain)
}
