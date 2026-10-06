import Foundation

/// The help behind a "Need help?" button: a title, then one section per topic. Loaded from a `*-help.json` file, like
/// `payment-option-help.json`.
nonisolated struct HelpArticle: Codable {
    struct Section: Codable, Hashable {
        let title: String
        let text: String
        /// Bullet points under the text. Leave it out for none.
        let bullets: [String]?
    }

    let title: String
    let sections: [Section]
}
