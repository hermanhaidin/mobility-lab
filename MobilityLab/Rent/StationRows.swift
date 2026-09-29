import SwiftUI

/// The stations of a search: the pick-up station, and the return station or a row to add one. Picked stations have a
/// button for their station details. Tapping a row opens the station picker. Shared by the Rent tab and the search
/// editor, which pass the live search or the draft.
struct StationRows: View {
    let search: RentSearch

    @State private var editedStation: StationRole?
    @State private var detailStation: Station?

    var body: some View {
        stationRow(search.pickUpStation, as: .pickUp)
            // On this row only. On the whole body, every row would present the same sheet.
            .sheet(item: $editedStation) { role in
                LocationPicker(
                    title: role.title,
                    recentStations: search.recentStations,
                    onSameAsPickUp: role == .return ? { search.returnStation = nil } : nil
                ) { station in
                    search.pick(station, as: role)
                }
            }
            .sheet(item: $detailStation) { station in
                StationDetailView(station: station)
            }

        if let returnStation = search.returnStation {
            stationRow(returnStation, as: .return)
        } else {
            Button("Optional different return station", systemImage: "plus") {
                editedStation = .return
            }
            .foregroundStyle(.secondary)
        }
    }

    /// A picked station, with a button for its station details.
    private func stationRow(_ station: Station, as role: StationRole) -> some View {
        HStack {
            Button(station.name, systemImage: station.kind.symbol) {
                editedStation = role
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            StationDetailsButton {
                detailStation = station
            }
        }
        .foregroundStyle(.primary)
    }
}

#Preview {
    List {
        StationRows(search: RentSearch())
    }
}
