# Architecture

```text
SwiftUI views (App/Views)
  → @MainActor view models (App/Models/ViewModels.swift)
  → Services protocols (App/Services/ServiceProtocols.swift)
      ├─ System services: NEHotspotNetwork, NWPathMonitor, getifaddrs,
      │   NWConnection, NWBrowser, getaddrinfo, URLSession → speed.cloudflare.com
      └─ Demo services: synthetic Taipei apartment for simulator, review and tests
  → WifiSpectrumCore (Swift package in Core/)
      channels, channel plans, IPv4 subnets, ports, latency/throughput maths, IEEE vendors
```

## Layers

| Layer | Responsibility | Platform dependency |
| --- | --- | --- |
| `Core` (Swift package) | Channel rules shared with the Android app, `ChannelPlan`, `Subnet`, `Ports`, `HostInput`, `LatencyStats`, `Throughput`, `VendorDatabase` | Foundation only; tested on Linux and macOS |
| `App/Services` | Protocols plus system and demo implementations | Network, NetworkExtension, CoreLocation |
| `App/Models` | One `@MainActor ObservableObject` per screen; cancellation, validation and user-facing messages | None beyond the protocols |
| `App/Views` | SwiftUI screens, theme and the band strip | SwiftUI |

Every view model receives a `Services` value, so tests swap in demo or failing implementations without touching the network.

## Why some features are absent

iOS gives third-party apps the current network's SSID, BSSID and security type through `NEHotspotNetwork.fetchCurrent`, gated by the Access Wi-Fi Information entitlement and location permission. There is no public API for scan results, channel, width, RSSI or MLO; `NEHotspotHelper` is restricted to hotspot operators and still offers no width or MLO. The app therefore provides a channel calculator instead of a spectrum view.

ICMP needs raw sockets that iOS denies normal apps, so latency is measured as TCP connect time with `NWConnection`.

## Speed test

1. One warm-up request, then ten `__down?bytes=0` round trips → `LatencyStats` (median and jitter).
2. Three 25 MB downloads and three 8 MB uploads → per-transfer Mbps → median (`Throughput.estimate`).
3. Cancellation stops between transfers; URLSession cancellation is reported as cancelled, not as an error.

## LAN discovery

- Bonjour: `NWBrowser` for the ten service types declared in `NSBonjourServices` for four seconds.
- Sweep: `Subnet.sweepTargets` (refuses more than 1,024 hosts), sixteen hosts in parallel, six ports each with a 0.5 s connect timeout.

## Tests

| Suite | Runs on | Covers |
| --- | --- | --- |
| `Core/Tests` | Linux and macOS (`swift test`) | Channel numbers, plans matching the Android expectations for every band/channel/width, subnets, port parsing, host validation, statistics, vendor lookup and fuzzing |
| `AppTests` | iOS simulator | View models with demo, scripted and failing services: states, cancellation, history cap, huge-network refusal, validation messages |
| `AppUITests` | iOS simulator | Every tab and tool in demo mode, rapid tab switching, double-tapped buttons, screenshots for the store and docs |

CI publishes logs and screenshots to the `ci-artifacts` branch because workflow logs require sign-in to download.
