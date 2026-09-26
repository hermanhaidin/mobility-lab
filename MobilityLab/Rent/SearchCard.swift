import SwiftUI

/// The search card on the Rent tab: vehicle type, stations, dates, and driver age.
struct SearchCard: View {
    @Bindable var search: RentSearch
    let onLogin: () -> Void

    @State private var editedStation: StationRole?
    @State private var detailStation: Station?

    var body: some View {
        VStack(spacing: 16) {
            Picker("Vehicle type", selection: $search.vehicleType) {
                ForEach(VehicleType.allCases) { type in
                    Text(type.title).tag(type)
                }
            }
            .pickerStyle(.segmented)

            VStack(spacing: 0) {
                pickUpRow
                separator
                returnRow
                separator
                DatePicker(selection: $search.pickUpDate, in: Date.now...) {
                    Text("Pick-up").fontWeight(.semibold)
                }
                .padding(.horizontal)
                .frame(minHeight: 52)
                separator
                DatePicker(selection: $search.dropOffDate, in: search.pickUpDate...) {
                    Text("Drop-off").fontWeight(.semibold)
                }
                .padding(.horizontal)
                .frame(minHeight: 52)
            }
            .background(Color(.tertiarySystemBackground), in: .rect(cornerRadius: 26))

            VStack(spacing: 8) {
                NavigationLink {
                    OfferListView()
                } label: {
                    Text("Search offers")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.glassProminent)
                .controlSize(.large)

                HStack {
                    ageMenu
                    Spacer()
                    Button("Login / Register", action: onLogin)
                        .padding(.horizontal)
                        .frame(minHeight: 44)
                }
                .font(.subheadline)
                .fontWeight(.semibold)
                .tint(.primary)
            }
        }
        .padding([.top, .horizontal])
        .padding(.bottom, 8)
        .background(Color(.secondarySystemBackground), in: .rect(cornerRadius: 32))
        .shadow(color: .black.opacity(0.25), radius: 12, y: 8)
        .sheet(item: $editedStation) { role in
            LocationPicker(title: role.title, recentStations: search.recentStations) { station in
                search.remember(station)
                switch role {
                case .pickUp: search.pickUpStation = station
                case .return: search.returnStation = station
                }
            }
        }
        .sheet(item: $detailStation) { station in
            StationDetailView(station: station)
        }
    }

    private var pickUpRow: some View {
        HStack(spacing: 12) {
            Button {
                editedStation = .pickUp
            } label: {
                stationLabel(search.pickUpStation)
            }

            Button("Station details", systemImage: "info.circle") {
                detailStation = search.pickUpStation
            }
            .labelStyle(.iconOnly)
        }
        .buttonStyle(.plain)
        .padding(.horizontal)
        .frame(minHeight: 52)
    }

    @ViewBuilder
    private var returnRow: some View {
        if let returnStation = search.returnStation {
            HStack(spacing: 12) {
                Button {
                    editedStation = .return
                } label: {
                    stationLabel(returnStation)
                }

                Button("Remove return station", systemImage: "xmark.circle.fill") {
                    search.returnStation = nil
                }
                .labelStyle(.iconOnly)
                .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .padding(.horizontal)
            .frame(minHeight: 52)
        } else {
            Button {
                editedStation = .return
            } label: {
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
            .buttonStyle(.plain)
            .padding(.horizontal)
            .frame(minHeight: 52)
        }
    }

    private func stationLabel(_ station: Station) -> some View {
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

    private var ageMenu: some View {
        Menu {
            Picker("Driver age", selection: $search.driverAge) {
                ForEach(RentSearch.driverAges, id: \.self) { age in
                    Text(RentSearch.ageLabel(age)).tag(age)
                }
            }
        } label: {
            HStack(spacing: 4) {
                Text("Age: \(RentSearch.ageLabel(search.driverAge))")
                Image(systemName: "chevron.up.chevron.down")
                    .font(.footnote)
            }
            .padding(.horizontal)
            .frame(minHeight: 44)
        }
        .accessibilityLabel("Driver age: \(RentSearch.ageLabel(search.driverAge))")
    }

    private var separator: some View {
        Divider()
            .padding(.horizontal)
    }
}

/// Which station the location picker is choosing.
private enum StationRole: Identifiable {
    case pickUp, `return`

    var id: Self { self }

    var title: String {
        switch self {
        case .pickUp: "Pickup location"
        case .return: "Return location"
        }
    }
}

#Preview {
    NavigationStack {
        SearchCard(search: RentSearch()) {}
            .padding()
    }
}
