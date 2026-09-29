import SwiftUI
import CoreLocation

struct SettingsScreen: View {
    @EnvironmentObject private var tracker: TourTrackingController
    @EnvironmentObject private var locationService: CoreLocationTrackingService

    var body: some View {
        NavigationStack {
            Form {
                Section("Standort") {
                    LabeledContent("Berechtigung", value: authorizationLabel)
                    LabeledContent("Genauigkeit", value: accuracyLabel)
                    Button("Standortzugriff anfordern") {
                        locationService.requestAlwaysAuthorization()
                    }
                    Text("Für Aufzeichnung bei gesperrtem Bildschirm wird ‚Immer‘ benötigt.")
                        .font(.caption).foregroundStyle(.secondary)
                }

                Section("Aufzeichnung") {
                    LabeledContent("GPS-Intervall", value: "ab 5 m")
                    LabeledContent("Max. akzeptierte Ungenauigkeit", value: "100 m")
                    LabeledContent("Hintergrundmodus", value: "Standort")
                }

                if let error = tracker.lastErrorDescription ?? locationService.lastErrorDescription {
                    Section("Letzter Fehler") { Text(error).foregroundStyle(.red) }
                }
            }
            .navigationTitle("Einstellungen")
        }
    }

    private var authorizationLabel: String {
        switch locationService.authorizationStatus {
        case .notDetermined: "Nicht angefragt"
        case .restricted: "Eingeschränkt"
        case .denied: "Abgelehnt"
        case .authorizedAlways: "Immer"
        case .authorizedWhenInUse: "Beim Verwenden"
        @unknown default: "Unbekannt"
        }
    }

    private var accuracyLabel: String {
        locationService.accuracyAuthorization == .fullAccuracy ? "Genau" : "Reduziert"
    }
}
