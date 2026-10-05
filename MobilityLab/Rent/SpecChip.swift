import SwiftUI

/// A spec in a glass capsule, like "5" seats or "Electric", as tall as the model label next to it.
/// On the offer cards and the offer details.
struct SpecChip: View {
    let title: String
    let systemImage: String

    var body: some View {
        Label(title, systemImage: systemImage)
            .font(.footnote)
            .fontWeight(.semibold)
            .padding(.horizontal, 10)
            .frame(minHeight: 28)
            .glassEffect(in: .capsule)
    }
}

#Preview {
    HStack {
        SpecChip(title: "5", systemImage: "person.fill")
        SpecChip(title: "Electric", systemImage: "bolt.fill")
    }
    .padding()
    .background(.black)
    .environment(\.colorScheme, .dark)
}
