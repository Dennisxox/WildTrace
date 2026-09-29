# ADR-007: Geodäsie in Dart, robuste Overlays nur nach Spike

Status: proposed

## Problem

Gradkoordinaten sind ungeeignet für Meter/Flächen; reine Dart-Bibliotheken decken robuste Overlay-Operationen nicht sicher vollständig ab.

## Entscheidung

Geobase für Repräsentation/Projektion/Distanzen evaluieren. GEOS nur nach iOS-Packaging-, Lizenz-, Binärgrößen- und Robustheitstest. Exploration soll Overlay-Union möglichst vermeiden.

## Konsequenzen

Golden-Geometrien und CRS-Metadaten werden Pflicht. Kein selbstgeschriebener Polygonkern.
