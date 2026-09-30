import SwiftUI

/// A hero behind a scrolling list, under the toolbar. The rows start over the hero's lower part and take it along
/// when they scroll; when the list bounces, the hero stays put.
struct HeroBackdrop<Hero: View, Content: View>: View {
    /// The hero's height. Past it, the offset stops updating: the hero is off-screen anyway.
    let height: Double
    @ViewBuilder let hero: Hero
    @ViewBuilder let content: Content

    /// How far the rows have scrolled: 0 at rest or bouncing, up to `height` once the hero is gone.
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
                hero
                    .offset(y: -scrollOffset)
            }
            .background(Color(.systemGroupedBackground))
            // After both backgrounds, or the hero starts under the toolbar with a white band above it.
            .ignoresSafeArea(edges: .top)
            .onScrollGeometryChange(for: Double.self) { geometry in
                // Clamped: nothing changes while the list bounces, or once the hero has scrolled away.
                min(max(geometry.contentOffset.y + geometry.contentInsets.top, 0), height)
            } action: { _, offset in
                scrollOffset = offset
            }
    }
}

#Preview {
    NavigationStack {
        HeroBackdrop(height: HeroPhoto.height) {
            HeroPhoto(photo: MockData.rentHome.carsHero)
        } content: {
            List {
                ForEach(0..<20) { row in
                    Text("Row \(row)")
                }
            }
        }
    }
}
