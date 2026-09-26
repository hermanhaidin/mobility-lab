import SwiftUI

@main
struct MobilityLabApp: App {
    init() {
        // Photos load from SIXT's servers. A larger cache keeps scrolling smooth and avoids loading them twice.
        URLCache.shared = URLCache(memoryCapacity: 50_000_000, diskCapacity: 200_000_000)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
