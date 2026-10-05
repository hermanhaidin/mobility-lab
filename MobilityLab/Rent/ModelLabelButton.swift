import SwiftUI

/// An offer's model label, like "Premium brand", tinted for a premium brand or a guaranteed model.
/// Its info button explains the label in a popover. On the offer cards and the offer details.
struct ModelLabelButton: View {
    let offer: Offer

    @State private var isShowingInfo = false

    var body: some View {
        let model = offer.model
        let button = Button {
            isShowingInfo = true
        } label: {
            HStack(spacing: 4) {
                Text(model.title)
                Image(systemName: "info.circle")
            }
            .font(.footnote)
            .fontWeight(.semibold)
        }
        .controlSize(.small)
        .popover(isPresented: $isShowingInfo) {
            Text(MockData.offers.modelDescription(for: offer))
                .font(.subheadline)
                .frame(width: 260, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
                .padding()
                .presentationCompactAdaptation(.popover)
        }

        if let tint = model.tint {
            button
                .buttonStyle(.glassProminent)
                .tint(tint)
        } else {
            button
                .buttonStyle(.glass)
        }
    }
}

#Preview {
    VStack {
        ForEach(Offer.Model.allCases, id: \.self) { model in
            ModelLabelButton(offer: MockData.offers.cars.first { $0.model == model }!)
        }
    }
    .padding()
    .background(.black)
    .environment(\.colorScheme, .dark)
}
