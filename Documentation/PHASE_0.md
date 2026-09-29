# Phase 0 – technische Risikovalidierung

## Regeln

- Minimal-UI; keine Produktfeatures vorziehen.
- Jeder Lauf speichert Datum, Git SHA, App Build, Gerät, iOS, Batterie/Low Power/Thermal, Berechtigungen, Audio-Route und Ergebnis.
- Logs und exportierte SQLite-Datei werden als Artefakt gesichert; keine privaten Testaufnahmen committen.
- `pass` erfordert reproduzierbares Verhalten und definierte Akzeptanzkriterien. Ein einzelner Erfolg ist kein Zuverlässigkeitsnachweis.

## Gates

| Gate | Test | Akzeptanz | aktueller Status |
|---|---|---|---|
| P0-G1 | macOS Build Pipeline | format/analyze/tests plus unsignierter Simulator-Build auf jedem PR; signierter Device-Build dokumentiert | not yet run |
| P0-G2 | BirdNET echtes iPhone | Golden-Output plausibel; 30 min foreground + 30 min locked/background; Latenz, Drop, Thermal protokolliert | not yet device tested |
| P0-G3 | GPS + BirdNET | beide 30 min locked/background; monotone persistierte Punkte/Detections; Verlustfenster gemessen | not yet device tested |
| P0-G4 | Audio Recovery | Call, Siri, Bluetooth/AirPods, Route Change, Interruption, Media Reset; jede Transition geloggt; Recovery oder terminaler Fehler | not yet device tested |
| P0-G5 | Prozessabbruch | Crash/Systemtermination/Force Quit unterscheiden soweit möglich; offene Session beim Relaunch konsistent finalisiert; Watchdog vorsichtig | not yet device tested |
| P0-G6 | Offline Map | lizenziertes Gebiet laden, Flugmodus, Start/Pan/Zoom/GPS/eigene Layer; Attribution sichtbar | not yet device tested |
| P0-G7 | CloudKit | zwei Installationen: CRUD, offline merge, Konflikt, Tombstone, Duplikat, TrackChunk, Account/Quota-Fehler | not yet device tested |

## Zusätzlich notwendige Matrizen

Mindestens je ein unterstütztes älteres Gerät und aktuelles Gerät; jeweils aktuelle Release-iOS-Version. Für P0-G2/G3 zusätzlich Normal/Low Power und Thermal nominal/serious soweit reproduzierbar. Bluetooth-Eingang darf nicht angenommen werden: tatsächliche `AVAudioSession`-Route und Sample Rate protokollieren.

## Evidenzvorlage

```yaml
gate: P0-Gx
git_sha:
build:
device_model:
ios_version:
started_utc:
duration_minutes:
power_mode:
thermal_states_seen: []
audio_routes_seen: []
permissions: {}
expected:
observed:
metrics: {}
artifacts: []
result: pass|conditional-pass|fail|blocked
notes:
```

## BLOCKER-Format

```text
BLOCKER
Anforderung:
Ursache:
Betroffene iOS-API/technische Grenze:
Getestetes Verhalten und Evidenz:
Option A:
Option B:
Empfehlung:
Sicherer Fallback:
```

## Verbotene Schlussfolgerungen

- Simulatorerfolg beweist kein Background-Audio/GPS.
- 30 Minuten beweisen keine Garantie für beliebige Dauer.
- fehlende Watchdog-Notification beweist keinen gesunden Prozess.
- zwei ähnliche überlappende Fenster sind keine unabhängigen Treffer.
- ein erfolgreicher CloudKit-Lauf beweist keine Konflikt- oder Quota-Sicherheit.
