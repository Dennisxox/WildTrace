# Implementierungsplan

## Phase 0 – jetzt zulässig

1. Repository/CI auf macOS stabilisieren; Flutter-Projekt mit iOS/iPadOS-Target erzeugen.
2. Native Swift-Servicepakete und typisierte Flutter-Channels für Audio, Location, Health, Notification und CloudKit anlegen.
3. SQLite-Capability-Spike: WAL, RTree, FTS5, Foreign Keys, Migration, Crash-Flush und 1M/100k-Datensatzbenchmark.
4. BirdNET-Modelllizenz klären; Testmanifest mit Hash anlegen, Golden-Audio gegen Referenz validieren.
5. Minimaler Recording-Screen: Start/Stop, Component-State, Zähler, letzte Health Events, Diagnoseexport.
6. Tests P0-G2 bis P0-G5 auf echten iPhones einschließlich Lockscreen/Background/Interruptions durchführen.
7. MapLibre + lizenziertes Offline-Testpaket auf Gerät validieren.
8. CKSyncEngine-Bridge + minimale Observation/Settings/Tombstone/TrackChunk-Testdaten auf zwei Installationen validieren.
9. Ergebnisse und Blocker dokumentieren; ADRs aktualisieren. Erst dann Phase-1-Freigabe entscheiden.

## Nach Freigabe

- Phase 1: Flutter-Struktur, Navigation, Drift-Migrationen, Map-Grundansicht, Settings-Skeleton.
- Phase 2: RecordingSession, GPS, Quality Flags, TrackChunks, GPX.
- Phase 3: ExplorationTiles/Fog und rekonstruierbarer Korridor.
- Phase 4: Taxonomie, Bibliothek, Referenzbildcache.
- Phase 5: manuelle Observations, Notizen, Marker, zentrale Filter.
- Phase 6: produktionsreife Audio-/BirdNET-Pipeline, Detection, Encounter, Confirmation, AudioPolicy.
- Phase 7: Live Strip, Notifications, Health Monitor, Watchdog.
- Phase 8: Today/DailyRecord/Timeline/Summary.
- Phase 9: Areas, Drawing, Membership, Analyse.
- Phase 10: Weather/Habitat/Protected Areas/Day Phase.
- Phase 11: BirdWeather/iNaturalist nur nach Contract-/Lizenzgate.
- Phase 12: OccurrenceClass und „Was könnte hier vorkommen?“ mit Datenqualitätsgate.
- Phase 13: Heatmaps/Phänologie/Jahresvergleich/Verteilung/Dashboard.
- Phase 14: vollständige CloudKit-Synchronisierung, Assets, Tombstones, Konflikte.
- Phase 15: Offlinegebiete, Download-/Speichermanagement.
- Phase 16: iPad, Accessibility, UI-Polish und finale Performancearbeit.

## Definition of Done je Phase

Format, Analyze/Lint, Unit-/Integrationtests, Flutter-Build, iOS-CI, Migrationstest, Dokumentation/ADRs, offene Risiken und passende Device-Tests. Ein roter Build oder ungeklärter Datenintegritätsblocker sperrt die nächste Phase.

## Noch nicht zulässig

Keine Featureimplementierung aus Phase 1+, keine Produktdeklaration des Legacy-Web-/SwiftUI-Codes und kein BirdNET-Modell im Repository, solange Phase 0 und die Modelllizenz offen sind.
