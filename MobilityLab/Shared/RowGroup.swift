import SwiftUI

/// Rows on a rounded gray background with a line between them, like a section of an inset-grouped list, for a scroll
/// view: the booking overview on the protection and add-ons screens. Rows bring their own padding, 16 points from the
/// sides like Figma.
struct RowGroup<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        Group(subviews: content) { rows in
            VStack(alignment: .leading, spacing: 0) {
                ForEach(rows) { row in
                    if row.id != rows.first?.id {
                        // Inset on both sides to where the rows' text starts, like the separators of an inset-grouped
                        // list in iOS 26.
                        Divider()
                            .padding(.horizontal, 16)
                    }
                    row
                }
            }
        }
        .background(Color(.secondarySystemBackground))
        // A list section's corners.
        .clipShape(.rect(cornerRadius: 26))
    }
}

#Preview {
    RowGroup {
        Text("Third Party Insurance")
            .padding()
        Text("24/7 Breakdown Assistance")
            .padding()
    }
    .padding()
}
