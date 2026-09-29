import SwiftUI
import SwiftData

@main
struct WildTraceApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var appModel: AppModel
    private let modelContainer: ModelContainer

    init() {
        let schema = Schema([
            Tour.self, TrackPoint.self, Taxon.self, RecordedObservation.self,
            Detection.self, Encounter.self, WeatherSnapshot.self,
            HabitatSnapshot.self, TaxonProfile.self, AudioStorageRule.self,
            ExternalObservationRecord.self, ExplorationCell.self
        ])
        do {
            let container = try ModelContainer(for: schema)
            self.modelContainer = container
            _appModel = StateObject(wrappedValue: AppModel(modelContainer: container))
        } catch {
            fatalError("WildTrace storage could not be created: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(appModel)
                .environmentObject(appModel.tourTracker)
                .environmentObject(appModel.locationService)
        }
        .modelContainer(modelContainer)
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase != .active { appModel.tourTracker.save() }
        }
    }
}
