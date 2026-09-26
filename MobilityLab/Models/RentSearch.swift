import Foundation
import Observation

/// What the customer is searching for on the Rent tab: vehicle type, stations, dates, and driver age.
@Observable
final class RentSearch {
    /// Driver ages to pick from. The last one stands for "30 and older".
    static let driverAges = 18...30

    static func ageLabel(_ age: Int) -> String {
        age == driverAges.upperBound ? "\(age)+" : "\(age)"
    }

    var vehicleType = VehicleType.cars
    var pickUpStation: Station
    var returnStation: Station?
    var pickUpDate: Date {
        didSet {
            if dropOffDate <= pickUpDate {
                dropOffDate = Calendar.current.date(byAdding: .day, value: 3, to: pickUpDate) ?? pickUpDate
            }
        }
    }
    var dropOffDate: Date
    var driverAge = driverAges.upperBound
    private(set) var recentStations: [Station]

    /// Starts tomorrow at 10:00 and ends three days later at 12:00, like the Figma design.
    init(catalog: StationCatalog = MockData.stations, now: Date = .now, calendar: Calendar = .current) {
        pickUpStation = catalog.requiredStation(id: catalog.defaultPickUpStationID)
        recentStations = catalog.recentStationIDs.compactMap(catalog.station(id:))

        let tomorrow = calendar.date(byAdding: .day, value: 1, to: now) ?? now
        let pickUp = calendar.date(bySettingHour: 10, minute: 0, second: 0, of: tomorrow) ?? tomorrow
        let dropOffDay = calendar.date(byAdding: .day, value: 3, to: pickUp) ?? pickUp
        pickUpDate = pickUp
        dropOffDate = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: dropOffDay) ?? dropOffDay
    }

    /// Moves a picked station to the top of the search history.
    func remember(_ station: Station) {
        recentStations.removeAll { $0 == station }
        recentStations.insert(station, at: 0)
        recentStations = Array(recentStations.prefix(5))
    }
}
