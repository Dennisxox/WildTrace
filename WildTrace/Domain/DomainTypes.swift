import Foundation
import CoreLocation

enum AnimalGroup: String, Codable, CaseIterable, Identifiable {
    case bird, mammal, insect, amphibian, reptile, other
    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .bird: "Vögel"
        case .mammal: "Säugetiere"
        case .insect: "Insekten"
        case .amphibian: "Amphibien"
        case .reptile: "Reptilien"
        case .other: "Andere"
        }
    }
}

enum ObservationMethod: String, Codable, CaseIterable {
    case automaticAudio, visual, manual
}

enum ObservationOrigin: String, Codable, CaseIterable {
    case local, birdNET, birdWeather, iNaturalist, futureProvider
}

enum DayPhase: String, Codable, CaseIterable {
    case night, dawn, morning, day, evening, dusk
}

enum TourState: String, Codable {
    case recording, finished
}

enum AudioStoragePolicyKind: String, Codable, CaseIterable {
    case always, never, firstX, maxPerDay
}

enum MapBaseStyle: String, CaseIterable, Identifiable {
    case standard, hybrid, satellite
    var id: String { rawValue }
    var label: String {
        switch self {
        case .standard: "Standard"
        case .hybrid: "Hybrid"
        case .satellite: "Satellit"
        }
    }
}

struct CoordinateBounds: Sendable {
    let southWest: CLLocationCoordinate2D
    let northEast: CLLocationCoordinate2D
}

struct ProviderObservation: Identifiable, Sendable {
    let id: String
    let providerID: String
    let scientificName: String
    let commonNameDE: String?
    let animalGroup: AnimalGroup
    let coordinate: CLLocationCoordinate2D
    let coordinateAccuracyMeters: Double?
    let observedAt: Date
    let sourceURL: URL?
}

struct DetectionCandidate: Sendable {
    let scientificName: String
    let commonNameDE: String?
    let confidence: Double
    let detectedAt: Date
    let coordinate: CLLocationCoordinate2D?
    let audioTemporaryURL: URL?
}

struct WeatherReading: Sendable {
    let capturedAt: Date
    let temperatureCelsius: Double?
    let conditionCode: String?
    let precipitationMillimeters: Double?
    let windSpeedMetersPerSecond: Double?
    let windDirectionDegrees: Double?
    let cloudCoverPercent: Double?
    let humidityPercent: Double?
    let pressureHectopascals: Double?
}

struct HabitatReading: Sendable {
    let category: String
    let sourceClassification: String
    let providerID: String
}

struct TaxonProfilePayload: Sendable {
    let scientificName: String
    let commonNameDE: String?
    let taxonomyJSON: Data?
    let summary: String?
    let imageData: Data?
    let imageSource: String?
    let imageAuthor: String?
    let imageLicense: String?
    let sourceURL: URL?
}

struct ProtectedAreaFeature: Identifiable, Sendable {
    let id: String
    let name: String
    let designation: String
    let polygonRings: [[CLLocationCoordinate2D]]
    let sourceURL: URL?
}

struct ObservationFilter: Equatable, Sendable {
    var includeOwned = true
    var includeExternal = false
    var animalGroups = Set<AnimalGroup>()
    var taxonIDs = Set<UUID>()
    var sources = Set<ObservationOrigin>()
    var dateInterval: DateInterval?
    var dayPhases = Set<DayPhase>()
    var hourRange: ClosedRange<Int>?
    var temperatureRange: ClosedRange<Double>?
    var habitatCategories = Set<String>()
    var methods = Set<ObservationMethod>()
    var minimumConfidence: Double?
}
