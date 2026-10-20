<p align="center">
  <a href="README.md">English</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.zh-TW.md">繁體中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a><br>
  <a href="README.de.md">Deutsch</a> · <a href="README.es.md">Español</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <strong>Tiếng Việt</strong> · <a href="README.id.md">Bahasa Indonesia</a> · <a href="README.it.md">Italiano</a>
</p>

<p align="center"><img src="assets/wifi-spectrum.png" width="112" alt="Biểu tượng Wi-Fi Spectrum"></p>
<h1 align="center">Bộ công cụ mạng Wi-Fi cho iPhone</h1>
<p align="center">Wi-Fi Spectrum (Wi-Fi 頻譜分析儀) · mạng hiện tại · đo tốc độ · LAN · máy tính kênh</p>
<p align="center">
  <a href="https://github.com/tonykfr1234/ios_wifi-spectrum/actions/workflows/security.yml"><img src="https://github.com/tonykfr1234/ios_wifi-spectrum/actions/workflows/security.yml/badge.svg" alt="CI"></a>
  <img src="https://img.shields.io/badge/platform-iOS%2016%2B-000000" alt="iOS 16+">
  <img src="https://img.shields.io/badge/Swift-6.1-F05138" alt="Swift 6.1">
  <img src="https://img.shields.io/badge/SwiftUI-iPhone-0A84FF" alt="SwiftUI">
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-green" alt="Giấy phép MIT"></a>
</p>
<p align="center">
  <a href="#quick-start">Bắt đầu nhanh</a> · <a href="#workflow">Quy trình</a> · <a href="#features">Tính năng</a> · <a href="#demo">Minh họa</a> · <a href="#faq">Câu hỏi thường gặp</a> · <a href="#documentation">Tài liệu</a>
</p>

```bash
brew install xcodegen && xcodegen generate && open WifiSpectrum.xcodeproj
```

---

Phiên bản 1.0: mọi thông tin Wi-Fi mà iOS cho phép ứng dụng xem, cùng đo tốc độ, khám phá LAN và năm công cụ mạng. Quy tắc kênh giống ứng dụng Android.

Wi-Fi Spectrum cho iOS hiển thị SSID, BSSID kèm nhà sản xuất, kiểu bảo mật, địa chỉ và mạng con của mạng hiện tại; đo tải xuống, tải lên, độ trễ và jitter; tìm thiết bị trong mạng nội bộ; và có độ trễ TCP, DNS, quét cổng, máy tính kênh 2,4/5/6 GHz với 20–320 MHz cùng máy tính mạng con.

Apple không cho ứng dụng truy cập mạng xung quanh, kênh, độ rộng kênh, cường độ tín hiệu hay Wi-Fi 7 MLO, nên ứng dụng này không quảng cáo những điều đó. Để phân tích phổ đầy đủ, hãy dùng bản Android [Android_wifi-spectrum](https://github.com/tonykfr1234/android_wifi-spectrum).

README có 12 ngôn ngữ là bản dịch tài liệu. Giao diện ứng dụng hiện dùng tiếng Trung phồn thể.

<a id="quick-start"></a>
## Bắt đầu nhanh

1. Trên máy Mac có Xcode 16+, clone kho này và chạy lệnh ở trên (cài XcodeGen, tạo dự án, mở Xcode).
2. Chọn target `WifiSpectrum`, chọn nhóm của bạn trong Signing & Capabilities và kiểm tra có Access Wi-Fi Information.
3. Chạy trên iPhone iOS 16+. Cho phép vị trí (chỉ để đọc tên Wi-Fi) và, ở lần quét LAN đầu tiên, cho phép “Mạng cục bộ”.
4. Trình mô phỏng không có thông tin Wi-Fi; bật chế độ minh họa ở thẻ 關於 để xem mọi màn hình với dữ liệu mô phỏng.
5. Mỗi lần push đều chạy kiểm thử trên GitHub Actions; nhật ký và ảnh chụp trình mô phỏng nằm ở nhánh `ci-artifacts`.

**Phát hành trên App Store?** Làm theo [docs/PUBLISHING.zh-TW.md](docs/PUBLISHING.zh-TW.md) ([tóm tắt tiếng Anh](docs/PUBLISHING.md)): đặt bundle ID và nhóm, archive, tải lên, thử bằng TestFlight rồi gửi kèm ghi chú duyệt đã soạn sẵn.

<a id="workflow"></a>
## Quy trình

```text
Mở thẻ 連線
  → đã cho phép vị trí? NEHotspotNetwork.fetchCurrent → SSID, BSSID, bảo mật
  → BSSID → tra nhà sản xuất IEEE ngoại tuyến (MAC ngẫu nhiên được đánh dấu)
  → getifaddrs + NWPathMonitor → IPv4, mặt nạ, mạng con, IPv6, trạng thái đường truyền
LAN: Bonjour (10 loại dịch vụ) + quét TCP 6 cổng trên /24
Tốc độ: 10 lượt HTTPS, 3 lần tải xuống, 3 lần tải lên → trung vị
```

Không có gì chạy nền và không lưu gì sau khi đóng ứng dụng. Mạng có hơn 1.024 địa chỉ không được quét. Độ trễ là thời gian kết nối TCP vì iOS không cho ứng dụng thường dùng ICMP.

<a id="features"></a>
## Tính năng

| Tính năng | Hoạt động |
| --- | --- |
| Wi-Fi hiện tại | SSID, BSSID, nhà sản xuất từ sổ đăng ký IEEE, kiểu bảo mật (iOS 15+) |
| Giao diện mạng | IPv4, mặt nạ, mạng con và số máy, IPv6, chế độ dữ liệu thấp và mạng tính phí |
| Đo tốc độ | Điểm cuối Cloudflare; trung vị 3 lần tải xuống và 3 lần tải lên; độ trễ và jitter; có thể hủy; lưu 20 kết quả |
| Khám phá LAN | Tên Bonjour và máy trả lời ở 80/443/22/445/554/62078; tiến độ và dừng |
| Máy tính kênh | 2,4/5/6 GHz, 20–320 MHz: dải chiếm dụng, kênh trung tâm và kênh bị phủ, PSC, DFS, băng con UNII |
| Công cụ mạng | Độ trễ TCP kèm mất gói và jitter, DNS A/AAAA/CNAME, quét 19 cổng phổ biến hoặc một dải |
| Máy tính mạng con | CIDR hoặc mặt nạ → mạng, broadcast, dải và số máy |
| Quyền riêng tư | Không thu thập dữ liệu, không quảng cáo, không phân tích; có tệp khai báo quyền riêng tư |

iOS không cung cấp mạng xung quanh, kênh, độ rộng, RSSI hay MLO; máy tính kênh áp dụng cùng quy tắc mà ứng dụng Android dùng cho kết quả quét. Kết quả LAN không có nhà sản xuất vì iOS ẩn địa chỉ MAC của thiết bị khác.

<a id="demo"></a>
## Minh họa

Các màn hình này được **kiểm thử giao diện trên trình mô phỏng iPhone chụp ở chế độ minh họa**: giao diện thật của ứng dụng với cùng căn hộ mô phỏng ở Đài Bắc như bản minh họa Android. Đây không phải mạng thật và không thể hiện hiệu năng của thiết bị nào.

![Minh họa ứng dụng iOS ở chế độ minh họa](docs/media/wifi-spectrum-ios-demo.gif)

[Mở hoặc tải video minh họa MP4](docs/media/wifi-spectrum-ios-demo.mp4)

| Mạng hiện tại | Đo tốc độ | Máy tính kênh |
| --- | --- | --- |
| ![Mạng hiện tại](docs/media/connection.png) | ![Đo tốc độ](docs/media/speedtest.png) | ![Máy tính kênh](docs/media/channel-calculator.png) |

## Thay đổi mới nhất

Bản phát hành đầu tiên với thông tin mạng hiện tại, đo tốc độ, khám phá LAN, năm công cụ, chế độ minh họa, hướng dẫn App Store và CI chạy 48 bài kiểm thử trên Linux, macOS và trình mô phỏng iPhone. Xem [nhật ký thay đổi](CHANGELOG.md).

<a id="controls"></a>
## Điều khiển

| Điều khiển | Tác dụng |
| --- | --- |
| Kéo xuống / ↻ (連線) | Đọc lại thông tin Wi-Fi và giao diện mạng |
| 開始測速 / 停止 (測速) | Bắt đầu hoặc hủy đo tốc độ |
| 開始掃描 / 停止掃描 (區網) | Bắt đầu hoặc dừng khám phá LAN |
| Chọn băng tần / kênh / độ rộng | Tính lại; độ rộng không hợp lệ không được hiển thị |
| Công cụ → ô máy chủ | Nhập tên hoặc IP; lỗi định dạng được giải thích trước khi gửi |
| 關於 → 示範模式 | Chuyển giữa dữ liệu thật và môi trường mô phỏng |

<a id="faq"></a>
## Câu hỏi thường gặp

**Vì sao không hiển thị mạng xung quanh hay kênh?** Apple không cung cấp API công khai và các API riêng bị từ chối khi duyệt. Hãy dùng bản Android để phân tích phổ.

**Vì sao cần quyền vị trí?** iOS chỉ cho ứng dụng có quyền vị trí biết SSID và BSSID hiện tại. Ứng dụng không đọc tọa độ.

**Vì sao trình mô phỏng báo chưa kết nối?** Trình mô phỏng không có thông tin Wi-Fi. Bật chế độ minh họa ở thẻ 關於.

**Vì sao quét LAN không tìm thấy gì?** Cho phép “Mạng cục bộ” trong Cài đặt → Quyền riêng tư & Bảo mật và kiểm tra router không cô lập máy khách không dây.

**Đo tốc độ kết nối tới đâu?** Tới điểm cuối công khai của Cloudflare tại speed.cloudflare.com. Mỗi lần đo dùng khoảng 100 MB.

<a id="docs"></a>
<a id="documentation"></a>
## Tài liệu

| Chủ đề | Tài liệu |
| --- | --- |
| Sử dụng hằng ngày | [繁中使用指南](docs/USER_GUIDE.zh-TW.md) · [English User Guide](docs/USER_GUIDE.md) |
| Cấu trúc bên trong | [Kiến trúc](docs/ARCHITECTURE.md) |
| Phát hành | [Hướng dẫn App Store (繁中)](docs/PUBLISHING.zh-TW.md) · [Tóm tắt tiếng Anh](docs/PUBLISHING.md) · [Chính sách quyền riêng tư](docs/PRIVACY.md) |
| Phiên bản và bảo mật | [Nhật ký thay đổi](CHANGELOG.md) · [Bảo mật](SECURITY.md) · [Đóng góp](CONTRIBUTING.md) |

Ứng dụng ở `App/`, logic dùng chung ở gói Swift `Core/`, kiểm thử ở `Core/Tests`, `AppTests` và `AppUITests`, công cụ ở `scripts/`. Tệp dự án được tạo từ `project.yml`. Hãy kiểm tra SSID, LAN và tốc độ trên iPhone thật; trình mô phỏng không làm được.

## Bảo mật

Không bao giờ commit chứng chỉ, hồ sơ cấp phép, khóa API App Store Connect, tệp `.ipa` hay dữ liệu quét mạng không thuộc về bạn. Trước khi push, chạy cùng trình quét mà GitHub Actions dùng:

```bash
python scripts/security_scan.py .
```

## Giấy phép

[MIT](LICENSE).

### 2026-10-20 · 1.0.0

首次發布：目前連線資訊、測速、區域網路探索、TCP 延遲、DNS、連接埠掃描、頻道與子網路計算機；48 個測試在 Linux、macOS 與 iPhone 模擬器上執行。

First release: current-network details, speed test, LAN discovery, TCP latency, DNS, port scan, channel and subnet calculators; 48 tests run on Linux, macOS and the iPhone simulator.

[Hướng dẫn sử dụng công khai (tiếng Trung phồn thể, văn bản thuần)](docs/使用說明.txt)
