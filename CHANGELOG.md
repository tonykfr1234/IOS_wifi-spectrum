# Changelog

## 1.0.0 - 2026-10-20

- Show the current Wi-Fi network as far as iOS allows: SSID, BSSID with offline IEEE vendor lookup, security type (iOS 15+), IPv4/netmask/subnet, IPv6 and path flags (Wi-Fi, expensive, constrained). Explain clearly that iOS exposes no nearby networks, channels, widths, RSSI or MLO.
- Speed test against Cloudflare's public endpoints: median of three downloads and uploads, latency and jitter from ten HTTPS round trips; cancellable, with a 20-result history.
- LAN discovery: Bonjour browsing for ten common service types plus a TCP sweep of six ports across the local subnet (refused above 1,024 hosts), with progress and cancellation.
- Tools: TCP connect latency (iOS forbids ICMP for normal apps), DNS A/AAAA/canonical-name lookup, port scan of the 19 common ports or a custom list/range, channel calculator for 2.4/5/6 GHz and 20–320 MHz with PSC, DFS and UNII sub-bands, and an IPv4 subnet calculator.
- Channel rules shared with the Android app and verified by the same expected values.
- Demo mode with the same synthetic Taipei apartment as the Android app, for the simulator, App Review and screenshots.
- Privacy manifest, purpose strings for location and local network, export-compliance flag and Access Wi-Fi Information entitlement.
- CI on GitHub Actions: secret scan, core tests on Linux and macOS, unit and UI tests on the newest iPhone simulator, unsigned device build, and a report with logs and screenshots on the `ci-artifacts` branch.
- 12 localized READMEs, App Store publishing guide, privacy policy and security policy.

### 繁體中文

- 在 iOS 允許的範圍內顯示目前 Wi-Fi：SSID、BSSID 與離線 IEEE 廠商查詢、加密類型（iOS 15 以上）、IPv4／遮罩／網段、IPv6 與網路狀態。清楚說明 iOS 不提供附近網路、頻道、頻寬、訊號強度與 MLO。
- 透過 Cloudflare 公開測速端點測速：下載與上傳各 3 次取中位數，延遲與抖動來自 10 次 HTTPS 往返；可取消，保留 20 筆紀錄。
- 區域網路：Bonjour 探索 10 種常見服務，並對本地網段每個位址測試 6 個連接埠（超過 1,024 個位址不掃描），顯示進度可取消。
- 工具：TCP 延遲（iOS 不允許一般 App 使用 ICMP）、DNS A／AAAA／正式名稱查詢、常用 19 個或自訂連接埠掃描、2.4／5／6 GHz 與 20–320 MHz 頻道計算機（含 PSC、DFS、UNII 子頻段）、IPv4 子網路計算機。
- 頻道規則與 Android 版相同，並用同一組預期值驗證。
- 示範模式使用與 Android 版相同的模擬台北公寓，供模擬器、App 審核與截圖使用。
- 隱私清單、位置與本地網路權限說明、出口合規設定、存取 Wi-Fi 資訊權限。
- GitHub Actions CI：機密掃描、Linux 與 macOS 核心測試、最新 iPhone 模擬器的單元與 UI 測試、不簽章實機編譯，並把日誌與截圖發布到 `ci-artifacts` 分支。
- 12 種語言 README、App Store 上架指南、隱私權政策與資安說明。
