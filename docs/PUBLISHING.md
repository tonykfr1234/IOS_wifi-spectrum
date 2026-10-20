# Publishing to the App Store

A full walkthrough in Traditional Chinese, including listing text and review notes, is in [PUBLISHING.zh-TW.md](PUBLISHING.zh-TW.md). Summary:

1. **Requirements**: a Mac with Xcode 16+, an Apple Developer Program membership and an iPhone on iOS 16+.
2. **Generate the project**:
   ```bash
   brew install xcodegen
   xcodegen generate
   open WifiSpectrum.xcodeproj
   ```
3. **Set your identity** in `project.yml`: `PRODUCT_BUNDLE_IDENTIFIER` and `DEVELOPMENT_TEAM`, then regenerate. The bundle ID cannot change after the app record exists.
4. **Signing & Capabilities**: automatic signing; confirm *Access Wi-Fi Information* is listed.
5. **Test on a device**: the simulator has no Wi-Fi information. Check SSID/BSSID after allowing location, LAN discovery after allowing Local Network, and a full speed test.
6. **App Store Connect**: create the app (primary language Traditional Chinese, your bundle ID).
7. **Archive and upload**: Product → Archive → Distribute App → App Store Connect, or `xcodebuild archive` + `-exportArchive` with `method = app-store-connect`.
8. **TestFlight**: install the uploaded build and repeat step 5.
9. **App information**: privacy policy URL (publish `docs/PRIVACY.md`, e.g. GitHub Pages from `/docs`), App Privacy "Data Not Collected", category Utilities, age rating 4+, export compliance already declared in `Info.plist`.
10. **Screenshots**: iPhone only, so 6.9-inch (1320×2868) is enough. CI saves Pro Max simulator screenshots on the `ci-artifacts` branch.
11. **Review notes**: explain that location is only for the Wi-Fi name, Local Network is for LAN discovery, and that demo mode (About tab) shows every screen without Wi-Fi.
12. **Submit**; for updates bump `MARKETING_VERSION` and `CURRENT_PROJECT_VERSION`.
