# Flutter Widget Testing & Golden UI Verification

- **Status:** Approved
- **Owner:** Mobile QA Lead / UI Architect
- **Last Updated:** 2026-10-29
- **Related Documents:** [`../03-ui-ux/loading-empty-error-states.md`](../03-ui-ux/loading-empty-error-states.md), [`../05-frontend-flutter/component-catalog.md`](../05-frontend-flutter/component-catalog.md)

---

## 1. Widget State Testing Standards

Every custom screen and stateful card must be tested across all 5 universal states:

```dart
testWidgets('YatraDestinationCard renders verified seal and timing pill correctly', (tester) async {
  final destination = DestinationFixture.sampleAmbaji;

  await tester.pumpWidget(
    MaterialApp(
      theme: YatraTheme.light,
      home: Scaffold(
        body: YatraDestinationCard(destination: destination),
      ),
    ),
  );

  // Assertions
  expect(find.text('Shri Ambaji Mata Temple'), findsOneWidget);
  expect(find.byType(YatraVerifiedBadge), findsOneWidget);
  expect(find.byType(YatraTimingPill), findsOneWidget);
});
```

---

## 2. Golden Visual Regression Tests

* Pixel-perfect golden file comparisons execute across light and dark themes using `golden_toolkit`.
* Changes exceeding 0.5% pixel delta fail the automated build to prevent visual regressions in padding, typography, or color contrast.
