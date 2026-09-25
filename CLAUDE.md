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
- No network calls, except loading images from URLs. Don't add photos to the project unless the person asks for a custom image.
- One type per file, named after the type. Every view file ends with a `#Preview`.
- Write the minimum code the request needs, and touch only what the change needs.

## Project layout

- `MobilityLab.xcodeproj`: folders are synced, so new files are picked up automatically. Don't edit `project.pbxproj` unless there's no other way.
- `MobilityLab/ContentView.swift`: the five-tab shell (Rent, Trips, Share, Ride, Subscribe).
- `MobilityLab/<Tab>/`: one folder per tab. A tab's screens go in its folder.
- `MobilityLab/Assets.xcassets`: the accent color.
- `MobilityLab/AppIcon.icon`: the app icon, made in Icon Composer.

The current scope lives in the README's **Status** line. Update it when the scope changes.

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
