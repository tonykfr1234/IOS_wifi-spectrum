# Contributing

Contributions are welcome. Keep changes focused and testable.

Before opening a pull request:

1. Do not commit certificates, provisioning profiles, App Store Connect API keys (`AuthKey_*.p8`), `.ipa` files or real network scans.
2. Run `python scripts/security_scan.py .`.
3. Run `swift test --package-path Core` (works on macOS and Linux).
4. On a Mac, run `xcodegen generate`, then the unit and UI tests: `xcodebuild test -project WifiSpectrum.xcodeproj -scheme WifiSpectrum -destination 'platform=iOS Simulator,name=iPhone 16 Pro Max' CODE_SIGNING_ALLOWED=NO`.
5. Run `python scripts/update_checksums.py` after staging your changes, then commit `SHA256SUMS.txt`.
6. Describe the iPhone model and iOS version used for testing. For network features, state the router and whether the Local Network permission was granted.

The simulator has no Wi-Fi information, so UI tests launch the app with `-demo -uiTesting` and use the synthetic environment. Real SSID, BSSID and LAN results must be checked on a device.

Channel rules live in `Core/Sources/WifiSpectrumCore/Channels.swift` and must stay identical to the Android app's `Channels.kt`. When changing them, update the shared expectations in `CoreTests.swift` and the Android `ChannelsTest`.

Do not add features that claim to read nearby networks, channels, widths or RSSI on iOS; Apple does not expose them and App Review rejects private-API use.

Keep the English and Traditional Chinese guides and all 12 README introductions aligned when behavior changes. The app interface currently uses Traditional Chinese.

## Generated files

- `WifiSpectrum.xcodeproj`, `App/Info.plist` and `App/WifiSpectrum.entitlements` are generated from `project.yml` by XcodeGen and are not committed.
- `python scripts/generate_icon.py` (Pillow) redraws the app icon and `assets/wifi-spectrum.png`.
- `python scripts/generate_demo.py ci-artifacts/screenshots` builds `docs/media/` from the screenshots CI publishes on the `ci-artifacts` branch.
- `Core/Sources/WifiSpectrumCore/Resources/oui.tsv` comes from the IEEE registry: `python scripts/build_oui.py oui.csv Core/Sources/WifiSpectrumCore/Resources/oui.tsv`.

`SHA256SUMS.txt` records SHA-256 hashes of the committed file bytes, excluding itself.
