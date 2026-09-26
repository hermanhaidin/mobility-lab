import SwiftUI

/// Lets the customer pick a station: from their search history, their current location, or by searching.
struct LocationPicker: View {
    let title: String
    let recentStations: [Station]
    let onSelect: (Station) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var query = ""
    @State private var detailStation: Station?

    private let catalog = MockData.stations

    var body: some View {
        NavigationStack {
            List {
                if query.isEmpty {
                    Button {
                        select(catalog.requiredStation(id: catalog.currentLocationStationID))
                    } label: {
                        Label("Use my current location", systemImage: "location.fill")
                            .foregroundStyle(.primary)
                    }
                    .listRowSeparator(.hidden)

                    if !recentStations.isEmpty {
                        Section("History") {
                            ForEach(recentStations) { station in
                                stationRow(station, showsAddress: false)
                            }
                        }
                        .listSectionSeparator(.hidden, edges: .bottom)
                    }
                } else {
                    searchResults
                }
            }
            .listStyle(.plain)
            .overlay {
                if !query.isEmpty && matchingStations.isEmpty {
                    ContentUnavailableView.search(text: query)
                }
            }
            .searchable(text: $query, prompt: "Airport, city, hotel, or address")
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: City.self) { city in
                List {
                    stationSections(catalog.stations.filter { $0.city == city.name })
                }
                .listStyle(.plain)
                .navigationTitle(city.name)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .close) {
                        dismiss()
                    }
                }
            }
            .sheet(item: $detailStation) { station in
                StationDetailView(station: station)
            }
        }
    }

    // MARK: - Search

    /// Airports first, then whole cities, then train and downtown stations, like the Figma design.
    @ViewBuilder
    private var searchResults: some View {
        let stations = matchingStations
        stationSection(.airport, stations: stations)

        let cities = matchingCities
        if !cities.isEmpty {
            Section("Locations") {
                ForEach(cities) { city in
                    NavigationLink(value: city) {
                        Label {
                            VStack(alignment: .leading) {
                                Text("\(city.name) (\(city.stationCount) stations)")
                                Text("See all stations in \(city.name), \(city.countryName)")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        } icon: {
                            Image(systemName: "map.fill")
                        }
                        .foregroundStyle(.primary)
                    }
                }
            }
            .listSectionSeparator(.hidden, edges: .bottom)
        }

        stationSection(.trainStation, stations: stations)
        stationSection(.downtown, stations: stations)
    }

    private var matchingStations: [Station] {
        catalog.stations.filter { station in
            [station.name, station.city, station.address].contains { $0.localizedStandardContains(query) }
        }
    }

    private var matchingCities: [City] {
        Dictionary(grouping: catalog.stations, by: \.city)
            .filter { $0.key.localizedStandardContains(query) }
            .map { name, stations in
                City(name: name, countryCode: stations[0].countryCode, stationCount: stations.count)
            }
            .sorted { $0.name < $1.name }
    }

    // MARK: - Rows

    private func stationSections(_ stations: [Station]) -> some View {
        ForEach(Station.Kind.allCases, id: \.self) { kind in
            stationSection(kind, stations: stations)
        }
    }

    @ViewBuilder
    private func stationSection(_ kind: Station.Kind, stations: [Station]) -> some View {
        let stationsOfKind = stations.filter { $0.kind == kind }
        if !stationsOfKind.isEmpty {
            Section(kind.sectionTitle) {
                ForEach(stationsOfKind) { station in
                    stationRow(station)
                }
            }
            .listSectionSeparator(.hidden, edges: .bottom)
        }
    }

    private func stationRow(_ station: Station, showsAddress: Bool = true) -> some View {
        HStack {
            Button {
                select(station)
            } label: {
                Label {
                    VStack(alignment: .leading) {
                        Text(station.name)
                        if showsAddress {
                            Text(station.address)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .multilineTextAlignment(.leading)
                } icon: {
                    Image(systemName: station.kind.symbol)
                }
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(.rect)
            }
            .buttonStyle(.plain)

            if showsAddress {
                Button("Station details", systemImage: "info.circle") {
                    detailStation = station
                }
                .labelStyle(.iconOnly)
                .buttonStyle(.borderless)
                .tint(.secondary)
            }
        }
    }

    private func select(_ station: Station) {
        onSelect(station)
        dismiss()
    }
}

/// A city in search results that groups all of its stations.
private struct City: Hashable, Identifiable {
    let name: String
    let countryCode: String
    let stationCount: Int

    var id: String { name }

    var countryName: String {
        Locale.current.localizedString(forRegionCode: countryCode) ?? countryCode
    }
}

#Preview {
    LocationPicker(title: "Pickup location", recentStations: Array(MockData.stations.stations.prefix(3))) { _ in }
}
