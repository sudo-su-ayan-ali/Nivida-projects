# Accessibility Implementation & Semantic Tree

- **Status:** Approved
- **Owner:** Accessibility Specialist / Flutter Engineer
- **Last Updated:** 2026-10-29
- **Related Documents:** [`../02-ux-research/accessibility-requirements.md`](../02-ux-research/accessibility-requirements.md), [`../03-ui-ux/accessibility-specifications.md`](../03-ui-ux/accessibility-specifications.md)

---

## 1. Semantic Tagging Policy

Every custom card, button, and image in Flutter must provide semantic information for Android TalkBack and iOS VoiceOver:

```dart
class YatraDestinationCard extends StatelessWidget {
  final Destination destination;
  const YatraDestinationCard({super.key, required this.destination});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${destination.name}, ${destination.category}. ${destination.accessibilitySummary}',
      hint: 'Double tap to open destination details, darshan schedules, and visitor rules',
      button: true,
      child: Card(
        child: Column(
          children: [
            Semantics(
              excludeFromSemantics: true, // Photo is decorative; card label handles speech
              child: Image.network(destination.heroImageUrl),
            ),
            Text(destination.name),
          ],
        ),
      ),
    );
  }
}
```

---

## 2. Text Scaling Safety

* Never set hardcoded container heights for text-bearing widgets.
* Use `TextScaler` aware sizing and wrap labels inside `Expanded` or `Flexible` with `TextOverflow.ellipsis` when needed.
* Touch targets are wrapped in `MinimumInteractiveModifier` guaranteeing $\ge 48\times 48\text{dp}$.
