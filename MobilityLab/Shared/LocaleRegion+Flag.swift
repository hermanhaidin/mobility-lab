import Foundation

extension Locale.Region {
    /// The flag emoji for this region, like 🇩🇪 for Germany.
    var flag: String {
        let letters = identifier.uppercased().unicodeScalars.compactMap { Unicode.Scalar(0x1F1E6 - 0x41 + $0.value) }
        return String(String.UnicodeScalarView(letters))
    }
}
