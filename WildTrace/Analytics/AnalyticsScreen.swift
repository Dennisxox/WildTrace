import SwiftUI

struct AnalyticsScreen: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView("Statistik", systemImage: "chart.bar",
                                   description: Text("Auswertungen werden auf Encounters und Tourdaten aufgebaut."))
                .navigationTitle("Statistik")
        }
    }
}
