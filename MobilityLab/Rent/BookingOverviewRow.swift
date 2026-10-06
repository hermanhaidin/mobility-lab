import SwiftUI

/// A row of the booking overview: a title with a chevron that shows its details when tapped, like the rows under
/// Information in the App Store. It isn't an accordion: once open, the chevron is gone and the row stays open.
struct BookingOverviewRow<Details: View>: View {
    let title: String
    /// Kept by the list, not the row, so the list animates the change.
    @Binding var isExpanded: Bool
    @ViewBuilder let details: Details

    var body: some View {
        Group {
            if isExpanded {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                    details
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            } else {
                Button {
                    withAnimation {
                        isExpanded = true
                    }
                } label: {
                    HStack {
                        Text(title)
                            .multilineTextAlignment(.leading)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .imageScale(.small)
                            .fontWeight(.semibold)
                            .foregroundStyle(.tertiary)
                    }
                }
                // Without it, the title takes the tint.
                .foregroundStyle(.primary)
                .accessibilityHint("Shows the details")
            }
        }
        // A new row rather than the same one grown: a list snaps a row to its new height, but animates a row in
        // and the rows below it down.
        .id(isExpanded)
    }
}

#Preview {
    @Previewable @State var expandedRows: Set<String> = []

    List {
        BookingOverviewRow(title: "Third Party Insurance", isExpanded: Binding($expandedRows, contains: "insurance")) {
            Text("Rest assured that if you accidentally injure someone or damage an object with the rental vehicle, such as another vehicle, SIXT will cover the cost.")
        }
        BookingOverviewRow(title: "All-Inclusive Protection", isExpanded: Binding($expandedRows, contains: "protection")) {
            BulletList(items: ["Collision damages, scratches, bumps, and theft", "Tire, windshield and windows"], spacing: 0)
        }
    }
}
