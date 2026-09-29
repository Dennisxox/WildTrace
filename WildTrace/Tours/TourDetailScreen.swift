import SwiftUI
import MapKit

struct TourDetailScreen: View {
    let tour: Tour

    var body: some View {
        List {
            Section("Übersicht") {
                LabeledContent("Start", value: tour.startedAt.formatted(date: .abbreviated, time: .shortened))
                if let endedAt = tour.endedAt {
                    LabeledContent("Ende", value: endedAt.formatted(date: .abbreviated, time: .shortened))
                }
                LabeledContent("Dauer", value: Duration.seconds(tour.durationSeconds).formatted(.time(pattern: .hourMinuteSecond)))
                LabeledContent("Strecke", value: Measurement(value: tour.distanceMeters, unit: UnitLength.meters)
                    .formatted(.measurement(width: .wide, usage: .road)))
                LabeledContent("Trackpunkte", value: "\(tour.trackPoints.count)")
            }

            if coordinates.count > 1 {
                Section("Track") {
                    Map {
                        MapPolyline(coordinates: coordinates).stroke(.blue, lineWidth: 4)
                    }
                    .frame(height: 280)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
        .navigationTitle(tour.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var coordinates: [CLLocationCoordinate2D] {
        tour.trackPoints.sorted(by: { $0.timestamp < $1.timestamp })
            .map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
    }
}
