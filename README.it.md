<p align="center">
  <a href="README.md">English</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.zh-TW.md">繁體中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a><br>
  <a href="README.de.md">Deutsch</a> · <a href="README.es.md">Español</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.vi.md">Tiếng Việt</a> · <a href="README.id.md">Bahasa Indonesia</a> · <strong>Italiano</strong>
</p>

<p align="center"><img src="assets/wifi-spectrum.png" width="112" alt="Icona di Wi-Fi Spectrum"></p>
<h1 align="center">Strumenti di rete Wi-Fi per iPhone</h1>
<p align="center">Wi-Fi Spectrum (Wi-Fi 頻譜分析儀) · rete attuale · test di velocità · LAN · calcolatore di canali</p>
<p align="center">
  <a href="https://github.com/tonykfr1234/ios_wifi-spectrum/actions/workflows/security.yml"><img src="https://github.com/tonykfr1234/ios_wifi-spectrum/actions/workflows/security.yml/badge.svg" alt="CI"></a>
  <img src="https://img.shields.io/badge/platform-iOS%2016%2B-000000" alt="iOS 16+">
  <img src="https://img.shields.io/badge/Swift-6.1-F05138" alt="Swift 6.1">
  <img src="https://img.shields.io/badge/SwiftUI-iPhone-0A84FF" alt="SwiftUI">
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-green" alt="Licenza MIT"></a>
</p>
<p align="center">
  <a href="#quick-start">Avvio rapido</a> · <a href="#workflow">Funzionamento</a> · <a href="#features">Funzionalità</a> · <a href="#demo">Demo</a> · <a href="#faq">FAQ</a> · <a href="#documentation">Documentazione</a>
</p>

```bash
brew install xcodegen && xcodegen generate && open WifiSpectrum.xcodeproj
```

---

Versione 1.0: tutto ciò che iOS lascia vedere a un'app sul Wi-Fi, più test di velocità, scoperta LAN e cinque strumenti di rete. Le regole dei canali sono le stesse dell'app Android.

Wi-Fi Spectrum per iOS mostra SSID, BSSID con il produttore, tipo di sicurezza, indirizzi e sottorete della rete attuale; misura download, upload, latenza e jitter; trova i dispositivi della rete locale; e offre latenza TCP, DNS, scansione delle porte, un calcolatore di canali per 2,4/5/6 GHz e 20–320 MHz e un calcolatore di sottoreti.

Apple non concede alle app l'accesso a reti vicine, canali, larghezze di canale, intensità del segnale o Wi-Fi 7 MLO, quindi questa app non li promette. Per un'analisi completa dello spettro usa la versione Android, [Android_wifi-spectrum](https://github.com/tonykfr1234/android_wifi-spectrum).

Le 12 lingue del README traducono la documentazione. L'interfaccia dell'app è attualmente in cinese tradizionale.

<a id="quick-start"></a>
## Avvio rapido

1. Su un Mac con Xcode 16+, clona questo repository ed esegui il comando sopra (installa XcodeGen, genera il progetto, apre Xcode).
2. Seleziona il target `WifiSpectrum`, scegli il tuo team in Signing & Capabilities e verifica che compaia Access Wi-Fi Information.
3. Avvia su un iPhone con iOS 16+. Consenti la posizione (solo per il nome del Wi-Fi) e, alla prima scansione LAN, «Rete locale».
4. Il simulatore non ha informazioni Wi-Fi; attiva la modalità demo nella scheda 關於 per vedere tutte le schermate con dati sintetici.
5. Ogni push esegue i test su GitHub Actions; log e screenshot del simulatore finiscono nel branch `ci-artifacts`.

**Pubblicare sull'App Store?** Segui [docs/PUBLISHING.zh-TW.md](docs/PUBLISHING.zh-TW.md) ([riepilogo in inglese](docs/PUBLISHING.md)): imposta bundle ID e team, archivia, carica, prova con TestFlight e invia con le note di revisione già pronte.

<a id="workflow"></a>
## Funzionamento

```text
Si apre la scheda 連線
  → posizione consentita? NEHotspotNetwork.fetchCurrent → SSID, BSSID, sicurezza
  → BSSID → produttore IEEE offline (MAC casuali segnalati)
  → getifaddrs + NWPathMonitor → IPv4, maschera, sottorete, IPv6, stato del percorso
LAN: Bonjour (10 tipi di servizio) + scansione TCP di 6 porte sulla /24
Velocità: 10 andate e ritorni HTTPS, 3 download, 3 upload → mediane
```

Nulla gira in background e nulla resta salvato dopo la chiusura. Le reti con più di 1.024 indirizzi non vengono scansionate. La latenza è il tempo di connessione TCP, perché iOS non consente l'ICMP alle app normali.

<a id="features"></a>
## Funzionalità

| Funzione | Comportamento |
| --- | --- |
| Wi-Fi attuale | SSID, BSSID, produttore dal registro IEEE, tipo di sicurezza (iOS 15+) |
| Interfaccia | IPv4, maschera, sottorete e numero di host, IPv6, modalità dati ridotti e rete a consumo |
| Test di velocità | Endpoint Cloudflare; mediana di 3 download e 3 upload; latenza e jitter; annullabile; cronologia di 20 |
| Scoperta LAN | Nomi Bonjour e host che rispondono su 80/443/22/445/554/62078; avanzamento e arresto |
| Calcolatore di canali | 2,4/5/6 GHz, 20–320 MHz: intervallo occupato, canali centrale e coperti, PSC, DFS, sottobanda UNII |
| Strumenti di rete | Latenza TCP con perdita e jitter, DNS A/AAAA/CNAME, scansione delle 19 porte comuni o di un intervallo |
| Calcolatore di sottoreti | CIDR o maschera → rete, broadcast, intervallo e numero di host |
| Privacy | Nessuna raccolta dati, pubblicità o analisi; manifesto della privacy incluso |

iOS non fornisce reti vicine, canali, larghezze, RSSI o MLO; il calcolatore applica le stesse regole che l'app Android usa sui risultati delle scansioni. I risultati LAN non hanno produttore perché iOS nasconde gli indirizzi MAC degli altri dispositivi.

<a id="demo"></a>
## Demo

Queste schermate sono state catturate dai **test dell'interfaccia nel simulatore iPhone in modalità demo**: la vera interfaccia dell'app con lo stesso appartamento sintetico di Taipei della demo Android. Non è una rete reale e non mostra le prestazioni di alcun dispositivo.

![Presentazione dell'app iOS in modalità demo](docs/media/wifi-spectrum-ios-demo.gif)

[Apri o scarica la demo MP4](docs/media/wifi-spectrum-ios-demo.mp4)

| Rete attuale | Test di velocità | Calcolatore di canali |
| --- | --- | --- |
| ![Rete attuale](docs/media/connection.png) | ![Test di velocità](docs/media/speedtest.png) | ![Calcolatore di canali](docs/media/channel-calculator.png) |

## Ultime modifiche

Prima versione con dettagli della rete attuale, test di velocità, scoperta LAN, cinque strumenti, modalità demo, guida all'App Store e CI che esegue 48 test su Linux, macOS e simulatore iPhone. Vedi il [registro delle modifiche](CHANGELOG.md).

<a id="controls"></a>
## Comandi

| Comando | Azione |
| --- | --- |
| Trascina giù / ↻ (連線) | Rileggi il Wi-Fi e l'interfaccia |
| 開始測速 / 停止 (測速) | Avvia o annulla il test di velocità |
| 開始掃描 / 停止掃描 (區網) | Avvia o ferma la scoperta LAN |
| Selettori banda / canale / larghezza | Ricalcola; le larghezze non valide non vengono proposte |
| Strumenti → campo host | Inserisci un nome o un IP; gli errori di formato vengono spiegati prima di inviare |
| 關於 → 示範模式 | Passa tra dati reali e ambiente sintetico |

<a id="faq"></a>
## FAQ

**Perché non mostra reti vicine o canali?** Apple non offre un'API pubblica e la revisione rifiuta le API private. Per l'analisi dello spettro usa la versione Android.

**Perché chiede la posizione?** iOS rivela SSID e BSSID attuali solo alle app con permesso di posizione. L'app non legge mai le coordinate.

**Perché il simulatore dice che non sono connesso?** Il simulatore non ha informazioni Wi-Fi. Attiva la modalità demo nella scheda 關於.

**Perché la scansione LAN non trova nulla?** Consenti «Rete locale» in Impostazioni → Privacy e sicurezza e verifica che il router non isoli i client wireless.

**A cosa si collega il test di velocità?** Agli endpoint pubblici di Cloudflare su speed.cloudflare.com. Un test usa circa 100 MB.

<a id="docs"></a>
<a id="documentation"></a>
## Documentazione

| Argomento | Documento |
| --- | --- |
| Uso quotidiano | [繁中使用指南](docs/USER_GUIDE.zh-TW.md) · [English User Guide](docs/USER_GUIDE.md) |
| Funzionamento interno | [Architettura](docs/ARCHITECTURE.md) |
| Pubblicazione | [Guida App Store (繁中)](docs/PUBLISHING.zh-TW.md) · [Riepilogo in inglese](docs/PUBLISHING.md) · [Informativa sulla privacy](docs/PRIVACY.md) |
| Versioni e sicurezza | [Registro delle modifiche](CHANGELOG.md) · [Sicurezza](SECURITY.md) · [Contribuire](CONTRIBUTING.md) |

L'app è in `App/`, la logica condivisa nel pacchetto Swift `Core/`, i test in `Core/Tests`, `AppTests` e `AppUITests`, gli strumenti in `scripts/`. Il progetto è generato da `project.yml`. Verifica SSID, LAN e velocità su un iPhone reale; il simulatore non può farlo.

## Sicurezza

Non fare mai commit di certificati, profili di provisioning, chiavi API di App Store Connect, file `.ipa` o scansioni di reti altrui. Prima del push, esegui lo stesso scanner usato da GitHub Actions:

```bash
python scripts/security_scan.py .
```

## Licenza

[MIT](LICENSE).

### 2026-10-20 · 1.0.0

首次發布：目前連線資訊、測速、區域網路探索、TCP 延遲、DNS、連接埠掃描、頻道與子網路計算機；48 個測試在 Linux、macOS 與 iPhone 模擬器上執行。

First release: current-network details, speed test, LAN discovery, TCP latency, DNS, port scan, channel and subnet calculators; 48 tests run on Linux, macOS and the iPhone simulator.

[Guida pubblica all'uso (cinese tradizionale, testo semplice)](docs/使用說明.txt)
