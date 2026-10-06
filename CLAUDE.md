# Mobility Lab

A high-fidelity SwiftUI mock of the SIXT app. SIXT product owners use it to prototype ideas, then hand the result to engineers as a ZIP.

## Who you're working with

The person in this chat is most likely a product owner or manager, not a programmer. They know their product. They don't know Swift, Xcode, or git, and they should never need to.

- Talk about screens and behavior, never code. Say "The price now sits under the car name", not "Updated OfferCard.swift".
- Don't show code, diffs, file paths, or error messages unless they ask.
- Never ask them to run a command, open Xcode, or edit a file. You do all of that.
- After every change: build, run it in the simulator, look at the screen, then report. If the build fails, fix it before you reply.
- If a request is unclear, ask in product terms: "Should the banner show at every station, or only at airports?"
- If they ask for something a prototype can't do (real payments, real login, live data), say so plainly and offer the closest fake.

If the person is clearly an engineer (they talk about code or ask for diffs), work with them as you would with any engineer.

## What people say

- **"Show me the app"**: build the `MobilityLab` scheme and launch it in the simulator panel, using the desktop app's iOS Simulator tools (fall back to `xcodebuild` and `simctl`). Use the newest iPhone Pro Max simulator.
- **"Package this for handoff"**: follow [Handoff](#handoff).
- **"Help me put this on my iPhone"**: follow [Running on an iPhone](#running-on-an-iphone).
- **"Start over"**: point them to the download link in the README. Never delete their work.

## Design rules

1. Stock components first. If iOS provides it, use it: `TabView`, `NavigationStack`, `List`, `Form`, `Picker`, `DatePicker`, sheets, full-screen covers, toolbars, glass buttons.
2. System fonts and semantic colors only (`.body`, `.headline`, `.primary`, `.secondary`, …). The accent color, SIXT orange #FF5000, is the one custom style. It's set in the asset catalog, so never hard-code it.
3. Native over exact. A plausible native screen is more useful to an engineer than a pixel-perfect custom one.
4. If no stock component fits, say so and propose the closest stock option. Don't build a custom control without asking.
5. Icons come from SF Symbols. Check that a symbol name exists before using it.

## Code rules

- iOS 26 minimum. Use iOS 26 APIs only, with no `#available` checks.
- Swift 6, strict concurrency, MainActor by default.
- SwiftUI with Observation: `@Observable`, `@State`, `@Environment`. No `ObservableObject`. UIKit only where SwiftUI has no stock equivalent.
- No dependencies, no packages.
- No network calls, except loading photos (see [Fake backend](#fake-backend)).
- One type per file, named after the type. Every view file ends with a `#Preview`.
- Name views after what they are, not how they're shown: `LocationPicker`, not `LocationPickerSheet`.
- A screen or row without a design yet opens `PlaceholderView`.
- Write the minimum code the request needs, and touch only what the change needs.

## Project layout

- `MobilityLab.xcodeproj`: folders are synced, so new files are picked up automatically. Don't edit `project.pbxproj` unless there's no other way.
- `MobilityLab/ContentView.swift`: the tab shell (Rent, Trips, Share, Ride, Subscribe).
- `MobilityLab/Rent/`: the Rent tab: hero photo, search rows, location picker, station details, promotions, offers.
- `MobilityLab/Account/`: login and settings.
- `MobilityLab/Trips/`, `Share/`, `Ride/`, `Subscribe/`: placeholder tabs.
- `MobilityLab/Models/`: the data types, like `Station` and `RentSearch`.
- `MobilityLab/MockData/`: the fake backend, as JSON files. `Services/MockData.swift` loads them.
- `MobilityLab/Shared/`: views used across tabs, like `RemoteImage` and `PlaceholderView`.
- `MobilityLab/Assets.xcassets`: the accent color and the SIXT logo, as its wordmark and swoosh.
- `MobilityLab/AppIcon.icon`: the app icon, made in Icon Composer.
- `MobilityLabTests/`: checks that the fake backend is valid.

The current scope lives in the README's **Status** line. Update it when the scope changes.

## Fake backend

- Content lives in JSON files in `MobilityLab/MockData`. To change stations, promotions, or texts, edit the JSON, not the Swift code.
  - `stations.json`: every station, plus the default pick-up station, the "current location" station, and the starting search history.
  - `station-details.json`: the directions and return text all stations share.
  - `rent-home.json`: the Rent tab's hero photos and "Recommended for you" cards. `zoom` and `focusY` frame a hero photo; `imageCrop` (`top`, `center`, `bottom`) picks which part of a card photo stays visible.
  - `offers.json`: every car and truck, with its daily price in US dollars, plus the studio photo behind the offer cards and what each model label ("Guaranteed model") means, where `{name}` stands for the vehicle's name. It also holds what the offer details offer: the payment options ("Stay flexible"), the mileage upgrades for cars and trucks, and the price of an extra kilometer. Surcharges are a share of the daily price. `fees` are the price details' taxes and fees, each a share of the rental days' price, charged at the station profiles they list or, without a list, at every station. Charges in the price details are in Title Case, so a payment option's `chargeTitle` is "Stay Flexible" where its card says "Stay flexible". Prices show in the currency picked in Settings.
  - `protection.json`: the protection packages on the protection screen, with their stars, deductible in US dollars (0 for none, left out for the full vehicle value), surcharge, and what each covers, plus the protection every rental includes, like Third Party Insurance. "No extra protection" is the package without a surcharge.
  - `payment-option-help.json`, `protection-help.json`: the help behind each "Need help?", one file per screen.
  - `station-profiles.json`: how many offers of each category a kind of station shows. Each station in `stations.json` points to one with `profileID`. To change what a station offers, change its profile's numbers or point it to another profile.
  - `countries.json`, `currencies.json`: codes and exchange rates only.
- Get anything generic from the system instead of JSON: country and currency names, flags, and formatting for dates, money, and distances. Only SIXT-specific data belongs in JSON.
- Photos load from URLs on SIXT's servers through `RemoteImage`. Use `null` until there's a URL; the screen shows a placeholder. Only add a photo file to the project if the person asks for a custom image.

## Tests

- After changing anything in `MockData`, run the tests: `xcodebuild test -scheme MobilityLab -destination 'platform=iOS Simulator,name=<simulator>'`.
- If a test fails, fix the data and tell the person what was wrong in product terms ("Two stations had the same ID").
- If a test fails because the person deliberately changed a rule, update the test and mention the change in `HANDOFF.md`.

## Handoff

When asked to package the prototype:

1. If the folder name doesn't describe the prototype, ask for a short name.
2. Write `HANDOFF.md` at the project root for an engineer: what the prototype shows, which screens and data changed, what's faked, and what's unfinished. Plain bullets, one page at most.
3. Build once more to make sure it compiles.
4. Zip the folder to the Desktop without build output or personal settings:

   ```bash
   cd .. && zip -rq ~/Desktop/<name>-handoff-<yyyy-mm-dd>.zip "<folder>" -x "*/.DS_Store" "*/xcuserdata/*" "*/DerivedData/*" "*/build/*" "*/.build/*" "*/.claude/settings.local.json"
   ```

5. Tell them where the file is, and suggest sending it with a screen recording.

## Running on an iPhone

Optional, and not needed for a screenshare. Walk the person through it one step at a time:

- The iPhone must run iOS 26 or later, and connect to the Mac with a cable the first time.
- They sign in to Xcode with their Apple ID (Xcode › Settings › Apple Accounts). They type the password themselves. Never ask for it.
- Change the bundle ID to one unique to them, like `com.<name>.mobilitylab`, and select their personal team for signing.
- On the iPhone, they turn on Developer Mode and, after the first install, trust the developer in Settings.
- Without a paid Apple Developer account, the app stops working after seven days. Installing again fixes it.

## Git

If the folder is a git repository, write commit messages as imperative sentences in sentence case ("Add the offer list"). If it isn't, don't create one unless asked.

## Maintainers

Building new screens from the Figma designs? Read `.claude/references/maintainer-notes.md` first. Nobody else needs it.
