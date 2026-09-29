import Foundation

/// A photo behind the Rent tab, and how to frame it. Loaded from `rent-home.json`.
nonisolated struct HeroImage: Codable {
    let url: URL?
    /// How much wider than the screen the photo is drawn. 1 fits the screen width; 1.2 is 20% wider and cropped at the sides.
    let zoom: Double
    /// Which height of the photo (0 = top edge, 1 = bottom edge) lands in the middle of the strip above the search rows.
    /// For a studio car shot, use the middle of the car's front.
    let focusY: Double
}
