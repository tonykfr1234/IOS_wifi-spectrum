# User Guide

The app interface is in Traditional Chinese. Labels below are given as 中文 (English).

## What the iOS app can and cannot do

| Can | Cannot (not exposed by Apple) |
| --- | --- |
| SSID, BSSID, vendor and security type of the current network | Nearby Wi-Fi networks |
| IP, subnet, IPv6 and path status | Channel, width, signal strength (RSSI) |
| Speed test, LAN device discovery | Wi-Fi 7 MLO links |
| TCP latency, DNS, port scan | ICMP ping |
| Channel and subnet calculators | |

For nearby networks, channels and widths, use the Android app.

## First launch

1. The 連線 (Connection) tab asks for location permission. iOS requires it before revealing the Wi-Fi name and BSSID; the app never reads coordinates.
2. The first 區網 (LAN) scan triggers iOS's Local Network prompt. Allow it, or no devices will be found.
3. If you declined, enable the app under Settings → Privacy & Security → Location Services / Local Network.

## Tabs

### 連線 (Connection)

- SSID, BSSID and vendor. Randomized BSSIDs show 隨機／本地管理位址 (randomized address).
- Security type; open and WEP networks are red.
- Interface: IPv4, netmask, subnet, IPv6, Low Data Mode and expensive-network flags.
- Pull to refresh.

### 測速 (Speed)

- 開始測速 (Start) measures latency, then three downloads and three uploads, reporting the medians.
- One run uses about 100 MB; watch your cellular allowance.
- The last 20 results are kept until the app closes.

### 區網 (LAN)

- 開始掃描 (Scan) browses Bonjour and probes ports 80, 443, 22, 445, 554 and 62078 on every address in the subnet.
- A /24 finishes in about a minute; networks larger than 1,024 addresses get Bonjour only.
- iOS does not reveal other devices' MAC addresses, so LAN results have no vendor names.

### 工具 (Tools)

| Tool | Purpose |
| --- | --- |
| 頻道計算機 (Channel calculator) | Band, primary channel and width → occupied range, centre channel, covered channels, PSC/DFS and UNII sub-band. Same rules as the Android app |
| 子網路計算機 (Subnet calculator) | `192.168.1.10/24` or `192.168.1.10 255.255.255.0` → network, broadcast and host range |
| TCP 延遲 (TCP latency) | Ten connection timings with min/median/max, jitter and loss |
| DNS 查詢 (DNS lookup) | A, AAAA and canonical name via the system resolver |
| 連接埠掃描 (Port scan) | Empty = 19 common ports; or `80,443` / `8000-8010` (up to 1,024 ports) |

### 關於 (About)

- 示範模式 (Demo mode) shows the synthetic Taipei apartment so the whole UI works without Wi-Fi.
- Privacy and data sources.

## Troubleshooting

| Symptom | Cause |
| --- | --- |
| Connection tab says not connected | No Wi-Fi, or running in the simulator (no Wi-Fi information there) |
| No SSID | Location permission not granted |
| LAN finds nothing | Local Network permission declined, or the router isolates clients |
| Speed test fails | Network down or speed.cloudflare.com blocked |
| TCP latency always times out | Host missing, port closed or filtered; try 443 |
