# State Management Architecture (Riverpod 2.x)

- **Status:** Approved
- **Owner:** Lead Flutter Architect
- **Last Updated:** 2026-10-29
- **Related Documents:** [`project-structure.md`](project-structure.md), [`../04-architecture/frontend-architecture.md`](../04-architecture/frontend-architecture.md)

---

## 1. Core State Principles

* **Framework**: **Flutter Riverpod 2.x** with code generation (`riverpod_generator`).
* **Declarative Async Handling**: Use `AsyncNotifier` / `AsyncValue` to model the full state lifecycle (`loading`, `data`, `error`) without manual boolean flags (`isLoading = true`).
* **Scoping & Lifecycle**:
  * Global providers for singleton infrastructure (Supabase client, AppConfig, Auth session).
  * Auto-dispose providers (`@riverpod` default) for screen-specific queries and forms to prevent memory leaks when navigating away.

---

## 2. Standard Notifier Pattern Example

```dart
@riverpod
class ItineraryController extends _$ItineraryController {
  @override
  FutureOr<Itinerary?> build(String itineraryId) async {
    final repository = ref.watch(itineraryRepositoryProvider);
    return repository.getItineraryById(itineraryId);
  }

  Future<void> customizeStop({required int dayIndex, required int stopIndex, required String newAttractionId}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(itineraryRepositoryProvider);
      return repository.updateStop(dayIndex: dayIndex, stopIndex: stopIndex, newAttractionId: newAttractionId);
    });
  }
}
```

---

## 3. UI Consumer Pattern

```dart
class ItineraryScreen extends ConsumerWidget {
  final String itineraryId;
  const ItineraryScreen({super.key, required this.itineraryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itineraryState = ref.watch(itineraryControllerProvider(itineraryId));

    return itineraryState.when(
      loading: () => const ItineraryShimmerSkeleton(),
      error: (err, stack) => YatraErrorView(error: err, onRetry: () => ref.refresh(itineraryControllerProvider(itineraryId))),
      data: (itinerary) => ItineraryContent(itinerary: itinerary!),
    );
  }
}
```
