# ADR-002: MapLibre und Providertrennung

Status: proposed, Phase-0-Gate offen

## Problem

Online-/Offlinekarten, Clustering und Layer dürfen nicht an einen Tilevertrag gekoppelt sein.

## Optionen

Apple MapKit; proprietäres SDK; MapLibre mit austauschbaren Styles/Tiles/Offlinepaketen.

## Entscheidung

MapLibre bevorzugen; `MapEngine`, `MapStyleProvider` und `OfflineMapProvider` trennen. Phase 0 muss Flutter-Adapter, PMTiles/Offline und große Sources auf iOS bestätigen.

## Konsequenzen

Tile-/Style-/Satellitenrechte bleiben separate Produktentscheidungen. Öffentliche OSM-Standardtiles sind für Offline verboten.
