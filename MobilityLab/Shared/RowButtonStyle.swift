import SwiftUI

/// A button that fills a row of a `RowGroup`: the row's padding, the label in the label color, and a gray highlight
/// while pressed, like a list cell.
struct RowButtonStyle: ButtonStyle {
    /// Lines the text up with the cards above it, 16 points in, like Figma.
    static let horizontalPadding = 16.0

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.primary)
            .padding(.horizontal, Self.horizontalPadding)
            // A 52-point row for one line of body text, like the kit's Row.
            .padding(.vertical, 15)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(.rect)
            .background(configuration.isPressed ? Color(.systemGray4) : .clear)
    }
}

#Preview {
    RowGroup {
        Button("Third Party Insurance") {}
        Button("24/7 Breakdown Assistance") {}
    }
    .buttonStyle(RowButtonStyle())
    .padding()
}
