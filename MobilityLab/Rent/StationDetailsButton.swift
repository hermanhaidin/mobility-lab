import SwiftUI

/// The info button that opens a station's details, like the info buttons in Health's Apps section: a black "i"
/// on a light gray circle.
struct StationDetailsButton: View {
    let action: () -> Void

    var body: some View {
        Button("Station details", systemImage: "info.circle.fill", action: action)
            .labelStyle(.iconOnly)
            .font(.title2)
            .foregroundStyle(.primary, .quaternary)
            .buttonStyle(.borderless)
    }
}

#Preview {
    StationDetailsButton {}
}
