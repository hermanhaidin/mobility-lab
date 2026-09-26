import SwiftUI

/// Stands in for a screen that isn't part of the prototype yet.
struct PlaceholderView: View {
    let title: String
    let systemImage: String

    var body: some View {
        ContentUnavailableView(
            title,
            systemImage: systemImage,
            description: Text("Not part of the prototype yet.")
        )
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        PlaceholderView(title: "Help center", systemImage: "headphones")
    }
}
