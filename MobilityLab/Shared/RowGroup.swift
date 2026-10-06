import SwiftUI

/// Rows on a rounded gray background with a line between them, like a section of an inset-grouped list, for a scroll
/// view: the booking overview on the protection screen. Rows bring their own padding, like `RowButtonStyle`'s.
struct RowGroup<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        Group(subviews: content) { rows in
            VStack(alignment: .leading, spacing: 0) {
                ForEach(rows) { row in
                    if row.id != rows.first?.id {
                        // Inset on both sides, like the separators of an inset-grouped list in iOS 26.
                        Divider()
                            .padding(.horizontal, RowButtonStyle.horizontalPadding)
                    }
                    row
                }
            }
        }
        .background(Color(.secondarySystemBackground))
        // A list section's corners, which also clip a pressed row's highlight.
        .clipShape(.rect(cornerRadius: 26))
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
