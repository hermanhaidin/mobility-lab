import SwiftUI

/// What each payment option means, opened from "Need help?" on the offer details.
struct PaymentOptionDetailView: View {
    @Environment(\.dismiss) private var dismiss

    private let options = MockData.offers.paymentOptions

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("Choose the payment option that’s right for you.")
                        .font(.title2)
                        .bold()

                    ForEach(options) { option in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(option.title)
                                .font(.headline)
                            VStack(alignment: .leading, spacing: 16) {
                                Text(option.details)
                                ForEach(option.detailBullets ?? [], id: \.self) { bullet in
                                    HStack(alignment: .firstTextBaseline, spacing: 10) {
                                        Text("•")
                                        Text(bullet)
                                    }
                                    .padding(.leading, 8)
                                }
                            }
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .toolbar {
                // Trailing, like Figma and the title-less sheets in iOS.
                ToolbarItem(placement: .topBarTrailing) {
                    Button(role: .close) {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    PaymentOptionDetailView()
}
