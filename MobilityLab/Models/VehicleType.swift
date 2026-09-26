import Foundation

/// The two things the Rent tab can search for.
nonisolated enum VehicleType: String, CaseIterable, Identifiable {
    case cars, trucks

    var id: Self { self }

    var title: String {
        switch self {
        case .cars: "Cars"
        case .trucks: "Trucks"
        }
    }
}
