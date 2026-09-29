# Codemagic → TestFlight: sichere Ersteinrichtung

Dieser Weg baut den vorhandenen nativen Phase-0-Spike und verteilt ihn nur an interne TestFlight-Tester. Er ersetzt weder die geplante Flutter-App noch die späteren Hardware-Tests.

## Voraussetzungen

1. GitHub-Account und ein privates Repository.
2. Apple Developer Program; ein kostenloses Personal Team kann nicht zu TestFlight hochladen.
3. App Store Connect mit aktivierter Zwei-Faktor-Authentifizierung.
4. Ein iPhone mit der TestFlight-App und derselben Apple-ID oder einer eingeladenen internen Testperson.

## 1. Quellcode nach GitHub pushen

In PowerShell im Projektordner ausführen. Ersetze `DEIN_GITHUB_NAME` nur im letzten Befehl.

```powershell
git add .
git commit -m "Prepare Phase 0 and Codemagic TestFlight"
git remote add origin "https://github.com/DEIN_GITHUB_NAME/WildTrace.git"
git push -u origin main
```

Das leere private Repository muss vorher auf GitHub angelegt sein. Keine Modelle, Audioaufnahmen, `.p8`, `.p12`, `.mobileprovision` oder Passwörter committen.

## 2. Eindeutige Bundle-ID wählen

In Xcode oder über die GitHub-Datei `WildTrace.xcodeproj/project.pbxproj` muss `PRODUCT_BUNDLE_IDENTIFIER` durch eine weltweit eindeutige Kennung ersetzt werden, beispielsweise `de.deinname.wildtrace.spike`.

Ändere anschließend dieselbe Kennung in `codemagic.yaml` unter `ios-testflight-internal.environment.ios_signing.bundle_identifier`. Beide Werte müssen exakt übereinstimmen. Das vorhandene `com.personal.WildTrace` ist nur ein Platzhalter und darf nicht für eine Verteilung verwendet werden.

## 3. App in App Store Connect anlegen

1. In App Store Connect **Apps → + → New App** wählen.
2. Plattform iOS, Name `WildTrace`, Primärsprache und die identische Bundle-ID auswählen.
3. Die Apple-ID der App notieren; sie ist für spätere automatisierte Versionsnummern nützlich, wird im aktuellen Workflow aber noch nicht benötigt.

## 4. Dedizierten Codemagic-API-Schlüssel anlegen

1. In App Store Connect: **Users and Access → Integrations → App Store Connect API → +**.
2. Name `Codemagic WildTrace`, Rolle **App Manager**.
3. Die `.p8`-Datei sofort einmalig herunterladen sowie Issuer ID und Key ID notieren.
4. In Codemagic: **Team settings → Developer Portal → Manage keys → Add key**.
5. Dort Key, Issuer ID und Key ID eintragen und als Namen exakt `wildtrace_app_store_connect` verwenden.

Die `.p8`-Datei gehört ausschließlich in Codemagic, nie in GitHub oder diesen Chat.

## 5. Signing automatisch verwalten lassen

1. In Codemagic Team settings: **codemagic.yaml settings → Code signing identities**.
2. Unter iOS provisioning profiles über den zuvor hinterlegten API-Key ein Profil für die Bundle-ID mit Typ **App Store** abrufen/erzeugen.
3. Unter iOS certificates eine **Apple Distribution**-Identität über denselben API-Key erzeugen oder eine vorhandene passende Identität verwenden.

Der Workflow ruft passende Files über `distribution_type: app_store` ab und installiert sie mit `xcode-project use-profiles`.

## 6. App mit Codemagic verbinden und erst prüfen

1. In Codemagic **Add application** wählen, GitHub verbinden, das private WildTrace-Repository auswählen und den Typ **Native iOS** wählen.
2. Branch `main` auswählen und `codemagic.yaml` scannen lassen.
3. Zuerst ausschließlich **WildTrace – iOS simulator verification** ausführen.
4. Bei grünem Log erst **WildTrace – TestFlight internal** manuell starten.

Der zweite Workflow erzeugt eine signierte IPA und lädt sie nach App Store Connect hoch. `testFlightInternalTestingOnly` beschränkt den Build auf interne Tester und vermeidet eine externe Beta-Review. Eine Veröffentlichung im App Store ist nicht konfiguriert.

## 7. Auf dem iPhone installieren

1. TestFlight aus dem App Store installieren.
2. In App Store Connect unter **Users and Access** deine Apple-ID als Nutzer mit einer passenden Rolle hinzufügen oder einen vorhandenen internen Benutzer nutzen.
3. Unter **Apps → WildTrace → TestFlight → Internal Testing** eine Gruppe anlegen und den verarbeiteten Build zuordnen.
4. Einladung akzeptieren und WildTrace in TestFlight installieren.

## Grenzen dieses ersten Uploads

- Es ist nur die bestehende SwiftUI-Phase-0-Hülle, keine fertige Flutter-/BirdNET-App.
- TestFlight ersetzt nicht die in `PHASE_0.md` geforderten Hardware-Evidenzen. Dafür bauen wir anschließend eine persistente Diagnose-/Exportfunktion ein.
- Für externe Tester oder einen öffentlichen TestFlight-Link müssen wir einen separaten Workflow mit Apple-Beta-Review konfigurieren.

## Fehlerbehandlung

| Meldung | Wahrscheinliche Ursache | Nächste Aktion |
|---|---|---|
| `No profiles for ...` | Bundle-ID in Projekt/YAML/App Store Connect unterschiedlich | alle drei Werte vergleichen, Profil neu abrufen |
| `No signing certificate` | keine passende Apple-Distribution-Identität | in Codemagic erzeugen/abrufen |
| `bundle identifier is not available` | Identifier bereits vergeben | neuen Reverse-DNS-Identifier wählen |
| `Missing compliance` | Apple wartet auf Export-Compliance-Angabe | in App Store Connect beantworten |
| `ITMS-90683` | Privacy-Purpose-String fehlt | betroffene iOS-API/Info.plist prüfen; nicht blind hinzufügen |

Quellen: [Codemagic native iOS](https://docs.codemagic.io/yaml-quick-start/building-a-native-ios-app/), [Codemagic signing](https://docs.codemagic.io/yaml-code-signing/signing-ios/), [Codemagic App Store Connect publishing](https://docs.codemagic.io/yaml-publishing/app-store-connect/).
