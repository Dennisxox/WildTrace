# Datenmodell und Datenbankentwurf

Status: logischer Entwurf; Drift-Schema entsteht erst nach Phase-0-Persistenzgate.

## Gemeinsame Konventionen

- UUID als 16-Byte-BLOB, UTC als Integer-Mikrosekunden.
- Synchronisierbare Datensätze: `id`, `created_at`, `updated_at`, `device_id`, `sync_version`, `deleted_at`.
- Ortsbezogene Events speichern WGS84 plus Accuracy. Geometrien als versioniertes WKB/Binärformat; BBox separat.
- Enums sind stabile Codes mit Unknown-Fallback.
- Rohereignisse werden nicht kaskadierend gelöscht. Audio/Cache darf ohne Domainverlust entfernt werden.

## Kernbeziehungen

```text
daily_record 1 <- calendar membership -> N recording_session
recording_session 1 -> N track_point -> N track_chunk
recording_session 1 -> N detection -> N detection_override
taxon 1 -> N detection -> 0..1 encounter
taxon 1 -> N observation
encounter 1 -> N detection; 0..1 audio_clip
weather_snapshot/habitat_snapshot <- detection|encounter|observation
area N <-> N observation|encounter via area_membership
sync_outbox -> any syncable entity; tombstone mirrors deletions
```

## Tabellen

| Tabelle | Wesentliche Felder/Constraints |
|---|---|
| `taxon` | UUID PK, scientific_name, rank, group_code, accepted_taxon_id?, taxonomy_version |
| `taxon_alias` | taxon_id FK, alias, locale, alias_type; unique(taxon_id, alias, locale) |
| `taxon_external_identifier` | taxon_id, provider, external_id; unique(provider, external_id) |
| `taxon_profile` | taxon_id, locale, Texte, source/version/attribution, fetched/expires |
| `observation` | taxon_id, observed_at, local_day_key, timezone_id, offset, location/accuracy, count, sex/age, evidence_status, method, indirect_evidence, note |
| `recording_session` | start/end, timezone-at-start, device/model manifest, component states, termination_reason, heartbeat_at |
| `track_point` | session_id, sequence_no, timestamp, lat/lon/altitude, accuracies, speed/course, quality_flags; unique(session_id, sequence_no) |
| `track_chunk` | session_id, chunk_index, start/end, bbox, count, codec, payload, checksum, schema; unique(session_id, chunk_index) |
| `detection` | taxon_id?, raw_label, timestamp/window, location/accuracy, confidence, model/geo/labels/preprocess versions, session/snapshots/audio/device |
| `detection_override` | detection_id, status, author_device, reason, updated_at, sync_version |
| `detection_chunk` | session_id, chunk_index, start/end, count, codec, payload/checksum/schema; unique(session_id, chunk_index) |
| `encounter` | taxon_id, session_id, start/end, count, highest_confidence, representative location, snapshots, notes, status, algorithm_version |
| `duplicate_group` | taxon_id, start/end, algorithm_version; Mitglieder aus mehreren Geräten |
| `daily_record` | local_day_key + timezone_id, Metrics-Cache, data_revision, algorithm_version, note |
| `weather_snapshot` | timestamp, location, Variablen+Einheiten, provider/model/version, attribution |
| `habitat_snapshot` | location/geometry ref, normalized/original class, source/version, mapping_version, attribution |
| `area` | name/type/source, WKB, bbox, geometry_hash, note, automatic_rule_version? |
| `area_membership` | area_id, entity_type/id, relation, algorithm_version, geometry_hash |
| `exploration_tile` | scheme/version/z/x/y, cell_resolution, compressed_bitset, track_revision, corridor_m, checksum |
| `target_species` | taxon_id, area_id?, active, note, notification policy |
| `personal_marker` | name, note, category, lat/lon |
| `audio_clip` | encounter/detection ref, path, codec/rate/channels, start/end, checksum, size, retention_reason, protection, sync_state |
| `audio_policy` | scope(global/taxon), taxon_id?, strategy, limit_value? |
| `recording_health_event` | session_id, timestamp, component, state, severity, code, redacted_details, sequence |
| `notification_event` | encounter_id?, type, scheduled/sent/cancelled, dedupe_key unique |
| `external_observation_cache` | provider + provider_id unique, source/mapped taxon, source time, fetched/expires, precision, bbox, payload, attribution |
| `reference_image_cache` | taxon_id, provider/file_id, path, author, license URLs, checksum, fetched/expires |
| `synced_preferences` | profile_id, schema_version, JSON, sync metadata |
| `device_preferences` | device_id PK, schema_version, JSON; niemals synchronisiert |
| `sync_metadata` | entity type/id, record/zone, server tag, last version, state |
| `sync_outbox` | sequence PK, entity type/id, operation, version, retry state |
| `tombstone` | entity type/id, deleted_at, device, version, purge_after |
| `provider_cache_tile` | provider, z/x/y, time/filter hash, payload, fetched/expires, etag, attribution |
| `model_manifest` | kind/version/hash/license, label hash, sample rate/window/preprocess, installed/active |
| `data_revision` | domain PK, monotone Revision für Cacheinvalidierung |

## Wichtige Indizes

- `track_point(session_id, timestamp)` und `(session_id, sequence_no)`.
- `detection(session_id, timestamp)`, `(taxon_id, timestamp)`, `(encounter_id)`.
- `encounter(taxon_id, start_time)`, `(session_id, start_time)`, `(status, start_time)`.
- `observation(taxon_id, observed_at)`, `(local_day_key)`, `(evidence_status, observed_at)`.
- `recording_health_event(session_id, sequence)`.
- `sync_outbox(next_attempt_at, sequence)` und `tombstone(purge_after)`.
- BBox-RTree für Observation, Encounter, Area, TrackChunk und External Cache; Fallback-B-Tree-Indizes auf BBox-Spalten.
- FTS5 für Namen, Aliase, Gebiete und Marker; Fallback mit normalisierten Präfixspalten.

## Zeitmodell

Eventzeit bleibt UTC. `timezone_id`, `utc_offset_seconds` und `local_day_key` werden am Ereignis gespeichert. Session-Metriken werden an echten lokalen Kalendergrenzen geteilt, nicht durch 24-Stunden-Division. Bei Zeitzonenwechseln bleibt die ursprüngliche Zuordnung reproduzierbar.

## Chunkformate

```text
magic | schemaVersion | entityKind | sessionUUID | chunkIndex
startUTC | endUTC | count | codec | uncompressedBytes | checksumSHA256 | payload
```

Track-Payload: erster Punkt vollständig, danach delta-kodierte Zeit/Koordinaten/Optionals; sortiert und sequenziert. Detection-Payload: UUID, Zeit/Location/Confidence/Modelreferenzen; Taxa als UUID/Stringtable. Der Decoder lehnt unbekannte Major-Versionen, falsche Checksums, Duplikat-UUIDs und unbegrenzte Allokationen ab.

## Löschung und Integrität

Normale Löschung setzt `deleted_at` und erzeugt im selben Commit Outbox+Tombstone. Rejected Detections bleiben. Cache-/Audio-Dateilöschung ändert niemals Detection/Encounter/Observation. Physisches Purging benötigt bestätigte Syncperiode, Backup-Policy und referenzielle Prüfung.
