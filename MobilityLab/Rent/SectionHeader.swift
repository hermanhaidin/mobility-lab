import SwiftUI

/// A section's title over its cards, like a prominent list header: bold, in sentence case, lined up with the text in
/// the cards, with an optional "Need help?" at the trailing edge. On the offer details and protection, which are
/// scroll views, not lists.
struct SectionHeader: View {
    let title: String
    /// Shows "Need help?" when set.
    var helpAction: (() -> Void)?

    init(_ title: String, helpAction: (() -> Void)? = nil) {
        self.title = title
        self.helpAction = helpAction
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(.title3)
                .fontWeight(.semibold)
            Spacer()
            if let helpAction {
                Button(action: helpAction) {
                    Text("Need help?")
                        .underline()
                }
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.primary)
            }
        }
        .padding(.horizontal)
        .padding(.top, 14)
    }
}

#Preview {
    VStack(alignment: .leading) {
        SectionHeader("Payment option") {}
        SectionHeader("Mileage package")
    }
    .padding()
}
