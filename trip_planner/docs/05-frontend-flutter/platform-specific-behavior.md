# Platform-Specific Behavior & Native Integration

- **Status:** Approved
- **Owner:** Mobile DevOps / Native Platform Specialist
- **Last Updated:** 2026-10-29
- **Related Documents:** [`development-setup.md`](development-setup.md), [`navigation.md`](navigation.md)

---

## 1. Android Specifics (API 24+)

* **Splash Screen**: Uses Android 12+ `SplashScreen` API with adaptive icon in `styles.xml`.
* **ProGuard & R8**: Rules defined in `proguard-rules.pro` protecting Supabase and Freezed models from code obfuscation crashes.
* **Permissions**:
  * `ACCESS_FINE_LOCATION` / `ACCESS_COARSE_LOCATION` (Optional, runtime prompt only on explicit user request for nearby satvik dining/taxis).
  * `INTERNET` and `ACCESS_NETWORK_STATE` for network state monitoring.

---

## 2. iOS Specifics (iOS 14+)

* **Info.plist Privacy Declarations**:
  * `NSLocationWhenInUseUsageDescription`: Clear rationale explaining nearby pilgrimage guidance.
* **Launch Screen**: Configured in `LaunchScreen.storyboard` matching light/dark system settings.

---

## 3. Flutter Web Specifics

* **Renderer**: CanvasKit / Impeller for high-performance map rendering and crisp Devanagari typography.
* **URL Strategy**: Clean path URLs enabled via `usePathUrlStrategy()` (removing `#` hash symbols from routes).
