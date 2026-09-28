import SwiftUI

/// The return station of a search, if it differs from the pick-up station, with a button to remove it.
/// Used on the search card and in the search editor, which set its padding and open the station picker.
struct ReturnStationRow: View {
    let station: Station?
    let onPick: () -> Void
    let onRemove: () -> Void

    var body: some View {
        Group {
            if let station {
                HStack(spacing: 12) {
                    Button(action: onPick) {
                        StationLabel(station: station)
                    }

                    Button("Remove return station", systemImage: "xmark.circle.fill", action: onRemove)
                        .labelStyle(.iconOnly)
                        .foregroundStyle(.secondary)
                }
            } else {
                Button(action: onPick) {
                    HStack(spacing: 12) {
                        Image(systemName: "plus")
                            .frame(width: 24)
                        Text("Optional different return station")
                            .lineLimit(1)
                        Spacer(minLength: 0)
                    }
                    .foregroundStyle(.secondary)
                    .contentShape(.rect)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: 24) {
        ReturnStationRow(station: nil) {} onRemove: {}
        ReturnStationRow(station: MockData.stations.requiredStation(id: "munich-airport")) {} onRemove: {}
    }
    .padding()
}
