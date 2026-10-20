<p align="center">
  <strong>English</strong> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.zh-TW.md">繁體中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a><br>
  <a href="README.de.md">Deutsch</a> · <a href="README.es.md">Español</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.vi.md">Tiếng Việt</a> · <a href="README.id.md">Bahasa Indonesia</a> · <a href="README.it.md">Italiano</a>
</p>

<p align="center"><img src="assets/wifi-spectrum.png" width="112" alt="Wi-Fi Spectrum icon"></p>
<h1 align="center">Wi-Fi Network Toolkit for iPhone</h1>
<p align="center">Wi-Fi Spectrum (Wi-Fi 頻譜分析儀) · current network · speed test · LAN · channel calculator</p>
<p align="center">
  <a href="https://github.com/tonykfr1234/ios_wifi-spectrum/actions/workflows/security.yml"><img src="https://github.com/tonykfr1234/ios_wifi-spectrum/actions/workflows/security.yml/badge.svg" alt="CI"></a>
  <img src="https://img.shields.io/badge/platform-iOS%2016%2B-000000" alt="iOS 16+">
  <img src="https://img.shields.io/badge/Swift-6.1-F05138" alt="Swift 6.1">
  <img src="https://img.shields.io/badge/SwiftUI-iPhone-0A84FF" alt="SwiftUI">
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-green" alt="MIT License"></a>
</p>
<p align="center">
  <a href="#quick-start">Quick start</a> · <a href="#workflow">Workflow</a> · <a href="#features">Features</a> · <a href="#demo">Demo</a> · <a href="#faq">FAQ</a> · <a href="#documentation">Documentation</a>
</p>

```bash
brew install xcodegen && xcodegen generate && open WifiSpectrum.xcodeproj
```

---

Version 1.0: everything iOS lets an app see about Wi-Fi, plus a speed test, LAN discovery and five network tools. Channel rules are shared with the Android app.

Wi-Fi Spectrum for iOS shows the current network's SSID, BSSID with its vendor, security type, addresses and subnet; measures download, upload, latency and jitter; finds devices on the local network; and offers TCP latency, DNS, port scanning, a 2.4/5/6 GHz channel calculator for 20–320 MHz and a subnet calculator.

Apple gives apps no access to nearby networks, channels, channel widths, signal strength or Wi-Fi 7 MLO, so this app does not claim them. For a full spectrum analyzer use the Android version, [Android_wifi-spectrum](https://github.com/tonykfr1234/android_wifi-spectrum).

The 12 README languages translate the documentation. The app interface currently uses Traditional Chinese.

<a id="quick-start"></a>
## Quick start

1. On a Mac with Xcode 16+, clone this repository and run the command above (installs XcodeGen, generates the project, opens Xcode).
2. Select the `WifiSpectrum` target, choose your team under Signing & Capabilities and confirm *Access Wi-Fi Information* is listed.
3. Run on an iPhone with iOS 16+. Allow location (needed only for the Wi-Fi name) and, at the first LAN scan, Local Network.
4. The simulator has no Wi-Fi information; switch on demo mode in the About tab to see every screen with synthetic data.
5. Every push runs the tests on GitHub Actions; logs and simulator screenshots appear on the `ci-artifacts` branch.

**Publishing to the App Store?** Follow [docs/PUBLISHING.zh-TW.md](docs/PUBLISHING.zh-TW.md) ([English summary](docs/PUBLISHING.md)): set your bundle ID and team, archive, upload, test with TestFlight and submit with the provided review notes.

<a id="workflow"></a>
## Workflow

```text
Connection tab opens
  → location allowed? NEHotspotNetwork.fetchCurrent → SSID, BSSID, security type
  → BSSID → offline IEEE vendor lookup (randomized MACs are marked)
  → getifaddrs + NWPathMonitor → IPv4, mask, subnet, IPv6, path flags
LAN tab: Bonjour (10 service types) + TCP sweep of 6 ports across the /24
Speed tab: 10 HTTPS round trips, 3 downloads, 3 uploads → medians
```

Nothing runs in the background and nothing is stored after the app closes. Networks larger than 1,024 addresses are not swept. Latency uses TCP connect time because iOS does not allow ICMP for normal apps.

<a id="features"></a>
## Features

| Feature | Behavior |
| --- | --- |
| Current Wi-Fi | SSID, BSSID, vendor from the IEEE registry, security type (iOS 15+) |
| Interface | IPv4, netmask, subnet and host count, IPv6, Low Data Mode and expensive-network flags |
| Speed test | Cloudflare endpoints; median of 3 downloads and 3 uploads; latency and jitter; cancellable; 20-result history |
| LAN discovery | Bonjour names plus hosts answering on 80/443/22/445/554/62078; progress and stop |
| Channel calculator | 2.4/5/6 GHz, 20–320 MHz: occupied range, centre and covered channels, PSC, DFS, UNII sub-band |
| Network tools | TCP latency with loss and jitter, DNS A/AAAA/CNAME, port scan of 19 common ports or a custom range |
| Subnet calculator | CIDR or dotted mask → network, broadcast, host range and count |
| Privacy | No data collection, ads or analytics; privacy manifest included |

iOS exposes no nearby networks, channels, widths, RSSI or MLO; the channel calculator applies the same rules the Android app uses for scanned networks. LAN results carry no vendor because iOS hides other devices' MAC addresses.

<a id="demo"></a>
## Demo

These screens were captured by the **UI tests on the iPhone simulator in demo mode**: the app's real interface with the synthetic Taipei apartment shared with the Android demo. They are not a real network and do not show any particular device's performance.

![Walkthrough of the iOS app in demo mode](docs/media/wifi-spectrum-ios-demo.gif)

[Open or download the MP4 demonstration](docs/media/wifi-spectrum-ios-demo.mp4)

| Current network | Speed test | Channel calculator |
| --- | --- | --- |
| ![Current network](docs/media/connection.png) | ![Speed test](docs/media/speedtest.png) | ![Channel calculator](docs/media/channel-calculator.png) |

## Latest changes

First release with current-network details, speed test, LAN discovery, five tools, demo mode, an App Store publishing guide and CI that runs 48 tests on Linux, macOS and the iPhone simulator. See the [changelog](CHANGELOG.md).

<a id="controls"></a>
## Controls

| Control | Action |
| --- | --- |
| Pull down / ↻ (Connection) | Refresh the Wi-Fi and interface details |
| 開始測速 / 停止 (Speed) | Start or cancel a speed test |
| 開始掃描 / 停止掃描 (LAN) | Start or stop LAN discovery |
| Band / channel / width pickers | Recalculate the channel plan; invalid widths are not offered |
| Tools → host fields | Enter a host name or IP; invalid input is explained before anything is sent |
| About → 示範模式 | Switch between real data and the synthetic environment |

<a id="faq"></a>
## FAQ

**Why can't it show nearby networks or channels?** Apple provides no public API for them. Private APIs would be rejected by App Review. Use the Android version for spectrum analysis.

**Why does it ask for location?** iOS only reveals the current SSID and BSSID to apps with location permission. The app never reads coordinates.

**Why does the simulator say I'm not connected?** The simulator has no Wi-Fi information. Turn on demo mode in the About tab.

**Why does the LAN scan find nothing?** Allow Local Network in Settings → Privacy & Security, and check that the router does not isolate wireless clients.

**Where does the speed test connect?** To Cloudflare's public speed-test endpoints at speed.cloudflare.com. One run uses about 100 MB.

<a id="docs"></a>
<a id="documentation"></a>
## Documentation

| Topic | Document |
| --- | --- |
| Daily operation | [繁中使用指南](docs/USER_GUIDE.zh-TW.md) · [English User Guide](docs/USER_GUIDE.md) |
| Internals | [Architecture](docs/ARCHITECTURE.md) |
| Publishing | [App Store guide (繁中)](docs/PUBLISHING.zh-TW.md) · [English summary](docs/PUBLISHING.md) · [Privacy policy](docs/PRIVACY.md) |
| Versions and safety | [Changelog](CHANGELOG.md) · [Security](SECURITY.md) · [Contributing](CONTRIBUTING.md) |

The app lives in `App/`, shared logic in the `Core/` Swift package, tests in `Core/Tests`, `AppTests` and `AppUITests`, and tools in `scripts/`. The project file is generated from `project.yml`. Check SSID, LAN and speed results on a real iPhone; the simulator cannot.

## Security

Never commit certificates, provisioning profiles, App Store Connect API keys, `.ipa` files or scans of networks you do not own. Before pushing, run the same scanner used by GitHub Actions:

```bash
python scripts/security_scan.py .
```

## License

[MIT](LICENSE).

### 2026-10-20 · 1.0.0

首次發布：目前連線資訊、測速、區域網路探索、TCP 延遲、DNS、連接埠掃描、頻道與子網路計算機；48 個測試在 Linux、macOS 與 iPhone 模擬器上執行。

First release: current-network details, speed test, LAN discovery, TCP latency, DNS, port scan, channel and subnet calculators; 48 tests run on Linux, macOS and the iPhone simulator.

[Public user guide (Traditional Chinese, plain text)](docs/使用說明.txt)
