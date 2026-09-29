# ADR-004: Kontrollierte CKSyncEngine-Synchronisierung

Status: proposed, Zwei-Geräte-Gate offen

## Problem

Lokale SQLite-Daten sollen optional über iCloud repliziert werden, ohne jede Zeile blind zu spiegeln.

## Entscheidung

Native CKSyncEngine-Bridge, private Custom Zone, persistierter Engine-State, SQLite-Outbox, idempotente Importe, Tombstones und Chunks. Lokale DB bleibt Source of Truth.

## Konsequenzen

Konflikte und Accountwechsel sind Anwendungslogik. Sync darf verzögert sein; offline wird vollständig weitergearbeitet.
