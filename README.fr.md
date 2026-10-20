<p align="center">
  <a href="README.md">English</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.zh-TW.md">繁體中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a><br>
  <a href="README.de.md">Deutsch</a> · <a href="README.es.md">Español</a> · <strong>Français</strong> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.vi.md">Tiếng Việt</a> · <a href="README.id.md">Bahasa Indonesia</a> · <a href="README.it.md">Italiano</a>
</p>

<p align="center"><img src="assets/wifi-spectrum.png" width="112" alt="Icône de Wi-Fi Spectrum"></p>
<h1 align="center">Boîte à outils réseau Wi-Fi pour iPhone</h1>
<p align="center">Wi-Fi Spectrum (Wi-Fi 頻譜分析儀) · réseau actuel · test de débit · LAN · calculateur de canaux</p>
<p align="center">
  <a href="https://github.com/tonykfr1234/ios_wifi-spectrum/actions/workflows/security.yml"><img src="https://github.com/tonykfr1234/ios_wifi-spectrum/actions/workflows/security.yml/badge.svg" alt="CI"></a>
  <img src="https://img.shields.io/badge/platform-iOS%2016%2B-000000" alt="iOS 16+">
  <img src="https://img.shields.io/badge/Swift-6.1-F05138" alt="Swift 6.1">
  <img src="https://img.shields.io/badge/SwiftUI-iPhone-0A84FF" alt="SwiftUI">
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-green" alt="Licence MIT"></a>
</p>
<p align="center">
  <a href="#quick-start">Démarrage rapide</a> · <a href="#workflow">Fonctionnement</a> · <a href="#features">Fonctionnalités</a> · <a href="#demo">Démonstration</a> · <a href="#faq">FAQ</a> · <a href="#documentation">Documentation</a>
</p>

```bash
brew install xcodegen && xcodegen generate && open WifiSpectrum.xcodeproj
```

---

Version 1.0 : tout ce qu'iOS laisse voir à une app sur le Wi-Fi, plus un test de débit, la découverte LAN et cinq outils réseau. Les règles de canaux sont celles de l'app Android.

Wi-Fi Spectrum pour iOS affiche le SSID, le BSSID et son fabricant, le type de sécurité, les adresses et le sous-réseau du réseau actuel ; mesure le débit descendant et montant, la latence et la gigue ; trouve les appareils du réseau local ; et propose la latence TCP, le DNS, le scan de ports, un calculateur de canaux 2,4/5/6 GHz de 20 à 320 MHz et un calculateur de sous-réseaux.

Apple ne donne aux apps aucun accès aux réseaux proches, canaux, largeurs de canal, intensité du signal ni Wi-Fi 7 MLO ; cette app ne prétend donc pas les fournir. Pour une analyse de spectre complète, utilisez la version Android, [Android_wifi-spectrum](https://github.com/tonykfr1234/android_wifi-spectrum).

Les 12 langues du README traduisent la documentation. L'interface de l'app est actuellement en chinois traditionnel.

<a id="quick-start"></a>
## Démarrage rapide

1. Sur un Mac avec Xcode 16+, clonez ce dépôt et lancez la commande ci-dessus (installe XcodeGen, génère le projet, ouvre Xcode).
2. Sélectionnez la cible `WifiSpectrum`, choisissez votre équipe dans Signing & Capabilities et vérifiez qu'Access Wi-Fi Information figure dans la liste.
3. Lancez l'app sur un iPhone sous iOS 16+. Autorisez la localisation (uniquement pour le nom du Wi-Fi) puis, au premier scan LAN, « Réseau local ».
4. Le simulateur n'a pas d'informations Wi-Fi ; activez le mode démonstration dans l'onglet 關於 pour voir tous les écrans avec des données synthétiques.
5. Chaque push lance les tests dans GitHub Actions ; journaux et captures du simulateur arrivent sur la branche `ci-artifacts`.

**Publier sur l'App Store ?** Suivez [docs/PUBLISHING.zh-TW.md](docs/PUBLISHING.zh-TW.md) ([résumé en anglais](docs/PUBLISHING.md)) : définissez le bundle ID et l'équipe, archivez, envoyez, testez avec TestFlight et soumettez avec les notes d'examen fournies.

<a id="workflow"></a>
## Fonctionnement

```text
Ouverture de l'onglet 連線
  → localisation autorisée ? NEHotspotNetwork.fetchCurrent → SSID, BSSID, sécurité
  → BSSID → fabricant IEEE hors ligne (MAC aléatoires signalées)
  → getifaddrs + NWPathMonitor → IPv4, masque, sous-réseau, IPv6, état du chemin
LAN : Bonjour (10 types de service) + balayage TCP de 6 ports sur le /24
Débit : 10 allers-retours HTTPS, 3 téléchargements, 3 envois → médianes
```

Rien ne tourne en arrière-plan et rien n'est conservé à la fermeture. Les réseaux de plus de 1 024 adresses ne sont pas balayés. La latence est le temps de connexion TCP, car iOS n'autorise pas l'ICMP pour les apps ordinaires.

<a id="features"></a>
## Fonctionnalités

| Fonction | Comportement |
| --- | --- |
| Wi-Fi actuel | SSID, BSSID, fabricant du registre IEEE, type de sécurité (iOS 15+) |
| Interface | IPv4, masque, sous-réseau et nombre d'hôtes, IPv6, mode données réduites et réseau facturé |
| Test de débit | Points d'accès Cloudflare ; médiane de 3 téléchargements et 3 envois ; latence et gigue ; annulable ; historique de 20 |
| Découverte LAN | Noms Bonjour et hôtes répondant sur 80/443/22/445/554/62078 ; progression et arrêt |
| Calculateur de canaux | 2,4/5/6 GHz, 20–320 MHz : plage occupée, canaux central et couverts, PSC, DFS, sous-bande UNII |
| Outils réseau | Latence TCP avec perte et gigue, DNS A/AAAA/CNAME, scan des 19 ports courants ou d'une plage |
| Calculateur de sous-réseaux | CIDR ou masque → réseau, diffusion, plage et nombre d'hôtes |
| Confidentialité | Aucune collecte, publicité ni statistique ; manifeste de confidentialité inclus |

iOS ne fournit ni réseaux proches, ni canaux, ni largeurs, ni RSSI, ni MLO ; le calculateur applique les mêmes règles que l'app Android pour les résultats d'analyse. Les résultats LAN n'ont pas de fabricant car iOS masque les adresses MAC des autres appareils.

<a id="demo"></a>
## Démonstration

Ces écrans ont été capturés par les **tests d'interface dans le simulateur iPhone en mode démonstration** : la véritable interface de l'app avec le même appartement synthétique à Taipei que la démo Android. Ce n'est pas un vrai réseau et cela ne montre les performances d'aucun appareil.

![Présentation de l'app iOS en mode démonstration](docs/media/wifi-spectrum-ios-demo.gif)

[Ouvrir ou télécharger la démonstration MP4](docs/media/wifi-spectrum-ios-demo.mp4)

| Réseau actuel | Test de débit | Calculateur de canaux |
| --- | --- | --- |
| ![Réseau actuel](docs/media/connection.png) | ![Test de débit](docs/media/speedtest.png) | ![Calculateur de canaux](docs/media/channel-calculator.png) |

## Dernières modifications

Première version avec les détails du réseau actuel, le test de débit, la découverte LAN, cinq outils, le mode démonstration, un guide App Store et une CI qui exécute 48 tests sous Linux, macOS et dans le simulateur iPhone. Voir le [journal des modifications](CHANGELOG.md).

<a id="controls"></a>
## Commandes

| Commande | Action |
| --- | --- |
| Tirer vers le bas / ↻ (連線) | Relire le Wi-Fi et l'interface |
| 開始測速 / 停止 (測速) | Lancer ou annuler le test de débit |
| 開始掃描 / 停止掃描 (區網) | Lancer ou arrêter la découverte LAN |
| Sélecteurs bande / canal / largeur | Recalculer ; les largeurs non valides ne sont pas proposées |
| Outils → champ hôte | Saisir un nom ou une IP ; les erreurs de format sont expliquées avant tout envoi |
| 關於 → 示範模式 | Basculer entre données réelles et environnement synthétique |

<a id="faq"></a>
## FAQ

**Pourquoi ne montre-t-elle pas les réseaux ou canaux proches ?** Apple ne propose pas d'API publique pour cela et l'examen refuse les API privées. Pour l'analyse de spectre, utilisez la version Android.

**Pourquoi demande-t-elle la localisation ?** iOS ne révèle le SSID et le BSSID actuels qu'aux apps autorisées à la localisation. L'app ne lit jamais de coordonnées.

**Pourquoi le simulateur dit-il que je ne suis pas connecté ?** Le simulateur n'a pas d'informations Wi-Fi. Activez le mode démonstration dans l'onglet 關於.

**Pourquoi le scan LAN ne trouve-t-il rien ?** Autorisez « Réseau local » dans Réglages → Confidentialité et sécurité et vérifiez que le routeur n'isole pas les clients sans fil.

**Où se connecte le test de débit ?** Aux points d'accès publics de Cloudflare sur speed.cloudflare.com. Un test utilise environ 100 Mo.

<a id="docs"></a>
<a id="documentation"></a>
## Documentation

| Sujet | Document |
| --- | --- |
| Utilisation quotidienne | [繁中使用指南](docs/USER_GUIDE.zh-TW.md) · [English User Guide](docs/USER_GUIDE.md) |
| Fonctionnement interne | [Architecture](docs/ARCHITECTURE.md) |
| Publication | [Guide App Store (繁中)](docs/PUBLISHING.zh-TW.md) · [Résumé en anglais](docs/PUBLISHING.md) · [Politique de confidentialité](docs/PRIVACY.md) |
| Versions et sécurité | [Journal des modifications](CHANGELOG.md) · [Sécurité](SECURITY.md) · [Contribuer](CONTRIBUTING.md) |

L'app se trouve dans `App/`, la logique partagée dans le paquet Swift `Core/`, les tests dans `Core/Tests`, `AppTests` et `AppUITests`, les outils dans `scripts/`. Le projet est généré à partir de `project.yml`. Vérifiez SSID, LAN et débit sur un vrai iPhone ; le simulateur ne le permet pas.

## Sécurité

Ne commitez jamais de certificats, profils de provisionnement, clés d'API App Store Connect, fichiers `.ipa` ou analyses de réseaux qui ne vous appartiennent pas. Avant de pousser, lancez le même scanner que GitHub Actions :

```bash
python scripts/security_scan.py .
```

## Licence

[MIT](LICENSE).

### 2026-10-20 · 1.0.0

首次發布：目前連線資訊、測速、區域網路探索、TCP 延遲、DNS、連接埠掃描、頻道與子網路計算機；48 個測試在 Linux、macOS 與 iPhone 模擬器上執行。

First release: current-network details, speed test, LAN discovery, TCP latency, DNS, port scan, channel and subnet calculators; 48 tests run on Linux, macOS and the iPhone simulator.

[Guide d'utilisation public (chinois traditionnel, texte brut)](docs/使用說明.txt)
