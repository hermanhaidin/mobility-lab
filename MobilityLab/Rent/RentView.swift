import SwiftUI

/// The Rent tab: the search rows, Search offers, and recommendations, as a list over a hero photo.
struct RentView: View {
    @State private var search = RentSearch()
    @State private var isShowingOffers = false
    @State private var isShowingLogin = false

    private let home = MockData.rentHome

    var body: some View {
        NavigationStack {
            HeroBackdrop(photo: home.hero(for: search.vehicleType)) {
                List {
                    Section {
                        Picker("Vehicle type", selection: $search.vehicleType) {
                            ForEach(VehicleType.allCases) { type in
                                Text(type.title).tag(type)
                            }
                        }
                        .pickerStyle(.segmented)
                        .listRowSeparator(.hidden, edges: .bottom)
                        StationRows(search: search)
                        DateRows(search: search)
                        DriverAgeRow(search: search)
                    }

                    Section {
                        Button {
                            isShowingOffers = true
                        } label: {
                            Text("Search offers")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.glassProminent)
                        .controlSize(.large)
                        // The button is the row.
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                    }

                    Section("Recommended for you") {
                        ForEach(home.promotions) { promotion in
                            PromoCard(promotion: promotion)
                        }
                    }
                    .headerProminence(.increased)

                    Section {
                        Button("Login or register", systemImage: "person") {
                            isShowingLogin = true
                        }
                    }
                }
                .listSectionSpacing(.compact)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Image(.sixtLogo)
                        .foregroundStyle(.white)
                        .accessibilityLabel("SIXT")
                }
                .sharedBackgroundVisibility(.hidden)

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Account", systemImage: "person.fill") {
                        isShowingLogin = true
                    }
                }
            }
            .sheet(isPresented: $isShowingLogin) {
                LoginView()
            }
            .fullScreenCover(isPresented: $isShowingOffers) {
                OfferListView(search: search)
            }
        }
    }
}

#Preview {
    RentView()
}
