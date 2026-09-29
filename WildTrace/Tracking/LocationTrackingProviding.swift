import CoreLocation

@MainActor
protocol LocationTrackingProviding: AnyObject {
    var authorizationStatus: CLAuthorizationStatus { get }
    var accuracyAuthorization: CLAccuracyAuthorization { get }
    var latestLocation: CLLocation? { get }
    var isUpdatingLocation: Bool { get }
    var onLocationUpdate: (([CLLocation]) -> Void)? { get set }
    var onError: ((Error) -> Void)? { get set }

    func requestAlwaysAuthorization()
    func startUpdatingLocation()
    func stopUpdatingLocation()
}
