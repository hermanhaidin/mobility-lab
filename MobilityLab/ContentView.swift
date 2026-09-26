import SwiftUI

/// The app shell: the five tabs of the SIXT app's home screen.
struct ContentView: View {
    @AppStorage(SettingsKey.appearance) private var appearance = Appearance.system
    @AppStorage(SettingsKey.showsAllServices) private var showsAllServices = true

    var body: some View {
        TabView {
            Tab("Rent", systemImage: "car.fill") {
                RentView()
            }
            Tab("Trips", systemImage: "point.bottomleft.forward.to.point.topright.scurvepath.fill") {
                TripsView()
            }
            if showsAllServices {
                Tab("Share", systemImage: "key.fill") {
                    ShareView()
                }
                Tab("Ride", systemImage: "figure.seated.side.right") {
                    RideView()
                }
                Tab("Subscribe", systemImage: "car.badge.gearshape.fill") {
                    SubscribeView()
                }
            }
        }
        .preferredColorScheme(appearance.colorScheme)
    }
}

#Preview {
    ContentView()
}
