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
| 3. Offer details (done) | Offer Detail View - Car `142:38463`, Truck `142:38464`, Price Details Sheet `142:38456`, Payment Option Detail Sheet `142:38455` | `OfferDetailView`, `ChoiceCard`, `PriceDetailView`, `PaymentOptionDetailView` |
| 4. Protection and add-ons | Protection View - No Selection `142:38452`, Selected `142:38453`, Protection Detail Sheet `142:38454`, Addons View - No Selection `172:4743`, With Expanded Details `172:4744`, Selected `172:4745` | |
| 5. Review and book | Review And Book View - Empty `172:4746`, Value Entered `172:4747`, Booking Overview Sheet `172:4748`, Add Payment Sheet - Credit Card `172:4749`, Apple Pay `172:4750`, PayPal `172:4751`, Edit Invoice Address Sheet `172:4884` | |
| 6. Polish | Everything above, with notes collected while clicking through | |

## Figma to SwiftUI decisions

- Colors: hex values typed in Figma become system colors (`#000000` is `.primary`). Only the accent color is custom.
- Rent tab: a stock inset-grouped `List` with `.listSectionSpacing(.compact)` over the hero photo, like Figma's List View frame and Health's Summary tab. Four sections: the search rows (the Cars/Trucks control with the separator under it hidden, then the shared station, dates, and driver age rows), Search offers as a `.glassProminent` button that fills its row, Recommended for you with `.headerProminence(.increased)` and one `PromoCard` row per promotion, and Login or register. The list picks `secondarySystemGroupedBackground` cells on `systemGroupedBackground` by itself, so dark mode comes out right without the custom colors the old search card needed.
- Login copies the Health app's inverted look: white sheet, gray text field.
- Native pickers over designed sheets:
  - Driver age is a `Picker` with `.pickerStyle(.menu)` in a list row (`DriverAgeRow`), which shows the value with the pop-up glyph (⌃⌄) like Figma. The Age Picker Sheet is gone.
  - Appearance uses `.pickerStyle(.navigationLink)`. Currency and country use `SearchablePicker`: a `NavigationLink` row (`LabeledContent` with the picked title) to a `List` with `.searchable`, since a navigation-link picker can't take a search field. It matches the shown text or the code, so "USD" finds US Dollar, and pops back on a pick. An option can carry an emoji icon, like a country's flag; the settings row shows it in front of the title ("🇺🇦 Ukraine"). The list is a private view in the same file, so `dismiss` pops it rather than Settings, and the query starts empty each time. Its search field takes focus on appear, like the station picker's.
- Naming: views are named after what they are, not how they're shown (`LocationPicker`, not `LocationPickerSheet`). Figma's "IBE" is the first section of `RentView`'s list.
- Screens without a design (Help center, About this App, Create account, vehicle dimensions, protection) open `PlaceholderView`.
- Station details: one shared text for every station, in `station-details.json`. Only name, address, and opening hours differ.
- Dates follow the device's region, so the simulator may show "27 Sep 2026, 10:00" where Figma shows "Sep 10, 2026, 10:00 AM". Prices and distances too: "71,56 US$" and "1 200 kilometers" in a Ukrainian region.
- Offer list: a full-screen cover, since Figma closes it with ✕ and has no tab bar. Offer details push onto its stack.
- Figma's "IBE Sheet" is `SearchEditor`, laid out like a new event in Calendar: ✕, a Cars/Trucks control across the toolbar, and a checkmark (`Button(role: .confirm)`) instead of Search offers. Below is a `Form` with `.listSectionSpacing(.compact)` and four sections, headed like Calendar's: Location, Dates, Details (driver age), and an unheaded "Login or register". Rows are stock `Button(_:systemImage:)` and `Label`s at the Form's own sizes and weights; bold station names were tried and dropped. Icons keep the list's default size and take their row's text color (`.foregroundStyle(.primary)` or `.secondary`), so Login or register is the one orange row. Calendar's gray icons were tried and dropped. Both station rows have an info button for station details, copied from the info buttons in Health's Apps section. It's `StationDetailsButton`, also used in the station picker's search results: `info.circle.fill` in `.font(.title2)` with `.foregroundStyle(.primary, .quaternary)`, a black "i" on a light gray circle. A picked return station goes back to the pickup station with "Same as pickup" (`arrow.uturn.backward`), which takes the place of "Use my current location" in the Return location picker, from the Rent tab too. A swipe action to remove it was dropped: the row slid away as if deleted, then the placeholder row appeared. Driver age keeps `.tint(.secondary)`, or its value turns orange. The sheet opens at `.medium` and drags up to `.large`, with the drag indicator hidden. It has an opaque grouped background, like Figma's IBE sheet, instead of a medium sheet's default glass: `.presentationBackground(Color(.systemGroupedBackground))`.
- The dates start as one summary row, like a new event in Calendar: a calendar icon and the range without the year ("29 Sep at 10:00 – 2 Oct at 12:00"), so it fits one line. Tapping it swaps in the Pick-up and Drop-off pickers for the rest of the sheet. With the year, it wrapped on a Pro Max.
- `SearchEditor` edits a copy of the search: the checkmark turns on once something changes and applies it, and ✕ throws it away. The Rent tab and the sheet share their rows, so they can't drift: `StationRows` (pick-up and return station; it opens the station picker and station details itself), `DateRows`, and `DriverAgeRow`. Each takes a `RentSearch`: the live one on the Rent tab, the draft in the sheet. The Cars/Trucks control and Login or register stay in each screen: one sits in the sheet's toolbar, the other toggles each screen's own state.
- Quick filters are `Toggle`s with `.toggleStyle(.button)` and share their state with the filter sheet. Selected ones turn orange; Figma only shows them off. They scroll away with the offers; only ✕, the search summary, and the filter button stay pinned. Changing a filter scrolls back to the top anyway. No divider after "Sort by": every chip is 8 points apart.
- The quick filters are the filter sheet's Features, in the same order; the model labels have shorter chip titles ("Premium" and "Guaranteed"). The chips and the sheet show only what at least one of the station's offers has (`OfferFeature.filters(for:in:)`, and the sheet's body styles and seat counts), so no option leads to an empty list. Changing the station drops the filters it has no offers for (`OfferFilter.removeUnavailable(in:)`), so a filter that's no longer shown can't keep offers out.
- "No matching offers" is a `ContentUnavailableView` with the filter button's `line.3.horizontal.decrease`, and Clear filters as a large `.glass` button sized to its label.
- Sort is a `Menu` with a `Picker`: Lowest price (the default) and Highest price, like Figma. No "Recommended" order for now.
- The filter sheet edits a draft; Show N offers applies it. Its driver age is the search's, so it also changes the Rent tab. Clear keeps the age.
- Trucks list only the minimum ages they need, like "18+", since other ages change nothing. The options come from `minDriverAge` in `offers.json`. Picking the one already shown keeps the search's age.
- Minimum seats starts at 4 and means 4 or more, like the SIXT app, which has no "any". So the 2-seat Mercedes-AMG GT 63 only shows up if the filter is dropped. Offers without a seat count, like trucks, aren't filtered by seats.
- Filters combine like in p100: any of the selected body styles, any of Premium brand and Guaranteed model, and all other features.
- Offer cards are always dark (`.environment(\.colorScheme, .dark)`). The glow is an `EllipticalGradient` from the top-trailing corner: the accent for premium brands, `.brown` for guaranteed models (Figma's #B78A66 is close), and `.blue` for electric trucks.
- The search summary in the toolbar sizes to its content, with both lines centered and without Figma's chevron. Figma stretches it between the buttons. The first line is `.subheadline` semibold, a smaller take on an inline navigation title (`.headline` looked too big), and reads "Munich Airport – Munich Central Train Station" when the return station differs. Long pairs grow the summary to the buttons and cut off at the end.
- Spec chips (`SpecChip`, a `Label` in a glass capsule as tall as the model label) wrap with `FlowLayout`, the one custom layout, since SwiftUI has none.
  - Cars: model, seats, suitcases, transmission, and range for electric cars.
  - Trucks: model, range for electric trucks, gross weight, payload, and license, like Figma. Transmission and equipment stay in `offers.json` for the offer details.
  - Range uses `battery.100percent.bolt`.
- Offer details (`OfferDetailView`) is a `ScrollView`, not a `List`: Figma's choice cards sit on a white page.
  - The top is the offer card's look, always dark: `OfferBackdrop` (the studio photo and glow, shared with `OfferCard`), the photo at 752 × 500, `ModelLabelButton` (also shared), and the specs as plain `Label`s without capsules, centered in `FlowLayout(alignment: .center)`. `Label` keeps its own icon spacing, a little wider than Figma's 4 points.
  - Electric vehicles get an untinted "Electric" `SpecChip` (`bolt.fill`) on the model label's line, with no info button.
  - Specs show what `offers.json` has. Figma's truck seats, Euro pallets, and dimensions aren't in the data, so they're left out, and "Show vehicle dimensions" opens `PlaceholderView`. Cars: "5 People", "5 Doors" (`car.window.right`, like Figma), "4 Large bags", transmission, range or Hybrid. Trucks: payload, gross weight, license, transmission, range, and equipment (tachograph, trailer hitch, tail lift). Both end with "Cables included" (`powercord.fill`) for electric vehicles, then "Age of the youngest driver: 21".
  - The truck weights keep the offer cards' symbols, by choice: `truck.box.fill` for payload, like Figma's details frame, and `scalemass.fill` for gross weight. Swapping them was considered.
  - "Unlimited kilometers available" is a green strip under the top, on offers with a kilometer limit that an upgrade lifts, which are cars with 1,200 km.
  - Payment option and Mileage package are `ChoiceCard`s, Figma's cards, asked for since iOS has no stock control like them: a `.plain` button with a 2-point accent border and `checkmark.circle.fill` when picked, a 1-point border and `circle` otherwise, on `secondarySystemGroupedBackground` so the cards stand out in dark mode. Title and subtitle are 2 points apart. The unpicked border is `systemGray2`: iOS has only two separator colors, and `opaqueSeparator`, the stronger one, was too faint on the white page (`tertiaryLabel` comes out the same).
  - Picking a card draws its checkmark on, like the Light and Dark choices in Settings › Display & Brightness: one `Image` whose name switches from `circle` to `checkmark.circle.fill`, with `.contentTransition(.symbolEffect(.replace))`. The replace fills the circle and draws the checkmark, checked frame by frame in a recording. Two images in an `if` just swap. The replace keeps the outgoing symbol's colors, so an unpicked card's checkmark would draw off on an orange fill: `showsCheckmark` follows `isSelected` one update late when a card is unpicked (a `Task` in `onChange`), so the fill turns gray first and the checkmark draws off in gray.
  - The headers match a prominent list header, measured: UIKit's `prominentInsetGroupedHeader()` is emphasized Title 3, SF Semibold 20, with no text transform, and the Rent tab's `.headerProminence(.increased)` header renders at the same width. So they're `.title3` semibold, which scales with Dynamic Type, 14 points above, lined up with the card text. "Need help?" is an underlined `.subheadline` medium button in `.primary`.
  - The total is a plain button in the toolbar's trailing slot, which gives it the glass capsule; it opens `PriceDetailView`. It sat in the footer with a chevron at first. Its digits roll to a new total: `.contentTransition(.numericText(value:))` with `.animation(_:value:)` on the label's `Text`, which works inside a toolbar item.
  - The title is the default `.inline` one: centered when it fits, and next to the back button, cut off before the price, when it doesn't ("Mercedes-Benz Atego 1…"). `.toolbarTitleDisplayMode(.inlineLarge)` would always lead, but falls back to a large title below the bar when there's a back button, as UIKit's header for `LargeTitleDisplayMode.inline` says. A `Text` in a `.topBarLeading` item cut "VW Golf" to "VW…", and with `.fixedSize()` a long name pushed the price into the overflow menu.
  - Continue fills a `.safeAreaBar` at the bottom, like the filter sheet's, so the soft scroll edge runs under it: a `.glassProminent` `NavigationLink` with `.buttonSizing(.flexible)`, `.controlSize(.large)`, and `.medium` weight, to `PlaceholderView` for protection. It sits 36 points from the sides and from the bottom (8 above, 2 below plus the 34-point home indicator inset), so the capsule's ends follow the display's corners.
  - `Booking` (`@Observable`, like `RentSearch`) holds the offer, the rental days, and the picked payment option and mileage package, and adds up the charges. It starts with the options that cost nothing extra, so the total matches the offer card's. Stage 4 extends it.
- Price details (`PriceDetailView`) is a stock inset-grouped `List`: "Rental charges" with one `LabeledContent` per charge, and a total row in semibold. Section headers already come out in sentence case, like Figma's. Taxes and fees aren't in the prototype, so Figma's "Taxes and fees" section is left out; the total keeps Figma's "(incl. tax)".
- Payment option help (`PaymentOptionDetailView`) is a sheet with ✕ and no title, like Figma. Bullets are an `HStack` of "•" and the text, since SwiftUI has no list style for them. The texts are `details` and `detailBullets` in `offers.json`.

## SwiftUI details that took a try or two

- Hero behind the `List`: `HeroBackdrop` hides the list's own background (`.scrollContentBackground(.hidden)`), draws its hero view behind it with `.background(alignment: .top)`, puts `systemGroupedBackground` behind that, and only then `.ignoresSafeArea(edges: .top)`. With `ignoresSafeArea` before the backgrounds, the photo starts under the toolbar with a white band above it. `.contentMargins(.top, 250, for: .scrollContent)` starts the rows over the photo's lower part, and `.scrollEdgeEffectStyle(.soft, for: .top)` keeps the toolbar edge soft. The photo isn't a row: as a row it can't run under the first section, and a bounce showed a gap above it. `listSectionMargins(.horizontal, 0)` for a full-bleed hero row was tried and dropped for the same reason.
- The photo scrolls away with the rows through `.onScrollGeometryChange`, the only way: the background is outside the scroll content, so `.visualEffect` and `.scrollTransition` never see it move. The tracked value is `contentOffset.y + contentInsets.top`, clamped to 0…538, so nothing changes while the list bounces (the photo stays pinned) or once the photo is gone. The state lives in `HeroBackdrop`, so a scroll frame re-runs only its body; `RentView` and its list don't re-run, checked with `Self._printChanges()`. `HeroPhoto` is its own view for the same reason: its `HeroImage` input doesn't change while scrolling.
- Cars/Trucks cross-fade: `RentView` keeps both `HeroPhoto`s in a `ZStack` and animates their opacity. One `AsyncImage` with a changing URL reloads through its placeholder, and its frame animates to the new zoom and focus at the same time, which showed as a blurry gray flash of about nine frames.
- Hero framing: `AsyncImage` doesn't pass custom alignment guides through, so the photo is moved with `.visualEffect` and an offset from its own height. The closure is `@Sendable`, so the constants it reads are `nonisolated static let`.
- The SIXT logo isn't a toolbar item: it's `HeroBackdrop`'s badge, so it scrolls away with the photo and stays pinned on a bounce, while the account button stays in the toolbar. The badge is an overlay on the list, not part of the hero: the toolbar's soft scroll edge effect is a backdrop blur, and it blurred the logo when it sat behind the list with the photo. Its row copies the toolbar's: 44 points tall under the status bar (`safeAreaInsets.top` of the `NavigationStack`, measured with `onGeometryChange`) and 20 points from the leading edge. When it was a toolbar item, `.sharedBackgroundVisibility(.hidden)` dropped its glass circle.
- The logo is two template SVGs, `SixtWordmark` and `SixtSwoosh`, with the same view box, stacked by `SixtLogo`. The swoosh takes `Color.accentColor`, the letters the surrounding foreground style. One template image can only be one color.
- Close buttons are `Button(role: .close)` in a `.cancellationAction` toolbar item. Sheets without a title put it in a `.topBarTrailing` item instead, like Figma's payment option sheet and title-less sheets in iOS.
- Bordered buttons: tinting them changes the fill too. Keep the default fill and set `.foregroundStyle(.primary)` for black text.
- Lists tint `Label` icons with the accent color. Set `.foregroundStyle(.primary)` on the label, or `.listItemTint(.primary)` on the section. It's a row trait: on the list itself it does nothing. Settings first used `.tint(.primary)` on the list, which also reached the Appearance picker's pushed list and turned its checkmark black; iOS pickers keep the tint for the checkmark. Toggles need `.tint(Color(.accent))` either way, or they're green.
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
- Pulling offer details down past the top grows the dark backdrop instead of showing white above it: a `.visualEffect` on `OfferBackdrop` scales it from its bottom edge by how far the top is pulled (`frame(in: .scrollView).minY`), so it always reaches the screen's top edge. The photo and specs move down as usual.
- Offer details' dark top runs under the status bar and toolbar. A background inside scroll content can't reach into the safe area (`.ignoresSafeArea` on it does nothing), so the `ScrollView` itself ignores the top safe area, and the photo is pushed down by the top inset, measured with `onGeometryChange` on the scroll view.
- While the photo is behind the toolbar, the toolbar is dark (`.toolbarColorScheme(.dark, for: .navigationBar)`, for a white title) and the soft edge is hidden (`.scrollEdgeEffectHidden(true, for: .top)`), or it fogs the dark backdrop white. Once the photo has scrolled away, both go back to standard, tracked with `onScrollGeometryChange`. Keeping the dark toolbar for the whole dark top ran the specs into the title, with nothing between them.
- `OfferBackdrop` clips itself: the filled studio photo spilled over its frame on the offer details, where nothing else clips it.
- `AttributedString(localized: "^[\(n) Rental Day](inflect: true)")` inflects in model code too, so `Booking` can name its charges.
- A `List` button shows its label in the tint, so `SearchablePicker`'s rows set `.foregroundStyle(.primary)` on the button. The checkmark is `.foregroundStyle(.tint)` in `.semibold`, which matches the stock picker's. Country rows are `Label`s with the flag as a `Text` icon, so the separators start at the name like rows with symbol icons; one `Text` with the flag in front ran them to the edge.

## Photos

- Remote only. Photo URLs live in the mock data; the Figma photos are not shipped.
- `img.sixt.com` serves each photo at several widths: `/600/`, `/1200/`, `/1600/`, `/3200/`. Use the smallest that's sharp on a 3× screen: `/1600/` for full-width heroes, `/1200/` for cards.
- `img.sixt.com` rejects curl's default user agent with a 403. Pass a browser user agent (`-A "Mozilla/5.0 …"`) to inspect a photo; the app itself loads fine.
- Figma's image links expire after 7 days. Never use them in mock data.
- The Cars hero is a BMW X5 instead of Figma's Z4, by choice. Hero framing is `zoom` and `focusY` in `rent-home.json`; card crops are `imageCrop`.
- Vehicle photos: transparent PNGs on sixt.com.
  - Cars use `/fileadmin2/files/global/sideview/user_upload/fleet/png/752x500/`, like p100. Every car has one, and it fills the 752 × 500 frame of the cards and the offer details with less empty space around the car than the `1050x600/` versions.
  - Trucks use `/fileadmin2/files/global/user_upload/fleet/png/1050x600/`, three-quarter views like Figma's truck frame. The frame is filled, so their empty sides are cut off; no vehicle reaches into the cut. Their `752x500/` versions under `sideview/` are side profiles, and four trucks (the Sprinter and Daily Luton boxes, the Eurocargo, and the Atego) have none, so trucks stay as they are.
- The studio backdrop behind every card is `cardBackdropURL` in `offers.json`.
- Photos show as SIXT serves them. Figma's photos have contrast and highlights adjusted; the app doesn't do that on purpose.

## Mock data from p100

- Source: `~/Projects/p100-booking-lab/data/*.js` (ES modules). Export one to JSON with `node --input-type=module -e "import * as m from './stations.js'; console.log(JSON.stringify(m))"`, then reshape with `jq`.
- Ported so far:
  - Stations: 97 from p100, plus Munich Laim and Munich Pasing from Figma. Each has an English `city` for grouping.
  - Countries: 70 codes.
  - Currencies: 98 codes and rates. XCG was removed because iOS 26.0 can't name it.
  - Offers: all 75 cars. `badges`, `subtitle`, the offer list banner, and the home carousel aren't ported, since no screen shows them. Neither is `totalPrice`: it's the daily price times the rental days, and days are the rental time rounded to whole days, like in p100.
  - Trucks: p100 has none. The 14 trucks, their photos, prices, specs, and equipment come from sixt.com, collected by Herman. Equipment: `tachograph`, `trailerHitch`, `tailLift`, and `chargingCable` for "cables included". Tail lift and cables show on the offer details but aren't filtered.
  - Every electric car has `chargingCable` too, since every electric vehicle comes with cables. A test checks it.
  - Doors: Herman gave them for 13 cars; the rest follow the same logic. Two for coupes and convertibles, four for sedans with a trunk and four-door coupes (Taycan, CLA, M235 Gran Coupe), and five for anything with a tailgate or sliding doors. The two mystery cars have no body style, so they have no doors either.
  - Profiles: all 7, with truck quotas added. Small train stations have no trucks. Every station has a `profileID`: p100's, or `small-train` for Munich Laim and Pasing.
  - Payment options: p100's "Best price" and "Stay flexible", with Figma's titles and texts. Stay flexible adds 5% of the daily price, like p100. The help texts are Figma's; p100 has them only in its design-system demo.
  - Mileage: p100 shows the included kilometers and nothing to pick. Our upgrades build on the data: cars with 1,200 km can add Unlimited, trucks with 200 km can go to 400 or 600 km, and offers with unlimited kilometers have only that. An extra kilometer costs 0.5% of the daily price, from `pricing.md`.
- Next to port:
  - `protection.js`, `add-ons.js`, `payment-methods.js`, `booking-disclosures.js`.
  - The rest of the pricing formulas in `prototype/docs/pricing.md`.
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
- Taxes and fees in the price details: where the rates come from, and whether the offer card's price includes them.
- Truck seats, Euro pallets, and vehicle dimensions: values for `offers.json`, and a design for the dimensions.

## Guesses to confirm

- The mileage upgrade surcharges: Unlimited for cars adds 10% of the daily price, 200 more km for trucks 10%, and 400 more 18%.
- The "Unlimited kilometers available" strip shows only on offers that can upgrade to unlimited. Cars that include unlimited kilometers don't get it.
- The AdBlue note shows under trucks that aren't electric, and keeps Figma's "€0.04" whatever currency is picked.
- The tail lift symbol (`arrow.up.and.down.square.fill`) was matched by eye.
- "Show all SIXT services" hides Share, Ride, and Subscribe when it's off.
- "Use my current location" picks Munich Central Train Station.
- Settings row icons were matched by eye.
- Continue stays disabled until an email is typed. The Figma frame shows it enabled.
- Each profile's truck quotas are made up.
- Herman's equipment list calls the Eurocargo "7.49t"; its specs say 7.5 t and 7 500 kg, which the app shows.
