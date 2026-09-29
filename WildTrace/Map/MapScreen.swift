import SwiftUI
import SwiftData
import MapKit

struct MapScreen: View {
    @EnvironmentObject private var tracker: TourTrackingController
    @Query(sort: \Tour.startedAt, order: .reverse) private var tours: [Tour]
    @State private var baseStyle: MapBaseStyle = .standard
    @State private var position: MapCameraPosition = .automatic
    @State private var showStylePicker = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                StyledMap(position: $position, style: baseStyle, tours: tours)
                    .ignoresSafeArea(edges: .top)

                VStack(spacing: 12) {
                    Button { showStylePicker = true } label: {
                        Image(systemName: "square.3.layers.3d")
                    }
                    .accessibilityLabel("Basiskarte wählen")

                    Button {
                        position = .userLocation(fallback: .automatic)
                    } label: {
                        Image(systemName: "location.fill")
                    }
                    .accessibilityLabel("Eigene Position anzeigen")

                    if tracker.activeTour == nil {
                        Button { tracker.startTour() } label: {
                            Image(systemName: "figure.walk.motion")
                        }
                        .accessibilityLabel("Tour starten")
                    }
                }
                .font(.title3)
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.circle)
                .padding(.trailing)
                .padding(.bottom, tracker.activeTour == nil ? 20 : 105)
            }
            .navigationTitle("WildTrace")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { } label: { Label("Sichtung", systemImage: "plus") }
                        .disabled(true)
                        .help("Manuelle Sichtungen folgen in Phase 2")
                }
            }
            .confirmationDialog("Basiskarte", isPresented: $showStylePicker) {
                ForEach(MapBaseStyle.allCases) { style in
                    Button(style.label) { baseStyle = style }
                }
            }
        }
    }
}

private struct StyledMap: View {
    @Binding var position: MapCameraPosition
    let style: MapBaseStyle
    let tours: [Tour]

    @ViewBuilder
    var body: some View {
        switch style {
        case .standard:
            map.mapStyle(.standard(elevation: .realistic))
        case .hybrid:
            map.mapStyle(.hybrid(elevation: .realistic))
        case .satellite:
            map.mapStyle(.imagery(elevation: .realistic))
        }
    }

    private var map: some View {
        Map(position: $position) {
            UserAnnotation()
            ForEach(tours) { tour in
                let coordinates = tour.trackPoints
                    .sorted(by: { $0.timestamp < $1.timestamp })
                    .map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
                if coordinates.count > 1 {
                    MapPolyline(coordinates: coordinates)
                        .stroke(tour.state == .recording ? .green : .blue, lineWidth: 4)
                }
            }
        }
        .mapControls {
            MapCompass()
            MapScaleView()
        }
    }
}
