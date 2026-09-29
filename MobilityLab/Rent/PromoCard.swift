import SwiftUI

/// A promotion under "Recommended for you", as a list row: the photo on top, a title, and one line of text.
/// Tapping it opens the full text.
struct PromoCard: View {
    let promotion: Promotion

    @State private var isShowingDetail = false

    var body: some View {
        Button {
            isShowingDetail = true
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                // Figma's photo frame: 408 × 245.
                RemoteImage(url: promotion.imageURL, crop: promotion.imageCrop ?? .center)
                    .aspectRatio(5 / 3, contentMode: .fit)
                    .clipped()

                VStack(alignment: .leading, spacing: 4) {
                    Text(promotion.title)
                        .font(.title2)
                        .fontWeight(.bold)
                    Text(promotion.teaser)
                        .font(.subheadline)
                }
                .padding()
            }
        }
        // On the button, not inside its label: there, `.primary` resolves to the button's tint.
        .foregroundStyle(.primary)
        .listRowInsets(EdgeInsets())
        .sheet(isPresented: $isShowingDetail) {
            PromotionDetailView(promotion: promotion)
        }
    }
}

#Preview {
    List {
        PromoCard(promotion: MockData.rentHome.promotions[0])
    }
}
