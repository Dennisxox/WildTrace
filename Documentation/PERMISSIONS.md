# iOS-Berechtigungen und Background Modes

- Mikrofon erst nach In-App-Erklärung und Startintention anfordern.
- Standort zunächst When In Use; weitere Background-/Always-Autorisierung kontextbezogen erklären und nur für Recording anfordern.
- Notifications erst nach Erklärung von Zielart/Problem-Watchdog anfordern.
- `UIBackgroundModes`: `audio` und `location` ausschließlich, wenn die Phase-0-Implementierung sie tatsächlich nutzt.
- Keine Kamera-/Fotoberechtigung für die Kernfunktion.
- Permission-Entzug während Recording erzeugt HealthEvent und degradiert nur die betroffene Komponente.
- `PrivacyInfo.xcprivacy`, SDK-Manifeste und App-Store-Datendeklaration müssen vor Distribution geprüft werden.

Der aktuelle SwiftUI-Vorläufer enthält nur Location-Strings und ist keine vollständige oder freigegebene Permission-Konfiguration.
