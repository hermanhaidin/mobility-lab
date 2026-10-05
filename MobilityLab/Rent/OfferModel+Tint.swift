import SwiftUI

extension Offer.Model {
    /// The model label's color: the accent for a premium brand, brown for a guaranteed model.
    var tint: Color? {
        switch self {
        case .orSimilar: nil
        case .premiumBrand: Color(.accent)
        case .guaranteed: .brown
        }
    }
}
