import SwiftUI

/// The Subscribe tab. Not part of the prototype yet.
struct SubscribeView: View {
    var body: some View {
        ContentUnavailableView(
            "Subscribe",
            systemImage: "car.badge.gearshape.fill",
            description: Text("Not part of the prototype yet.")
        )
    }
}

#Preview {
    SubscribeView()
}
