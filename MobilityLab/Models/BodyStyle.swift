import Foundation

/// The body styles customers can filter offers by, in the order the filter sheet lists them.
nonisolated enum BodyStyle: String, Codable, CaseIterable, Identifiable {
    case convertible, coupe, familyVan, sedan, stationWagon, suv
    case cargoVan, minibus, movingTruck

    var id: Self { self }

    var title: String {
        switch self {
        case .convertible: "Convertible"
        case .coupe: "Coupe"
        case .familyVan: "Family van"
        case .sedan: "Sedan"
        case .stationWagon: "Station wagon"
        case .suv: "SUV"
        case .cargoVan: "Cargo van"
        case .minibus: "Minibus"
        case .movingTruck: "Moving truck"
        }
    }

    var vehicleType: VehicleType {
        switch self {
        case .convertible, .coupe, .familyVan, .sedan, .stationWagon, .suv: .cars
        case .cargoVan, .minibus, .movingTruck: .trucks
        }
    }
}
