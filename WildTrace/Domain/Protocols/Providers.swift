import Foundation
import CoreLocation

protocol ObservationProvider: Sendable {
    var providerID: String { get }
    func observations(in bounds: CoordinateBounds, from: Date?, to: Date?) async throws -> [ProviderObservation]
}

protocol DetectionProvider: Sendable {
    var providerID: String { get }
    func startDetection() async throws -> AsyncThrowingStream<DetectionCandidate, Error>
    func stopDetection() async
}

protocol WeatherProvider: Sendable {
    var providerID: String { get }
    func weather(at coordinate: CLLocationCoordinate2D, date: Date) async throws -> WeatherReading
}

protocol HabitatProvider: Sendable {
    var providerID: String { get }
    func habitat(at coordinate: CLLocationCoordinate2D) async throws -> HabitatReading
}

protocol TaxonInfoProvider: Sendable {
    var providerID: String { get }
    func profile(scientificName: String, locale: Locale) async throws -> TaxonProfilePayload
}

protocol ProtectedAreaProvider: Sendable {
    var providerID: String { get }
    func protectedAreas(in bounds: CoordinateBounds) async throws -> [ProtectedAreaFeature]
}

protocol ExportProviding: Sendable {
    func gpx(for tourID: UUID) async throws -> Data
    func observationsCSV(filter: ObservationFilter) async throws -> Data
    func geoJSON(filter: ObservationFilter) async throws -> Data
    func fullBackupJSON() async throws -> Data
}
