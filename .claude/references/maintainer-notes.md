# Maintainer notes

For the people building Mobility Lab from the Figma designs, and their Claude sessions. Managers and product owners never need this file.

## Figma

- File: https://www.figma.com/design/gKdsTHQVBD7BX0hCGxHlfi/SwiftUI-Rent, one page, "Rent" (`0:1`).
- Built with Apple's iOS and iPadOS 27 UI Kit, with some values overridden by hand. Treat kit components (Toolbar, Tab Bar, Row, Segmented Control, Date and time, Button - Liquid Glass) as the system controls they stand for.
- Before reading frames, load the `figma-swiftui` and `figma-design-to-code` skills. Call `get_design_context` with `clientLanguages: swift` and `clientFrameworks: swiftui`.
- `get_design_context` sometimes answers with a Code Connect prompt instead of the design. Call it again with `disableCodeConnect: false`.
- Kit `Row` instances hide their SF Symbol names. When the output doesn't name a symbol, match it by eye and check the name exists in `/System/Library/CoreServices/CoreGlyphs.bundle/Contents/Resources/name_availability.plist`.
- Frames are 440 × 956, the same as the iPhone 18 Pro Max simulator, so screenshots compare 1:1.

## Frames by stage

| Stage | Frames (node ID) | Views |
|---|---|---|
| 1. Rent tab (done) | Rent Tab - Cars - List View `235:7848` (the current layout; it replaced Rent Tab - Cars `7:15284` and Trucks `59:29784`), Location Picker Sheet - Not in Focus `14:20196`, Focus `9:19554`, Typing `9:19926`, No Results `29:21969`, Station Details Sheet `59:29781`, Login Sheet `9:16635`, Settings Sheet `9:18529`, Date and time - Pickers `31:22061`, Age Picker Sheet `19:20835` (replaced by a menu) | `RentView`, `HeroBackdrop`, `HeroPhoto`, `StationRows`, `DateRows`, `DriverAgeRow`, `LocationPicker`, `StationDetailView`, `PromoCard`, `PromotionDetailView`, `LoginView`, `SettingsView` |
| 2. Offer list (done) | Offer List View - Cars `79:32084`, Trucks `79:32512`, Offer Card - Car: Similar `77:31681`, Premium `65:31254`, Guaranteed `77:31815`, Offer Card - Truck `77:31919`, Filter Sheet - Cars `79:33528`, Trucks `81:33989`, IBE Sheet - Cars `79:32085`, Trucks `79:32513`, Menu `81:34349` | `OfferListView`, `OfferCard`, `OfferFilterView`, `SearchEditor` |
| 3. Offer details | Offer Detail View - Car `142:38463`, Truck `142:38464`, Price Details Sheet `142:38456`, Payment Option Detail Sheet `142:38455` | |
| 4. Protection and add-ons | Protection View - No Selection `142:38452`, Selected `142:38453`, Protection Detail Sheet `142:38454`, Addons View - No Selection `172:4743`, With Expanded Details `172:4744`, Selected `172:4745` | |
| 5. Review and book | Review And Book View - Empty `172:4746`, Value Entered `172:4747`, Booking Overview Sheet `172:4748`, Add Payment Sheet - Credit Card `172:4749`, Apple Pay `172:4750`, PayPal `172:4751`, Edit Invoice Address Sheet `172:4884` | |
| 6. Polish | Everything above, with notes collected while clicking through | |

## Figma to SwiftUI decisions

- Colors: hex values typed in Figma become system colors (`#000000` is `.primary`). Only the accent color is custom.
- Rent tab: a stock inset-grouped `List` with `.listSectionSpacing(.compact)` over the hero photo, like Figma's List View frame and Health's Summary tab. Four sections: the search rows (the Cars/Trucks control with the separator under it hidden, then the shared station, dates, and driver age rows), Search offers as a `.glassProminent` button that fills its row, Recommended for you with `.headerProminence(.increased)` and one `PromoCard` row per promotion, and Login or register. The list picks `secondarySystemGroupedBackground` cells on `systemGroupedBackground` by itself, so dark mode comes out right without the custom colors the old search card needed.
- Login copies the Health app's inverted look: white sheet, gray text field.
- Native pickers over designed sheets:
  - Driver age is a `Picker` with `.pickerStyle(.menu)` in a list row (`DriverAgeRow`), which shows the value with the pop-up glyph (⌃⌄) like Figma. The Age Picker Sheet is gone.
  - Appearance uses `.pickerStyle(.navigationLink)`. Currency and country use `SearchablePicker`: a `NavigationLink` row (`LabeledContent` with the picked title) to a `List` with `.searchable`, since a navigation-link picker can't take a search field. It matches the shown text or the code, so "USD" finds US Dollar, and pops back on a pick. The list is a private view in the same file, so `dismiss` pops it rather than Settings, and the query starts empty each time. Its search field takes focus on appear, like the station picker's.
- Naming: views are named after what they are, not how they're shown (`LocationPicker`, not `LocationPickerSheet`). Figma's "IBE" is the first section of `RentView`'s list.
- Screens without a design (Help center, About this App, Create account, offer details) open `PlaceholderView`.
- Station details: one shared text for every station, in `station-details.json`. Only name, address, and opening hours differ.
- Dates follow the device's region, so the simulator may show "27 Sep 2026, 10:00" where Figma shows "Sep 10, 2026, 10:00 AM". Prices and distances too: "71,56 US$" and "1 200 kilometers" in a Ukrainian region.
- Offer list: a full-screen cover, since Figma closes it with ✕ and has no tab bar. Offer details (stage 3) will push onto its stack; for now a card opens `PlaceholderView`.
- Figma's "IBE Sheet" is `SearchEditor`, laid out like a new event in Calendar: ✕, a Cars/Trucks control across the toolbar, and a checkmark (`Button(role: .confirm)`) instead of Search offers. Below is a `Form` with `.listSectionSpacing(.compact)` and four sections, headed like Calendar's: Location, Dates, Details (driver age), and an unheaded "Login or register". Rows are stock `Button(_:systemImage:)` and `Label`s at the Form's own sizes and weights; bold station names were tried and dropped. Icons keep the list's default size and take their row's text color (`.foregroundStyle(.primary)` or `.secondary`), so Login or register is the one orange row. Calendar's gray icons were tried and dropped. Both station rows have an info button for station details, copied from the info buttons in Health's Apps section. It's `StationDetailsButton`, also used in the station picker's search results: `info.circle.fill` in `.font(.title2)` with `.foregroundStyle(.primary, .quaternary)`, a black "i" on a light gray circle. A picked return station goes back to the pickup station with "Same as pickup" (`arrow.uturn.backward`), which takes the place of "Use my current location" in the Return location picker, from the Rent tab too. A swipe action to remove it was dropped: the row slid away as if deleted, then the placeholder row appeared. Driver age keeps `.tint(.secondary)`, or its value turns orange. The sheet opens at `.medium` and drags up to `.large`, with the drag indicator hidden. It has an opaque grouped background, like Figma's IBE sheet, instead of a medium sheet's default glass: `.presentationBackground(Color(.systemGroupedBackground))`.
- The dates start as one summary row, like a new event in Calendar: a calendar icon and the range without the year ("29 Sep at 10:00 – 2 Oct at 12:00"), so it fits one line. Tapping it swaps in the Pick-up and Drop-off pickers for the rest of the sheet. With the year, it wrapped on a Pro Max.
- `SearchEditor` edits a copy of the search: the checkmark turns on once something changes and applies it, and ✕ throws it away. The Rent tab and the sheet share their rows, so they can't drift: `StationRows` (pick-up and return station; it opens the station picker and station details itself), `DateRows`, and `DriverAgeRow`. Each takes a `RentSearch`: the live one on the Rent tab, the draft in the sheet. The Cars/Trucks control and Login or register stay in each screen: one sits in the sheet's toolbar, the other toggles each screen's own state.
- Quick filters are `Toggle`s with `.toggleStyle(.button)` and share their state with the filter sheet. Selected ones turn orange; Figma only shows them off. They scroll away with the offers; only ✕, the search summary, and the filter button stay pinned. Changing a filter scrolls back to the top anyway. No divider after "Sort by": every chip is 8 points apart.
- Sort is a `Menu` with a `Picker`: Lowest price (the default) and Highest price, like Figma. No "Recommended" order for now.
- The filter sheet edits a draft; Show N offers applies it. Its driver age is the search's, so it also changes the Rent tab. Clear keeps the age.
- Trucks list only the minimum ages they need, like "18+", since other ages change nothing. The options come from `minDriverAge` in `offers.json`. Picking the one already shown keeps the search's age.
- Minimum seats starts at 4 and means 4 or more, like the SIXT app, which has no "any". So the 2-seat Mercedes-AMG GT 63 only shows up if the filter is dropped. Offers without a seat count, like trucks, aren't filtered by seats.
- Filters combine like in p100: any of the selected body styles, any of Premium brand and Guaranteed model, and all other features.
- Offer cards are always dark (`.environment(\.colorScheme, .dark)`). The glow is an `EllipticalGradient` from the top-trailing corner: the accent for premium brands, `.brown` for guaranteed models (Figma's #B78A66 is close), and `.blue` for electric trucks.
- The search summary in the toolbar sizes to its content, with both lines centered and without Figma's chevron. Figma stretches it between the buttons. The first line is `.subheadline` semibold, a smaller take on an inline navigation title (`.headline` looked too big), and reads "Munich Airport – Munich Central Train Station" when the return station differs. Long pairs grow the summary to the buttons and cut off at the end.
- Spec chips wrap with `FlowLayout`, the one custom layout, since SwiftUI has none.
  - Cars: model, seats, suitcases, transmission, and range for electric cars.
  - Trucks: model, range for electric trucks, gross weight, payload, and license, like Figma. Transmission and equipment stay in `offers.json` for the offer details.
  - Range uses `battery.100percent.bolt`.

## SwiftUI details that took a try or two

- Hero behind the `List`: `HeroBackdrop` hides the list's own background (`.scrollContentBackground(.hidden)`), draws its hero view behind it with `.background(alignment: .top)`, puts `systemGroupedBackground` behind that, and only then `.ignoresSafeArea(edges: .top)`. With `ignoresSafeArea` before the backgrounds, the photo starts under the toolbar with a white band above it. `.contentMargins(.top, 250, for: .scrollContent)` starts the rows over the photo's lower part, and `.scrollEdgeEffectStyle(.soft, for: .top)` keeps the toolbar edge soft. The photo isn't a row: as a row it can't run under the first section, and a bounce showed a gap above it. `listSectionMargins(.horizontal, 0)` for a full-bleed hero row was tried and dropped for the same reason.
- The photo scrolls away with the rows through `.onScrollGeometryChange`, the only way: the background is outside the scroll content, so `.visualEffect` and `.scrollTransition` never see it move. The tracked value is `contentOffset.y + contentInsets.top`, clamped to 0…538, so nothing changes while the list bounces (the photo stays pinned) or once the photo is gone. The state lives in `HeroBackdrop`, so a scroll frame re-runs only its body; `RentView` and its list don't re-run, checked with `Self._printChanges()`. `HeroPhoto` is its own view for the same reason: its `HeroImage` input doesn't change while scrolling.
- Cars/Trucks cross-fade: `RentView` keeps both `HeroPhoto`s in a `ZStack` and animates their opacity. One `AsyncImage` with a changing URL reloads through its placeholder, and its frame animates to the new zoom and focus at the same time, which showed as a blurry gray flash of about nine frames.
- Hero framing: `AsyncImage` doesn't pass custom alignment guides through, so the photo is moved with `.visualEffect` and an offset from its own height. The closure is `@Sendable`, so the constants it reads are `nonisolated static let`.
- The SIXT logo isn't a toolbar item: it's `HeroBackdrop`'s badge, so it scrolls away with the photo and stays pinned on a bounce, while the account button stays in the toolbar. The badge is an overlay on the list, not part of the hero: the toolbar's soft scroll edge effect is a backdrop blur, and it blurred the logo when it sat behind the list with the photo. Its row copies the toolbar's: 44 points tall under the status bar (`safeAreaInsets.top` of the `NavigationStack`, measured with `onGeometryChange`) and 20 points from the leading edge. When it was a toolbar item, `.sharedBackgroundVisibility(.hidden)` dropped its glass circle.
- The logo is two template SVGs, `SixtWordmark` and `SixtSwoosh`, with the same view box, stacked by `SixtLogo`. The swoosh takes `Color.accentColor`, the letters the surrounding foreground style. One template image can only be one color.
- Close buttons are `Button(role: .close)` in a `.cancellationAction` toolbar item.
- Bordered buttons: tinting them changes the fill too. Keep the default fill and set `.foregroundStyle(.primary)` for black text.
- Lists tint `Label` icons with the accent color. Set `.foregroundStyle(.primary)` on the label, or `.tint(.primary)` on the list and `.tint(Color(.accent))` on any toggle inside it.
- A list row with two tap targets: the main button keeps the default style, so the whole row taps and highlights, and the secondary one uses `.buttonStyle(.borderless)`. A `.plain` main button taps only on its label; `.contentShape` outside the button doesn't widen it.
- In a Form, a button's `.tint` colors its text but not its `Label` icon, and `.tint(.secondary)` left the text black. `.listItemTint` colors the icon; `.foregroundStyle` colors both.
- `.foregroundStyle(.primary)` goes on the button, not inside its label: inside, `.primary` resolves against the button's tint and stays orange. `PromoCard` learned it.
- A row view that emits several rows attaches its `.sheet(item:)` to one of them: `StationRows` uses the pick-up row. On the whole body, every row gets its own presenter for the same state, and iOS refuses the second sheet.
- A glass button as a whole list row: `.listRowInsets(EdgeInsets())` and `.listRowBackground(Color.clear)`. The capsule then spans the section's inset width, like Figma's 52-point orange row.
- `.listRowSeparator(.hidden, edges: .bottom)` hides only the line under a row; the default `.all` also hides the one above.
- `.headerProminence(.increased)` on a `Section` shows the header as bold title text in sentence case, like Health's "Pinned"; a standard grouped header is small and uppercased.
- A row with zero insets clips its content to the cell's rounded corners: `PromoCard`'s photo needs no `clipShape`.
- Form `Label` icons render at `.imageScale(.large)`, about 21 points next to body text; Calendar's are about 17. `.font(.body)` and `.imageScale` on the row or button change nothing. Only `.imageScale(.medium)` on the icon's `Image` shrinks it, which needs `Label { } icon: { }`. The sheet keeps the default size on purpose.
- Button labels center wrapped text. Add `.multilineTextAlignment(.leading)` for multi-line rows.
- iOS 26 switches are green unless tinted. The filter sheet tints each toggle with the accent, and the form with `.secondary` so its menu pickers show gray values.
- Sheets opened from a glass sheet inherit its `backgroundMaterial`, so bordered buttons in them lose their fill. An opaque `presentationBackground` avoids it; otherwise reset it with `.environment(\.backgroundMaterial, nil)` on the sheet's content.
- In a `Form`, compact `DatePicker` rows are 63 points tall and text rows 50. The date and time pills are about 35 points, with the Form's 14 points above and below. Calendar (UIKit) uses the same pills with 9 points, so its date rows are 53. `.listRowInsets(.vertical, 9)` (iOS 26) would match it; not done.
- Toolbar title items get only the width they ask for. None of these stretch them: `.frame(maxWidth: .infinity)`, `.buttonSizing(.flexible)` on the picker or the whole toolbar, or the `.title` placement. `.containerRelativeFrame` hides them. `SearchEditor` measures the sheet and gives its Cars/Trucks control the space between the buttons.
- Health's info button, measured in the simulator: 22.3 points across, circle RGB 227, 227, 228 on white, and a black "i". `.quaternary` gives exactly that circle; `.fill` is lighter (233) and `.tertiary` darker. `.title2` semibold lands at 21.7 points and matches the "i" weight; regular weight looks thin next to it, but the sheet uses it by choice. Two foreground styles switch the symbol to palette rendering on their own.
- Fitting a sheet to a `Form` was tried and dropped. Measuring the form's frame just returns the sheet's height, since a form fills it. `onScrollGeometryChange` works: content height plus the top inset (the toolbar) as a `.height` detent. The bottom inset is better left out, since the form's bottom margin already clears the home indicator. But when rows appear, the sheet jumps to its new height instead of animating. `withAnimation` on the detents, animating a `selection` binding, and changing the selection one update later all jumped. Recordings showed the sheet's top edge moving 77 points in one frame.
- The simulator tool's launch installs the app; `simctl launch` reruns whatever was installed last. After building, launch through the tool, or you'll look at an old build.
- `.badge()` works on toolbar buttons: the filter button shows how many filters are on.
- A button inside a `NavigationLink` card works in a `ScrollView`: the model label's info button opens its popover without opening the offer. The popover needs `.presentationCompactAdaptation(.popover)` on iPhone.
- `.safeAreaBar` holds the filter sheet's Show offers button, so the soft scroll edge runs under it.
- Known quirk: after Appearance goes from Dark back to System, an open sheet stays dark until it's reopened.
- The station picker's search field takes focus with the sheet: `.searchFocused($isSearchFocused)` (iOS 18) and `isSearchFocused = true` in `.onAppear`. `.defaultFocus($isSearchFocused, true)` did nothing. In an iOS 26 sheet the field sits at the bottom, and an active search hides the title and ✕ unless `.searchPresentationToolbarBehavior(.avoidHidingContent)` is set. After a city's station list pops, the keyboard comes back with the query on its own: the system restores the active search, not `onAppear` (it happened with `onAppear` on the `NavigationStack` too).
- `.tint(.primary)` on the settings list doesn't reach a `NavigationLink` destination: `SearchablePicker`'s rows came out orange, and so did a checkmark with `.foregroundStyle(.tint)`. The stock Appearance picker's pushed list is black. The rows set `.foregroundStyle(.primary)` on the button, and the checkmark inherits it.

## Photos

- Remote only. Photo URLs live in the mock data; the Figma photos are not shipped.
- `img.sixt.com` serves each photo at several widths: `/600/`, `/1200/`, `/1600/`, `/3200/`. Use the smallest that's sharp on a 3× screen: `/1600/` for full-width heroes, `/1200/` for cards.
- `img.sixt.com` rejects curl's default user agent with a 403. Pass a browser user agent (`-A "Mozilla/5.0 …"`) to inspect a photo; the app itself loads fine.
- Figma's image links expire after 7 days. Never use them in mock data.
- The Cars hero is a BMW X5 instead of Figma's Z4, by choice. Hero framing is `zoom` and `focusY` in `rent-home.json`; card crops are `imageCrop`.
- Vehicle photos: transparent PNGs on sixt.com at `/fileadmin2/files/global/.../fleet/png/1050x600/`. Cars are under `sideview/user_upload/`, trucks under `user_upload/`. p100 uses the softer `752x500/` car photos.
- Offer cards frame a photo like Figma: 752 × 500, filled, so the empty sides of the 1050 × 600 photos are cut off. No vehicle reaches into the cut.
- The studio backdrop behind every card is `cardBackdropURL` in `offers.json`.
- Photos show as SIXT serves them. Figma's photos have contrast and highlights adjusted; the app doesn't do that on purpose.

## Mock data from p100

- Source: `~/Projects/p100-booking-lab/data/*.js` (ES modules). Export one to JSON with `node --input-type=module -e "import * as m from './stations.js'; console.log(JSON.stringify(m))"`, then reshape with `jq`.
- Ported so far:
  - Stations: 97 from p100, plus Munich Laim and Munich Pasing from Figma. Each has an English `city` for grouping.
  - Countries: 70 codes.
  - Currencies: 98 codes and rates. XCG was removed because iOS 26.0 can't name it.
  - Offers: all 75 cars. `badges`, `subtitle`, the offer list banner, and the home carousel aren't ported, since no screen shows them. Neither is `totalPrice`: it's the daily price times the rental days, and days are the rental time rounded to whole days, like in p100.
  - Trucks: p100 has none. The 14 trucks, their photos, prices, specs, and equipment come from sixt.com, collected by Herman. Equipment: `tachograph`, `trailerHitch`, `tailLift`, and `chargingCable` for "cables included". Tail lift and cables aren't shown or filtered yet.
  - The trucks filter's Minibus finds nothing, since no truck is a minibus.
  - Profiles: all 7, with truck quotas added. Small train stations have no trucks. Every station has a `profileID`: p100's, or `small-train` for Munich Laim and Pasing.
- Next to port:
  - `protection.js`, `add-ons.js`, `payment-methods.js`, `booking-disclosures.js`.
  - The pricing formulas are in `prototype/docs/pricing.md`.
- Prices stay in USD and are converted for display with the rate of the currency picked in Settings.

## Simulator and tests

- Build and look: iPhone 18 Pro Max on iOS 27.
- Test on the iOS 26.0 simulator (iPhone 17 Pro Max) to cover the minimum version. The tests caught the XCG problem there.
- Simulator tool quirks:
  - Instant taps don't flip iOS 26 switches, so drag them with `touch_path`.
  - `inspect` may be unavailable, so use screenshots.
  - Screenshots of the iPhone 18 Pro Max are 921 × 2000 pixels for 440 × 956 points. Divide pixel positions by 2.09 to tap; dividing by 2 lands about 40 points low at the bottom of the screen.
  - To reset saved settings, run `xcrun simctl uninstall <device> com.hermanhaidin.mobilitylab`.
  - The saved Appearance setting beats `xcrun simctl ui <device> appearance dark`. Check dark mode through the app's Settings › Appearance, or edit `appearance` in the app's container plist (`xcrun simctl get_app_container <device> com.hermanhaidin.mobilitylab data`, then `Library/Preferences/com.hermanhaidin.mobilitylab.plist`) with `plutil -replace` while the app is terminated. `simctl spawn … defaults write` lands in another domain and changes nothing.

## Git and GitHub

- Don't open pull requests: they're turned off on the GitHub repo (`has_pull_requests` is false). `gh pr create` fails with a permissions error, and the pulls API answers 404 even with admin rights.
- Work on a branch, in atomic commits that each build. To land it, run the tests, fast-forward `main` to the branch with `git merge --ff-only`, and push `main`. History stays linear, with no merge commits.

## Open questions

- What happens after "Book"? There's no confirmation screen yet.
- Logged-in state: Continue on the login sheet only closes it.
- What Trips, Share, Ride, and Subscribe should show beyond a placeholder.

## Guesses to confirm

- "Show all SIXT services" hides Share, Ride, and Subscribe when it's off.
- "Use my current location" picks Munich Central Train Station.
- Settings row icons were matched by eye.
- Continue stays disabled until an email is typed. The Figma frame shows it enabled.
- The model label texts behind the info buttons are placeholders.
- Each profile's truck quotas are made up.
- Herman's equipment list calls the Eurocargo "7.49t"; its specs say 7.5 t and 7 500 kg, which the app shows.
