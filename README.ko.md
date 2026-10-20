<p align="center">
  <a href="README.md">English</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.zh-TW.md">繁體中文</a> · <a href="README.ja.md">日本語</a> · <strong>한국어</strong><br>
  <a href="README.de.md">Deutsch</a> · <a href="README.es.md">Español</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.vi.md">Tiếng Việt</a> · <a href="README.id.md">Bahasa Indonesia</a> · <a href="README.it.md">Italiano</a>
</p>

<p align="center"><img src="assets/wifi-spectrum.png" width="112" alt="Wi-Fi Spectrum 아이콘"></p>
<h1 align="center">iPhone용 Wi-Fi 네트워크 도구</h1>
<p align="center">Wi-Fi 頻譜分析儀 · 현재 연결 · 속도 측정 · LAN · 채널 계산기</p>
<p align="center">
  <a href="https://github.com/tonykfr1234/ios_wifi-spectrum/actions/workflows/security.yml"><img src="https://github.com/tonykfr1234/ios_wifi-spectrum/actions/workflows/security.yml/badge.svg" alt="CI"></a>
  <img src="https://img.shields.io/badge/platform-iOS%2016%2B-000000" alt="iOS 16+">
  <img src="https://img.shields.io/badge/Swift-6.1-F05138" alt="Swift 6.1">
  <img src="https://img.shields.io/badge/SwiftUI-iPhone-0A84FF" alt="SwiftUI">
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-green" alt="MIT 라이선스"></a>
</p>
<p align="center">
  <a href="#quick-start">빠른 시작</a> · <a href="#workflow">동작 흐름</a> · <a href="#features">기능</a> · <a href="#demo">데모</a> · <a href="#faq">자주 묻는 질문</a> · <a href="#documentation">문서</a>
</p>

```bash
brew install xcodegen && xcodegen generate && open WifiSpectrum.xcodeproj
```

---

버전 1.0: iOS가 앱에 허용하는 모든 Wi-Fi 정보와 속도 측정, LAN 탐색, 다섯 가지 네트워크 도구. 채널 규칙은 Android 앱과 같습니다.

Wi-Fi Spectrum iOS 버전은 현재 연결의 SSID, BSSID와 제조사, 보안 방식, 주소와 서브넷을 보여주고, 다운로드·업로드·지연·지터를 측정하며, 로컬 네트워크의 기기를 찾습니다. TCP 지연, DNS, 포트 스캔, 2.4/5/6 GHz 및 20–320 MHz 채널 계산기, 서브넷 계산기도 제공합니다.

Apple은 앱에 주변 네트워크, 채널, 채널 폭, 신호 세기, Wi-Fi 7 MLO를 공개하지 않으므로 이 앱은 그런 기능을 내세우지 않습니다. 전체 스펙트럼 분석은 Android 버전 [Android_wifi-spectrum](https://github.com/tonykfr1234/android_wifi-spectrum)을 사용하세요.

12개 언어 README는 문서 번역입니다. 앱 화면은 현재 번체 중국어를 사용합니다.

<a id="quick-start"></a>
## 빠른 시작

1. Xcode 16 이상이 설치된 Mac에서 이 저장소를 클론하고 위 명령을 실행합니다(XcodeGen 설치, 프로젝트 생성, Xcode 실행).
2. `WifiSpectrum` 타깃을 선택하고 Signing & Capabilities에서 팀을 고른 뒤 Access Wi-Fi Information이 있는지 확인합니다.
3. iOS 16 이상 iPhone에서 실행합니다. 위치(Wi-Fi 이름 확인용)를 허용하고, 첫 LAN 스캔 때 '로컬 네트워크'를 허용합니다.
4. 시뮬레이터에는 Wi-Fi 정보가 없습니다. '關於' 탭에서 데모 모드를 켜면 합성 데이터로 모든 화면을 볼 수 있습니다.
5. 푸시할 때마다 GitHub Actions에서 테스트가 실행되고 로그와 시뮬레이터 스크린샷이 `ci-artifacts` 브랜치에 올라갑니다.

**App Store에 출시하려면** [docs/PUBLISHING.zh-TW.md](docs/PUBLISHING.zh-TW.md)([영어 요약](docs/PUBLISHING.md))를 따라 번들 ID와 팀을 설정하고, 아카이브와 업로드, TestFlight 테스트를 거쳐 준비된 심사 메모와 함께 제출하세요.

<a id="workflow"></a>
## 동작 흐름

```text
'連線' 탭 열기
  → 위치 허용? NEHotspotNetwork.fetchCurrent → SSID, BSSID, 보안 방식
  → BSSID → IEEE 제조사 오프라인 조회 (랜덤 MAC 표시)
  → getifaddrs + NWPathMonitor → IPv4, 마스크, 서브넷, IPv6, 경로 상태
LAN: Bonjour(서비스 10종) + /24의 모든 주소에서 6개 포트 확인
속도: HTTPS 왕복 10회, 다운로드 3회, 업로드 3회 → 중앙값
```

백그라운드에서 동작하지 않으며 앱을 닫으면 아무것도 남지 않습니다. 주소가 1,024개를 넘는 네트워크는 포트 스캔을 하지 않습니다. iOS는 일반 앱에 ICMP를 허용하지 않아 지연은 TCP 연결 시간으로 측정합니다.

<a id="features"></a>
## 기능

| 기능 | 동작 |
| --- | --- |
| 현재 Wi-Fi | SSID, BSSID, IEEE 등록부 제조사, 보안 방식(iOS 15 이상) |
| 인터페이스 | IPv4, 마스크, 서브넷과 호스트 수, IPv6, 저데이터 모드와 데이터 요금제 네트워크 |
| 속도 측정 | Cloudflare 엔드포인트. 다운로드·업로드 각 3회 중앙값, 지연과 지터, 취소 가능, 기록 20개 |
| LAN 탐색 | Bonjour 기기 이름과 80/443/22/445/554/62078에 응답하는 호스트. 진행 표시와 중지 |
| 채널 계산기 | 2.4/5/6 GHz, 20–320 MHz: 점유 범위, 중심·포함 채널, PSC, DFS, UNII 하위 대역 |
| 네트워크 도구 | 손실률과 지터를 포함한 TCP 지연, DNS A/AAAA/CNAME, 일반 포트 19개 또는 사용자 지정 범위 스캔 |
| 서브넷 계산기 | CIDR 또는 마스크 → 네트워크, 브로드캐스트, 호스트 범위와 개수 |
| 개인정보 | 데이터 수집, 광고, 분석 없음. 개인정보 매니페스트 포함 |

iOS는 주변 네트워크, 채널, 폭, RSSI, MLO를 제공하지 않습니다. 채널 계산기는 Android 앱이 스캔 결과에 쓰는 것과 같은 규칙을 적용합니다. iOS가 다른 기기의 MAC 주소를 숨기므로 LAN 결과에는 제조사가 없습니다.

<a id="demo"></a>
## 데모

아래 화면은 **iPhone 시뮬레이터의 UI 테스트가 데모 모드에서 캡처한 것**입니다. 실제 앱 화면에 Android 데모와 같은 합성 타이베이 아파트를 사용했습니다. 실제 네트워크가 아니며 특정 기기의 성능을 나타내지 않습니다.

![데모 모드에서 iOS 앱 둘러보기](docs/media/wifi-spectrum-ios-demo.gif)

[MP4 데모 재생 또는 다운로드](docs/media/wifi-spectrum-ios-demo.mp4)

| 현재 연결 | 속도 측정 | 채널 계산기 |
| --- | --- | --- |
| ![현재 연결](docs/media/connection.png) | ![속도 측정](docs/media/speedtest.png) | ![채널 계산기](docs/media/channel-calculator.png) |

## 최근 변경 사항

첫 출시: 현재 연결 정보, 속도 측정, LAN 탐색, 도구 다섯 가지, 데모 모드, App Store 출시 가이드, 그리고 Linux·macOS·iPhone 시뮬레이터에서 48개의 테스트를 실행하는 CI. [변경 기록](CHANGELOG.md)을 참고하세요.

<a id="controls"></a>
## 조작

| 조작 | 동작 |
| --- | --- |
| 아래로 당기기 / ↻ (連線) | Wi-Fi와 인터페이스 정보 새로고침 |
| 開始測速 / 停止 (測速) | 속도 측정 시작 또는 취소 |
| 開始掃描 / 停止掃描 (區網) | LAN 탐색 시작 또는 중지 |
| 대역 / 채널 / 폭 선택 | 다시 계산. 규칙에 맞지 않는 폭은 표시되지 않음 |
| 도구 → 호스트 입력 | 호스트 이름이나 IP 입력. 형식 오류는 전송 전에 설명 |
| 關於 → 示範模式 | 실제 데이터와 합성 환경 전환 |

<a id="faq"></a>
## 자주 묻는 질문

**주변 네트워크나 채널을 왜 보여주지 못하나요?** Apple이 공개 API를 제공하지 않습니다. 비공개 API는 App 심사에서 거절됩니다. 스펙트럼 분석은 Android 버전을 사용하세요.

**왜 위치 권한이 필요한가요?** iOS는 위치 권한이 있는 앱에만 현재 SSID와 BSSID를 알려줍니다. 앱은 좌표를 읽지 않습니다.

**시뮬레이터에서 연결되지 않았다고 나오는 이유는?** 시뮬레이터에는 Wi-Fi 정보가 없습니다. '關於' 탭에서 데모 모드를 켜세요.

**LAN 스캔에서 아무것도 찾지 못하는 이유는?** 설정 → 개인정보 보호 및 보안 → 로컬 네트워크에서 앱을 허용하고, 라우터가 무선 클라이언트를 격리하지 않는지 확인하세요.

**속도 측정은 어디에 연결하나요?** Cloudflare 공개 속도 측정 엔드포인트 speed.cloudflare.com입니다. 한 번에 약 100 MB를 사용합니다.

<a id="docs"></a>
<a id="documentation"></a>
## 문서

| 주제 | 문서 |
| --- | --- |
| 일상 사용 | [繁中使用指南](docs/USER_GUIDE.zh-TW.md) · [English User Guide](docs/USER_GUIDE.md) |
| 내부 구조 | [아키텍처](docs/ARCHITECTURE.md) |
| 출시 | [App Store 출시 가이드(번체)](docs/PUBLISHING.zh-TW.md) · [영어 요약](docs/PUBLISHING.md) · [개인정보처리방침](docs/PRIVACY.md) |
| 버전과 보안 | [변경 기록](CHANGELOG.md) · [보안](SECURITY.md) · [기여 가이드](CONTRIBUTING.md) |

앱은 `App/`, 공용 로직은 `Core/` Swift 패키지, 테스트는 `Core/Tests`·`AppTests`·`AppUITests`, 도구는 `scripts/`에 있습니다. 프로젝트 파일은 `project.yml`에서 생성합니다. SSID, LAN, 속도 결과는 실제 iPhone에서 확인하세요. 시뮬레이터로는 할 수 없습니다.

## 보안

인증서, 프로비저닝 프로파일, App Store Connect API 키, `.ipa`, 본인 소유가 아닌 네트워크의 스캔 결과를 커밋하지 마세요. 푸시 전에 GitHub Actions와 같은 스캐너를 실행하세요:

```bash
python scripts/security_scan.py .
```

## 라이선스

[MIT](LICENSE).

### 2026-10-20 · 1.0.0

首次發布：目前連線資訊、測速、區域網路探索、TCP 延遲、DNS、連接埠掃描、頻道與子網路計算機；48 個測試在 Linux、macOS 與 iPhone 模擬器上執行。

First release: current-network details, speed test, LAN discovery, TCP latency, DNS, port scan, channel and subnet calculators; 48 tests run on Linux, macOS and the iPhone simulator.

[공개 사용 설명서(번체 중국어, 텍스트)](docs/使用說明.txt)
