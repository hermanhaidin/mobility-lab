import SwiftUI

/// Lines with a bullet in front, since SwiftUI has no list style for them.
struct BulletList: View {
    let items: [String]
    var spacing = 16.0

    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            ForEach(items, id: \.self) { item in
                HStack(alignment: .firstTextBaseline, spacing: 10) {
                    Text("•")
                    Text(item)
                }
            }
        }
    }
}

#Preview {
    BulletList(items: ["Collision damages, scratches, bumps, and theft", "Tire, windshield and windows"])
        .padding()
}
