import SwiftUI

/// The offers for a search. A placeholder until the offer list is built.
struct OfferListView: View {
    var body: some View {
        PlaceholderView(title: "Offers", systemImage: "car.2.fill")
    }
}

#Preview {
    NavigationStack {
        OfferListView()
    }
}
