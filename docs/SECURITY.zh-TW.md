# 資安說明

## 絕對不要提交的檔案

- 開發或發布憑證（`.p12`、`.cer`）與密碼。
- 佈建描述檔（`.mobileprovision`）。
- App Store Connect API 金鑰（`AuthKey_*.p8`），以及搭配金鑰的 Key ID、Issuer ID。
- 匯出的 `.ipa`，或含團隊資訊的 `ExportOptions.plist`。
- GitHub 權杖或其他憑證。
- 不屬於你的網路掃描資料。

Xcode 把憑證存在 macOS 鑰匙圈，不需要複製到專案裡。

## 每次 Push 前

```bash
python scripts/security_scan.py .
```

GitHub Actions 會在每次 Push 和 Pull Request 執行同一支掃描程式。

## 不小心外洩時

1. 立刻撤銷：憑證與 API 金鑰分別在開發者網站「Certificates, Identifiers & Profiles」與 App Store Connect「使用者與存取權限 → 金鑰」。
2. 從目前的檔案中移除。
3. 如果已經提交，要改寫 Git 歷史；只刪掉最新版的檔案不夠。
4. 重新執行掃描後再 Push。

## App 隱私

App 不收集任何資料。App 自己產生的網路流量只有連到 speed.cloudflare.com 的測速，以及你按下掃描後的區網探測。詳見[隱私權政策](PRIVACY.md)。

## 回報問題

請私下聯絡 Repo 擁有者，不要在 Issue 公開仍有效的憑證。
