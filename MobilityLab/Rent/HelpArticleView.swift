import SwiftUI

/// The help behind a "Need help?" button, like what each payment option means. A sheet with ✕ and no title.
struct HelpArticleView: View {
    let article: HelpArticle

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text(article.title)
                        .font(.title2)
                        .bold()

                    ForEach(article.sections, id: \.self) { section in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(section.title)
                                .font(.headline)
                            VStack(alignment: .leading, spacing: 16) {
                                Text(section.text)
                                if let bullets = section.bullets {
                                    BulletList(items: bullets)
                                        .padding(.leading, 8)
                                }
                            }
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .toolbar {
                // Trailing, like Figma and the title-less sheets in iOS.
                ToolbarItem(placement: .topBarTrailing) {
                    Button(role: .close) {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview("Payment options") {
    HelpArticleView(article: MockData.paymentOptionHelp)
}

#Preview("Protection") {
    HelpArticleView(article: MockData.protectionHelp)
}
