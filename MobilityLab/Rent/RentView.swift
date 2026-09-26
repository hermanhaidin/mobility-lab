import SwiftUI

/// The Rent tab: a hero photo, the search card, and recommendations.
struct RentView: View {
    @State private var search = RentSearch()
    @State private var isShowingLogin = false

    private let home = MockData.rentHome

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    SearchCard(search: search) {
                        isShowingLogin = true
                    }

                    VStack(alignment: .leading, spacing: 16) {
                        Text("Recommended for you")
                            .font(.title3)
                            .fontWeight(.semibold)

                        ForEach(home.promotions) { promotion in
                            PromoCard(promotion: promotion)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 250)
                .padding(.bottom)
                .background(alignment: .top) {
                    hero
                }
            }
            .ignoresSafeArea(edges: .top)
            .scrollEdgeEffectStyle(.soft, for: .top)
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
        }
    }

    /// Where a hero photo's focus point lands, from the top of the screen: the middle of the strip above the search card.
    private nonisolated static let heroFocusLine = 160.0

    /// The photo behind the search card, framed by its zoom and focus point. Its bottom fades into the background.
    private var hero: some View {
        let photo = home.hero(for: search.vehicleType)
        let focusY = photo.focusY

        return Color.clear
            .frame(height: 538)
            .overlay(alignment: .top) {
                AsyncImage(url: photo.url, transaction: Transaction(animation: .default)) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .scaledToFit()
                            .containerRelativeFrame(.horizontal) { width, _ in width * photo.zoom }
                            .fixedSize(horizontal: false, vertical: true)
                            .mask { fade(from: 0.75) }
                            .visualEffect { content, geometry in
                                content.offset(y: Self.heroFocusLine - geometry.size.height * focusY)
                            }
                    } else {
                        Rectangle()
                            .fill(Color(.secondarySystemFill))
                            .mask { fade(from: 0.6) }
                    }
                }
            }
            .clipped()
    }

    /// Opaque at the top, fading to clear from `start` (0 = top, 1 = bottom) down to the bottom edge.
    private func fade(from start: Double) -> LinearGradient {
        LinearGradient(
            stops: [.init(color: .black, location: start), .init(color: .clear, location: 1)],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

#Preview {
    RentView()
}
