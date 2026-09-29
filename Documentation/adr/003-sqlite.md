# ADR-003: Drift/SQLite als lokale Source of Truth

Status: proposed, Capability-Gate offen

## Problem

Millionen Zeit-/Raumpunkte, Migrationen, Transaktionen und kontrollierter Sync benötigen portables relationales Storage.

## Optionen

SwiftData/Core Data; Object Store; SQLite direkt; Drift auf SQLite.

## Entscheidung

Drift auf gebündeltem SQLite im Background-Isolate. Native RTree/FTS/WAL werden zur Laufzeit und in CI geprüft; Fallback-Indizes sind Pflicht.

## Konsequenzen

Schema/Migrationen bleiben unabhängig von CloudKit. Codegenerierung und Performance-Suite werden Buildbestandteil.
