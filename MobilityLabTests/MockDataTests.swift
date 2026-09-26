import Foundation
import Testing
@testable import MobilityLab

/// Checks the JSON files in `MockData`. When one of these fails, the message says which file and entry to fix.
struct MockDataTests {
    @Test(arguments: ["stations", "station-details", "rent-home", "countries", "currencies"])
    func fileLoads(_ name: String) throws {
        switch name {
        case "stations": let _: StationCatalog = try MockData.load(name)
        case "station-details": let _: StationGuide = try MockData.load(name)
        case "rent-home": let _: RentHome = try MockData.load(name)
        case "countries": let _: [String] = try MockData.load(name)
        case "currencies": let _: [Currency] = try MockData.load(name)
        default: Issue.record("Add a check for \(name).json")
        }
    }

    @Test func stationIDsAreUnique() throws {
        let catalog: StationCatalog = try MockData.load("stations")
        let duplicates = Dictionary(grouping: catalog.stations, by: \.id).filter { $0.value.count > 1 }.keys
        #expect(duplicates.isEmpty, "stations.json has more than one station with the id \(duplicates.sorted())")
    }

    @Test func referencedStationsExist() throws {
        let catalog: StationCatalog = try MockData.load("stations")
        let referencedIDs = [catalog.defaultPickUpStationID, catalog.currentLocationStationID] + catalog.recentStationIDs
        for id in referencedIDs {
            #expect(catalog.station(id: id) != nil, "stations.json refers to \"\(id)\", which isn't in its station list")
        }
    }

    @Test func everyStationHasOpeningHours() throws {
        let catalog: StationCatalog = try MockData.load("stations")
        for station in catalog.stations {
            #expect(!station.openingHours.isEmpty, "\(station.name) in stations.json has no opening hours")
        }
    }

    @Test func countryCodesAreReal() throws {
        let codes: [String] = try MockData.load("countries")
        for code in codes {
            #expect(Locale.Region(code).isISORegion, "countries.json has \"\(code)\", which isn't a country code")
        }
    }

    @Test func currencyCodesAreReal() throws {
        let currencies: [Currency] = try MockData.load("currencies")
        for currency in currencies {
            #expect(Locale.Currency(currency.code).isISOCurrency, "currencies.json has \"\(currency.code)\", which isn't a currency code")
            #expect(currency.rate > 0, "\(currency.code) in currencies.json needs a rate above zero")
        }
    }
}
