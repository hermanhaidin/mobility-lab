import Foundation

/// Which station of a search the station picker is choosing.
nonisolated enum StationRole: Identifiable {
    case pickUp, `return`

    var id: Self { self }

    var title: String {
        switch self {
        case .pickUp: "Pickup location"
        case .return: "Return location"
        }
    }
}
