<p align="center">
  <a href="README.md">English</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.zh-TW.md">繁體中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a><br>
  <a href="README.de.md">Deutsch</a> · <a href="README.es.md">Español</a> · <a href="README.fr.md">Français</a> · <strong>Português (Brasil)</strong> · <a href="README.vi.md">Tiếng Việt</a> · <a href="README.id.md">Bahasa Indonesia</a> · <a href="README.it.md">Italiano</a>
</p>

<p align="center"><img src="assets/wifi-spectrum.png" width="112" alt="Ícone do Wi-Fi Spectrum"></p>
<h1 align="center">Ferramentas de rede Wi-Fi para iPhone</h1>
<p align="center">Wi-Fi Spectrum (Wi-Fi 頻譜分析儀) · rede atual · teste de velocidade · LAN · calculadora de canais</p>
<p align="center">
  <a href="https://github.com/tonykfr1234/ios_wifi-spectrum/actions/workflows/security.yml"><img src="https://github.com/tonykfr1234/ios_wifi-spectrum/actions/workflows/security.yml/badge.svg" alt="CI"></a>
  <img src="https://img.shields.io/badge/platform-iOS%2016%2B-000000" alt="iOS 16+">
  <img src="https://img.shields.io/badge/Swift-6.1-F05138" alt="Swift 6.1">
  <img src="https://img.shields.io/badge/SwiftUI-iPhone-0A84FF" alt="SwiftUI">
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-green" alt="Licença MIT"></a>
</p>
<p align="center">
  <a href="#quick-start">Início rápido</a> · <a href="#workflow">Fluxo</a> · <a href="#features">Recursos</a> · <a href="#demo">Demonstração</a> · <a href="#faq">Perguntas frequentes</a> · <a href="#documentation">Documentação</a>
</p>

```bash
brew install xcodegen && xcodegen generate && open WifiSpectrum.xcodeproj
```

---

Versão 1.0: tudo o que o iOS deixa um app ver sobre o Wi-Fi, mais teste de velocidade, descoberta na LAN e cinco ferramentas de rede. As regras de canais são as mesmas do app Android.

O Wi-Fi Spectrum para iOS mostra o SSID, o BSSID com fabricante, o tipo de segurança, os endereços e a sub-rede da rede atual; mede download, upload, latência e jitter; encontra dispositivos na rede local; e oferece latência TCP, DNS, varredura de portas, uma calculadora de canais para 2,4/5/6 GHz e 20–320 MHz e uma calculadora de sub-redes.

A Apple não dá aos apps acesso a redes próximas, canais, larguras de canal, intensidade de sinal ou Wi-Fi 7 MLO, então este app não promete isso. Para uma análise de espectro completa, use a versão Android, [Android_wifi-spectrum](https://github.com/tonykfr1234/android_wifi-spectrum).

Os 12 idiomas do README traduzem a documentação. A interface do app está atualmente em chinês tradicional.

<a id="quick-start"></a>
## Início rápido

1. Em um Mac com Xcode 16+, clone este repositório e execute o comando acima (instala o XcodeGen, gera o projeto e abre o Xcode).
2. Selecione o target `WifiSpectrum`, escolha sua equipe em Signing & Capabilities e confirme que Access Wi-Fi Information aparece.
3. Rode em um iPhone com iOS 16+. Permita a localização (só para o nome do Wi-Fi) e, na primeira varredura da LAN, “Rede local”.
4. O simulador não tem informações de Wi-Fi; ative o modo demonstração na aba 關於 para ver todas as telas com dados sintéticos.
5. Cada push executa os testes no GitHub Actions; logs e capturas do simulador aparecem no branch `ci-artifacts`.

**Publicar na App Store?** Siga [docs/PUBLISHING.zh-TW.md](docs/PUBLISHING.zh-TW.md) ([resumo em inglês](docs/PUBLISHING.md)): defina o bundle ID e a equipe, arquive, envie, teste com o TestFlight e submeta com as notas de revisão prontas.

<a id="workflow"></a>
## Fluxo

```text
A aba 連線 abre
  → localização permitida? NEHotspotNetwork.fetchCurrent → SSID, BSSID, segurança
  → BSSID → fabricante IEEE offline (MACs aleatórios são marcados)
  → getifaddrs + NWPathMonitor → IPv4, máscara, sub-rede, IPv6, estado do caminho
LAN: Bonjour (10 tipos de serviço) + varredura TCP de 6 portas na /24
Velocidade: 10 idas e voltas HTTPS, 3 downloads, 3 uploads → medianas
```

Nada roda em segundo plano e nada fica salvo após fechar o app. Redes com mais de 1.024 endereços não são varridas. A latência é o tempo de conexão TCP, porque o iOS não permite ICMP a apps comuns.

<a id="features"></a>
## Recursos

| Recurso | Comportamento |
| --- | --- |
| Wi-Fi atual | SSID, BSSID, fabricante do registro IEEE, tipo de segurança (iOS 15+) |
| Interface | IPv4, máscara, sub-rede e número de hosts, IPv6, modo de dados reduzidos e rede tarifada |
| Teste de velocidade | Endpoints da Cloudflare; mediana de 3 downloads e 3 uploads; latência e jitter; cancelável; histórico de 20 |
| Descoberta na LAN | Nomes Bonjour e hosts que respondem em 80/443/22/445/554/62078; progresso e parada |
| Calculadora de canais | 2,4/5/6 GHz, 20–320 MHz: faixa ocupada, canais central e cobertos, PSC, DFS, sub-banda UNII |
| Ferramentas de rede | Latência TCP com perda e jitter, DNS A/AAAA/CNAME, varredura das 19 portas comuns ou de um intervalo |
| Calculadora de sub-redes | CIDR ou máscara → rede, broadcast, faixa e número de hosts |
| Privacidade | Sem coleta de dados, anúncios ou análises; manifesto de privacidade incluído |

O iOS não fornece redes próximas, canais, larguras, RSSI ou MLO; a calculadora aplica as mesmas regras que o app Android usa nos resultados de varredura. Os resultados da LAN não têm fabricante porque o iOS oculta os endereços MAC de outros dispositivos.

<a id="demo"></a>
## Demonstração

Estas telas foram capturadas pelos **testes de interface no simulador do iPhone em modo demonstração**: a interface real do app com o mesmo apartamento sintético em Taipé da demonstração Android. Não é uma rede real e não mostra o desempenho de nenhum aparelho.

![Demonstração do app iOS em modo demonstração](docs/media/wifi-spectrum-ios-demo.gif)

[Abrir ou baixar a demonstração em MP4](docs/media/wifi-spectrum-ios-demo.mp4)

| Rede atual | Teste de velocidade | Calculadora de canais |
| --- | --- | --- |
| ![Rede atual](docs/media/connection.png) | ![Teste de velocidade](docs/media/speedtest.png) | ![Calculadora de canais](docs/media/channel-calculator.png) |

## Mudanças recentes

Primeira versão com detalhes da rede atual, teste de velocidade, descoberta na LAN, cinco ferramentas, modo demonstração, guia da App Store e CI que executa 48 testes no Linux, no macOS e no simulador do iPhone. Veja o [registro de mudanças](CHANGELOG.md).

<a id="controls"></a>
## Controles

| Controle | Ação |
| --- | --- |
| Puxar para baixo / ↻ (連線) | Reler o Wi-Fi e a interface |
| 開始測速 / 停止 (測速) | Iniciar ou cancelar o teste de velocidade |
| 開始掃描 / 停止掃描 (區網) | Iniciar ou parar a descoberta na LAN |
| Seletores de banda / canal / largura | Recalcular; larguras inválidas não aparecem |
| Ferramentas → campo de host | Digite um nome ou IP; erros de formato são explicados antes de enviar |
| 關於 → 示範模式 | Alternar entre dados reais e o ambiente sintético |

<a id="faq"></a>
## Perguntas frequentes

**Por que não mostra redes próximas ou canais?** A Apple não oferece API pública para isso e a revisão rejeita APIs privadas. Para análise de espectro, use a versão Android.

**Por que pede a localização?** O iOS só revela o SSID e o BSSID atuais a apps com permissão de localização. O app nunca lê coordenadas.

**Por que o simulador diz que não estou conectado?** O simulador não tem informações de Wi-Fi. Ative o modo demonstração na aba 關於.

**Por que a varredura da LAN não encontra nada?** Permita “Rede local” em Ajustes → Privacidade e Segurança e verifique se o roteador não isola os clientes sem fio.

**Para onde o teste de velocidade se conecta?** Para os endpoints públicos da Cloudflare em speed.cloudflare.com. Um teste usa cerca de 100 MB.

<a id="docs"></a>
<a id="documentation"></a>
## Documentação

| Tópico | Documento |
| --- | --- |
| Uso diário | [繁中使用指南](docs/USER_GUIDE.zh-TW.md) · [English User Guide](docs/USER_GUIDE.md) |
| Funcionamento interno | [Arquitetura](docs/ARCHITECTURE.md) |
| Publicação | [Guia da App Store (繁中)](docs/PUBLISHING.zh-TW.md) · [Resumo em inglês](docs/PUBLISHING.md) · [Política de privacidade](docs/PRIVACY.md) |
| Versões e segurança | [Registro de mudanças](CHANGELOG.md) · [Segurança](SECURITY.md) · [Como contribuir](CONTRIBUTING.md) |

O app fica em `App/`, a lógica compartilhada no pacote Swift `Core/`, os testes em `Core/Tests`, `AppTests` e `AppUITests`, e as ferramentas em `scripts/`. O projeto é gerado a partir de `project.yml`. Confira SSID, LAN e velocidade em um iPhone real; o simulador não consegue.

## Segurança

Nunca faça commit de certificados, perfis de provisionamento, chaves da API do App Store Connect, arquivos `.ipa` ou varreduras de redes que não são suas. Antes do push, rode o mesmo scanner do GitHub Actions:

```bash
python scripts/security_scan.py .
```

## Licença

[MIT](LICENSE).

### 2026-10-20 · 1.0.0

首次發布：目前連線資訊、測速、區域網路探索、TCP 延遲、DNS、連接埠掃描、頻道與子網路計算機；48 個測試在 Linux、macOS 與 iPhone 模擬器上執行。

First release: current-network details, speed test, LAN discovery, TCP latency, DNS, port scan, channel and subnet calculators; 48 tests run on Linux, macOS and the iPhone simulator.

[Guia de uso público (chinês tradicional, texto simples)](docs/使用說明.txt)
