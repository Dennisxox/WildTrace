import Foundation
import SwiftData
import Combine

@MainActor
final class AppModel: ObservableObject {
    let modelContainer: ModelContainer
    let locationService: CoreLocationTrackingService
    let tourTracker: TourTrackingController

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        let locationService = CoreLocationTrackingService()
        self.locationService = locationService
        self.tourTracker = TourTrackingController(
            modelContainer: modelContainer,
            locationService: locationService
        )
    }
}
