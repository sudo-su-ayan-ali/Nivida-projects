# Development Setup & Environment Guide (Flutter)

- **Status:** Approved
- **Owner:** Lead Flutter Architect / Mobile DevOps Lead
- **Last Updated:** 2026-10-29
- **Related Documents:** [`../04-architecture/frontend-architecture.md`](../04-architecture/frontend-architecture.md), [`coding-standards.md`](coding-standards.md)

---

## 1. Toolchain & Prerequisites

* **Flutter SDK**: `3.22.x` or higher (Channel: `stable`).
* **Dart SDK**: `3.4.x` or higher.
* **JDK**: OpenJDK 17 (Required for modern Android Gradle plugin).
* **Android SDK**: Android API Level 34 (Upside Down Cake), Min SDK: 24 (Android 7.0 Nougat).
* **iOS / macOS**: Xcode 15+ (iOS Deployment Target: 14.0+), CocoaPods 1.14+.
* **Supabase CLI**: `1.165.x` or higher (for local backend testing).

---

## 2. Initial Setup Instructions

```bash
# 1. Verify environment health
flutter doctor -v

# 2. Get dependencies
flutter pub get

# 3. Generate Freezed / Riverpod code
dart run build_runner build --delete-conflicting-outputs

# 4. Run static analysis
flutter analyze

# 5. Run automated test suite
flutter test
```

---

## 3. Environment Flavors & Configuration

The application supports 3 distinct execution flavors: `dev`, `staging`, and `prod`.  
Configuration values are loaded via compile-time variables (`--dart-define`):

```bash
flutter run --flavor dev --dart-define=ENVIRONMENT=dev --dart-define=SUPABASE_URL=http://127.0.0.1:54321 --dart-define=SUPABASE_ANON_KEY=eyJhbG...
```
