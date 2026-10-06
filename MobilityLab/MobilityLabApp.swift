import SwiftUI

@main
struct MobilityLabApp: App {
    init() {
        // Photos load from SIXT's servers. A larger cache keeps scrolling smooth and avoids loading them twice.
        URLCache.shared = URLCache(memoryCapacity: 50_000_000, diskCapacity: 200_000_000)
        // Pick-up and drop-off times go in 30-minute steps. SwiftUI's DatePicker has no minute interval.
        UIDatePicker.appearance().minuteInterval = 30
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
