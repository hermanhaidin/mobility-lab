import SwiftUI

/// The orange Continue button at the bottom of each step of the booking, which goes on to the next one. Fills a
/// `.safeAreaBar`, so the soft scroll edge runs under it.
struct ContinueButton<Destination: View>: View {
    @ViewBuilder let destination: () -> Destination

    var body: some View {
        NavigationLink(destination: destination) {
            Text("Continue")
        }
        .buttonStyle(.glassProminent)
        .buttonSizing(.flexible)
        .controlSize(.large)
        .fontWeight(.medium)
        // 36 points in from the screen's edges, so the capsule's ends follow the curve of the display corners.
        // Below it, the 34-point home indicator inset and 2 more make 36 too.
        .padding(.horizontal, 36)
        .padding(.top, 8)
        .padding(.bottom, 2)
    }
}

#Preview {
    NavigationStack {
        Color.clear
            .safeAreaBar(edge: .bottom) {
                ContinueButton {
                    PlaceholderView(title: "Protection", systemImage: "shield.lefthalf.filled")
                }
            }
    }
}
