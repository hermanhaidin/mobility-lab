import SwiftUI

/// A picked station in a search: its kind's icon and its name, filling the row so all of it can be tapped.
struct StationLabel: View {
    let station: Station

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: station.kind.symbol)
                .frame(width: 24)
            Text(station.name)
                .fontWeight(.semibold)
                .lineLimit(1)
            Spacer(minLength: 0)
        }
        .contentShape(.rect)
    }
}

#Preview {
    StationLabel(station: MockData.stations.requiredStation(id: "munich-airport"))
        .padding()
}
