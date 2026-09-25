import SwiftUI

/// The Rent tab, where the rent funnel starts.
struct RentView: View {
    var body: some View {
        ContentUnavailableView(
            "Rent",
            systemImage: "car.fill",
            description: Text("Coming soon.")
        )
    }
}

#Preview {
    RentView()
}
