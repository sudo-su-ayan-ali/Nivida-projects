# Theming Implementation & ThemeExtensions

- **Status:** Approved
- **Owner:** Design System Architect / Flutter UI Lead
- **Last Updated:** 2026-10-29
- **Related Documents:** [`../03-ui-ux/design-system.md`](../03-ui-ux/design-system.md), [`../03-ui-ux/color-system.md`](../03-ui-ux/color-system.md)

---

## 1. Custom Theme Extension Architecture

To cleanly support domain-specific colors (such as Aarti glow, Satvik green, and Temple Stone neutrals) without polluting standard Material 3 properties, custom `ThemeExtension` classes are implemented:

```dart
@immutable
class YatraCustomColors extends ThemeExtension<YatraCustomColors> {
  final Color saffronPrimary;
  final Color marigoldSecondary;
  final Color satvikGreen;
  final Color aartiAmber;
  final Color templeStoneSurface;

  const YatraCustomColors({
    required this.saffronPrimary,
    required this.marigoldSecondary,
    required this.satvikGreen,
    required this.aartiAmber,
    required this.templeStoneSurface,
  });

  @override
  YatraCustomColors copyWith({Color? saffronPrimary, Color? marigoldSecondary, Color? satvikGreen, Color? aartiAmber, Color? templeStoneSurface}) {
    return YatraCustomColors(
      saffronPrimary: saffronPrimary ?? this.saffronPrimary,
      marigoldSecondary: marigoldSecondary ?? this.marigoldSecondary,
      satvikGreen: satvikGreen ?? this.satvikGreen,
      aartiAmber: aartiAmber ?? this.aartiAmber,
      templeStoneSurface: templeStoneSurface ?? this.templeStoneSurface,
    );
  }

  @override
  YatraCustomColors lerp(ThemeExtension<YatraCustomColors>? other, double t) {
    if (other is! YatraCustomColors) return this;
    return YatraCustomColors(
      saffronPrimary: Color.lerp(saffronPrimary, other.saffronPrimary, t)!,
      marigoldSecondary: Color.lerp(marigoldSecondary, other.marigoldSecondary, t)!,
      satvikGreen: Color.lerp(satvikGreen, other.satvikGreen, t)!,
      aartiAmber: Color.lerp(aartiAmber, other.aartiAmber, t)!,
      templeStoneSurface: Color.lerp(templeStoneSurface, other.templeStoneSurface, t)!,
    );
  }
}
```

---

## 2. Global Extension Accessor

```dart
extension YatraThemeGetter on BuildContext {
  YatraCustomColors get yatraColors => Theme.of(this).extension<YatraCustomColors>()!;
  TextTheme get textTheme => Theme.of(this).textTheme;
}
```
