import SwiftUI

/// The photo behind the Rent tab, framed by its zoom and focus point: always `height` tall, with its bottom fading
/// into the background. The photo is moved so its focus point lands on the focus line.
struct HeroPhoto: View {
    let photo: HeroImage

    /// The strip the photo covers, from the top of the screen.
    nonisolated static let height = 538.0

    /// Where the photo's focus point lands, from the top of the screen: the middle of the strip above the search rows.
    private nonisolated static let focusLine = 160.0

    var body: some View {
        let focusY = photo.focusY

        Color.clear
            .frame(height: Self.height)
            .overlay(alignment: .top) {
                AsyncImage(url: photo.url, transaction: Transaction(animation: .default)) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .scaledToFit()
                            .containerRelativeFrame(.horizontal) { width, _ in width * photo.zoom }
                            .fixedSize(horizontal: false, vertical: true)
                            .mask { fade(from: 0.75) }
                            .visualEffect { content, geometry in
                                content.offset(y: Self.focusLine - geometry.size.height * focusY)
                            }
                    } else {
                        Rectangle()
                            .fill(Color(.secondarySystemFill))
                            .mask { fade(from: 0.6) }
                    }
                }
            }
            .clipped()
    }

    /// Opaque at the top, fading to clear from `start` (0 = top, 1 = bottom) down to the bottom edge.
    private func fade(from start: Double) -> LinearGradient {
        LinearGradient(
            stops: [.init(color: .black, location: start), .init(color: .clear, location: 1)],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

#Preview {
    HeroPhoto(photo: MockData.rentHome.carsHero)
}
