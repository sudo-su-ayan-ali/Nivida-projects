# Responsive Layouts Implementation

- **Status:** Approved
- **Owner:** UI Architect / Responsive Layout Lead
- **Last Updated:** 2026-10-29
- **Related Documents:** [`../03-ui-ux/responsive-design.md`](../03-ui-ux/responsive-design.md), [`../03-ui-ux/spacing-and-layout.md`](../03-ui-ux/spacing-and-layout.md)

---

## 1. Responsive Builder Utility

The application uses an adaptive layout builder widget (`ResponsiveLayout`) to cleanly render distinct UI trees based on screen width:

```dart
enum FormFactor { mobile, tablet, desktop }

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  static FormFactor getFormFactor(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 840) return FormFactor.desktop;
    if (width >= 600) return FormFactor.tablet;
    return FormFactor.mobile;
  }

  @override
  Widget build(BuildContext context) {
    final formFactor = getFormFactor(context);
    switch (formFactor) {
      case FormFactor.desktop:
        return desktop ?? tablet ?? mobile;
      case FormFactor.tablet:
        return tablet ?? mobile;
      case FormFactor.mobile:
        return mobile;
    }
  }
}
```

---

## 2. Max Width Constraint Wrapper

On expanded tablet and desktop screens, content is automatically centered inside a constrained box to prevent awkward stretching:

```dart
class ContentConstraintWrapper extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const ContentConstraintWrapper({
    super.key,
    required this.child,
    this.maxWidth = 1024,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
```
