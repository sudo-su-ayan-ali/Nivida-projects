# Navigation & Deep Linking Architecture (GoRouter 14.x)

- **Status:** Approved
- **Owner:** Mobile Navigation Specialist / Frontend Architect
- **Last Updated:** 2026-10-29
- **Related Documents:** [`project-structure.md`](project-structure.md), [`../02-ux-research/sitemap.md`](../02-ux-research/sitemap.md)

---

## 1. Declarative Routing Engine: GoRouter

The application utilizes **GoRouter (v14.x)** for declarative routing, URL deep linking across mobile and web, and shell-based bottom navigation:

```dart
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: '/discover',
    refreshListenable: GoRouterRefreshStream(ref.watch(authStreamProvider)),
    redirect: (context, state) {
      final isLoggedIn = authState.asData?.value != null;
      final isAuthRoute = state.matchedLocation.startsWith('/auth');

      if (!isLoggedIn && !isAuthRoute && state.matchedLocation.startsWith('/admin')) {
        return '/auth/login';
      }
      return null;
    },
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => AppShellScaffold(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [GoRoute(path: '/discover', builder: (context, state) => const DiscoverScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/planner', builder: (context, state) => const PlannerScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/services', builder: (context, state) => const ServicesScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen())]),
        ],
      ),
      GoRoute(path: '/attraction/:id', builder: (context, state) => AttractionDetailScreen(id: state.pathParameters['id']!)),
    ],
  );
});
```

---

## 2. Deep Linking Configuration

* **Android Scheme**: `bharatyatra://` and App Links for `https://bharatyatra.app/circuit/*` configured in `AndroidManifest.xml`.
* **iOS Universal Links**: Configured in `Runner.entitlements` for domain verification.
