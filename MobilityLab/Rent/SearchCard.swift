import SwiftUI

/// The search card on the Rent tab: vehicle type, stations, dates, and driver age.
struct SearchCard: View {
    @Bindable var search: RentSearch
    let onSearch: () -> Void
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
                PickUpStationRow(station: search.pickUpStation) {
                    editedStation = .pickUp
                } onShowDetails: {
                    detailStation = search.pickUpStation
                }
                .padding(.horizontal)
                .frame(minHeight: 52)
                separator
                ReturnStationRow(station: search.returnStation) {
                    editedStation = .return
                } onRemove: {
                    search.returnStation = nil
                }
                .padding(.horizontal)
                .frame(minHeight: 52)
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
                Button(action: onSearch) {
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

#Preview {
    SearchCard(search: RentSearch()) {} onLogin: {}
        .padding()
}
