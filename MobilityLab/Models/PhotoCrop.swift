import SwiftUI

/// Which part of a photo stays visible when it's cropped to fit its frame.
nonisolated enum PhotoCrop: String, Codable {
    case top, center, bottom

    var alignment: Alignment {
        switch self {
        case .top: .top
        case .center: .center
        case .bottom: .bottom
        }
    }
}
