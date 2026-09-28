import SwiftUI

/// Filters for the offer list. The changes apply when the customer taps Show offers; closing the sheet throws them away.
struct OfferFilterView: View {
    let vehicleType: VehicleType
    /// The station's offers before filtering, to count what the filters let through.
    let offers: [Offer]
    @Binding var filter: OfferFilter
    @Binding var driverAge: Int

    @Environment(\.dismiss) private var dismiss
    @State private var draft: OfferFilter
    @State private var draftAge: Int

    init(vehicleType: VehicleType, offers: [Offer], filter: Binding<OfferFilter>, driverAge: Binding<Int>) {
        self.vehicleType = vehicleType
        self.offers = offers
        _filter = filter
        _driverAge = driverAge
        _draft = State(initialValue: filter.wrappedValue)
        _draftAge = State(initialValue: driverAge.wrappedValue)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Vehicle type") {
                    ForEach(BodyStyle.allCases.filter { $0.vehicleType == vehicleType }) { bodyStyle in
                        Toggle(bodyStyle.title, isOn: Binding($draft.bodyStyles, contains: bodyStyle))
                            .tint(Color(.accent))
                    }
                }

                Section("Features") {
                    ForEach(OfferFeature.filters(for: vehicleType)) { feature in
                        Toggle(feature.title, isOn: Binding($draft.features, contains: feature))
                            .tint(Color(.accent))
                    }
                }

                Section("People") {
                    switch vehicleType {
                    case .cars:
                        Picker("Minimum number of seats", selection: $draft.minimumSeats) {
                            ForEach(seatCounts, id: \.self) { seats in
                                Text("\(seats)").tag(seats)
                            }
                        }
                        Picker("Age of the primary driver", selection: $draftAge) {
                            ForEach(RentSearch.driverAges, id: \.self) { age in
                                Text(RentSearch.ageLabel(age)).tag(age)
                            }
                        }
                    case .trucks:
                        Picker("Driver age", selection: minimumAge) {
                            ForEach(minimumAges, id: \.self) { age in
                                Text("\(age)+").tag(age)
                            }
                        }
                    }
                }
            }
            .pickerStyle(.menu)
            .tint(.secondary)
            .navigationTitle("Filter")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .close) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Clear") {
                        draft = OfferFilter()
                    }
                    .disabled(draft.isEmpty)
                }
            }
            .safeAreaBar(edge: .bottom) {
                Button {
                    filter = draft
                    driverAge = draftAge
                    dismiss()
                } label: {
                    Text("Show ^[\(matchCount) offer](inflect: true)")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.glassProminent)
                .controlSize(.large)
                .disabled(matchCount == 0)
                .padding(.horizontal, 36)
                .padding(.vertical, 8)
            }
        }
    }

    private var matchCount: Int {
        offers.count { draft.matches($0, driverAge: draftAge) }
    }

    /// The minimum driver ages the offers need, like 18. Trucks list only these, since other ages change nothing.
    private var minimumAges: [Int] {
        Set(offers.map(\.minDriverAge)).sorted()
    }

    /// The highest of those ages the driver meets. Picking another one sets the driver's age to it; picking the
    /// same one keeps the driver's age, so "18+" doesn't turn a 30-year-old into an 18-year-old.
    private var minimumAge: Binding<Int> {
        let met = minimumAges.last { $0 <= draftAge } ?? minimumAges.first ?? draftAge
        return Binding {
            met
        } set: { age in
            if age != met {
                draftAge = age
            }
        }
    }

    /// 4, then every larger seat count in the catalog.
    private var seatCounts: [Int] {
        let fewest = OfferFilter.fewestSeats
        return Set(MockData.offers.cars.compactMap(\.seats) + [fewest]).filter { $0 >= fewest }.sorted()
    }
}

#Preview {
    @Previewable @State var filter = OfferFilter()
    @Previewable @State var driverAge = RentSearch.driverAges.upperBound

    OfferFilterView(vehicleType: .cars, offers: MockData.offers.cars, filter: $filter, driverAge: $driverAge)
}
