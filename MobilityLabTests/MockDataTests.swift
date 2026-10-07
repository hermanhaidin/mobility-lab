import Foundation
import Testing
import UIKit
@testable import MobilityLab

/// Checks the JSON files in `MockData`. When one of these fails, the message says which file and entry to fix.
struct MockDataTests {
    @Test(arguments: ["stations", "station-details", "rent-home", "countries", "currencies", "offers", "station-profiles", "protection", "add-ons", "payment-option-help", "protection-help"])
    func fileLoads(_ name: String) throws {
        switch name {
        case "stations": let _: StationCatalog = try MockData.load(name)
        case "station-details": let _: StationGuide = try MockData.load(name)
        case "rent-home": let _: RentHome = try MockData.load(name)
        case "countries": let _: [String] = try MockData.load(name)
        case "currencies": let _: [Currency] = try MockData.load(name)
        case "offers": let _: OfferCatalog = try MockData.load(name)
        case "station-profiles": let _: [String: StationProfile] = try MockData.load(name)
        case "protection": let _: ProtectionCatalog = try MockData.load(name)
        case "add-ons": let _: [AddOn] = try MockData.load(name)
        case "payment-option-help", "protection-help": let _: HelpArticle = try MockData.load(name)
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

    @Test(arguments: ["payment-option-help", "protection-help"])
    func helpArticlesHaveText(_ name: String) throws {
        let article: HelpArticle = try MockData.load(name)
        #expect(!article.title.isEmpty, "\(name).json needs a title")
        #expect(!article.sections.isEmpty, "\(name).json needs at least one section")
        for section in article.sections {
            #expect(!section.title.isEmpty && !section.text.isEmpty, "Every section in \(name).json needs a title and a text")
        }
    }

    // MARK: - Offers

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
                // Mystery cars have no body style, so their doors aren't known.
                if offer.bodyStyle != nil {
                    #expect(offer.doors != nil, "\(offer.name) in offers.json needs doors")
                }
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

    @Test func electricOffersComeWithCables() throws {
        let catalog: OfferCatalog = try MockData.load("offers")
        for offer in catalog.cars + catalog.trucks where offer.fuel == .electric {
            #expect(offer.equipment?.contains(.chargingCable) == true, "\(offer.name) in offers.json is electric, so its equipment needs \"chargingCable\"")
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
            #expect(!option.chargeTitle.isEmpty, "The \(option.title) payment option in offers.json needs a chargeTitle, its line in the price details")
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

    @Test func feesAreValid() throws {
        let catalog: OfferCatalog = try MockData.load("offers")
        let profiles: [String: StationProfile] = try MockData.load("station-profiles")
        for fee in catalog.fees {
            #expect(fee.rate > 0, "The \(fee.title) fee in offers.json needs a rate above zero")
            for id in fee.stationProfileIDs ?? [] {
                #expect(profiles[id] != nil, "The \(fee.title) fee in offers.json is charged at \"\(id)\" stations, but station-profiles.json has no such profile")
            }
        }
        let duplicates = Dictionary(grouping: catalog.fees, by: \.title).filter { $0.value.count > 1 }.keys
        #expect(duplicates.isEmpty, "offers.json has more than one fee titled \(duplicates.sorted())")
    }

    // MARK: - Protection

    @Test func protectionPackagesAreValid() throws {
        let catalog: ProtectionCatalog = try MockData.load("protection")
        let withoutSurcharge = catalog.packages.filter { $0.dailySurchargeRate == 0 }
        #expect(withoutSurcharge.count == 1, "protection.json needs exactly one package with a dailySurchargeRate of 0, \"No extra protection\". It has \(withoutSurcharge.count)")
        for package in catalog.packages {
            #expect(package.dailySurchargeRate >= 0, "\(package.title) in protection.json needs a dailySurchargeRate of 0 or more")
            #expect((0...3).contains(package.stars), "\(package.title) in protection.json needs from 0 to 3 stars")
            #expect((package.deductible ?? 0) >= 0, "\(package.title) in protection.json needs a deductible of 0 or more. Leave it out for the full vehicle value")
            // Only a package that covers something is charged and shows in the booking overview.
            #expect(package.coverage.isEmpty == (package.dailySurchargeRate == 0), "\(package.title) in protection.json needs coverage if it costs extra, and none if it doesn't")
        }
        let duplicates = Dictionary(grouping: catalog.packages, by: \.id).filter { $0.value.count > 1 }.keys
        #expect(duplicates.isEmpty, "protection.json has more than one package with the id \(duplicates.sorted())")
    }

    @Test func includedProtectionHasDetails() throws {
        let catalog: ProtectionCatalog = try MockData.load("protection")
        for item in catalog.included {
            #expect(!item.title.isEmpty && !item.details.isEmpty, "Every included protection in protection.json needs a title and details")
        }
    }

    // MARK: - Add-ons

    @Test func addOnsAreValid() throws {
        let addOns: [AddOn] = try MockData.load("add-ons")
        for addOn in addOns {
            #expect(!addOn.title.isEmpty && !addOn.details.isEmpty, "Every add-on in add-ons.json needs a title and details")
            #expect(addOn.price > 0, "\(addOn.title) in add-ons.json needs a price above zero")
            #expect(UIImage(systemName: addOn.systemImage) != nil, "\(addOn.title) in add-ons.json has the symbol \"\(addOn.systemImage)\", which isn't an SF Symbol")
            if let maxQuantity = addOn.maxQuantity {
                #expect(maxQuantity >= 2, "\(addOn.title) in add-ons.json has a maxQuantity of \(maxQuantity). Leave it out for an add-on that's picked or not")
            }
        }
        let duplicates = Dictionary(grouping: addOns, by: \.id).filter { $0.value.count > 1 }.keys
        #expect(duplicates.isEmpty, "add-ons.json has more than one add-on with the id \(duplicates.sorted())")
    }

    // MARK: - Station profiles

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
