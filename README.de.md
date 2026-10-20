<p align="center">
  <a href="README.md">English</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.zh-TW.md">繁體中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a><br>
  <strong>Deutsch</strong> · <a href="README.es.md">Español</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.vi.md">Tiếng Việt</a> · <a href="README.id.md">Bahasa Indonesia</a> · <a href="README.it.md">Italiano</a>
</p>

<p align="center"><img src="assets/wifi-spectrum.png" width="112" alt="Wi-Fi-Spectrum-Symbol"></p>
<h1 align="center">WLAN-Netzwerkwerkzeuge für das iPhone</h1>
<p align="center">Wi-Fi Spectrum (Wi-Fi 頻譜分析儀) · aktuelles Netz · Geschwindigkeitstest · LAN · Kanalrechner</p>
<p align="center">
  <a href="https://github.com/tonykfr1234/ios_wifi-spectrum/actions/workflows/security.yml"><img src="https://github.com/tonykfr1234/ios_wifi-spectrum/actions/workflows/security.yml/badge.svg" alt="CI"></a>
  <img src="https://img.shields.io/badge/platform-iOS%2016%2B-000000" alt="iOS 16+">
  <img src="https://img.shields.io/badge/Swift-6.1-F05138" alt="Swift 6.1">
  <img src="https://img.shields.io/badge/SwiftUI-iPhone-0A84FF" alt="SwiftUI">
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-green" alt="MIT-Lizenz"></a>
</p>
<p align="center">
  <a href="#quick-start">Schnellstart</a> · <a href="#workflow">Ablauf</a> · <a href="#features">Funktionen</a> · <a href="#demo">Demo</a> · <a href="#faq">FAQ</a> · <a href="#documentation">Dokumentation</a>
</p>

```bash
brew install xcodegen && xcodegen generate && open WifiSpectrum.xcodeproj
```

---

Version 1.0: alles, was iOS einer App über das WLAN verrät, dazu Geschwindigkeitstest, LAN-Suche und fünf Netzwerkwerkzeuge. Die Kanalregeln sind dieselben wie in der Android-App.

Wi-Fi Spectrum für iOS zeigt SSID, BSSID samt Hersteller, Verschlüsselung, Adressen und Subnetz des aktuellen Netzes, misst Download, Upload, Latenz und Jitter, findet Geräte im lokalen Netz und bietet TCP-Latenz, DNS, Portscan, einen Kanalrechner für 2,4/5/6 GHz mit 20–320 MHz und einen Subnetzrechner.

Apple gibt Apps keinen Zugriff auf Netze in der Nähe, Kanäle, Kanalbreiten, Signalstärke oder Wi-Fi 7 MLO, daher behauptet diese App das auch nicht. Für eine vollständige Spektrumanalyse gibt es die Android-Version [Android_wifi-spectrum](https://github.com/tonykfr1234/android_wifi-spectrum).

Die 12 README-Sprachen übersetzen die Dokumentation. Die App-Oberfläche ist derzeit in traditionellem Chinesisch.

<a id="quick-start"></a>
## Schnellstart

1. Klone dieses Repository auf einem Mac mit Xcode 16+ und führe den Befehl oben aus (installiert XcodeGen, erzeugt das Projekt, öffnet Xcode).
2. Wähle das Ziel `WifiSpectrum`, unter Signing & Capabilities dein Team und prüfe, dass Access Wi-Fi Information aufgeführt ist.
3. Starte die App auf einem iPhone mit iOS 16+. Erlaube den Standort (nur für den WLAN-Namen) und beim ersten LAN-Scan „Lokales Netzwerk“.
4. Der Simulator hat keine WLAN-Daten; schalte im Tab 關於 den Demomodus ein, um alle Ansichten mit synthetischen Daten zu sehen.
5. Jeder Push führt die Tests in GitHub Actions aus; Logs und Simulator-Screenshots landen im Branch `ci-artifacts`.

**Veröffentlichung im App Store?** Folge [docs/PUBLISHING.zh-TW.md](docs/PUBLISHING.zh-TW.md) ([englische Zusammenfassung](docs/PUBLISHING.md)): Bundle-ID und Team setzen, archivieren, hochladen, mit TestFlight testen und mit den vorbereiteten Prüfhinweisen einreichen.

<a id="workflow"></a>
## Ablauf

```text
Tab 連線 öffnet sich
  → Standort erlaubt? NEHotspotNetwork.fetchCurrent → SSID, BSSID, Verschlüsselung
  → BSSID → IEEE-Hersteller offline nachschlagen (zufällige MACs werden markiert)
  → getifaddrs + NWPathMonitor → IPv4, Maske, Subnetz, IPv6, Pfadstatus
LAN: Bonjour (10 Diensttypen) + TCP-Prüfung von 6 Ports im /24
Geschwindigkeit: 10 HTTPS-Roundtrips, 3 Downloads, 3 Uploads → Mediane
```

Im Hintergrund läuft nichts, und nach dem Schließen bleibt nichts gespeichert. Netze mit mehr als 1.024 Adressen werden nicht gescannt. Die Latenz ist die TCP-Verbindungszeit, weil iOS normalen Apps kein ICMP erlaubt.

<a id="features"></a>
## Funktionen

| Funktion | Verhalten |
| --- | --- |
| Aktuelles WLAN | SSID, BSSID, Hersteller aus dem IEEE-Register, Verschlüsselung (iOS 15+) |
| Schnittstelle | IPv4, Maske, Subnetz und Hostanzahl, IPv6, Modus für geringe Datennutzung und getaktete Netze |
| Geschwindigkeitstest | Cloudflare-Endpunkte; Median aus 3 Downloads und 3 Uploads; Latenz und Jitter; abbrechbar; Verlauf mit 20 Ergebnissen |
| LAN-Suche | Bonjour-Namen und Hosts, die auf 80/443/22/445/554/62078 antworten; Fortschritt und Stopp |
| Kanalrechner | 2,4/5/6 GHz, 20–320 MHz: belegter Bereich, Mitten- und überdeckte Kanäle, PSC, DFS, UNII-Teilband |
| Netzwerkwerkzeuge | TCP-Latenz mit Verlust und Jitter, DNS A/AAAA/CNAME, Portscan der 19 üblichen Ports oder eines Bereichs |
| Subnetzrechner | CIDR oder Maske → Netz, Broadcast, Hostbereich und -anzahl |
| Datenschutz | Keine Datenerfassung, Werbung oder Analyse; Privacy Manifest enthalten |

iOS liefert keine Netze in der Nähe, Kanäle, Breiten, RSSI oder MLO; der Kanalrechner nutzt dieselben Regeln, die die Android-App auf Scanergebnisse anwendet. LAN-Ergebnisse haben keinen Hersteller, weil iOS die MAC-Adressen anderer Geräte verbirgt.

<a id="demo"></a>
## Demo

Diese Ansichten wurden von den **UI-Tests im iPhone-Simulator im Demomodus** aufgenommen: die echte App-Oberfläche mit derselben synthetischen Wohnung in Taipeh wie in der Android-Demo. Es ist kein echtes Netz und zeigt nicht die Leistung eines bestimmten Geräts.

![Rundgang durch die iOS-App im Demomodus](docs/media/wifi-spectrum-ios-demo.gif)

[MP4-Demo öffnen oder herunterladen](docs/media/wifi-spectrum-ios-demo.mp4)

| Aktuelles Netz | Geschwindigkeitstest | Kanalrechner |
| --- | --- | --- |
| ![Aktuelles Netz](docs/media/connection.png) | ![Geschwindigkeitstest](docs/media/speedtest.png) | ![Kanalrechner](docs/media/channel-calculator.png) |

## Neueste Änderungen

Erste Veröffentlichung mit Netzdetails, Geschwindigkeitstest, LAN-Suche, fünf Werkzeugen, Demomodus, App-Store-Anleitung und CI, die 48 Tests unter Linux, macOS und im iPhone-Simulator ausführt. Siehe [Changelog](CHANGELOG.md).

<a id="controls"></a>
## Bedienung

| Bedienelement | Aktion |
| --- | --- |
| Herunterziehen / ↻ (連線) | WLAN- und Schnittstellendaten neu laden |
| 開始測速 / 停止 (測速) | Geschwindigkeitstest starten oder abbrechen |
| 開始掃描 / 停止掃描 (區網) | LAN-Suche starten oder stoppen |
| Band-/Kanal-/Breitenauswahl | Neu berechnen; unzulässige Breiten werden nicht angeboten |
| Werkzeuge → Hostfeld | Hostname oder IP eingeben; Formatfehler werden vor dem Senden erklärt |
| 關於 → 示範模式 | Zwischen echten Daten und synthetischer Umgebung wechseln |

<a id="faq"></a>
## FAQ

**Warum zeigt die App keine Netze oder Kanäle in der Nähe?** Apple bietet dafür keine öffentliche Schnittstelle. Private Schnittstellen lehnt die App-Prüfung ab. Für Spektrumanalyse gibt es die Android-Version.

**Warum braucht die App den Standort?** iOS verrät SSID und BSSID nur Apps mit Standortberechtigung. Die App liest keine Koordinaten.

**Warum meldet der Simulator, ich sei nicht verbunden?** Der Simulator hat keine WLAN-Daten. Schalte im Tab 關於 den Demomodus ein.

**Warum findet der LAN-Scan nichts?** Erlaube „Lokales Netzwerk“ unter Einstellungen → Datenschutz & Sicherheit und prüfe, ob der Router WLAN-Clients isoliert.

**Wohin verbindet sich der Geschwindigkeitstest?** Zu den öffentlichen Cloudflare-Endpunkten auf speed.cloudflare.com. Ein Durchlauf verbraucht etwa 100 MB.

<a id="docs"></a>
<a id="documentation"></a>
## Dokumentation

| Thema | Dokument |
| --- | --- |
| Täglicher Betrieb | [繁中使用指南](docs/USER_GUIDE.zh-TW.md) · [English User Guide](docs/USER_GUIDE.md) |
| Interna | [Architektur](docs/ARCHITECTURE.md) |
| Veröffentlichung | [App-Store-Anleitung (繁中)](docs/PUBLISHING.zh-TW.md) · [Englische Zusammenfassung](docs/PUBLISHING.md) · [Datenschutzerklärung](docs/PRIVACY.md) |
| Versionen und Sicherheit | [Changelog](CHANGELOG.md) · [Sicherheit](SECURITY.md) · [Mitwirken](CONTRIBUTING.md) |

Die App liegt in `App/`, gemeinsame Logik im Swift-Paket `Core/`, Tests in `Core/Tests`, `AppTests` und `AppUITests`, Werkzeuge in `scripts/`. Die Projektdatei wird aus `project.yml` erzeugt. SSID-, LAN- und Geschwindigkeitswerte musst du auf einem echten iPhone prüfen; der Simulator kann das nicht.

## Sicherheit

Committe niemals Zertifikate, Provisioning-Profile, App-Store-Connect-API-Schlüssel, `.ipa`-Dateien oder Scans fremder Netze. Führe vor dem Push denselben Scanner wie GitHub Actions aus:

```bash
python scripts/security_scan.py .
```

## Lizenz

[MIT](LICENSE).

### 2026-10-20 · 1.0.0

首次發布：目前連線資訊、測速、區域網路探索、TCP 延遲、DNS、連接埠掃描、頻道與子網路計算機；48 個測試在 Linux、macOS 與 iPhone 模擬器上執行。

First release: current-network details, speed test, LAN discovery, TCP latency, DNS, port scan, channel and subnet calculators; 48 tests run on Linux, macOS and the iPhone simulator.

[Öffentliche Kurzanleitung (traditionelles Chinesisch, Text)](docs/使用說明.txt)
