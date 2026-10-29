# Build, Sign & Release Process (Android & iOS)

- **Status:** Approved
- **Owner:** Mobile Release Engineer / DevOps Lead
- **Last Updated:** 2026-10-29
- **Related Documents:** [`ci-cd.md`](ci-cd.md), [`../05-frontend-flutter/development-setup.md`](../05-frontend-flutter/development-setup.md)

---

## 1. Automated Build Commands

```bash
# Android App Bundle (Production Flavor)
flutter build appbundle \
  --flavor prod \
  --target lib/main.dart \
  --dart-define=ENVIRONMENT=prod \
  --dart-define=SUPABASE_URL=https://prod.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJhbG...

# iOS Release Archive
flutter build ipa \
  --flavor prod \
  --target lib/main.dart \
  --dart-define=ENVIRONMENT=prod \
  --export-options-plist=ios/ExportOptions.plist
```

---

## 2. Cryptographic Code Signing & Keystore Security

1. **Android Keystore**:
   * Stored in GitHub Secrets as a Base64-encoded string (`ANDROID_KEYSTORE_BASE64`).
   * Decoded dynamically into the ephemeral build runner; never committed to git.
2. **iOS Certificates & Provisioning Profiles**:
   * Managed via Fastlane Match with encrypted git repository storage and App Store Connect API keys.
