import SwiftUI

/// The app shell: the five tabs of the SIXT app's home screen.
struct ContentView: View {
    var body: some View {
        TabView {
            Tab("Rent", systemImage: "car.fill") {
                RentView()
            }
            Tab("Trips", systemImage: "point.bottomleft.forward.to.point.topright.scurvepath.fill") {
                TripsView()
            }
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
}

#Preview {
    ContentView()
}
