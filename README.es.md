<p align="center">
  <a href="README.md">English</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.zh-TW.md">繁體中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a><br>
  <a href="README.de.md">Deutsch</a> · <strong>Español</strong> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.vi.md">Tiếng Việt</a> · <a href="README.id.md">Bahasa Indonesia</a> · <a href="README.it.md">Italiano</a>
</p>

<p align="center"><img src="assets/wifi-spectrum.png" width="112" alt="Icono de Wi-Fi Spectrum"></p>
<h1 align="center">Herramientas de red Wi-Fi para iPhone</h1>
<p align="center">Wi-Fi Spectrum (Wi-Fi 頻譜分析儀) · red actual · test de velocidad · LAN · calculadora de canales</p>
<p align="center">
  <a href="https://github.com/tonykfr1234/ios_wifi-spectrum/actions/workflows/security.yml"><img src="https://github.com/tonykfr1234/ios_wifi-spectrum/actions/workflows/security.yml/badge.svg" alt="CI"></a>
  <img src="https://img.shields.io/badge/platform-iOS%2016%2B-000000" alt="iOS 16+">
  <img src="https://img.shields.io/badge/Swift-6.1-F05138" alt="Swift 6.1">
  <img src="https://img.shields.io/badge/SwiftUI-iPhone-0A84FF" alt="SwiftUI">
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-green" alt="Licencia MIT"></a>
</p>
<p align="center">
  <a href="#quick-start">Inicio rápido</a> · <a href="#workflow">Flujo</a> · <a href="#features">Funciones</a> · <a href="#demo">Demostración</a> · <a href="#faq">Preguntas frecuentes</a> · <a href="#documentation">Documentación</a>
</p>

```bash
brew install xcodegen && xcodegen generate && open WifiSpectrum.xcodeproj
```

---

Versión 1.0: todo lo que iOS deja ver a una app sobre el Wi-Fi, más test de velocidad, descubrimiento LAN y cinco herramientas de red. Las reglas de canales son las mismas que en la app de Android.

Wi-Fi Spectrum para iOS muestra el SSID, el BSSID con su fabricante, el tipo de seguridad, las direcciones y la subred de la red actual; mide descarga, subida, latencia y jitter; encuentra dispositivos en la red local; y ofrece latencia TCP, DNS, escaneo de puertos, una calculadora de canales para 2,4/5/6 GHz y 20–320 MHz y una calculadora de subredes.

Apple no da a las apps acceso a redes cercanas, canales, anchos de canal, intensidad de señal ni Wi-Fi 7 MLO, así que esta app no los promete. Para un análisis de espectro completo, usa la versión de Android, [Android_wifi-spectrum](https://github.com/tonykfr1234/android_wifi-spectrum).

Los 12 idiomas del README traducen la documentación. La interfaz de la app está actualmente en chino tradicional.

<a id="quick-start"></a>
## Inicio rápido

1. En un Mac con Xcode 16+, clona este repositorio y ejecuta el comando de arriba (instala XcodeGen, genera el proyecto y abre Xcode).
2. Selecciona el target `WifiSpectrum`, elige tu equipo en Signing & Capabilities y confirma que aparece Access Wi-Fi Information.
3. Ejecuta en un iPhone con iOS 16+. Permite la ubicación (solo para el nombre del Wi-Fi) y, en el primer escaneo LAN, «Red local».
4. El simulador no tiene información Wi-Fi; activa el modo demostración en la pestaña 關於 para ver todas las pantallas con datos sintéticos.
5. Cada push ejecuta las pruebas en GitHub Actions; los registros y capturas del simulador aparecen en la rama `ci-artifacts`.

**¿Publicar en el App Store?** Sigue [docs/PUBLISHING.zh-TW.md](docs/PUBLISHING.zh-TW.md) ([resumen en inglés](docs/PUBLISHING.md)): configura el bundle ID y el equipo, archiva, sube, prueba con TestFlight y envía con las notas de revisión preparadas.

<a id="workflow"></a>
## Flujo

```text
Se abre la pestaña 連線
  → ¿ubicación permitida? NEHotspotNetwork.fetchCurrent → SSID, BSSID, seguridad
  → BSSID → fabricante IEEE sin conexión (las MAC aleatorias se marcan)
  → getifaddrs + NWPathMonitor → IPv4, máscara, subred, IPv6, estado de la ruta
LAN: Bonjour (10 tipos de servicio) + barrido TCP de 6 puertos en la /24
Velocidad: 10 viajes HTTPS, 3 descargas, 3 subidas → medianas
```

Nada se ejecuta en segundo plano y nada queda guardado al cerrar la app. Las redes con más de 1.024 direcciones no se barren. La latencia es el tiempo de conexión TCP porque iOS no permite ICMP a las apps normales.

<a id="features"></a>
## Funciones

| Función | Comportamiento |
| --- | --- |
| Wi-Fi actual | SSID, BSSID, fabricante del registro IEEE, tipo de seguridad (iOS 15+) |
| Interfaz | IPv4, máscara, subred y número de hosts, IPv6, modo de datos reducidos y red de pago |
| Test de velocidad | Endpoints de Cloudflare; mediana de 3 descargas y 3 subidas; latencia y jitter; cancelable; historial de 20 |
| Descubrimiento LAN | Nombres Bonjour y hosts que responden en 80/443/22/445/554/62078; progreso y parada |
| Calculadora de canales | 2,4/5/6 GHz, 20–320 MHz: rango ocupado, canales central y cubiertos, PSC, DFS, subbanda UNII |
| Herramientas de red | Latencia TCP con pérdida y jitter, DNS A/AAAA/CNAME, escaneo de 19 puertos comunes o un rango |
| Calculadora de subredes | CIDR o máscara → red, difusión, rango y número de hosts |
| Privacidad | Sin recopilación de datos, anuncios ni analítica; manifiesto de privacidad incluido |

iOS no ofrece redes cercanas, canales, anchos, RSSI ni MLO; la calculadora aplica las mismas reglas que la app de Android usa con los resultados del escaneo. Los resultados LAN no tienen fabricante porque iOS oculta las direcciones MAC de otros dispositivos.

<a id="demo"></a>
## Demostración

Estas pantallas las capturaron las **pruebas de UI en el simulador de iPhone en modo demostración**: la interfaz real de la app con el mismo apartamento sintético de Taipéi que la demo de Android. No es una red real ni muestra el rendimiento de ningún dispositivo.

![Recorrido por la app de iOS en modo demostración](docs/media/wifi-spectrum-ios-demo.gif)

[Abrir o descargar la demostración MP4](docs/media/wifi-spectrum-ios-demo.mp4)

| Red actual | Test de velocidad | Calculadora de canales |
| --- | --- | --- |
| ![Red actual](docs/media/connection.png) | ![Test de velocidad](docs/media/speedtest.png) | ![Calculadora de canales](docs/media/channel-calculator.png) |

## Últimos cambios

Primera versión con detalles de la red actual, test de velocidad, descubrimiento LAN, cinco herramientas, modo demostración, guía para el App Store y CI que ejecuta 48 pruebas en Linux, macOS y el simulador de iPhone. Consulta el [registro de cambios](CHANGELOG.md).

<a id="controls"></a>
## Controles

| Control | Acción |
| --- | --- |
| Deslizar hacia abajo / ↻ (連線) | Volver a leer el Wi-Fi y la interfaz |
| 開始測速 / 停止 (測速) | Iniciar o cancelar el test de velocidad |
| 開始掃描 / 停止掃描 (區網) | Iniciar o detener el descubrimiento LAN |
| Selectores de banda / canal / ancho | Recalcular; los anchos no válidos no se ofrecen |
| Herramientas → campo de host | Escribe un nombre o IP; los errores de formato se explican antes de enviar nada |
| 關於 → 示範模式 | Cambiar entre datos reales y el entorno sintético |

<a id="faq"></a>
## Preguntas frecuentes

**¿Por qué no muestra redes cercanas ni canales?** Apple no ofrece una API pública para ello y las API privadas se rechazan en la revisión. Para análisis de espectro, usa la versión de Android.

**¿Por qué pide la ubicación?** iOS solo revela el SSID y el BSSID actuales a apps con permiso de ubicación. La app nunca lee coordenadas.

**¿Por qué el simulador dice que no estoy conectado?** El simulador no tiene información Wi-Fi. Activa el modo demostración en la pestaña 關於.

**¿Por qué el escaneo LAN no encuentra nada?** Permite «Red local» en Ajustes → Privacidad y seguridad y comprueba que el router no aísle a los clientes inalámbricos.

**¿Adónde se conecta el test de velocidad?** A los endpoints públicos de Cloudflare en speed.cloudflare.com. Una prueba usa unos 100 MB.

<a id="docs"></a>
<a id="documentation"></a>
## Documentación

| Tema | Documento |
| --- | --- |
| Uso diario | [繁中使用指南](docs/USER_GUIDE.zh-TW.md) · [English User Guide](docs/USER_GUIDE.md) |
| Funcionamiento interno | [Arquitectura](docs/ARCHITECTURE.md) |
| Publicación | [Guía del App Store (繁中)](docs/PUBLISHING.zh-TW.md) · [Resumen en inglés](docs/PUBLISHING.md) · [Política de privacidad](docs/PRIVACY.md) |
| Versiones y seguridad | [Registro de cambios](CHANGELOG.md) · [Seguridad](SECURITY.md) · [Contribuir](CONTRIBUTING.md) |

La app está en `App/`, la lógica compartida en el paquete Swift `Core/`, las pruebas en `Core/Tests`, `AppTests` y `AppUITests`, y las herramientas en `scripts/`. El proyecto se genera desde `project.yml`. Comprueba SSID, LAN y velocidad en un iPhone real; el simulador no puede.

## Seguridad

Nunca subas certificados, perfiles de aprovisionamiento, claves de la API de App Store Connect, archivos `.ipa` ni escaneos de redes ajenas. Antes de hacer push, ejecuta el mismo escáner que GitHub Actions:

```bash
python scripts/security_scan.py .
```

## Licencia

[MIT](LICENSE).

### 2026-10-20 · 1.0.0

首次發布：目前連線資訊、測速、區域網路探索、TCP 延遲、DNS、連接埠掃描、頻道與子網路計算機；48 個測試在 Linux、macOS 與 iPhone 模擬器上執行。

First release: current-network details, speed test, LAN discovery, TCP latency, DNS, port scan, channel and subnet calculators; 48 tests run on Linux, macOS and the iPhone simulator.

[Guía pública de uso (chino tradicional, texto plano)](docs/使用說明.txt)
