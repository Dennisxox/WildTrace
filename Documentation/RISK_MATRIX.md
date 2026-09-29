# Risikomatrix

Skala: Wahrscheinlichkeit (W) und Auswirkung (A) jeweils niedrig/mittel/hoch/kritisch. Status: offen, Spike, Blocker, entschieden.

| ID | Risiko | W | A | Mitigation | Fallback | Status |
|---|---|---:|---:|---|---|---|
| R01 | iOS suspendiert/beendet lang laufendes Audio | mittel | kritisch | Background Mode, minimale Callback-Arbeit, Health Events, 30/120-min Device-Test | vorsichtiger Watchdog; Session nach Relaunch finalisieren | Spike |
| R02 | Audio+GPS+Inference überhitzt/entlädt Akku | hoch | hoch | Instruments, Thermal/Power-Logging, Backpressure, messbare Qualitätsstufen | Inference-Rate sichtbar reduzieren; GPS weiterführen | Spike |
| R03 | Interruptions/Route Changes lassen Pipeline hängen | hoch | hoch | explizite State Machine, begrenzte Recovery, Reset aller Audioobjekte | Audio `failed`, GPS läuft, Nutzerhinweis | Spike |
| R04 | Force Quit wird als weiterlaufende Aufnahme missverstanden | mittel | kritisch | UI/Onboarding mit korrekter Semantik, Relaunch-Recovery | Watchdog-Heuristik | entschieden |
| R05 | BirdNET-Modell nicht kommerziell lizenzierbar | hoch | kritisch | Geschäftsmodell + schriftliche Lizenzklärung vor Bundling | alternatives lizenziertes Modell oder nicht-kommerzielle Distribution | **Blocker** |
| R06 | BirdNET läuft auf älteren iPhones nicht echtzeitfähig | mittel | hoch | Geräte-Matrix, quantisierte Modelle, Latenz-/Drop-Metriken | unterstützte Geräte einschränken oder serverfreie reduzierte Rate | Spike |
| R07 | Falsches Preprocessing verfälscht Ergebnisse | mittel | kritisch | Golden WAVs gegen Referenz, Manifest/Hash pinnen | Inference nicht freigeben | offen |
| R08 | Öffentliche Tiles werden durch Offline-Download missbraucht | mittel | hoch | nur explizit erlaubter Provider/PMTiles, Attribution Registry | keine Offlinekarte bis Vertrag steht | entschieden |
| R09 | Satelliten-Offline-Rechte fehlen | hoch | mittel | Providervertrag separat prüfen | Satellit nur online oder ausblenden | offen |
| R10 | Flutter-MapLibre-Plugin erfüllt iOS Offline/Clustering nicht robust | mittel | hoch | Gerätetest, große GeoJSON-Last, Offline-Pack-Abbruch/Resume | eigene native MapLibre-Bridge | Spike |
| R11 | SQLite/RTree nicht im gebündelten Build verfügbar | niedrig | hoch | Startup-Capability-Probe und CI-Test | BBox-Spalten + B-Tree | offen |
| R12 | DB-Writes blockieren Audio/UI | mittel | hoch | Background-Isolate, Batching, WAL, Performance-Dataset | Writer-Queue mit kontrollierter Degradation | offen |
| R13 | Crash verliert letzte Track-/Detection-Daten | mittel | hoch | gemessener Flush, kleine Transaktionen, Recovery-Markierung | dokumentiertes Maximalverlustfenster | Spike |
| R14 | Geometriefehler/ungezügelte MultiPolygons | hoch | hoch | gekacheltes Bitset, projizierte/geodätische Tests, Algorithmusversion | Raw Tracks neu berechnen | offen |
| R15 | GEOS-Lizenz/Packaging problematisch | mittel | mittel | Legal Review, dynamische Link-/Notice-Prüfung | raster-/tilebasierte Algorithmen | offen |
| R16 | CloudKit-Konflikt erzeugt Duplikate/Datenverlust | mittel | kritisch | immutable IDs, Outbox, idempotenter Import, Tombstones, Merge-Tests | Sync pausieren, lokal weiterarbeiten/exportieren | Spike |
| R17 | iCloud-Quota/Accountwechsel | mittel | hoch | Quota-Status, Asset-Sync optional, Account-Silo | lokal weiterarbeiten | offen |
| R18 | Chunk zu groß/inkompatibel | mittel | hoch | konservatives Größenlimit, SchemaVersion, Checksum, Fuzz/Golden Tests | CKAsset oder kleinere Chunks | offen |
| R19 | Externe APIs ändern Limits/Schemata | hoch | mittel | Adapter, Cache, Circuit Breaker, Contract Tests, Kill-Switch | Cache/„nicht verfügbar“ | offen |
| R20 | Externe Daten werden als persönliche Evidenz gezählt | niedrig | kritisch | getrennte Tabellen/Typen/Filtertests | externen Layer deaktivieren | entschieden |
| R21 | Seltenheit suggeriert unbelegte Wissenschaftlichkeit | mittel | hoch | `unknown` Default, Datenqualitätsgate, Algorithmusversion | Ring ausblenden | offen |
| R22 | Referenzbild-Attribution geht offline verloren | mittel | hoch | Attribution als persistente Metadaten, Lizenz-Allowlist | kein Bild anzeigen | offen |
| R23 | präzise GPS-/Audio-Daten gelangen nach außen | niedrig | kritisch | Local First, Opt-in Sync, minimierte Logs, Threat Model | Provider/Sync deaktivieren | offen |
| R24 | Dateischutz verhindert Writes bei gesperrtem Gerät | mittel | kritisch | File-Protection-Matrix auf Gerät testen | geeignete Protection-Klasse nur für aktive Daten | Spike |
| R25 | Windows-only Entwicklung lässt iOS-Build lange rot | hoch | hoch | macOS CI auf jedem relevanten Commit | Phase pausieren, bis CI grün | offen |
| R26 | Legacy-PWA/SwiftUI wird versehentlich weiterentwickelt | mittel | mittel | README/CI klar markieren, später archivieren | Buildpfad explizit sperren | entschieden |
| R27 | 1M TrackPoints/100k Detections machen Queries langsam | hoch | hoch | synthetischer Benchmark, viewport/paginiert, Indizes | Aggregat-/Chunk-Caches | offen |
| R28 | Backup/Restore ist nicht atomar oder beschädigt Daten | mittel | kritisch | Manifest+Checksums, temp DB, Validierung vor Swap | Original-DB unverändert lassen | offen |

## Release-Blocker

- R05 muss vor Modellbundling gelöst sein.
- R01/R02/R03/R06/R10/R13/R16/R24/R25 benötigen Phase-0-Evidenz.
- Kein „Device tested“-Status ohne ausgefüllte Testevidenz in `PHASE_0.md`.
