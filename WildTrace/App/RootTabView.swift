import SwiftUI

struct RootTabView: View {
    @EnvironmentObject private var tracker: TourTrackingController

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView {
                MapScreen()
                    .tabItem { Label("Karte", systemImage: "map") }
                ToursScreen()
                    .tabItem { Label("Touren", systemImage: "figure.walk") }
                SpeciesScreen()
                    .tabItem { Label("Arten", systemImage: "leaf") }
                AnalyticsScreen()
                    .tabItem { Label("Statistik", systemImage: "chart.bar") }
                SettingsScreen()
                    .tabItem { Label("Einstellungen", systemImage: "gearshape") }
            }

            if tracker.activeTour != nil {
                ActiveTourBar()
                    .padding(.horizontal)
                    .padding(.bottom, 50)
            }
        }
    }
}
