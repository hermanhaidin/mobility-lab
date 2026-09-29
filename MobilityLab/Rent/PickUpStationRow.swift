import SwiftUI

/// The pick-up station of a search, with a button for its station details. Used on the search card, which sets its
/// padding and opens the station picker and station details. The search editor has its own Form rows.
struct PickUpStationRow: View {
    let station: Station
    let onPick: () -> Void
    let onShowDetails: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onPick) {
                StationLabel(station: station)
            }

            Button("Station details", systemImage: "info.circle", action: onShowDetails)
                .labelStyle(.iconOnly)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    PickUpStationRow(station: MockData.stations.requiredStation(id: "munich-airport")) {} onShowDetails: {}
        .padding()
}
