import SwiftUI

/// A row of the booking overview: a title with a chevron that shows its details when tapped, like the rows under
/// Information in the App Store. It isn't an accordion: once open, the chevron is gone and the row stays open.
struct BookingOverviewRow<Details: View>: View {
    let title: String
    @ViewBuilder let details: Details

    @State private var isExpanded = false

    var body: some View {
        // One button the whole time, so the title stays put while the details slide in under it.
        Button {
            withAnimation {
                isExpanded = true
            }
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                    if isExpanded {
                        details
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                .multilineTextAlignment(.leading)
                Spacer()
                if !isExpanded {
                    Image(systemName: "chevron.down")
                        .imageScale(.small)
                        .fontWeight(.semibold)
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .buttonStyle(RowButtonStyle())
        // An open row takes no taps, so it doesn't highlight either.
        .allowsHitTesting(!isExpanded)
        .accessibilityHint(isExpanded ? "" : "Shows the details")
    }
}

#Preview {
    RowGroup {
        BookingOverviewRow(title: "Third Party Insurance") {
            Text("Rest assured that if you accidentally injure someone or damage an object with the rental vehicle, such as another vehicle, SIXT will cover the cost.")
        }
        BookingOverviewRow(title: "All-Inclusive Protection") {
            BulletList(items: ["Collision damages, scratches, bumps, and theft", "Tire, windshield and windows"], spacing: 0)
        }
    }
    .padding()
}
