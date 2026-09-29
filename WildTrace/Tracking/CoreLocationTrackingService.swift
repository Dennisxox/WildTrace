import CoreLocation
import Combine

@MainActor
final class CoreLocationTrackingService: NSObject, ObservableObject, LocationTrackingProviding {
    @Published private(set) var authorizationStatus: CLAuthorizationStatus
    @Published private(set) var accuracyAuthorization: CLAccuracyAuthorization
    @Published private(set) var latestLocation: CLLocation?
    @Published private(set) var isUpdatingLocation = false
    @Published private(set) var lastErrorDescription: String?

    var onLocationUpdate: (([CLLocation]) -> Void)?
    var onError: ((Error) -> Void)?

    private let manager: CLLocationManager

    override init() {
        let manager = CLLocationManager()
        self.manager = manager
        self.authorizationStatus = manager.authorizationStatus
        self.accuracyAuthorization = manager.accuracyAuthorization
        super.init()
        manager.delegate = self
        manager.activityType = .fitness
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 5
        manager.pausesLocationUpdatesAutomatically = false
        manager.showsBackgroundLocationIndicator = true
    }

    func requestAlwaysAuthorization() {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestAlwaysAuthorization()
        case .authorizedWhenInUse:
            manager.requestAlwaysAuthorization()
        default:
            break
        }
    }

    func startUpdatingLocation() {
        requestAlwaysAuthorization()
        guard manager.authorizationStatus == .authorizedAlways ||
                manager.authorizationStatus == .authorizedWhenInUse else { return }
        manager.allowsBackgroundLocationUpdates = true
        manager.startUpdatingLocation()
        isUpdatingLocation = true
    }

    func stopUpdatingLocation() {
        manager.stopUpdatingLocation()
        manager.allowsBackgroundLocationUpdates = false
        isUpdatingLocation = false
    }
}

// Core Location still declares these callbacks as nonisolated Objective-C
// requirements. The service itself intentionally owns UI-facing state on the
// main actor, so defer that legacy SDK isolation check at this boundary.
extension CoreLocationTrackingService: @preconcurrency CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        accuracyAuthorization = manager.accuracyAuthorization
        if isUpdatingLocation,
           manager.authorizationStatus != .authorizedAlways,
           manager.authorizationStatus != .authorizedWhenInUse {
            stopUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        latestLocation = locations.last
        onLocationUpdate?(locations)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        lastErrorDescription = error.localizedDescription
        onError?(error)
    }
}
