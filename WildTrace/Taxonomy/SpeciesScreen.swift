import SwiftUI

struct SpeciesScreen: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView("Artenbibliothek", systemImage: "leaf",
                                   description: Text("Globale Artensuche und Offline-Profile folgen in Phase 2."))
                .navigationTitle("Arten")
        }
    }
}
