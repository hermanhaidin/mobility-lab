import SwiftUI

/// A station's address, opening hours, and directions. The directions text is shared by all stations.
struct StationDetailView: View {
    let station: Station

    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    private let guide = MockData.stationGuide

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 4) {
                        Image(systemName: station.kind.symbol)
                        Text(station.name)
                        Text(station.address)
                            .font(.subheadline)
                            .fontWeight(.regular)
                            .foregroundStyle(.secondary)
                    }
                    .font(.title2)
                    .fontWeight(.bold)

                    section("Opening hours") {
                        Grid(alignment: .leading, horizontalSpacing: 24, verticalSpacing: 4) {
                            ForEach(station.openingHours, id: \.self) { line in
                                GridRow {
                                    Text("\(line.days):")
                                    Text(line.hours)
                                }
                            }
                        }
                    }
                    section("Your way to SIXT") { Text(guide.wayToSixt) }
                    section("Diamond Lounge") { Text(guide.diamondLounge) }
                    section("Return information") { Text(guide.returnInformation) }

                    VStack(spacing: 8) {
                        NavigationLink {
                            PlaceholderView(title: "Help and contact", systemImage: "questionmark.circle.fill")
                        } label: {
                            Label("Help and contact", systemImage: "questionmark.circle.fill")
                                .frame(maxWidth: .infinity)
                        }

                        Button {
                            openURL(directionsURL)
                        } label: {
                            Label("Directions", systemImage: "arrow.trianglehead.turn.up.right.diamond.fill")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.capsule)
                    .controlSize(.large)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .navigationTitle("Station details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .close) {
                        dismiss()
                    }
                }
            }
        }
    }

    /// Opens Apple Maps at the station's address.
    private var directionsURL: URL {
        URL(string: "https://maps.apple.com/")!.appending(queryItems: [URLQueryItem(name: "q", value: station.address)])
    }

    private func section(_ title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            content()
        }
    }
}

#Preview {
    StationDetailView(station: MockData.stations.requiredStation(id: "munich-airport"))
}
