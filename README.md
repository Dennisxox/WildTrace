# WildTrace

WildTrace wird als lokale, native iPhone- und iPad-App zur persönlichen Wildtierbeobachtung entwickelt. Die Karte ist die Hauptoberfläche; eine RecordingSession koppelt Audioanalyse, GPS, Exploration und Health Monitoring. Die lokale SQLite-Datenbank bleibt die primäre Datenquelle.

## Aktueller Status

Das Projekt befindet sich in **Phase 0 – technische Risikovalidierung**. Es gibt noch kein freigegebenes Produkt und keine als gerätegetestet deklarierte Recording-Pipeline.

| Bereich | Status |
|---|---|
| Spezifikationsanalyse | dokumentiert |
| Architektur und Datenmodell | Entwurf für Phase 0 |
| Flutter-App | noch nicht angelegt; Flutter SDK fehlt auf diesem Windows-Host |
| Native iOS-Spike | vorhandener, nicht gerätevalidierter SwiftUI-Vorläufer |
| iOS CI | Phase-0-Workflow angelegt |
| Background Audio/GPS | **nicht auf Gerät getestet** |
| BirdNET-Modell | **Lizenz- und Performance-Gate offen** |
| Offlinekarte | **nicht auf Gerät getestet** |
| CloudKit/CKSyncEngine | **nicht auf zwei Geräten getestet** |

Die frühere React-PWA in `web/` und der SwiftUI-Vorläufer in `WildTrace/` sind nur Legacy-/Spike-Material. Sie sind nicht das Hauptprodukt und dürfen nicht als Umsetzung der Master-Spezifikation bewertet werden.

## Verbindliche Dokumente

- [Spezifikationsprüfung](Documentation/SPECIFICATION_REVIEW.md)
- [Technische Recherche](Documentation/TECHNICAL_RESEARCH.md)
- [Risikomatrix](Documentation/RISK_MATRIX.md)
- [Architektur](Documentation/ARCHITECTURE.md)
- [Datenmodell und Indizes](Documentation/DATA_MODEL.md)
- [Provider- und Serviceverträge](Documentation/PROVIDER_INTERFACES.md)
- [Phase-0-Testprotokoll](Documentation/PHASE_0.md)
- [Codemagic-/TestFlight-Einrichtung](Documentation/CODEMAGIC_TESTFLIGHT_SETUP.md)
- [Implementierungsplan](Documentation/IMPLEMENTATION_PLAN.md)
- [Architecture Decision Records](Documentation/adr/README.md)

## Statusbegriffe

- **Unit tested**: automatisierter Test ausgeführt.
- **Simulator tested**: im iOS Simulator geprüft; kein Nachweis für Hardware-/Background-Verhalten.
- **Device tested**: mit dokumentiertem Gerät, iOS-Version, Build und Ergebnis geprüft.
- **Not yet device tested**: kein Hardware-Nachweis. Dies ist derzeit der Status aller Phase-0-Hardwaretests.

## Nächster zulässiger Schritt

Auf einem macOS-Host Flutter/Xcode installieren, den Phase-0-Spike erzeugen bzw. den nativen Service-Spike in einen Flutter-Host integrieren, CI grün bekommen und anschließend die Checkliste in `Documentation/PHASE_0.md` auf echten Geräten durchführen. Phase 1 bleibt bis zur Bewertung der Gates P0-G1 bis P0-G7 gesperrt.
