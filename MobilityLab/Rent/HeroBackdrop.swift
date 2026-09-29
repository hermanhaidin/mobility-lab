import SwiftUI

/// A hero photo behind a scrolling list, under the toolbar. The rows start over the photo's lower part and take the
/// photo along when they scroll; when the list bounces, the photo stays put.
struct HeroBackdrop<Content: View>: View {
    let photo: HeroImage
    @ViewBuilder let content: Content

    /// How far the rows have scrolled: 0 at rest or bouncing, up to the photo's height once it's gone.
    /// Kept here, so a scroll frame re-runs this body only, not the list's.
    @State private var scrollOffset = 0.0

    /// Where the rows start, from the top of the screen.
    private let contentStart = 250.0

    var body: some View {
        content
            .contentMargins(.top, contentStart, for: .scrollContent)
            .scrollEdgeEffectStyle(.soft, for: .top)
            .scrollContentBackground(.hidden)
            .background(alignment: .top) {
                HeroPhoto(photo: photo)
                    .offset(y: -scrollOffset)
            }
            .background(Color(.systemGroupedBackground))
            // After both backgrounds, or the photo starts under the toolbar with a white band above it.
            .ignoresSafeArea(edges: .top)
            .onScrollGeometryChange(for: Double.self) { geometry in
                // Clamped: nothing changes while the list bounces, or once the photo has scrolled away.
                min(max(geometry.contentOffset.y + geometry.contentInsets.top, 0), HeroPhoto.height)
            } action: { _, offset in
                scrollOffset = offset
            }
    }
}

#Preview {
    NavigationStack {
        HeroBackdrop(photo: MockData.rentHome.carsHero) {
            List {
                ForEach(0..<20) { row in
                    Text("Row \(row)")
                }
            }
        }
    }
}
