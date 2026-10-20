# 上架 App Store 步驟

iOS App 只能在 Mac 上用 Xcode 簽章與上傳。這份指南從準備帳號一路到送審。

## 0. 事前準備

| 項目 | 說明 |
|---|---|
| Mac | macOS 15 以上，安裝 Xcode 16 以上（App Store 免費下載） |
| Apple Developer Program | 每年 99 美元，個人或公司都可以，審核通常 1–2 天 |
| iPhone | 實機測試用，iOS 16 以上 |
| Homebrew | 用來安裝 XcodeGen：`/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"` |
| 隱私權政策網址 | 公開可存取的網頁，內容可用 `docs/PRIVACY.md` |

## 1. 取得專案並產生 Xcode 專案檔

```bash
git clone https://github.com/tonykfr1234/ios_wifi-spectrum.git
cd ios_wifi-spectrum
brew install xcodegen
xcodegen generate
open WifiSpectrum.xcodeproj
```

專案檔由 `project.yml` 產生。之後改設定請改 `project.yml` 再重跑 `xcodegen generate`，不要直接改 Xcode 專案檔，下次產生時會被覆蓋。

## 2. 改成你自己的 Bundle ID 與開發團隊

Bundle ID 一旦在 App Store Connect 建立就不能改。打開 `project.yml`：

```yaml
PRODUCT_BUNDLE_IDENTIFIER: com.wifispectrum.ios   # 改成例如 com.你的名字.wifispectrum
DEVELOPMENT_TEAM: ""                              # 填入你的 Team ID
```

Team ID 在 [developer.apple.com/account](https://developer.apple.com/account) →「Membership details」。改完重跑 `xcodegen generate`。

## 3. 開啟「存取 Wi-Fi 資訊」功能

App 要讀 SSID／BSSID，必須有 **Access Wi-Fi Information** 權限（`com.apple.developer.networking.wifi-info`）。`project.yml` 已經宣告，使用自動簽章時 Xcode 會自動到 Apple 開發者網站幫 App ID 開啟。

在 Xcode 選 `WifiSpectrum` target →「Signing & Capabilities」，確認：

- 勾選「Automatically manage signing」，Team 選你的帳號。
- 下方出現「Access Wi-Fi Information」。

沒有出現的話，按「+ Capability」手動加入。

## 4. 實機測試

1. 用線把 iPhone 接上 Mac，iPhone 上按「信任這部電腦」。
2. iPhone：「設定 → 隱私權與安全性 → 開發者模式」打開，依指示重新開機。
3. Xcode 上方選你的 iPhone，按 ▶ 執行。
4. 第一次執行要到 iPhone「設定 → 一般 → VPN 與裝置管理」信任你的開發者憑證。
5. 檢查：
   - 「連線」允許位置後，有顯示 SSID、BSSID 與廠商。
   - 「區網」第一次掃描會詢問「本地網路」，允許後能找到家裡的裝置。
   - 「測速」能完成下載與上傳。

模擬器沒有 Wi-Fi 資訊，只會看到「沒有連上 Wi-Fi」，這是正常的。

## 5. 在 App Store Connect 建立 App

1. 到 [App Store Connect](https://appstoreconnect.apple.com) →「App」→「＋」→「新增 App」。
2. 平台 iOS；名稱 `Wi-Fi 頻譜分析儀`（名稱全球唯一，被用走就換一個）；主要語言「繁體中文」；Bundle ID 選第 2 步設定的；SKU 自訂，例如 `wifispectrum-ios-001`。

## 6. 封存並上傳

**用 Xcode（建議第一次用）：**

1. Xcode 上方裝置選「Any iOS Device (arm64)」。
2. 選單「Product → Archive」。
3. 完成後 Organizer 視窗出現，按「Distribute App」→「App Store Connect」→「Upload」，一路下一步。

**用指令（之後更新方便）：**

```bash
xcodebuild archive -project WifiSpectrum.xcodeproj -scheme WifiSpectrum \
  -configuration Release -destination 'generic/platform=iOS' \
  -archivePath build/WifiSpectrum.xcarchive -allowProvisioningUpdates

xcodebuild -exportArchive -archivePath build/WifiSpectrum.xcarchive \
  -exportOptionsPlist ExportOptions.plist -exportPath build/export -allowProvisioningUpdates
```

`ExportOptions.plist` 內容（存在專案外或確認不要提交）：

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>method</key><string>app-store-connect</string>
  <key>destination</key><string>upload</string>
</dict>
</plist>
```

上傳後約 10–30 分鐘，版本會出現在 App Store Connect 的「TestFlight」。

## 7. TestFlight 測試

1. 「TestFlight → 內部測試」建立群組，加入自己的 Apple ID。
2. iPhone 安裝 TestFlight App，用收到的邀請安裝。
3. 用正式簽章的版本再完整測一次第 4 步。

## 8. 填寫 App 資訊

### App 隱私權

「App 隱私權」→「資料收集」選**否，我們不會從這個 App 收集資料**。理由：

- 掃描與測速結果只在手機記憶體裡處理，不會傳出裝置。
- 測速傳送到 Cloudflare 的只有測試用的空白資料，不含使用者資料。

### 隱私權政策網址

最簡單的方式是 GitHub Pages：repo「Settings → Pages」，Source 選 `main` 分支、資料夾 `/docs`，網址是 `https://tonykfr1234.github.io/ios_wifi-spectrum/PRIVACY`。

### 其他欄位

| 欄位 | 填入 |
|---|---|
| 類別 | 工具程式（Utilities） |
| 年齡分級 | 問卷全部選「無」，結果 4+ |
| 出口合規 | `Info.plist` 已設定 `ITSAppUsesNonExemptEncryption = NO`，不需要另外上傳文件 |
| 價格 | 免費 |

### 商店說明範本

副標題（30 字內）：

```
Wi-Fi 連線資訊、測速與網路工具
```

描述：

```
Wi-Fi 頻譜分析儀是給網管人員與進階使用者的網路工具。

【目前連線】
顯示 Wi-Fi 名稱、基地台 BSSID 與廠商（內建 IEEE 登錄表，離線查詢）、加密類型、IP 位址、子網路與 IPv6。

【測速】
透過 Cloudflare 測速伺服器量測下載、上傳、延遲與抖動。

【區域網路】
用 Bonjour 與連接埠探測，找出同一網段的路由器、NAS、印表機、攝影機等裝置。

【工具】
TCP 延遲、DNS 查詢、連接埠掃描、頻道計算機（2.4／5／6 GHz、20–320 MHz、PSC／DFS）、子網路計算機。

【隱私】
不收集任何資料、沒有廣告、沒有追蹤。

※ iOS 不開放 App 讀取附近 Wi-Fi、頻道、頻寬與訊號強度；需要這些功能請使用 Android 版。
```

關鍵字（100 字元內）：

```
wifi,網路,測速,頻道,子網路,DNS,ping,區網,掃描,路由器,Wi-Fi 7,6GHz
```

### 截圖

只支援 iPhone，所以只需要 **6.9 吋**（1320×2868）截圖，3–10 張。GitHub Actions 每次都會在 iPhone Pro Max 模擬器拍下示範模式的畫面，存在 `ci-artifacts` 分支的 `screenshots/` 資料夾，可以直接使用：

```bash
git fetch origin ci-artifacts
git checkout origin/ci-artifacts -- screenshots
```

## 9. 審核備註

「App 審查資訊 → 備註」建議填：

```
位置權限只用於讓 iOS 提供目前連線的 Wi-Fi 名稱（NEHotspotNetwork.fetchCurrent），App 不讀取座標。
本地網路權限用於「區網」分頁的裝置探索。
審核環境沒有 Wi-Fi 時，可以到「關於」開啟「示範模式」查看所有畫面。
```

不需要提供測試帳號（App 沒有登入功能）。

## 10. 送審

1. 「App Store → iOS App → 1.0 準備提交」，選擇上傳的版本（Build）。
2. 按「新增以供審查」→「提交審查」。
3. 審核通常 1–2 天。被退回時，App Store Connect 的「解決方案中心」會寫明原因。

## 11. 之後要更新

1. `project.yml` 的 `MARKETING_VERSION`（例如 `1.0.1`）與 `CURRENT_PROJECT_VERSION`（每次上傳都要加 1）。
2. `xcodegen generate`。
3. 重做第 6 步並在 App Store Connect 建立新版本。

## 常見退件原因與預防

| 原因 | 本專案的做法 |
|---|---|
| 5.1.1 權限用途說明不清楚 | `project.yml` 的位置與本地網路說明已寫明用途 |
| 2.1 審核時功能無法使用 | 提供示範模式，並在審核備註說明 |
| 4.2 功能太少 | 連線資訊、測速、區網、5 種工具 |
| 隱私權政策網址失效 | 用 GitHub Pages 發布 `docs/PRIVACY.md` |
| 宣稱做不到的功能 | 說明已註明 iOS 無法讀取頻道、頻寬與附近網路 |
