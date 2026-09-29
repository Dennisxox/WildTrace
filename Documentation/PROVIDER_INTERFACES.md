# Provider- und Serviceverträge

Alle Verträge liefern Domain-DTOs, `ProviderAttribution` und typisierte Fehler. Sie erhalten Cancellation/Deadline und dürfen keine UI- oder Persistenzobjekte zurückgeben.

```text
AudioCaptureService
  start(config, sessionId) -> stream<AudioFrame|AudioEvent>
  stop(reason) -> AudioStopReport

LocationService
  start(config, sessionId) -> stream<LocationSample|LocationEvent>
  stop() -> LocationStopReport

InferenceEngine
  load(ModelManifest) -> ModelRuntimeInfo
  infer(AudioWindow, GeoPrior?) -> DetectionCandidate[]

MapEngine
  setStyle(MapStyleDescriptor)
  updateSource(sourceId, revision, featureDelta)
  queryRenderedFeatures(viewport, filter)

OfflineMapProvider
  estimate(region, style) -> OfflineEstimate
  download(request) -> stream<OfflineProgress>
  verify(packageId) -> VerificationReport

ObservationProvider
  capabilities() -> ProviderCapabilities
  fetch(bbox, timeWindow, filters, pageToken?) -> ExternalObservationPage

WeatherProvider
  fetch(location, instant, fields) -> WeatherSnapshotDTO

HabitatProvider / ProtectedAreaProvider
  fetch(bbox, sourceVersion?) -> SpatialFeaturePage

ReferenceImageProvider
  fetch(taxonExternalIds, size) -> LicensedImageDTO

SyncEngine
  enqueue(LocalChange)
  synchronize(reason) -> stream<SyncEvent>
  status() -> SyncStatus
```

`ProviderCapabilities` nennt API-/Schema-Version, räumliche/zeitliche Grenzen, Pagination, Cache-/Offline-Rechte, Lizenz/Attribution, Auth-Modus und Rate-Limit-Hinweise. Ein Adapter wird deaktiviert, wenn die Serverantwort nicht sicher interpretierbar ist.
