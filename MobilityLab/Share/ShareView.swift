import SwiftUI

/// The Share tab. Not part of the prototype yet.
struct ShareView: View {
    var body: some View {
        ContentUnavailableView(
            "Share",
            systemImage: "key.fill",
            description: Text("Not part of the prototype yet.")
        )
    }
}

#Preview {
    ShareView()
}
