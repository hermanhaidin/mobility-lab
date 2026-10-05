import SwiftUI

/// The studio photo behind an offer, with a glow for premium brands, guaranteed models, and electric trucks.
/// Behind the offer cards and the top of the offer details, which are always dark.
struct OfferBackdrop: View {
    let offer: Offer

    var body: some View {
        Color(.secondarySystemBackground)
            .overlay {
                AsyncImage(url: MockData.offers.cardBackdropURL) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Color.clear
                }
            }
            .overlay {
                if let glow {
                    EllipticalGradient(colors: [glow, .clear], center: .topTrailing, endRadiusFraction: 0.8)
                }
            }
            // The filled photo spills over the edges.
            .clipped()
    }

    /// The model label's color, or blue for an electric truck.
    private var glow: Color? {
        if offer.vehicleType == .trucks && offer.fuel == .electric {
            return .blue
        }
        return offer.model.tint
    }
}

#Preview {
    OfferBackdrop(offer: MockData.offers.cars.first { $0.model == .premiumBrand }!)
        .frame(height: 300)
        .environment(\.colorScheme, .dark)
}
