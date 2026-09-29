# Prüfung der Master-Spezifikation

## Ergebnis

Die Produktausrichtung ist konsistent: native Local-First-App, Karte als Zentrum, eine gekoppelte RecordingSession, nachvollziehbare Rohdaten und keine erfundenen Daten. Die Reihenfolge „erst Risiken, dann Produkt“ ist richtig. Die vorhandene Codebasis erfüllt sie jedoch nicht: PWA/SwiftData/Tour-Navigation widersprechen Flutter/SQLite/DailyRecord/RecordingSession.

## Widersprüche und aufzulösende Mehrdeutigkeiten

| Thema | Befund | Entscheidung/Gate |
|---|---|---|
| „keine Tour starten/beenden“ vs. Mikrofontap startet/stoppt | Gemeint ist keine separat benannte Tourfunktion; eine explizite RecordingSession bleibt nötig. | UI nennt nur Aufnahme; Domain nutzt RecordingSession. |
| GPS „läuft nur während RecordingSession“ vs. Kartenstandort | Live-Kartenposition ist ebenfalls GPS, aber kein persistenter Track. | `MapLocation` und `RecordingLocation` getrennt behandeln. |
| Tageszusammenfassung „nach abgeschlossenem Kalendertag“ | Eine Session darf über Mitternacht laufen; der Tag kann Nachträge erhalten. | Summary ist revisionsgebundener Cache und wird nach Ende/Änderung neu berechnet. |
| Encounter über Sessiongrenzen | Schema fordert `recordingSessionId`, Regel nennt nur Art/Zeit/Ort. | Encounter zunächst sessiongebunden; Cross-Session-DuplicateGroup separat. |
| „bester Clip je Encounter“ während Encounter wächst | Der beste Treffer kann sich später ändern. | Clipkandidat temporär halten, atomar ersetzen, Policy/Audit protokollieren. |
| DetectionChunk und Overrides | Importreihenfolge und Idempotenz fehlen. | Chunk unveränderlich; Overrides referenzieren Detection UUID und dürfen vor Chunk eintreffen. |
| Force Quit/Termination | Audio kann nicht garantiert weiterlaufen; Watchdog ist nur Heuristik. | Vorsichtige Semantik beibehalten. |
| Referenzbilder vs. „keine eigenen Fotos“ | Kein Konflikt, aber Cache/Lizenz und Offlineverhalten fehlen. | Nur providerlizenzierte Referenzbilder mit vollständiger Attribution. |

## Fehlende technische Anforderungen

Vor Phase 1 festlegen bzw. testen:

- minimale iOS/iPadOS-Version, unterstützte Geräte/RAM und App-Binärgrößenbudget;
- App-Vertriebs-/Geschäftsmodell, weil BirdNET- und Providerlizenzen davon abhängen;
- Audioformat, Kanalwahl, Clipverschlüsselung, iOS File Protection und Backup-Ausschlüsse;
- zulässiges Crash-Loss-Fenster, DB-WAL-/Checkpoint-/Korruptionsstrategie;
- Model-Download/Update-Signatur, Rollback und freier Speicher;
- genaue Definition unabhängiger Evidenzfenster und räumlicher Encounter-Grenzen;
- sensible Arten/Koordinatenunschärfe bei externen Daten und Exporten;
- Taxonomie-Autorität, Release-Zyklus und Merge-/Split-Provenienz;
- Maßeinheiten, CRS, Antimeridian/Polargebiete und ungültige Polygone;
- CloudKit-Zone, Accountwechsel, Schlüsselrotation, Asset-Garbage-Collection und Tombstone-Frist;
- Verhalten bei Reboot, Force Quit und deaktivierten Benachrichtigungen;
- Datenbank-/Backup-Verschlüsselung, Restore-Atomizität und freier Speicher;
- Observability ohne Preisgabe präziser Standort-/Audiodaten;
- Lokalisierung, Dynamic Type, VoiceOver, Reduced Motion und iPad Multitasking;
- Provider-SLA-/Nutzungsbedingungen, User-Agent/Attribution und Kill-Switch;
- reproduzierbare Builds, Dependency-Pinning, SBOM und Lizenzprüfung.

## Bestehende Implementierung

- `web/`: PWA-Prototyp, nicht Hauptprodukt; Background Audio/GPS auf iOS ungeeignet.
- `WildTrace/`: SwiftUI/SwiftData-Prototyp mit manueller Tour und fünf Tabs; nicht Zielarchitektur.
- kein Flutter-SDK/Projekt, keine Tests, keine CI und anfänglich kein Git-Repository.
- keine Hardwarebelege. Aussagen wie „implemented“ aus alten Dokumenten sind aufgehoben.

## Phase-1-Gate

Phase 1 darf erst beginnen, wenn jedes Gate in `PHASE_0.md` ein Ergebnis `pass`, `conditional pass` oder dokumentierten `BLOCKER` mit gewähltem Fallback besitzt. „Nicht getestet“ ist kein Pass.
