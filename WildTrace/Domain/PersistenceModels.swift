import Foundation
import SwiftData

@Model
final class Tour {
    @Attribute(.unique) var id: UUID
    var name: String
    var startedAt: Date
    var endedAt: Date?
    var stateRawValue: String
    var durationSeconds: TimeInterval
    var distanceMeters: Double
    var encounterCount: Int
    var speciesCount: Int
    @Relationship(deleteRule: .cascade) var trackPoints: [TrackPoint]

    init(id: UUID = UUID(), name: String, startedAt: Date = .now) {
        self.id = id
        self.name = name
        self.startedAt = startedAt
        self.stateRawValue = TourState.recording.rawValue
        self.durationSeconds = 0
        self.distanceMeters = 0
        self.encounterCount = 0
        self.speciesCount = 0
        self.trackPoints = []
    }

    var state: TourState {
        get { TourState(rawValue: stateRawValue) ?? .finished }
        set { stateRawValue = newValue.rawValue }
    }
}

@Model
final class TrackPoint {
    @Attribute(.unique) var id: UUID
    var latitude: Double
    var longitude: Double
    var altitude: Double
    var timestamp: Date
    var horizontalAccuracy: Double
    var verticalAccuracy: Double
    var speed: Double
    var course: Double

    init(id: UUID = UUID(), latitude: Double, longitude: Double, altitude: Double,
         timestamp: Date, horizontalAccuracy: Double, verticalAccuracy: Double,
         speed: Double, course: Double) {
        self.id = id
        self.latitude = latitude
        self.longitude = longitude
        self.altitude = altitude
        self.timestamp = timestamp
        self.horizontalAccuracy = horizontalAccuracy
        self.verticalAccuracy = verticalAccuracy
        self.speed = speed
        self.course = course
    }
}

@Model
final class Taxon {
    @Attribute(.unique) var id: UUID
    var scientificName: String
    var commonNameDE: String
    var animalGroupRawValue: String
    var taxonomyJSON: Data?

    init(id: UUID = UUID(), scientificName: String, commonNameDE: String = "", animalGroup: AnimalGroup) {
        self.id = id
        self.scientificName = scientificName
        self.commonNameDE = commonNameDE
        self.animalGroupRawValue = animalGroup.rawValue
    }
}

@Model
final class Observation {
    @Attribute(.unique) var id: UUID
    var taxonID: UUID
    var scientificName: String
    var commonNameDE: String
    var animalGroupRawValue: String
    var latitude: Double
    var longitude: Double
    var positionAccuracy: Double
    var observedAt: Date
    var methodRawValue: String
    var sourceRawValue: String
    var confidence: Double?
    var tourID: UUID?
    var weatherSnapshotID: UUID?
    var habitatSnapshotID: UUID?
    var count: Int
    var sex: String?
    var age: String?
    var note: String
    var photoLocalPath: String?
    var audioLocalPath: String?
    var dayPhaseRawValue: String?

    init(taxonID: UUID, scientificName: String, commonNameDE: String, animalGroup: AnimalGroup,
         latitude: Double, longitude: Double, positionAccuracy: Double, observedAt: Date,
         method: ObservationMethod, source: ObservationOrigin = .local) {
        self.id = UUID(); self.taxonID = taxonID; self.scientificName = scientificName
        self.commonNameDE = commonNameDE; self.animalGroupRawValue = animalGroup.rawValue
        self.latitude = latitude; self.longitude = longitude; self.positionAccuracy = positionAccuracy
        self.observedAt = observedAt; self.methodRawValue = method.rawValue; self.sourceRawValue = source.rawValue
        self.count = 1; self.note = ""
    }
}

@Model
final class Detection {
    @Attribute(.unique) var id: UUID
    var taxonID: UUID
    var scientificName: String
    var detectedAt: Date
    var latitude: Double?
    var longitude: Double?
    var confidence: Double
    var providerID: String
    var audioLocalPath: String?
    var encounterID: UUID?
    var tourID: UUID?

    init(taxonID: UUID, scientificName: String, detectedAt: Date, confidence: Double, providerID: String) {
        self.id = UUID(); self.taxonID = taxonID; self.scientificName = scientificName
        self.detectedAt = detectedAt; self.confidence = confidence; self.providerID = providerID
    }
}

@Model
final class Encounter {
    @Attribute(.unique) var id: UUID
    var taxonID: UUID
    var scientificName: String
    var startedAt: Date
    var endedAt: Date
    var centroidLatitude: Double
    var centroidLongitude: Double
    var detectionCount: Int
    var tourID: UUID?

    init(taxonID: UUID, scientificName: String, startedAt: Date, latitude: Double, longitude: Double) {
        self.id = UUID(); self.taxonID = taxonID; self.scientificName = scientificName
        self.startedAt = startedAt; self.endedAt = startedAt
        self.centroidLatitude = latitude; self.centroidLongitude = longitude; self.detectionCount = 1
    }
}

@Model
final class WeatherSnapshot {
    @Attribute(.unique) var id: UUID
    var capturedAt: Date
    var latitude: Double
    var longitude: Double
    var temperatureCelsius: Double?
    var conditionCode: String?
    var precipitationMillimeters: Double?
    var windSpeedMetersPerSecond: Double?
    var windDirectionDegrees: Double?
    var cloudCoverPercent: Double?
    var humidityPercent: Double?
    var pressureHectopascals: Double?
    var providerID: String

    init(capturedAt: Date, latitude: Double, longitude: Double, providerID: String) {
        self.id = UUID(); self.capturedAt = capturedAt; self.latitude = latitude
        self.longitude = longitude; self.providerID = providerID
    }
}

@Model
final class HabitatSnapshot {
    @Attribute(.unique) var id: UUID
    var capturedAt: Date
    var latitude: Double
    var longitude: Double
    var category: String
    var sourceClassification: String
    var providerID: String

    init(capturedAt: Date, latitude: Double, longitude: Double, category: String,
         sourceClassification: String, providerID: String) {
        self.id = UUID(); self.capturedAt = capturedAt; self.latitude = latitude
        self.longitude = longitude; self.category = category
        self.sourceClassification = sourceClassification; self.providerID = providerID
    }
}

@Model
final class TaxonProfile {
    @Attribute(.unique) var id: UUID
    var taxonID: UUID
    var scientificName: String
    var commonNameDE: String
    var taxonomyJSON: Data?
    var profileDescription: String?
    var habitatText: String?
    var activityText: String?
    var imageLocalPath: String?
    var imageSource: String?
    var imageAuthor: String?
    var imageLicense: String?
    var sourceURLString: String?
    var lastUpdated: Date

    init(taxonID: UUID, scientificName: String, commonNameDE: String, lastUpdated: Date = .now) {
        self.id = UUID(); self.taxonID = taxonID; self.scientificName = scientificName
        self.commonNameDE = commonNameDE; self.lastUpdated = lastUpdated
    }
}

@Model
final class AudioStorageRule {
    @Attribute(.unique) var id: UUID
    var taxonID: UUID?
    var policyRawValue: String
    var limit: Int?

    init(taxonID: UUID? = nil, policy: AudioStoragePolicyKind, limit: Int? = nil) {
        self.id = UUID(); self.taxonID = taxonID; self.policyRawValue = policy.rawValue; self.limit = limit
    }
}

@Model
final class ExternalObservationRecord {
    @Attribute(.unique) var id: UUID
    var providerID: String
    var providerRecordID: String
    var scientificName: String
    var commonNameDE: String?
    var animalGroupRawValue: String
    var latitude: Double
    var longitude: Double
    var coordinateAccuracyMeters: Double?
    var observedAt: Date
    var fetchedAt: Date
    var expiresAt: Date?
    var sourceURLString: String?

    init(providerID: String, providerRecordID: String, scientificName: String,
         animalGroup: AnimalGroup, latitude: Double, longitude: Double, observedAt: Date) {
        self.id = UUID(); self.providerID = providerID; self.providerRecordID = providerRecordID
        self.scientificName = scientificName; self.animalGroupRawValue = animalGroup.rawValue
        self.latitude = latitude; self.longitude = longitude; self.observedAt = observedAt; self.fetchedAt = .now
    }
}

@Model
final class ExplorationCell {
    @Attribute(.unique) var id: UUID
    var geospatialKey: String
    var firstVisitedAt: Date
    var lastVisitedAt: Date
    var corridorRadiusMeters: Double

    init(geospatialKey: String, visitedAt: Date, corridorRadiusMeters: Double) {
        self.id = UUID(); self.geospatialKey = geospatialKey; self.firstVisitedAt = visitedAt
        self.lastVisitedAt = visitedAt; self.corridorRadiusMeters = corridorRadiusMeters
    }
}
