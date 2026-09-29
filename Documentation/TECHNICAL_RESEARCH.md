# Technische Recherche

Stand: 29. September 2026. Quellen sind primär/autoritätsnah; Lizenzfragen sind keine Rechtsberatung.

## iOS Background Audio, GPS und Sperrbildschirm

Apple erlaubt kontinuierliche Location-Updates mit Background Mode und laufendem Core-Location-Service, weist aber darauf hin, dass Apps suspendiert oder beendet werden können. `allowsBackgroundLocationUpdates` benötigt den `location`-Background-Mode. Standard-Location-Updates stoppen nach Terminierung. Audio benötigt eine passende `AVAudioSession`-Kategorie und den Audio-Background-Mode. Interruptions, Route Changes und Media-Services-Reset sind Zustandsübergänge; Apple garantiert kein passendes End-Event zu jeder Unterbrechung. Nach Media-Services-Reset müssen Audioobjekte neu erstellt werden.

Daraus folgt: Display-locked/background ist technisch plausibel, aber kein garantierter Dauerbetrieb; Force Quit bleibt außerhalb der Zusage.

Quellen: [Background location](https://developer.apple.com/documentation/corelocation/handling-location-updates-in-the-background), [`allowsBackgroundLocationUpdates`](https://developer.apple.com/documentation/corelocation/cllocationmanager/allowsbackgroundlocationupdates), [`startUpdatingLocation`](https://developer.apple.com/documentation/CoreLocation/CLLocationManager/startUpdatingLocation%28%29), [AVAudioSession](https://developer.apple.com/documentation/avfaudio/avaudiosession), [Media services reset](https://developer.apple.com/documentation/avfaudio/avaudiosession/mediaserviceswereresetnotification).

## BirdNET

Der offizielle Analyzer-Code ist MIT, die offiziellen Modelle sind laut Projekt CC BY-NC-SA 4.0. V2.4 erwartet 48 kHz und dokumentiert 6.522 Klassen; neuere 3.0-Backends existieren, sind aber nicht automatisch die richtige Mobile-Wahl. Ein Modell darf erst gebundelt werden, wenn konkrete Artefakte, SHA-256, Labels, Geo-Modell, Preprocessing, Laufzeit und Lizenz freigegeben sind.

**BLOCKER B-01:** Ohne geklärtes Geschäftsmodell und gegebenenfalls separate Modelllizenz ist kein kommerzieller App-Release mit dem offiziellen NC-Modell freigegeben. Phase 0 darf ein lokal bezogenes Testartefakt nur für nicht-kommerzielle technische Evaluation verwenden und darf es nicht unbedacht ins Repository committen.

Quellen: [BirdNET model documentation](https://github.com/birdnet-team/BirdNET-Analyzer/blob/main/docs/models.rst), [BirdNET library/license](https://github.com/birdnet-team/birdnet).

## Karte und Offline

MapLibre Native ist BSD-lizenziert; Flutter-Adapter unterstützen iOS/Android, Sources, Offline Regions und PMTiles. Die Engine gewährt aber keine Rechte an Styles/Tiles. Der öffentliche OSM-Rastertile-Server verbietet Offline-/Prefetch-Nutzung und hat kein SLA. Zulässig sind selbst gehostete/erzeugte Tiles oder ein Providervertrag mit ausdrücklichem Offline-Recht. OSM-Daten erfordern ODbL-konforme Attribution.

Empfehlung: MapLibre + Provider-Abstraktion; Phase 0 mit kleinem versionierten PMTiles-Testpaket aus lizenzkonformer Quelle. Produktionsprovider erst nach Kosten-, Offline-, Cache-, Attribution- und Satellitenrechteprüfung auswählen.

Quellen: [MapLibre Flutter](https://github.com/maplibre/flutter-maplibre-gl), [MapLibre Native](https://github.com/maplibre/maplibre-native), [OSM Tile Policy](https://operations.osmfoundation.org/policies/tiles/), [OSM copyright](https://www.openstreetmap.org/copyright).

## CloudKit/CKSyncEngine

CKSyncEngine verwaltet Push/Pull-Scheduling, benötigt aber Delegate, persistierten Engine-State, CloudKit- und Remote-Notification-Entitlements sowie eigene Konfliktbehandlung. Automatische Synchronisation ist zeitlich unbestimmt. CKRecords sollen unter 1 MB Nicht-Asset-Daten bleiben; größere Binärdaten gehören in CKAsset.

Empfehlung: private Custom Zone, native Swift-Bridge, Drift-Outbox, idempotente Imports, Chunks mit konservativem Ziel deutlich unter 1 MB, Audio als CKAsset. Zwei reale Geräte/Installationen sind Pflicht.

Quellen: [CKSyncEngine](https://developer.apple.com/documentation/cloudkit/cksyncengine-4b4w9), [CKRecord size](https://developer.apple.com/documentation/cloudkit/ckrecord), [CKAsset](https://developer.apple.com/documentation/cloudkit/ckasset).

## Flutter SQLite

Drift auf `sqlite3` ist die bevorzugte Option: typisierte Queries/Migrationen, Transaktionen und Background-Isolate; die Native-Implementierung bündelt SQLite. Vor Festlegung werden RTree, WAL, FTS5, Foreign Keys und Backup/Restore auf iOS geprüft. RTree beschleunigt BBox-Kandidaten, ersetzt keine exakte Geometrieprüfung.

Quellen: [Drift native](https://drift.simonbinder.eu/platforms/vm/), [Drift isolates](https://drift.simonbinder.eu/isolates/), [SQLite RTree](https://www.sqlite.org/rtree.html).

## Geometrie

`geobase` deckt Datenstrukturen, Projektionen und geodätische Distanzen ab, aber nicht alle robusten Overlay-Operationen. TurfDart ist nicht vollständig zu Turf.js feature-paritätisch. GEOS bietet robuste Buffer/Union/Intersection, bringt auf iOS jedoch native Integration, Binärgröße und LGPL-Verteilungsfragen mit.

Empfehlung: Phase-0-Golden-Tests mit Antimeridian, Löchern, Self-Intersections und großen Tracks. Für Distanz/Projektion zunächst `geobase`; für robuste Polygon-Overlays GEOS nur nach Lizenz-/Packaging-Gate, sonst tile-/rasterbasierte Exploration ohne globale Polygon-Union.

Quellen: [geobase](https://pub.dev/packages/geobase), [TurfDart](https://pub.dev/packages/turf), [GEOS C API](https://libgeos.org/usage/c_api/).

## Externe Beobachtungen

BirdWeather dokumentiert eine V1-API; Tokens sind Geheimnisse und dürfen nicht als globaler Admin-Token in der App liegen. Vertrag, Rate Limits und Weiterverwendung müssen mit konkreten Endpoints verifiziert werden. iNaturalist begrenzt auf maximal 100 Requests/min und empfiehlt etwa 60/min bzw. 10.000/Tag; Bulk-Download ist nicht Zweck der API. Externe Datensätze bleiben Caches und getrennt von persönlichen Nachweisen.

Quellen: [BirdWeather API v1](https://app.birdweather.com/api/v1), [iNaturalist developers](https://www.inaturalist.org/pages/developers), [iNaturalist API practices](https://www.inaturalist.org/pages/api%2Brecommended%2Bpractices).

## Wetter

Open-Meteo ist für Prototyping geeignet: Daten CC BY 4.0, freie API nur nicht-kommerziell und limitiert; kommerzielle Apps benötigen Plan oder Self-Hosting. Provider/Modell und Attribution müssen im Snapshot erhalten bleiben.

Quellen: [Open-Meteo terms](https://open-meteo.com/en/terms), [Pricing/licence](https://open-meteo.com/en/pricing), [API](https://open-meteo.com/en/docs).

## Habitat und Schutzgebiete

OSM kann Habitat-/Landuse-Hinweise liefern, ist aber keine wissenschaftlich vollständige Habitatkartierung. Öffentliche Overpass-Instanzen sind kein Produktionsbackend. EEA/Natura-2000-Daten sind Kandidaten, doch Metadaten können Rechte Dritter enthalten und müssen pro Produkt geprüft werden. Deutschlandweite Schutzgebiete können föderale Quellen mit unterschiedlichen Lizenzen erfordern.

Empfehlung: Provider pro Datensatz/Land; Originalklassifikation, Version, Lizenz und Retrieval-Zeit speichern; keine Vereinheitlichung ohne Mappingversion. Quellen: [EEA Legal Notice](https://www.eea.europa.eu/en/legal-notice), [EEA data policy](https://www.eea.europa.eu/en/datahub/eea-data-policy), [OSM ODbL](https://www.openstreetmap.org/copyright).

## Referenzbilder

Wikimedia Commons ist als erste Quelle geeignet, wenn pro Datei `imageinfo/extmetadata` ausgewertet, zulässige Lizenz/Autor/URL dauerhaft gespeichert und Attribution offline mitgeführt wird. „Wikimedia“ allein ist keine Bildlizenz. Quelle: [Wikimedia Commons API](https://commons.wikimedia.org/wiki/Commons%3AAPI).

## Privacy und App Store

Mikrofon/Standort werden kontextbezogen angefragt. `PrivacyInfo.xcprivacy` muss eigene und SDK-Nutzung sowie Required-Reason-APIs beschreiben; App Store Connect benötigt Datenschutzangaben und eine Privacy-Policy-URL. Quellen: [Privacy manifests](https://developer.apple.com/documentation/BundleResources/privacy-manifest-files), [App privacy](https://developer.apple.com/help/app-store-connect/manage-app-information/manage-app-privacy).
