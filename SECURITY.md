# Security Policy

## Never commit secrets

This repository must never contain signing material or private data, including:

- distribution or development certificates (`.p12`, `.cer`) and their passwords;
- provisioning profiles (`.mobileprovision`);
- App Store Connect API keys (`AuthKey_*.p8`), key IDs or issuer IDs paired with keys;
- exported `.ipa` builds or `ExportOptions.plist` files containing team details;
- GitHub tokens or other credentials;
- scans of networks you do not own.

Xcode keeps certificates in the macOS keychain; there is no reason to copy them into the project.

## Before every push

Run:

```bash
python scripts/security_scan.py .
```

The GitHub Actions workflow runs the same scanner on push and pull request.

## If a secret is exposed

1. Revoke it immediately: certificates and API keys in Certificates, Identifiers & Profiles or App Store Connect → Users and Access → Keys.
2. Remove it from the current tree.
3. Rewrite Git history if it was committed; deleting the latest file is not enough.
4. Re-run the scanner before pushing again.

## App privacy

The app collects no data. The only network traffic it creates on its own is the speed test against speed.cloudflare.com and the LAN probes you start. See [docs/PRIVACY.md](docs/PRIVACY.md).

## Reporting

Please report security issues privately to the repository owner rather than publishing active credentials in an issue.

繁體中文版本：[docs/SECURITY.zh-TW.md](docs/SECURITY.zh-TW.md)
