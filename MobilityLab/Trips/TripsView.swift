import SwiftUI

/// The Trips tab. Not part of the prototype yet.
struct TripsView: View {
    var body: some View {
        ContentUnavailableView(
            "Trips",
            systemImage: "point.bottomleft.forward.to.point.topright.scurvepath.fill",
            description: Text("Not part of the prototype yet.")
        )
    }
}

#Preview {
    TripsView()
}
