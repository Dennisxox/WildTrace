# ADR-001: Flutter mit nativen Swift-Diensten

Status: accepted

## Problem

Die Produkt-UI soll plattformweit wartbar sein; iOS-Audio, Location, Lifecycle, Notifications und CKSyncEngine benötigen native Kontrolle.

## Optionen

Reines Flutter mit Plugins; komplett SwiftUI; Flutter plus eigene Swift-Services.

## Entscheidung

Flutter für UI/Domain/Queries, kleine klar versionierte Swift-Dienste über typisierte Channels für iOS-nahe Komponenten.

## Begründung

Entspricht der Spezifikation und hält riskante Lifecycle-Pfade testbar, ohne die ganze App an SwiftUI oder unkontrollierte Plugins zu binden.

## Konsequenzen

Channel-Verträge brauchen Versions- und Integrationstests. Der bestehende SwiftUI-Code ist nur Spike-Material.
