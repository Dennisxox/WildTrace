# Technische Architektur

Status: Architekturentwurf für Phase 0. Noch nicht als gerätevalidiert anzusehen.

## Leitlinien

1. Flutter/Dart bildet UI, Navigation, Domain-Logik und Query-Schicht.
2. Swift besitzt iOS-Lifecycle-nahe Dienste: Audio, Core Location, CKSyncEngine, Notifications, Background Modes und Privacy-Zustände.
3. SQLite/Drift ist die lokale Source of Truth. CloudKit ist ein replizierender Transport, kein primärer Store.
4. Rohdaten bleiben unverändert bzw. nachvollziehbar; abgeleitete Daten tragen Algorithmusversionen und sind rekonstruierbar.
5. Kein externer Adapter darf Recording, Karte oder lokale Auswertung blockieren.

## Modulgrenzen

```text
Flutter UI
  map | today | recording | species | areas | settings | diagnostics
       |
Application services
  RecordingCoordinator | FilterEngine | EncounterEngine | Export/Backup
       |
Domain
  immutable events | policies | versioned algorithms | provider contracts
       |
Infrastructure
  Drift/SQLite | MapLibre | HTTP caches | file store
       |
iOS native services (Swift, typed platform channels)
  AudioEngine | LocationEngine | NotificationWatchdog | CKSyncEngineBridge
```

Abhängigkeiten zeigen nur nach unten. Native Callbacks liefern versionierte DTOs über einen seriellen Eventkanal. UI-Code greift nie direkt auf CloudKit, Dateien oder AVAudioSession zu.

## Recording-Orchestrierung

Ein Tap erzeugt zuerst transaktional eine `recording_session` mit Status `starting`. Danach startet der Coordinator unabhängig voneinander Audio, GPS, Health Monitor und Watchdog. Teilfehler beenden nicht automatisch andere gesunde Komponenten. Der sichtbare Gesamtzustand enthält Component-States und einen degradierten Gesamtstatus.

Audio-Zustände:

```text
idle -> starting -> recording -> stopping -> idle
                    |   ^
                    v   |
               interrupted -> recovering
                    |            |
                    +----------> failed
```

- Jede Transition erzeugt ein persistiertes `recording_health_event`.
- Recovery nutzt begrenztes exponentielles Backoff mit Jitter, maximaler Versuchszahl und Circuit Breaker.
- `mediaServicesWereReset` verwirft und erstellt Audioobjekte neu.
- Es gibt keine Aussage, dass ein Interruption-Ende-Event immer eintrifft.
- Beim Neustart werden offene Sessions als `systemTerminationSuspected` oder `crashRecovered` finalisiert; die genaue Ursache bleibt unbekannt, wenn sie nicht beweisbar ist.

## Audio- und Inference-Pipeline

`AVAudioEngine`/Audio-Tap -> lock-armer PCM-Ringbuffer -> Segmenter -> Resampler gemäß ModelManifest -> Inference-Worker -> Postprocessing -> Detection-Writer -> Encounter-Engine -> optionale Clip-Selektion.

- Keine kontinuierliche Audiodatei.
- Der Ringbuffer bleibt im RAM; persistiert wird höchstens der nach Policy ausgewählte Clip.
- Inference läuft nicht auf dem UI-Isolate.
- Begrenzte Queue; Drop-Policy: ältestes noch nicht gestartetes Analysefenster verwerfen, Zähler und HealthEvent schreiben. Niemals Audio-Callback blockieren.
- `ModelManifest` pinnt Modell-/Geo-/Label-Version, SHA-256, Lizenz, Sample Rate, Fenster, Overlap und Preprocessing-Version.

## Persistenz

Drift mit gebündeltem SQLite und Background-Isolate ist die bevorzugte Flutter-Schicht. Transaktionen schreiben Domain-Record, Outbox und Revision atomar. WAL, Foreign Keys und regelmäßige passive Checkpoints werden auf Gerät geprüft. Große Streams werden stapelweise geschrieben; UI-Abfragen sind paginiert bzw. viewport-begrenzt.

RTree wird beim Start per Feature-Probe getestet. Wenn nicht verfügbar, nutzt die App BBox-Spalten und zusammengesetzte B-Tree-Indizes. RTree liefert nur Kandidaten; exakte Geometrieprüfung erfolgt anschließend.

## Karten- und Offlinearchitektur

- Engine: MapLibre über ein austauschbares Flutter-Adapterinterface.
- Style-, Tile- und Offline-Provider sind getrennt.
- Phase-0-Offlinepaket: kleines, reproduzierbares PMTiles-/Vector-Tile-Testgebiet mit dokumentierter Quelle und Attribution.
- Keine Downloads vom öffentlichen `tile.openstreetmap.org`.
- Eigene Features werden als GeoJSON-/Vector-Source inkrementell und geclustert aktualisiert, nicht als tausende Flutter-Widgets.
- Viewport + FilterHash + DataRevision steuern Queries und Cacheinvalidierung.

## Geometrie und Exploration

WGS84 bleibt Austauschformat. Berechnungen in Metern erfolgen geodätisch oder in einer passenden lokalen Projektion. Phase 0 vergleicht reine Dart-Optionen gegen eine native GEOS-Bridge; vor einer Entscheidung müssen Robustheit, Binärgröße und LGPL-Verteilung geklärt sein.

Exploration nutzt versionierte Rasterkacheln (Vorschlag: Web-Mercator-Tile + feste Subzellen/Bitset) als Cache. Raw TrackPoints bleiben Source of Truth. Änderungen am Korridorradius erzeugen einen resumierbaren Rebuild, niemals eine irreversible Geometrieänderung.

## Synchronisierung

Swift `CKSyncEngine` synchronisiert eine private Custom Record Zone. Drift-Outbox und `sync_metadata` bleiben maßgeblich; der serialisierte CKSyncEngine-State wird dauerhaft gespeichert.

- Kleine Entitäten: ein CKRecord pro Datensatz.
- Track-/Detection-Daten: immutable, komprimierte und gehashte Chunks deutlich unter 1 MB Recorddaten; größere Payloads als CKAsset.
- Änderungen an Detections als separate Overrides.
- Konflikte: immutable Events vereinigen; editierbare Felder feldweise/LWW nur mit deterministischem Tie-Breaker; Löschungen als Tombstones.
- Import ist idempotent über UUID, SyncVersion und Checksum.
- Accountwechsel isoliert lokale Sync-Identität; lokale Daten werden nicht automatisch gelöscht.

## Offline und Provider

Jeder Provider implementiert Timeout, Retry mit Jitter, Rate-Limit-Reaktion, Cancellation, Cache, Attribution und Circuit Breaker. `ObservationProvider` liefert ausschließlich externe Cache-DTOs. Eigene Observations haben separate Tabellen und Typen.

## Fehler- und Recovery-Semantik

Fehler besitzen `domain`, `code`, `severity`, `retryability`, `occurredAt`, `component`, optionale Systemdaten und eine datenschutzbereinigte Diagnose. Persistenz-/Storage-Fehler haben Vorrang vor Komfortfunktionen. Vor Recording wird freier Speicher geprüft. Ein Flush-Intervall und Maximalverlustfenster werden in Phase 0 gemessen und festgelegt.

## Sicherheits- und Datenschutzanforderungen

- File Protection für DB und Audio muss so gewählt und auf gesperrtem Gerät getestet werden, dass laufende Aufnahmen nicht durch Dateisperre scheitern.
- Keine geheimen Provider-Schlüssel in der App.
- Keine Logs mit präzisen Koordinaten oder Audioinhalten im normalen Telemetriepfad.
- Backup/Export wird gehasht; verschlüsselte Exporte sind vor Release zu entscheiden.
- PrivacyInfo.xcprivacy, App-Store-Datendeklaration, Lösch-/Exportpfad und Retention Policy sind Release-Gates.
