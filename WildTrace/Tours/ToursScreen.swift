import SwiftUI
import SwiftData

struct ToursScreen: View {
    @EnvironmentObject private var tracker: TourTrackingController
    @Query(sort: \Tour.startedAt, order: .reverse) private var tours: [Tour]

    var body: some View {
        NavigationStack {
            Group {
                if tours.isEmpty {
                    ContentUnavailableView("Noch keine Touren", systemImage: "figure.walk",
                                           description: Text("Starte deine erste GPS-Tour."))
                } else {
                    List(tours) { tour in
                        NavigationLink {
                            TourDetailScreen(tour: tour)
                        } label: {
                            VStack(alignment: .leading, spacing: 5) {
                                Text(tour.name).font(.headline)
                                HStack {
                                    Text(tour.startedAt, format: .dateTime.day().month().year().hour().minute())
                                    Spacer()
                                    Text(Measurement(value: tour.distanceMeters, unit: UnitLength.meters),
                                         format: .measurement(width: .abbreviated, usage: .road))
                                }
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Touren")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if tracker.activeTour == nil {
                        Button("Start", systemImage: "play.fill") { tracker.startTour() }
                    } else {
                        Button("Beenden", systemImage: "stop.fill", role: .destructive) {
                            tracker.endTour()
                        }
                    }
                }
            }
        }
    }
}
