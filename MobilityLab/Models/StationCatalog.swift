import Foundation

/// Every station in the prototype, plus the ones the Rent tab starts with. Loaded from `stations.json`.
nonisolated struct StationCatalog: Codable {
    let defaultPickUpStationID: String
    /// The station "Use my current location" picks, since the prototype has no real location.
    let currentLocationStationID: String
    let recentStationIDs: [String]
    let stations: [Station]

    func station(id: String) -> Station? {
        stations.first { $0.id == id }
    }

    func requiredStation(id: String) -> Station {
        guard let station = station(id: id) else {
            fatalError("stations.json refers to \"\(id)\", which isn't in its station list.")
        }
        return station
    }
}
