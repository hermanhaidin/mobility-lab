import SwiftUI

/// The SIXT wordmark with its swoosh in the accent color, 65 × 27 points. The letters take the foreground style
/// of where the logo sits, white on the Rent tab's hero photo.
struct SixtLogo: View {
    var body: some View {
        ZStack {
            Image(.sixtWordmark)
            Image(.sixtSwoosh)
                .foregroundStyle(Color.accentColor)
        }
        .accessibilityLabel("SIXT")
    }
}

#Preview {
    SixtLogo()
        .foregroundStyle(.white)
        .padding()
        .background(.black)
}
