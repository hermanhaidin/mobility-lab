import Foundation
import Testing
@testable import MobilityLab

/// Checks the JSON files in `MockData`. When one of these fails, the message says which file and entry to fix.
struct MockDataTests {
    @Test(arguments: ["stations", "station-details", "rent-home", "countries", "currencies", "offers", "station-profiles"])
    func fileLoads(_ name: String) throws {
        switch name {
        case "stations": let _: StationCatalog = try MockData.load(name)
        case "station-details": let _: StationGuide = try MockData.load(name)
        case "rent-home": let _: RentHome = try MockData.load(name)
        case "countries": let _: [String] = try MockData.load(name)
        case "currencies": let _: [Currency] = try MockData.load(name)
        case "offers": let _: OfferCatalog = try MockData.load(name)
        case "station-profiles": let _: [String: StationProfile] = try MockData.load(name)
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

    // MARK: - Offers and station profiles

    @Test func offerIDsAreUnique() throws {
        let catalog: OfferCatalog = try MockData.load("offers")
        let duplicates = Dictionary(grouping: catalog.cars + catalog.trucks, by: \.id).filter { $0.value.count > 1 }.keys
        #expect(duplicates.isEmpty, "offers.json has more than one offer with the id \(duplicates.sorted())")
    }

    @Test(arguments: VehicleType.allCases)
    func offersHaveTheSpecsTheirCardShows(_ vehicleType: VehicleType) throws {
        let catalog: OfferCatalog = try MockData.load("offers")
        for offer in catalog.offers(for: vehicleType) {
            #expect(offer.vehicleType == vehicleType, "\(offer.name) is under \(vehicleType.rawValue) in offers.json, but its body style \(offer.bodyStyle?.rawValue ?? "is missing")")
            switch vehicleType {
            case .cars:
                #expect(offer.seats != nil && offer.suitcases != nil, "\(offer.name) in offers.json needs seats and suitcases")
            case .trucks:
                #expect(offer.grossWeightKg != nil && offer.licenseClass != nil, "\(offer.name) in offers.json needs a gross weight and a license class")
            }
        }
    }

    @Test func offerPricesAndAgesAreValid() throws {
        let catalog: OfferCatalog = try MockData.load("offers")
        let ages = RentSearch.driverAges
        for offer in catalog.cars + catalog.trucks {
            #expect(offer.pricePerDay > 0, "\(offer.name) in offers.json needs a price above zero")
            #expect(ages.contains(offer.minDriverAge), "\(offer.name) in offers.json needs a minimum driver age from \(ages.lowerBound) to \(ages.upperBound)")
            if let includedKilometers = offer.includedKilometers {
                #expect(includedKilometers > 0, "\(offer.name) in offers.json includes \(includedKilometers) kilometers. Leave it out for unlimited kilometers")
            }
        }
    }

    @Test func everyModelLabelHasADescription() throws {
        let catalog: OfferCatalog = try MockData.load("offers")
        for model in Offer.Model.allCases {
            #expect(catalog.modelDescriptions[model]?.isEmpty == false, "offers.json needs a model description for \(model.rawValue)")
        }
    }

    @Test func paymentOptionsAreValid() throws {
        let catalog: OfferCatalog = try MockData.load("offers")
        let included = catalog.paymentOptions.filter { $0.dailySurchargeRate == 0 }
        #expect(included.count == 1, "offers.json needs exactly one payment option with a dailySurchargeRate of 0, picked first on the offer details. It has \(included.count)")
        for option in catalog.paymentOptions {
            #expect(option.dailySurchargeRate >= 0, "The \(option.title) payment option in offers.json needs a dailySurchargeRate of 0 or more")
        }
        let duplicates = Dictionary(grouping: catalog.paymentOptions, by: \.id).filter { $0.value.count > 1 }.keys
        #expect(duplicates.isEmpty, "offers.json has more than one payment option with the id \(duplicates.sorted())")
    }

    @Test(arguments: VehicleType.allCases)
    func mileageUpgradesAreValid(_ vehicleType: VehicleType) throws {
        let catalog: OfferCatalog = try MockData.load("offers")
        #expect(catalog.extraKilometerRate > 0, "offers.json needs an extraKilometerRate above zero")
        let upgrades = catalog.mileageUpgrades.upgrades(for: vehicleType)
        for upgrade in upgrades {
            #expect(upgrade.dailySurchargeRate > 0, "A \(vehicleType.rawValue) mileage upgrade in offers.json needs a dailySurchargeRate above zero")
            if let extraKilometers = upgrade.extraKilometers {
                #expect(extraKilometers > 0, "A \(vehicleType.rawValue) mileage upgrade in offers.json adds \(extraKilometers) kilometers. Leave extraKilometers out for unlimited kilometers")
            }
        }
        // Unlimited counts as the most kilometers.
        for (smaller, larger) in zip(upgrades, upgrades.dropFirst()) {
            #expect((smaller.extraKilometers ?? .max) < (larger.extraKilometers ?? .max), "The \(vehicleType.rawValue) mileage upgrades in offers.json need to go from fewest to most kilometers, with unlimited last")
            #expect(smaller.dailySurchargeRate < larger.dailySurchargeRate, "The \(vehicleType.rawValue) mileage upgrades in offers.json need to cost more as the kilometers go up")
        }
    }

    @Test func everyStationHasAKnownProfile() throws {
        let catalog: StationCatalog = try MockData.load("stations")
        let profiles: [String: StationProfile] = try MockData.load("station-profiles")
        for station in catalog.stations {
            #expect(profiles[station.profileID] != nil, "\(station.name) in stations.json has the profile \"\(station.profileID)\", which isn't in station-profiles.json")
        }
    }

    @Test(arguments: VehicleType.allCases)
    func profileCategoriesHaveOffers(_ vehicleType: VehicleType) throws {
        let catalog: OfferCatalog = try MockData.load("offers")
        let profiles: [String: StationProfile] = try MockData.load("station-profiles")
        let categories = Set(catalog.offers(for: vehicleType).map(\.category))
        for (id, profile) in profiles {
            for category in profile.quotas(for: vehicleType).keys {
                #expect(categories.contains(category), "The \(id) profile in station-profiles.json counts \"\(category)\" \(vehicleType.rawValue), but no offer in offers.json has that category")
            }
        }
    }

    @Test func everyStationHasCars() throws {
        let stations: StationCatalog = try MockData.load("stations")
        let catalog: OfferCatalog = try MockData.load("offers")
        let profiles: [String: StationProfile] = try MockData.load("station-profiles")
        for station in stations.stations {
            guard let profile = profiles[station.profileID] else { continue }
            #expect(!catalog.offers(for: .cars, profile: profile).isEmpty, "\(station.name) shows no cars. Give the \(station.profileID) profile in station-profiles.json some car quotas")
        }
    }
}
