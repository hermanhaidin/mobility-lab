import SwiftUI

/// A photo loaded from a URL on SIXT's servers. Shows a neutral placeholder while it loads, or if there's no URL yet.
/// Fills the frame it's given, so give it a size and clip it. The placeholder goes away once the photo loads,
/// so vehicle photos on transparent backgrounds show what's behind them.
struct RemoteImage: View {
    let url: URL?
    var crop: PhotoCrop = .center

    var body: some View {
        Color.clear
            .overlay(alignment: crop.alignment) {
                AsyncImage(url: url, transaction: Transaction(animation: .default)) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .scaledToFill()
                    } else {
                        Rectangle()
                            .fill(Color(.secondarySystemFill))
                            .overlay {
                                Image(systemName: "photo")
                                    .font(.title)
                                    .foregroundStyle(.tertiary)
                            }
                    }
                }
            }
    }
}

#Preview {
    RemoteImage(url: nil)
        .frame(width: 200, height: 140)
        .clipped()
}
