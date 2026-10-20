<p align="center">
  <a href="README.md">English</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.zh-TW.md">繁體中文</a> · <strong>日本語</strong> · <a href="README.ko.md">한국어</a><br>
  <a href="README.de.md">Deutsch</a> · <a href="README.es.md">Español</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.vi.md">Tiếng Việt</a> · <a href="README.id.md">Bahasa Indonesia</a> · <a href="README.it.md">Italiano</a>
</p>

<p align="center"><img src="assets/wifi-spectrum.png" width="112" alt="Wi-Fi Spectrum アイコン"></p>
<h1 align="center">iPhone 向け Wi-Fi ネットワークツール</h1>
<p align="center">Wi-Fi 頻譜分析儀 · 現在の接続 · 速度測定 · LAN · チャネル計算機</p>
<p align="center">
  <a href="https://github.com/tonykfr1234/ios_wifi-spectrum/actions/workflows/security.yml"><img src="https://github.com/tonykfr1234/ios_wifi-spectrum/actions/workflows/security.yml/badge.svg" alt="CI"></a>
  <img src="https://img.shields.io/badge/platform-iOS%2016%2B-000000" alt="iOS 16+">
  <img src="https://img.shields.io/badge/Swift-6.1-F05138" alt="Swift 6.1">
  <img src="https://img.shields.io/badge/SwiftUI-iPhone-0A84FF" alt="SwiftUI">
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-green" alt="MIT ライセンス"></a>
</p>
<p align="center">
  <a href="#quick-start">はじめに</a> · <a href="#workflow">動作の流れ</a> · <a href="#features">機能</a> · <a href="#demo">デモ</a> · <a href="#faq">よくある質問</a> · <a href="#documentation">ドキュメント</a>
</p>

```bash
brew install xcodegen && xcodegen generate && open WifiSpectrum.xcodeproj
```

---

バージョン 1.0：iOS がアプリに許可する Wi-Fi 情報のすべてに加え、速度測定、LAN 探索、5 つのネットワークツール。チャネル規則は Android 版と共通です。

Wi-Fi Spectrum の iOS 版は、現在の接続の SSID、BSSID とベンダー、暗号化方式、アドレスとサブネットを表示し、ダウンロード・アップロード・遅延・ジッターを測定し、LAN 上の機器を探します。さらに TCP 遅延、DNS、ポートスキャン、2.4/5/6 GHz と 20–320 MHz のチャネル計算機、サブネット計算機を備えています。

Apple はアプリに周囲のネットワーク、チャネル、チャネル幅、信号強度、Wi-Fi 7 MLO を公開していないため、本アプリはそれらを扱いません。完全なスペクトラム分析は Android 版 [Android_wifi-spectrum](https://github.com/tonykfr1234/android_wifi-spectrum) をお使いください。

12 言語の README はドキュメントの翻訳です。アプリの画面は現在、繁体字中国語です。

<a id="quick-start"></a>
## はじめに

1. Xcode 16 以上の Mac でこのリポジトリをクローンし、上のコマンドを実行します（XcodeGen の導入、プロジェクト生成、Xcode の起動）。
2. `WifiSpectrum` ターゲットを選び、Signing & Capabilities でチームを選択し、Access Wi-Fi Information があることを確認します。
3. iOS 16 以上の iPhone で実行します。位置情報（Wi-Fi 名の取得のみ）を許可し、最初の LAN スキャンで「ローカルネットワーク」を許可します。
4. シミュレーターには Wi-Fi 情報がありません。「関於」タブでデモモードをオンにすると、合成データで全画面を確認できます。
5. プッシュのたびに GitHub Actions でテストが実行され、ログとシミュレーターのスクリーンショットが `ci-artifacts` ブランチに置かれます。

**App Store に公開する場合**は [docs/PUBLISHING.zh-TW.md](docs/PUBLISHING.zh-TW.md)（[英語の概要](docs/PUBLISHING.md)）に従い、Bundle ID とチームを設定し、アーカイブ、アップロード、TestFlight でのテストを行い、用意した審査メモを添えて提出します。

<a id="workflow"></a>
## 動作の流れ

```text
「連線」タブを開く
  → 位置情報が許可済み？NEHotspotNetwork.fetchCurrent → SSID、BSSID、暗号化方式
  → BSSID → IEEE ベンダーをオフライン検索（ランダム MAC は明示）
  → getifaddrs + NWPathMonitor → IPv4、マスク、サブネット、IPv6、経路情報
LAN：Bonjour（10 種類のサービス）＋ /24 の各アドレスで 6 ポートを確認
速度：HTTPS 往復 10 回、ダウンロード 3 回、アップロード 3 回 → 中央値
```

バックグラウンドでは動作せず、アプリを閉じると何も残りません。1,024 アドレスを超えるネットワークはポートスキャンしません。iOS は通常のアプリに ICMP を許可しないため、遅延は TCP 接続時間で測ります。

<a id="features"></a>
## 機能

| 機能 | 動作 |
| --- | --- |
| 現在の Wi-Fi | SSID、BSSID、IEEE 登録簿のベンダー、暗号化方式（iOS 15 以上） |
| インターフェース | IPv4、マスク、サブネットとホスト数、IPv6、省データモードと従量制ネットワーク |
| 速度測定 | Cloudflare のエンドポイント。ダウンロードとアップロード各 3 回の中央値、遅延とジッター、中止可能、20 件の履歴 |
| LAN 探索 | Bonjour の機器名と、80/443/22/445/554/62078 に応答するホスト。進捗表示と停止 |
| チャネル計算機 | 2.4/5/6 GHz、20–320 MHz：占有範囲、中心とカバーするチャネル、PSC、DFS、UNII サブバンド |
| ネットワークツール | 損失率とジッター付きの TCP 遅延、DNS A/AAAA/CNAME、19 の一般的なポートまたは任意範囲のスキャン |
| サブネット計算機 | CIDR またはマスク → ネットワーク、ブロードキャスト、ホスト範囲と数 |
| プライバシー | データ収集、広告、解析なし。プライバシーマニフェスト付き |

iOS は周囲のネットワーク、チャネル、幅、RSSI、MLO を提供しません。チャネル計算機は Android 版がスキャン結果に使うのと同じ規則を適用します。iOS は他の機器の MAC アドレスを隠すため、LAN の結果にはベンダー名がありません。

<a id="demo"></a>
## デモ

以下の画面は **iPhone シミュレーター上の UI テストがデモモードで撮影したもの**です。実際のアプリ画面に、Android 版と共通の合成された台北のアパートを組み合わせています。実際のネットワークではなく、特定の端末の性能を示すものでもありません。

![デモモードでの iOS アプリの操作](docs/media/wifi-spectrum-ios-demo.gif)

[MP4 デモを再生またはダウンロード](docs/media/wifi-spectrum-ios-demo.mp4)

| 現在の接続 | 速度測定 | チャネル計算機 |
| --- | --- | --- |
| ![現在の接続](docs/media/connection.png) | ![速度測定](docs/media/speedtest.png) | ![チャネル計算機](docs/media/channel-calculator.png) |

## 最新の変更

初回リリース：現在の接続情報、速度測定、LAN 探索、5 つのツール、デモモード、App Store 公開ガイド、そして Linux・macOS・iPhone シミュレーターで 48 件のテストを実行する CI。[変更履歴](CHANGELOG.md)を参照してください。

<a id="controls"></a>
## 操作

| 操作 | 動作 |
| --- | --- |
| 下に引く／↻（連線） | Wi-Fi とインターフェース情報を再取得 |
| 開始測速／停止（測速） | 速度測定の開始または中止 |
| 開始掃描／停止掃描（區網） | LAN 探索の開始または停止 |
| 帯域／チャネル／幅の選択 | 再計算。規則に合わない幅は表示されない |
| ツール → ホスト欄 | ホスト名または IP を入力。形式エラーは送信前に説明 |
| 關於 → 示範模式 | 実データと合成環境を切り替え |

<a id="faq"></a>
## よくある質問

**なぜ周囲のネットワークやチャネルを表示できないのですか？** Apple が公開 API を提供していないためです。非公開 API は App 審査で却下されます。スペクトラム分析には Android 版をお使いください。

**なぜ位置情報が必要ですか？** iOS は位置情報の許可を得たアプリにのみ現在の SSID と BSSID を渡します。アプリは座標を読み取りません。

**シミュレーターで未接続と表示されるのはなぜですか？** シミュレーターには Wi-Fi 情報がありません。「關於」タブでデモモードをオンにしてください。

**LAN スキャンで何も見つからないのはなぜですか？** 設定 → プライバシーとセキュリティ → ローカルネットワークでアプリを許可し、ルーターが無線クライアントを分離していないか確認してください。

**速度測定の接続先はどこですか？** Cloudflare の公開速度測定エンドポイント speed.cloudflare.com です。1 回で約 100 MB を使います。

<a id="docs"></a>
<a id="documentation"></a>
## ドキュメント

| 項目 | ドキュメント |
| --- | --- |
| 日常の操作 | [繁中使用指南](docs/USER_GUIDE.zh-TW.md) · [English User Guide](docs/USER_GUIDE.md) |
| 内部構造 | [アーキテクチャ](docs/ARCHITECTURE.md) |
| 公開 | [App Store 公開ガイド（繁体字）](docs/PUBLISHING.zh-TW.md) · [英語の概要](docs/PUBLISHING.md) · [プライバシーポリシー](docs/PRIVACY.md) |
| バージョンと安全性 | [変更履歴](CHANGELOG.md) · [セキュリティ](SECURITY.md) · [コントリビューション](CONTRIBUTING.md) |

アプリは `App/`、共通ロジックは `Core/` の Swift Package、テストは `Core/Tests`・`AppTests`・`AppUITests`、ツールは `scripts/` にあります。プロジェクトファイルは `project.yml` から生成します。SSID、LAN、速度の結果は実機の iPhone で確認してください。シミュレーターではできません。

## セキュリティ

証明書、プロビジョニングプロファイル、App Store Connect API キー、`.ipa`、自分のものではないネットワークのスキャン結果をコミットしないでください。プッシュ前に GitHub Actions と同じスキャナーを実行します：

```bash
python scripts/security_scan.py .
```

## ライセンス

[MIT](LICENSE)。

### 2026-10-20 · 1.0.0

首次發布：目前連線資訊、測速、區域網路探索、TCP 延遲、DNS、連接埠掃描、頻道與子網路計算機；48 個測試在 Linux、macOS 與 iPhone 模擬器上執行。

First release: current-network details, speed test, LAN discovery, TCP latency, DNS, port scan, channel and subnet calculators; 48 tests run on Linux, macOS and the iPhone simulator.

[公開版の使い方（繁体字中国語、テキスト形式）](docs/使用說明.txt)
