import SwiftUI

/// The Ride tab. Not part of the prototype yet.
struct RideView: View {
    var body: some View {
        ContentUnavailableView(
            "Ride",
            systemImage: "figure.seated.side.right",
            description: Text("Not part of the prototype yet.")
        )
    }
}

#Preview {
    RideView()
}
