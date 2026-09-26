import SwiftUI

/// The full text of a promotion, opened from "More info".
struct PromotionDetailView: View {
    let promotion: Promotion

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    RemoteImage(url: promotion.imageURL, crop: promotion.imageCrop ?? .center)
                        .frame(height: 240)
                        .clipShape(.rect(cornerRadius: 20))
                    Text(promotion.text)
                }
                .padding()
            }
            .navigationTitle(promotion.title)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .close) {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

#Preview {
    PromotionDetailView(promotion: MockData.rentHome.promotions[0])
}
