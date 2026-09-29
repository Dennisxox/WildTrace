import SwiftUI

struct ActiveTourBar: View {
    @EnvironmentObject private var tracker: TourTrackingController

    var body: some View {
        if let tour = tracker.activeTour {
            HStack(spacing: 18) {
                metric("Dauer", Duration.seconds(tracker.elapsedSeconds).formatted(.time(pattern: .hourMinuteSecond)))
                metric("Strecke", Measurement(value: tour.distanceMeters, unit: UnitLength.meters)
                    .formatted(.measurement(width: .abbreviated, usage: .road)))
                metric("Enc.", "\(tour.encounterCount)")
                metric("Arten", "\(tour.speciesCount)")
                Spacer(minLength: 0)
                Button(role: .destructive) { tracker.endTour() } label: {
                    Image(systemName: "stop.fill")
                }
                .buttonStyle(.borderedProminent)
            }
            .font(.caption)
            .padding(12)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
            .shadow(radius: 6, y: 2)
        }
    }

    private func metric(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title).foregroundStyle(.secondary)
            Text(value).fontWeight(.semibold).monospacedDigit()
        }
    }
}
