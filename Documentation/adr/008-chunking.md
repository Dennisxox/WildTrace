# ADR-008: Immutable, versionierte Stream-Chunks

Status: proposed

## Problem

TrackPoints und Detections sind zu zahlreich für einzelne CloudKit-Records.

## Entscheidung

Lokale Einzelzeilen; Cloud-Sync über immutable Chunks mit Session, Index, Zeitraum, Count, Codec, SchemaVersion und SHA-256. Korrekturen sind separate Overrides.

## Konsequenzen

Chunker/Decoder benötigen Golden-, Fuzz-, Größen- und Idempotenztests. Zielgröße bleibt konservativ unter CKRecord-Limits; größere Daten als Asset.
