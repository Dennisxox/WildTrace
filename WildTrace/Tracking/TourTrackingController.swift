import Foundation
import CoreLocation
import SwiftData
import Combine

@MainActor
final class TourTrackingController: ObservableObject {
    @Published private(set) var activeTour: Tour?
    @Published private(set) var elapsedSeconds: TimeInterval = 0
    @Published private(set) var lastErrorDescription: String?

    let locationService: CoreLocationTrackingService
    private let modelContext: ModelContext
    private var timer: Timer?
    private let maximumAcceptedAccuracy: CLLocationAccuracy = 100

    init(modelContainer: ModelContainer, locationService: CoreLocationTrackingService) {
        self.modelContext = ModelContext(modelContainer)
        self.locationService = locationService
        locationService.onLocationUpdate = { [weak self] locations in
            self?.receive(locations)
        }
        locationService.onError = { [weak self] error in
            self?.lastErrorDescription = error.localizedDescription
        }
        restoreActiveTourIfNeeded()
    }

    func startTour() {
        guard activeTour == nil else { return }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        let tour = Tour(name: "Tour \(formatter.string(from: .now))")
        modelContext.insert(tour)
        activeTour = tour
        elapsedSeconds = 0
        save()
        startTimer()
        locationService.startUpdatingLocation()
    }

    func endTour() {
        guard let tour = activeTour else { return }
        let end = Date.now
        tour.endedAt = end
        tour.durationSeconds = max(0, end.timeIntervalSince(tour.startedAt))
        tour.state = .finished
        locationService.stopUpdatingLocation()
        timer?.invalidate()
        timer = nil
        save()
        activeTour = nil
        elapsedSeconds = 0
    }

    func save() {
        do { try modelContext.save() }
        catch { lastErrorDescription = error.localizedDescription }
    }

    private func restoreActiveTourIfNeeded() {
        do {
            var descriptor = FetchDescriptor<Tour>(sortBy: [SortDescriptor(\.startedAt, order: .reverse)])
            descriptor.fetchLimit = 1
            if let tour = try modelContext.fetch(descriptor).first, tour.state == .recording {
                activeTour = tour
                elapsedSeconds = max(0, Date.now.timeIntervalSince(tour.startedAt))
                startTimer()
                locationService.startUpdatingLocation()
            }
        } catch {
            lastErrorDescription = error.localizedDescription
        }
    }

    private func receive(_ locations: [CLLocation]) {
        guard let tour = activeTour else { return }
        for location in locations.sorted(by: { $0.timestamp < $1.timestamp }) {
            guard location.horizontalAccuracy >= 0,
                  location.horizontalAccuracy <= maximumAcceptedAccuracy,
                  abs(location.timestamp.timeIntervalSinceNow) <= 15 else { continue }

            let last = tour.trackPoints.max(by: { $0.timestamp < $1.timestamp })
            if let last, location.timestamp <= last.timestamp { continue }

            let point = TrackPoint(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude,
                altitude: location.altitude,
                timestamp: location.timestamp,
                horizontalAccuracy: location.horizontalAccuracy,
                verticalAccuracy: location.verticalAccuracy,
                speed: location.speed,
                course: location.course
            )
            modelContext.insert(point)
            tour.trackPoints.append(point)

            if let last {
                let previous = CLLocation(latitude: last.latitude, longitude: last.longitude)
                let segment = location.distance(from: previous)
                if segment.isFinite, segment < 1_000 { tour.distanceMeters += segment }
            }
        }
        tour.durationSeconds = max(0, Date.now.timeIntervalSince(tour.startedAt))
        save()
    }

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self, let tour = self.activeTour else { return }
                self.elapsedSeconds = max(0, Date.now.timeIntervalSince(tour.startedAt))
            }
        }
    }
}
