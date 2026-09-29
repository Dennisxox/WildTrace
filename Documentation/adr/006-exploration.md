# ADR-006: Gekachelte Exploration statt wachsendem MultiPolygon

Status: proposed

## Problem

Eine globale Union gepufferter Tracks wächst teuer, ist konfliktanfällig und schlecht synchronisierbar.

## Entscheidung

Raw Tracks bleiben Source of Truth; Exploration wird als versionierte, komprimierte Rasterkachel/Bitmaske je Korridorradius abgeleitet.

## Konsequenzen

Inkrementelles Rendern/Sync wird einfach; Genauigkeit hängt von Zellauflösung ab und muss sichtbar dokumentiert werden. Radiuswechsel löst Rebuild aus.
