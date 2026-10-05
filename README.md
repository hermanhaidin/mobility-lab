# Mobility Lab

A prototyping environment for the SIXT iOS app, built for people who don't write code.

A SIXT product owner describes a change in plain words. Claude builds it into a high-fidelity SwiftUI mock of the SIXT app and shows it in the iOS Simulator. When the idea works, the prototype goes to engineers as a ZIP file.

- **Native, not a replica.** Stock SwiftUI throughout: tab bars, toolbars, sheets, lists, forms, Liquid Glass. SIXT orange is the only custom style.
- **Fake backend.** Stations, offers, and prices come from JSON files in the repo. No servers, no accounts.
- **Nothing to install but Xcode.** No dependencies, no packages.
- **Made for Claude Code.** [CLAUDE.md](CLAUDE.md) tells Claude how to work with someone who has never seen Swift.

**Status:** early. The Rent tab works up to the offer details: search, station picker, station details, login, settings, the cars and trucks each station offers, with sorting and filters, and each offer's specs, payment options, mileage packages, and price details. The rest of the Rent funnel is next: protection, add-ons, and booking.

Mobility Lab is an independent project, not an official SIXT product. See [License](#license).

---

## Build a prototype

This part is for SIXT product owners and managers. You don't need to know how to code.

### What you need

- A Mac.
- **Xcode**, free from the Mac App Store. It's a big download, so start early. Use the regular version, not a beta.
- The **Claude** desktop app, signed in with your SIXT account.

You don't need an Apple Developer account or a GitHub account.

### First time only

Open Xcode once. Agree to the terms, and when it asks which platforms to install, include **iOS**. Wait for the download to finish, then quit Xcode. You won't need to open it again.

### Start a prototype

1. [Download Mobility Lab](https://github.com/hermanhaidin/mobility-lab/archive/refs/heads/main.zip) and unzip it.
2. Rename the folder after your experiment, for example `mobility-lab-early-bird-banner`, and move it to where you keep your work.
3. Open the Claude app, go to **Code**, and select that folder.
4. Type: **Show me the app.**

The app opens on a simulated iPhone next to the chat. Describe what you want to change the way you'd describe it to a designer.

### Things you can say

| Say | What happens |
|---|---|
| Show me the app. | Claude builds the prototype and opens it in the simulator. |
| Move the price under the car name. | Claude changes the screen and shows you the result. |
| Add a station in Lisbon with three SUVs. | Claude adds it to the fake backend. |
| Package this for handoff. | Claude puts a ZIP of your prototype on your Desktop. |
| Help me put this on my iPhone. | Claude walks you through it. |

### One copy per experiment

Each prototype starts from a fresh download, so you always get the latest version. If an experiment gets messy, download again and start over.

### Hand off to engineers

Say **Package this for handoff.** Claude puts a ZIP on your Desktop with the prototype and a short note on what you changed. Send it in Slack or Teams with a screen recording. The engineer unzips it and runs it. No accounts needed.

### Show it on a real iPhone

Not needed for a screenshare demo, but possible. It needs your Apple ID, and without a paid Apple Developer account the app stops working after seven days. Ask Claude: **Help me put this on my iPhone.**

---

## For engineers

Open `MobilityLab.xcodeproj` and run the `MobilityLab` scheme. No setup, no packages.

- iOS 26, Swift 6 with MainActor default isolation, iPhone only.
- SwiftUI and Observation. UIKit only where SwiftUI has no stock equivalent.
- One folder per tab under `MobilityLab/`. Folders are synced, so new files need no project file changes.
- No server calls. Data comes from JSON files in `MobilityLab/MockData`; images load from URLs on SIXT's servers.
- `MobilityLabTests` checks the JSON files. Run the tests after editing them.

[CLAUDE.md](CLAUDE.md) has the full conventions. Point your own Claude at the folder and it will follow them.

## Use as a template

With a GitHub account, click **Use this template** to get your own copy with branches and pull requests. This repository doesn't take pull requests.

## License

[PolyForm Noncommercial 1.0.0](LICENSE.md), plus a permanent permission for SIXT to use it internally and reuse its code in SIXT's own apps. The SIXT name, logo, and photos belong to SIXT SE and aren't covered by the license.
