<p align="center">
  <a href="README.md">English</a> · <strong>简体中文</strong> · <a href="README.zh-TW.md">繁體中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a><br>
  <a href="README.de.md">Deutsch</a> · <a href="README.es.md">Español</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.vi.md">Tiếng Việt</a> · <a href="README.id.md">Bahasa Indonesia</a> · <a href="README.it.md">Italiano</a>
</p>

<p align="center"><img src="assets/wifi-spectrum.png" width="112" alt="Wi-Fi 频谱分析仪图标"></p>
<h1 align="center">iPhone 版 Wi-Fi 网络工具</h1>
<p align="center">Wi-Fi 頻譜分析儀 · 当前连接 · 测速 · 局域网 · 信道计算器</p>
<p align="center">
  <a href="https://github.com/tonykfr1234/ios_wifi-spectrum/actions/workflows/security.yml"><img src="https://github.com/tonykfr1234/ios_wifi-spectrum/actions/workflows/security.yml/badge.svg" alt="CI"></a>
  <img src="https://img.shields.io/badge/platform-iOS%2016%2B-000000" alt="iOS 16+">
  <img src="https://img.shields.io/badge/Swift-6.1-F05138" alt="Swift 6.1">
  <img src="https://img.shields.io/badge/SwiftUI-iPhone-0A84FF" alt="SwiftUI">
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-green" alt="MIT 许可证"></a>
</p>
<p align="center">
  <a href="#quick-start">快速开始</a> · <a href="#workflow">工作流程</a> · <a href="#features">功能</a> · <a href="#demo">演示</a> · <a href="#faq">常见问题</a> · <a href="#documentation">文档</a>
</p>

```bash
brew install xcodegen && xcodegen generate && open WifiSpectrum.xcodeproj
```

---

1.0 版：iOS 允许应用读取的全部 Wi-Fi 信息，加上测速、局域网发现和五种网络工具。信道规则与 Android 版共用。

Wi-Fi 频谱分析仪 iOS 版显示当前连接的 SSID、BSSID 及厂商、加密类型、地址和网段；测量下载、上传、延迟和抖动；查找局域网中的设备；并提供 TCP 延迟、DNS、端口扫描、2.4／5／6 GHz 及 20–320 MHz 的信道计算器，以及子网计算器。

Apple 不允许应用读取附近网络、信道、信道宽度、信号强度和 Wi-Fi 7 MLO，因此本应用不声称具备这些功能。需要完整的频谱分析请使用 Android 版 [Android_wifi-spectrum](https://github.com/tonykfr1234/android_wifi-spectrum)。

12 种 README 语言是文档翻译，应用界面目前使用繁体中文。

<a id="quick-start"></a>
## 快速开始

1. 在装有 Xcode 16 以上的 Mac 上克隆本仓库，运行上方命令（安装 XcodeGen、生成项目并打开 Xcode）。
2. 选择 `WifiSpectrum` target，在“Signing & Capabilities”选择你的开发团队，确认列出了“Access Wi-Fi Information”。
3. 在 iOS 16 以上的 iPhone 上运行。允许定位（仅用于读取 Wi-Fi 名称），首次局域网扫描时允许“本地网络”。
4. 模拟器没有 Wi-Fi 信息；在“关于”中打开演示模式即可用模拟数据查看所有页面。
5. 每次推送都会在 GitHub Actions 上运行测试，日志和模拟器截图会出现在 `ci-artifacts` 分支。

**要上架 App Store？** 按照 [docs/PUBLISHING.zh-TW.md](docs/PUBLISHING.zh-TW.md)（[英文摘要](docs/PUBLISHING.md)）：设置 Bundle ID 和开发团队、归档、上传、用 TestFlight 测试，再附上准备好的审核备注提交。

<a id="workflow"></a>
## 工作流程

```text
打开“连线”页
  → 已允许定位？NEHotspotNetwork.fetchCurrent → SSID、BSSID、加密类型
  → BSSID → 离线查询 IEEE 厂商（随机 MAC 会标注）
  → getifaddrs + NWPathMonitor → IPv4、掩码、网段、IPv6、网络状态
局域网：Bonjour（10 种服务）+ 对 /24 每个地址测试 6 个端口
测速：10 次 HTTPS 往返、3 次下载、3 次上传 → 取中位数
```

应用不在后台运行，关闭后不保留任何数据。超过 1,024 个地址的网段不做端口扫描。延迟使用 TCP 连接时间，因为 iOS 不允许普通应用使用 ICMP。

<a id="features"></a>
## 功能

| 功能 | 行为 |
| --- | --- |
| 当前 Wi-Fi | SSID、BSSID、IEEE 注册表厂商、加密类型（iOS 15 以上） |
| 网络接口 | IPv4、掩码、网段与主机数、IPv6、低数据模式与计量网络 |
| 测速 | Cloudflare 测速端点；下载和上传各 3 次取中位数；延迟与抖动；可取消；保留 20 条 |
| 局域网 | Bonjour 设备名称，以及响应 80／443／22／445／554／62078 的主机；显示进度可停止 |
| 信道计算器 | 2.4／5／6 GHz、20–320 MHz：占用范围、中心与覆盖信道、PSC、DFS、UNII 子频段 |
| 网络工具 | TCP 延迟（含丢失率与抖动）、DNS A／AAAA／CNAME、常用 19 个或自定义端口扫描 |
| 子网计算器 | CIDR 或掩码 → 网络地址、广播地址、主机范围与数量 |
| 隐私 | 不收集数据、无广告与统计工具；附隐私清单 |

iOS 不提供附近网络、信道、宽度、信号强度和 MLO；信道计算器使用的规则与 Android 版分析扫描结果时相同。iOS 隐藏其他设备的 MAC 地址，所以局域网结果没有厂商名称。

<a id="demo"></a>
## 演示

以下画面由 **iPhone 模拟器上的 UI 测试在演示模式下截取**：应用的真实界面，配合与 Android 版共用的模拟台北公寓。这不是真实网络，也不代表任何设备的性能。

![iOS 应用演示模式操作](docs/media/wifi-spectrum-ios-demo.gif)

[播放或下载 MP4 演示视频](docs/media/wifi-spectrum-ios-demo.mp4)

| 当前连接 | 测速 | 信道计算器 |
| --- | --- | --- |
| ![当前连接](docs/media/connection.png) | ![测速](docs/media/speedtest.png) | ![信道计算器](docs/media/channel-calculator.png) |

## 最新变更

首次发布：当前连接信息、测速、局域网发现、五种工具、演示模式、App Store 上架指南，以及在 Linux、macOS 和 iPhone 模拟器上运行 48 个测试的 CI。详见[更新记录](CHANGELOG.md)。

<a id="controls"></a>
## 操作

| 操作 | 功能 |
| --- | --- |
| 下拉／↻（连线） | 重新读取 Wi-Fi 与网络接口信息 |
| 开始测速／停止（测速） | 开始或取消测速 |
| 开始扫描／停止扫描（局域网） | 开始或停止局域网发现 |
| 频段／信道／宽度选择 | 重新计算；不合规的宽度不会出现 |
| 工具 → 主机输入框 | 输入主机名或 IP；格式错误会先提示，不会发送 |
| 关于 → 演示模式 | 在真实数据与模拟环境之间切换 |

<a id="faq"></a>
## 常见问题

**为什么不能显示附近网络或信道？** Apple 没有提供公开 API。使用私有 API 会被 App 审核拒绝。需要频谱分析请用 Android 版。

**为什么需要定位权限？** iOS 只会把当前的 SSID 和 BSSID 提供给有定位权限的应用。应用不读取坐标。

**为什么模拟器显示未连接？** 模拟器没有 Wi-Fi 信息。在“关于”中打开演示模式。

**为什么局域网扫描找不到设备？** 在“设置 → 隐私与安全性 → 本地网络”允许本应用，并确认路由器没有开启无线客户端隔离。

**测速连接到哪里？** Cloudflare 公开测速端点 speed.cloudflare.com，一次约用 100 MB 流量。

<a id="docs"></a>
<a id="documentation"></a>
## 文档

| 主题 | 文档 |
| --- | --- |
| 日常使用 | [繁中使用指南](docs/USER_GUIDE.zh-TW.md) · [English User Guide](docs/USER_GUIDE.md) |
| 程序设计 | [架构](docs/ARCHITECTURE.md) |
| 上架 | [App Store 上架指南（繁中）](docs/PUBLISHING.zh-TW.md) · [英文摘要](docs/PUBLISHING.md) · [隐私政策](docs/PRIVACY.md) |
| 版本与安全 | [更新记录](CHANGELOG.md) · [安全说明](SECURITY.md) · [贡献指南](CONTRIBUTING.md) |

应用在 `App/`，共用逻辑在 `Core/` Swift Package，测试在 `Core/Tests`、`AppTests`、`AppUITests`，工具在 `scripts/`。项目文件由 `project.yml` 生成。SSID、局域网和测速结果请用 iPhone 真机确认，模拟器做不到。

## 安全

不要提交证书、描述文件、App Store Connect API 密钥、`.ipa` 或不属于你的网络扫描数据。推送前运行与 GitHub Actions 相同的扫描：

```bash
python scripts/security_scan.py .
```

## 许可证

[MIT](LICENSE)。

### 2026-10-20 · 1.0.0

首次發布：目前連線資訊、測速、區域網路探索、TCP 延遲、DNS、連接埠掃描、頻道與子網路計算機；48 個測試在 Linux、macOS 與 iPhone 模擬器上執行。

First release: current-network details, speed test, LAN discovery, TCP latency, DNS, port scan, channel and subnet calculators; 48 tests run on Linux, macOS and the iPhone simulator.

[公开版使用说明（繁体中文纯文本）](docs/使用說明.txt)
