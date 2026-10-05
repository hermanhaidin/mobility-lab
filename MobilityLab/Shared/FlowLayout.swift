import SwiftUI

/// Places views side by side and wraps them onto a new line when a line is full, like words in a paragraph.
/// SwiftUI has no stock layout for this.
struct FlowLayout: Layout {
    /// Where a line shorter than the widest one sits: at the leading edge, centered, or at the trailing edge.
    var alignment = HorizontalAlignment.leading
    var spacing = 8.0

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let lines = lines(of: subviews, maxWidth: proposal.width ?? .infinity)
        let width = lines.map(\.width).max() ?? 0
        let height = lines.map(\.height).reduce(0, +) + spacing * Double(max(lines.count - 1, 0))
        return CGSize(width: width, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var y = bounds.minY
        for line in lines(of: subviews, maxWidth: bounds.width) {
            var x = bounds.minX + (bounds.width - line.width) * alignmentFraction
            for (subview, size) in zip(line.subviews, line.sizes) {
                subview.place(
                    at: CGPoint(x: x, y: y + (line.height - size.height) / 2),
                    proposal: ProposedViewSize(width: min(size.width, bounds.width), height: size.height)
                )
                x += size.width + spacing
            }
            y += line.height + spacing
        }
    }

    /// How much of a line's free space goes before it.
    private var alignmentFraction: Double {
        switch alignment {
        case .center: 0.5
        case .trailing: 1
        default: 0
        }
    }

    private struct Line {
        var subviews: [LayoutSubview] = []
        var sizes: [CGSize] = []
        var width = 0.0
        var height = 0.0
    }

    private func lines(of subviews: Subviews, maxWidth: Double) -> [Line] {
        var lines: [Line] = []
        var line = Line()
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if !line.subviews.isEmpty && line.width + spacing + size.width > maxWidth {
                lines.append(line)
                line = Line()
            }
            line.width += (line.subviews.isEmpty ? 0 : spacing) + size.width
            line.height = max(line.height, size.height)
            line.subviews.append(subview)
            line.sizes.append(size)
        }
        if !line.subviews.isEmpty {
            lines.append(line)
        }
        return lines
    }
}

#Preview {
    FlowLayout {
        ForEach(["Premium brand", "5 seats", "4 suitcases", "Automatic", "Electric"], id: \.self) { text in
            Text(text)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(.quaternary, in: .capsule)
        }
    }
    .frame(width: 240)
    .border(.red)
}
