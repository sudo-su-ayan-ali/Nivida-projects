# Localization Architecture & Vernacular Support

- **Status:** Approved
- **Owner:** Localization Lead / Frontend Engineer
- **Last Updated:** 2026-10-29
- **Related Documents:** [`../02-ux-research/localization-research.md`](../02-ux-research/localization-research.md), [`theming.md`](theming.md)

---

## 1. Localization Framework (`flutter_localizations`)

The platform utilizes standard Flutter `.arb` (Application Resource Bundle) localization files with type-safe generated delegates:

```text
lib/app/localization/l10n/
├── app_en.arb      # English (Source of Truth)
├── app_hi.arb      # Hindi
└── app_gu.arb      # Gujarati
```

---

## 2. Sample ARB Specification (`app_en.arb`)

```json
{
  "@@locale": "en",
  "appTitle": "Bharat Yatra",
  "aartiTimingsHeader": "Verified Aarti & Darshan Schedule",
  "bookOfficialPass": "Book via Official Trust Portal",
  "elderAccessibility": "Elder & Senior-Citizen Guidance",
  "ropewayAvailable": "Ropeway (Udankhatola) Operational",
  "stepCountAlert": "{count} steps to summit. Doli/Palanquin available.",
  "@stepCountAlert": {
    "placeholders": {
      "count": { "type": "int" }
    }
  }
}
```

---

## 3. Dynamic Font Switching

The application dynamically adjusts font family based on the active `Locale`:
```dart
TextStyle getLocalizedTextStyle(BuildContext context, TextStyle baseStyle) {
  final locale = Localizations.localeOf(context);
  switch (locale.languageCode) {
    case 'hi':
      return GoogleFonts.notoSansDevanagari(textStyle: baseStyle);
    case 'gu':
      return GoogleFonts.notoSansGujarati(textStyle: baseStyle);
    default:
      return GoogleFonts.inter(textStyle: baseStyle);
  }
}
```
