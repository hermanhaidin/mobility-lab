import Foundation

/// The protection every rental includes and the packages to pick from on the protection screen. Loaded from
/// `protection.json`.
nonisolated struct ProtectionCatalog: Codable {
    /// Protection that comes with every rental, like Third Party Insurance. Listed first in the booking overview.
    struct IncludedProtection: Codable, Hashable {
        let title: String
        /// Shown when its row in the booking overview is tapped.
        let details: String
    }

    let included: [IncludedProtection]
    /// From most to least coverage. The one without a surcharge is "No extra protection".
    let packages: [ProtectionPackage]
}
