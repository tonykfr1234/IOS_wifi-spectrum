<p align="center">
  <a href="README.md">English</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.zh-TW.md">繁體中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a><br>
  <a href="README.de.md">Deutsch</a> · <a href="README.es.md">Español</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.vi.md">Tiếng Việt</a> · <strong>Bahasa Indonesia</strong> · <a href="README.it.md">Italiano</a>
</p>

<p align="center"><img src="assets/wifi-spectrum.png" width="112" alt="Ikon Wi-Fi Spectrum"></p>
<h1 align="center">Perangkat Jaringan Wi-Fi untuk iPhone</h1>
<p align="center">Wi-Fi Spectrum (Wi-Fi 頻譜分析儀) · jaringan saat ini · uji kecepatan · LAN · kalkulator kanal</p>
<p align="center">
  <a href="https://github.com/tonykfr1234/ios_wifi-spectrum/actions/workflows/security.yml"><img src="https://github.com/tonykfr1234/ios_wifi-spectrum/actions/workflows/security.yml/badge.svg" alt="CI"></a>
  <img src="https://img.shields.io/badge/platform-iOS%2016%2B-000000" alt="iOS 16+">
  <img src="https://img.shields.io/badge/Swift-6.1-F05138" alt="Swift 6.1">
  <img src="https://img.shields.io/badge/SwiftUI-iPhone-0A84FF" alt="SwiftUI">
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-green" alt="Lisensi MIT"></a>
</p>
<p align="center">
  <a href="#quick-start">Mulai cepat</a> · <a href="#workflow">Alur kerja</a> · <a href="#features">Fitur</a> · <a href="#demo">Demo</a> · <a href="#faq">Tanya jawab</a> · <a href="#documentation">Dokumentasi</a>
</p>

```bash
brew install xcodegen && xcodegen generate && open WifiSpectrum.xcodeproj
```

---

Versi 1.0: semua informasi Wi-Fi yang diizinkan iOS untuk aplikasi, ditambah uji kecepatan, penemuan LAN, dan lima alat jaringan. Aturan kanal sama dengan aplikasi Android.

Wi-Fi Spectrum untuk iOS menampilkan SSID, BSSID beserta vendornya, jenis keamanan, alamat, dan subnet jaringan saat ini; mengukur unduh, unggah, latensi, dan jitter; menemukan perangkat di jaringan lokal; serta menyediakan latensi TCP, DNS, pemindaian port, kalkulator kanal 2,4/5/6 GHz untuk 20–320 MHz, dan kalkulator subnet.

Apple tidak memberi aplikasi akses ke jaringan di sekitar, kanal, lebar kanal, kekuatan sinyal, atau Wi-Fi 7 MLO, jadi aplikasi ini tidak mengklaimnya. Untuk analisis spektrum lengkap, gunakan versi Android [Android_wifi-spectrum](https://github.com/tonykfr1234/android_wifi-spectrum).

README dalam 12 bahasa adalah terjemahan dokumentasi. Antarmuka aplikasi saat ini memakai bahasa Tionghoa tradisional.

<a id="quick-start"></a>
## Mulai cepat

1. Di Mac dengan Xcode 16+, clone repositori ini dan jalankan perintah di atas (memasang XcodeGen, membuat proyek, membuka Xcode).
2. Pilih target `WifiSpectrum`, pilih tim Anda di Signing & Capabilities, dan pastikan Access Wi-Fi Information tercantum.
3. Jalankan di iPhone dengan iOS 16+. Izinkan lokasi (hanya untuk nama Wi-Fi) dan, pada pemindaian LAN pertama, “Jaringan Lokal”.
4. Simulator tidak punya informasi Wi-Fi; aktifkan mode demo di tab 關於 untuk melihat semua layar dengan data sintetis.
5. Setiap push menjalankan pengujian di GitHub Actions; log dan tangkapan layar simulator ada di branch `ci-artifacts`.

**Ingin rilis di App Store?** Ikuti [docs/PUBLISHING.zh-TW.md](docs/PUBLISHING.zh-TW.md) ([ringkasan bahasa Inggris](docs/PUBLISHING.md)): atur bundle ID dan tim, buat arsip, unggah, uji dengan TestFlight, lalu kirim dengan catatan peninjauan yang sudah disiapkan.

<a id="workflow"></a>
## Alur kerja

```text
Tab 連線 dibuka
  → lokasi diizinkan? NEHotspotNetwork.fetchCurrent → SSID, BSSID, keamanan
  → BSSID → cari vendor IEEE secara offline (MAC acak ditandai)
  → getifaddrs + NWPathMonitor → IPv4, mask, subnet, IPv6, status jalur
LAN: Bonjour (10 jenis layanan) + pemindaian TCP 6 port pada /24
Kecepatan: 10 perjalanan HTTPS, 3 unduhan, 3 unggahan → median
```

Tidak ada yang berjalan di latar belakang dan tidak ada yang disimpan setelah aplikasi ditutup. Jaringan dengan lebih dari 1.024 alamat tidak dipindai. Latensi diukur sebagai waktu koneksi TCP karena iOS tidak mengizinkan ICMP untuk aplikasi biasa.

<a id="features"></a>
## Fitur

| Fitur | Perilaku |
| --- | --- |
| Wi-Fi saat ini | SSID, BSSID, vendor dari registri IEEE, jenis keamanan (iOS 15+) |
| Antarmuka | IPv4, mask, subnet dan jumlah host, IPv6, mode data rendah dan jaringan berbayar |
| Uji kecepatan | Endpoint Cloudflare; median 3 unduhan dan 3 unggahan; latensi dan jitter; bisa dibatalkan; riwayat 20 |
| Penemuan LAN | Nama Bonjour dan host yang menjawab di 80/443/22/445/554/62078; progres dan berhenti |
| Kalkulator kanal | 2,4/5/6 GHz, 20–320 MHz: rentang yang ditempati, kanal tengah dan tercakup, PSC, DFS, sub-pita UNII |
| Alat jaringan | Latensi TCP dengan kehilangan dan jitter, DNS A/AAAA/CNAME, pemindaian 19 port umum atau rentang |
| Kalkulator subnet | CIDR atau mask → jaringan, broadcast, rentang dan jumlah host |
| Privasi | Tanpa pengumpulan data, iklan, atau analitik; manifes privasi disertakan |

iOS tidak menyediakan jaringan sekitar, kanal, lebar, RSSI, atau MLO; kalkulator kanal menerapkan aturan yang sama dengan yang dipakai aplikasi Android untuk hasil pindaian. Hasil LAN tidak memiliki vendor karena iOS menyembunyikan alamat MAC perangkat lain.

<a id="demo"></a>
## Demo

Layar ini diambil oleh **pengujian UI di simulator iPhone dalam mode demo**: antarmuka asli aplikasi dengan apartemen sintetis di Taipei yang sama dengan demo Android. Ini bukan jaringan nyata dan tidak menunjukkan kinerja perangkat apa pun.

![Demo aplikasi iOS dalam mode demo](docs/media/wifi-spectrum-ios-demo.gif)

[Buka atau unduh demo MP4](docs/media/wifi-spectrum-ios-demo.mp4)

| Jaringan saat ini | Uji kecepatan | Kalkulator kanal |
| --- | --- | --- |
| ![Jaringan saat ini](docs/media/connection.png) | ![Uji kecepatan](docs/media/speedtest.png) | ![Kalkulator kanal](docs/media/channel-calculator.png) |

## Perubahan terbaru

Rilis pertama dengan detail jaringan saat ini, uji kecepatan, penemuan LAN, lima alat, mode demo, panduan App Store, dan CI yang menjalankan 48 pengujian di Linux, macOS, dan simulator iPhone. Lihat [catatan perubahan](CHANGELOG.md).

<a id="controls"></a>
## Kontrol

| Kontrol | Tindakan |
| --- | --- |
| Tarik ke bawah / ↻ (連線) | Baca ulang Wi-Fi dan antarmuka |
| 開始測速 / 停止 (測速) | Mulai atau batalkan uji kecepatan |
| 開始掃描 / 停止掃描 (區網) | Mulai atau hentikan penemuan LAN |
| Pemilih pita / kanal / lebar | Hitung ulang; lebar yang tidak valid tidak ditawarkan |
| Alat → kolom host | Masukkan nama atau IP; kesalahan format dijelaskan sebelum apa pun dikirim |
| 關於 → 示範模式 | Beralih antara data nyata dan lingkungan sintetis |

<a id="faq"></a>
## Tanya jawab

**Mengapa tidak bisa menampilkan jaringan atau kanal di sekitar?** Apple tidak menyediakan API publik dan API privat ditolak saat peninjauan. Untuk analisis spektrum, gunakan versi Android.

**Mengapa meminta lokasi?** iOS hanya memberi tahu SSID dan BSSID saat ini kepada aplikasi yang punya izin lokasi. Aplikasi tidak membaca koordinat.

**Mengapa simulator bilang tidak terhubung?** Simulator tidak punya informasi Wi-Fi. Aktifkan mode demo di tab 關於.

**Mengapa pemindaian LAN tidak menemukan apa pun?** Izinkan “Jaringan Lokal” di Pengaturan → Privasi & Keamanan, dan pastikan router tidak mengisolasi klien nirkabel.

**Uji kecepatan terhubung ke mana?** Ke endpoint publik Cloudflare di speed.cloudflare.com. Satu kali uji memakai sekitar 100 MB.

<a id="docs"></a>
<a id="documentation"></a>
## Dokumentasi

| Topik | Dokumen |
| --- | --- |
| Penggunaan harian | [繁中使用指南](docs/USER_GUIDE.zh-TW.md) · [English User Guide](docs/USER_GUIDE.md) |
| Cara kerja internal | [Arsitektur](docs/ARCHITECTURE.md) |
| Rilis | [Panduan App Store (繁中)](docs/PUBLISHING.zh-TW.md) · [Ringkasan bahasa Inggris](docs/PUBLISHING.md) · [Kebijakan privasi](docs/PRIVACY.md) |
| Versi dan keamanan | [Catatan perubahan](CHANGELOG.md) · [Keamanan](SECURITY.md) · [Berkontribusi](CONTRIBUTING.md) |

Aplikasi ada di `App/`, logika bersama di paket Swift `Core/`, pengujian di `Core/Tests`, `AppTests`, dan `AppUITests`, serta alat di `scripts/`. File proyek dibuat dari `project.yml`. Periksa SSID, LAN, dan kecepatan di iPhone sungguhan; simulator tidak bisa.

## Keamanan

Jangan pernah meng-commit sertifikat, profil provisioning, kunci API App Store Connect, file `.ipa`, atau hasil pindaian jaringan milik orang lain. Sebelum push, jalankan pemindai yang sama dengan GitHub Actions:

```bash
python scripts/security_scan.py .
```

## Lisensi

[MIT](LICENSE).

### 2026-10-20 · 1.0.0

首次發布：目前連線資訊、測速、區域網路探索、TCP 延遲、DNS、連接埠掃描、頻道與子網路計算機；48 個測試在 Linux、macOS 與 iPhone 模擬器上執行。

First release: current-network details, speed test, LAN discovery, TCP latency, DNS, port scan, channel and subnet calculators; 48 tests run on Linux, macOS and the iPhone simulator.

[Panduan penggunaan publik (bahasa Tionghoa tradisional, teks biasa)](docs/使用說明.txt)
