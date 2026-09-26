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
| 1. Rent tab (done) | Rent Tab - Cars `7:15284`, Rent Tab - Trucks `59:29784`, Location Picker Sheet - Not in Focus `14:20196`, Focus `9:19554`, Typing `9:19926`, No Results `29:21969`, Station Details Sheet `59:29781`, Login Sheet `9:16635`, Settings Sheet `9:18529`, Date and time - Pickers `31:22061`, Age Picker Sheet `19:20835` (replaced by a menu) | `RentView`, `SearchCard`, `LocationPicker`, `StationDetailView`, `PromoCard`, `PromotionDetailView`, `LoginView`, `SettingsView` |
| 2. Offer list | Offer List View - Cars `79:32084`, Trucks `79:32512`, Offer Card - Car: Similar `77:31681`, Premium `65:31254`, Guaranteed `77:31815`, Offer Card - Truck `77:31919`, Filter Sheet - Cars `79:33528`, Trucks `81:33989`, IBE Sheet - Cars `79:32085`, Trucks `79:32513`, Menu `81:34349` | `OfferListView` (placeholder today) |
| 3. Offer details | Offer Detail View - Car `142:38463`, Truck `142:38464`, Price Details Sheet `142:38456`, Payment Option Detail Sheet `142:38455` | |
| 4. Protection and add-ons | Protection View - No Selection `142:38452`, Selected `142:38453`, Protection Detail Sheet `142:38454`, Addons View - No Selection `172:4743`, With Expanded Details `172:4744`, Selected `172:4745` | |
| 5. Review and book | Review And Book View - Empty `172:4746`, Value Entered `172:4747`, Booking Overview Sheet `172:4748`, Add Payment Sheet - Credit Card `172:4749`, Apple Pay `172:4750`, PayPal `172:4751`, Edit Invoice Address Sheet `172:4884` | |
| 6. Polish | Everything above, with notes collected while clicking through | |

## Figma to SwiftUI decisions

- Colors: hex values typed in Figma become system colors (`#000000` is `.primary`). Only the accent color is custom.
- Search card: `secondarySystemBackground` for the card and `tertiarySystemBackground` for its rows. The grouped colors turn black on black in dark mode outside a sheet.
- Login copies the Health app's inverted look: white sheet, gray text field.
- Native pickers over designed sheets:
  - Driver age is a `Menu` with a `Picker`, because the search card shows the pop-up glyph (⌃⌄). The Age Picker Sheet is gone.
  - Appearance, currency, and country use `.pickerStyle(.navigationLink)`.
- Naming: views are named after what they are, not how they're shown (`LocationPicker`, not `LocationPickerSheet`). Figma's "IBE" is `SearchCard`.
- Screens without a design (Help center, About this App, Create account, Offers) open `PlaceholderView`.
- Station details: one shared text for every station, in `station-details.json`. Only name, address, and opening hours differ.
- Dates follow the device's region, so the simulator may show "27 Sep 2026, 10:00" where Figma shows "Sep 10, 2026, 10:00 AM".

## SwiftUI details that took a try or two

- Hero under the toolbar: the `ScrollView` ignores the top safe area and uses `.scrollEdgeEffectStyle(.soft, for: .top)`. Without the soft style, iOS draws a hard edge.
- Hero framing: `AsyncImage` doesn't pass custom alignment guides through, so the photo is moved with `.visualEffect` and an offset from its own height.
- The logo toolbar item uses `.sharedBackgroundVisibility(.hidden)` to drop its glass circle.
- Close buttons are `Button(role: .close)` in a `.cancellationAction` toolbar item.
- Bordered buttons: tinting them changes the fill too. Keep the default fill and set `.foregroundStyle(.primary)` for black text.
- Lists tint `Label` icons with the accent color. Set `.foregroundStyle(.primary)` on the label, or `.tint(.primary)` on the list and `.tint(Color(.accent))` on any toggle inside it.
- A list row with two tap targets: the main button uses `.buttonStyle(.plain)` and the secondary one `.buttonStyle(.borderless)`.
- Button labels center wrapped text. Add `.multilineTextAlignment(.leading)` for multi-line rows.
- Known quirk: after Appearance goes from Dark back to System, an open sheet stays dark until it's reopened.

## Photos

- Remote only. Photo URLs live in the mock data; the Figma photos are not shipped.
- `img.sixt.com` serves each photo at several widths: `/600/`, `/1200/`, `/1600/`, `/3200/`. Use the smallest that's sharp on a 3× screen: `/1600/` for full-width heroes, `/1200/` for cards.
- `img.sixt.com` rejects curl's default user agent with a 403. Pass a browser user agent (`-A "Mozilla/5.0 …"`) to inspect a photo; the app itself loads fine.
- Figma's image links expire after 7 days. Never use them in mock data.
- The Cars hero is a BMW X5 instead of Figma's Z4, by choice. Hero framing is `zoom` and `focusY` in `rent-home.json`; card crops are `imageCrop`.

## Mock data from p100

- Source: `~/Projects/p100-booking-lab/data/*.js` (ES modules). Export one to JSON with `node --input-type=module -e "import * as m from './stations.js'; console.log(JSON.stringify(m))"`, then reshape with `jq`.
- Ported so far:
  - Stations: 97 from p100, plus Munich Laim and Munich Pasing from Figma. Each has an English `city` for grouping.
  - Countries: 70 codes.
  - Currencies: 98 codes and rates. XCG was removed because iOS 26.0 can't name it.
- Next to port:
  - `offers.js` and `profiles.js`: each station points to a profile whose quotas pick the offer mix.
  - `protection.js`, `add-ons.js`, `payment-methods.js`, `booking-disclosures.js`.
  - The pricing formulas are in `prototype/docs/pricing.md`.
- Prices stay in USD and are converted for display with the rate of the currency picked in Settings.

## Simulator and tests

- Build and look: iPhone 18 Pro Max on iOS 27.
- Test on the iOS 26.0 simulator (iPhone 17 Pro Max) to cover the minimum version. The tests caught the XCG problem there.
- Simulator tool quirks:
  - Instant taps don't flip iOS 26 switches, so drag them with `touch_path`.
  - `inspect` may be unavailable, so use screenshots.
  - To reset saved settings, run `xcrun simctl uninstall <device> com.hermanhaidin.mobilitylab`.

## Open questions

- What happens after "Book"? There's no confirmation screen yet.
- Logged-in state: Continue on the login sheet only closes it.
- What Trips, Share, Ride, and Subscribe should show beyond a placeholder.

## Guesses to confirm

- "Show all SIXT services" hides Share, Ride, and Subscribe when it's off.
- "Use my current location" picks Munich Central Train Station.
- Settings row icons were matched by eye.
- Continue stays disabled until an email is typed. The Figma frame shows it enabled.
