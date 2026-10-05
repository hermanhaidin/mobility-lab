import SwiftUI

/// The offers for a search at the pick-up station, with quick filters, sorting, and a filter sheet.
/// Opens full screen from Search offers; the summary at the top opens the search to change it.
struct OfferListView: View {
    @Bindable var search: RentSearch

    @Environment(\.dismiss) private var dismiss
    @State private var filter = OfferFilter()
    @State private var sort = OfferSort.lowestPrice
    @State private var scrollPosition = ScrollPosition(edge: .top)
    @State private var isEditingSearch = false
    @State private var isShowingFilters = false

    var body: some View {
        let stationOffers = MockData.offers(at: search.pickUpStation, for: search.vehicleType)
        let offers = sort.sorted(stationOffers.filter { filter.matches($0, driverAge: search.driverAge) })

        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    if !stationOffers.isEmpty {
                        quickFilters
                    }
                    ForEach(offers) { offer in
                        NavigationLink(value: offer) {
                            OfferCard(offer: offer, rentalDays: search.rentalDays)
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom)
            }
            .scrollPosition($scrollPosition)
            .onChange(of: offers.map(\.id)) {
                scrollPosition.scrollTo(edge: .top)
            }
            .overlay {
                if stationOffers.isEmpty {
                    ContentUnavailableView {
                        Label("No \(search.vehicleType.title.lowercased()) here", systemImage: "exclamationmark.magnifyingglass")
                    } description: {
                        Text("\(search.pickUpStation.name) has no \(search.vehicleType.title.lowercased()) to rent. Try another station.")
                    } actions: {
                        Button("Change search") {
                            isEditingSearch = true
                        }
                    }
                } else if offers.isEmpty {
                    ContentUnavailableView {
                        Label("No matching offers", systemImage: "line.3.horizontal.decrease.circle")
                    } description: {
                        Text("Change or clear the filters to see more offers.")
                    } actions: {
                        if !filter.isEmpty {
                            Button("Clear filters") {
                                filter = OfferFilter()
                            }
                        }
                    }
                }
            }
            .navigationTitle(search.pickUpStation.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .close) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .principal) {
                    searchSummary
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Filter", systemImage: "line.3.horizontal.decrease") {
                        isShowingFilters = true
                    }
                    .badge(filter.count)
                    .disabled(stationOffers.isEmpty)
                }
            }
            .navigationDestination(for: Offer.self) { offer in
                OfferDetailView(offer: offer, rentalDays: search.rentalDays)
            }
            .sheet(isPresented: $isEditingSearch) {
                SearchEditor(search: search)
            }
            .sheet(isPresented: $isShowingFilters) {
                OfferFilterView(
                    vehicleType: search.vehicleType,
                    offers: stationOffers,
                    filter: $filter,
                    driverAge: $search.driverAge
                )
            }
            .onChange(of: search.vehicleType) {
                filter = OfferFilter()
            }
        }
    }

    /// The stations and dates. Tapping it opens the search to change it.
    private var searchSummary: some View {
        Button {
            isEditingSearch = true
        } label: {
            VStack {
                Text(search.returnStation.map { "\(search.pickUpStation.name) – \($0.name)" } ?? search.pickUpStation.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text((search.pickUpDate..<search.dropOffDate).formatted(.interval.day().month(.abbreviated).hour().minute()))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .lineLimit(1)
        }
        .buttonStyle(.glass)
        .accessibilityHint("Changes the search")
    }

    /// Sorting, then the most used filters as toggles. The filter sheet has the same ones. They scroll away with
    /// the offers: changing one scrolls back to the top anyway.
    private var quickFilters: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 8) {
                Menu {
                    Picker("Sort", selection: $sort) {
                        ForEach(OfferSort.allCases) { sort in
                            Text(sort.title).tag(sort)
                        }
                    }
                } label: {
                    Label("Sort by", systemImage: "arrow.up.arrow.down")
                }
                .foregroundStyle(.primary)

                ForEach(OfferFeature.quickFilters(for: search.vehicleType)) { feature in
                    let isOn = filter.features.contains(feature)
                    Toggle(isOn: Binding($filter.features, contains: feature)) {
                        Label(feature.quickFilterTitle, systemImage: feature.symbol)
                    }
                    .foregroundStyle(isOn ? Color(.accent) : .primary)
                }
            }
            .buttonStyle(.bordered)
            .toggleStyle(.button)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, 4)
        }
        .scrollIndicators(.hidden)
    }
}

#Preview {
    OfferListView(search: RentSearch())
}
