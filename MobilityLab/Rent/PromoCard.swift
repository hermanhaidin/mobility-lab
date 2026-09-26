import SwiftUI

/// A promotion card under "Recommended for you": a square photo, a title, a short text, and "More info".
struct PromoCard: View {
    let promotion: Promotion

    @State private var isShowingDetail = false

    var body: some View {
        HStack(spacing: 0) {
            RemoteImage(url: promotion.imageURL, crop: promotion.imageCrop ?? .center)
                .frame(width: 138)
                .frame(maxHeight: .infinity)
                .clipped()

            VStack(alignment: .leading, spacing: 4) {
                Text(promotion.title)
                    .font(.headline)
                Text(promotion.text)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)

                Button {
                    isShowingDetail = true
                } label: {
                    HStack(spacing: 4) {
                        Text("More info")
                        Image(systemName: "chevron.right")
                            .font(.footnote)
                    }
                    .frame(minHeight: 44)
                }
                .buttonStyle(.plain)
                .font(.subheadline)
                .fontWeight(.semibold)
            }
            .padding([.top, .horizontal])
            .padding(.bottom, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .fixedSize(horizontal: false, vertical: true)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 20))
        .shadow(color: .black.opacity(0.25), radius: 24, y: 8)
        .sheet(isPresented: $isShowingDetail) {
            PromotionDetailView(promotion: promotion)
        }
    }
}

#Preview {
    PromoCard(promotion: MockData.rentHome.promotions[0])
        .padding()
}
