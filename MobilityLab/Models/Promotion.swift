import Foundation

/// A card under "Recommended for you" on the Rent tab.
nonisolated struct Promotion: Codable, Identifiable {
    let id: String
    let title: String
    /// One line for the card. `text` is the full story.
    let teaser: String
    let text: String
    let imageURL: URL?
    /// Which part of the photo to keep when it's cropped. Leave it out to keep the center.
    let imageCrop: PhotoCrop?
}
