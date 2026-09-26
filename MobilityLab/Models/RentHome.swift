import Foundation

/// Content for the Rent tab's home screen. Loaded from `rent-home.json`.
nonisolated struct RentHome: Codable {
    let carsHero: HeroImage
    let trucksHero: HeroImage
    let promotions: [Promotion]

    func hero(for vehicleType: VehicleType) -> HeroImage {
        switch vehicleType {
        case .cars: carsHero
        case .trucks: trucksHero
        }
    }
}
