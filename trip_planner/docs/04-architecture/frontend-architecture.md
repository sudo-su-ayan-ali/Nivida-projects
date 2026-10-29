# Frontend Architecture Specification (Flutter)

- **Status:** Approved
- **Owner:** Lead Flutter Architect
- **Last Updated:** 2026-10-29
- **Related Documents:** [`architecture-overview.md`](architecture-overview.md), [`../05-frontend-flutter/project-structure.md`](../05-frontend-flutter/project-structure.md)

---

## 1. Feature-First Directory Structure

The Flutter client uses a **Feature-Driven Package Layout** to isolate modules and prevent tight coupling:

```text
lib/
├── app/
│    ├── app.dart               # Root MaterialApp with theme & router bindings
│    ├── router/router.dart     # GoRouter configuration & auth redirect guards
│    └── theme/                 # YatraDS ThemeData and ThemeExtensions
├── core/
│    ├── constants/             # App-wide asset paths, API constants
│    ├── errors/                # Failure & Exception classes
│    ├── networking/            # SupabaseClient singleton, HTTP interceptors
│    ├── storage/               # Local Hive/SharedPreferences offline cache
│    └── widgets/               # Universal design-system UI components
├── features/
│    ├── auth/                  # Login, Register, Role state
│    ├── discovery/             # Circuits, Destinations, Attractions, Aarti schedules
│    ├── trip_planner/          # AI Wizard, Itinerary view, Stop editing
│    ├── pilgrimage/            # Temple etiquette, official passes, accessibility
│    ├── services/              # Merchant directory, Taxis, Guides, Enquiries
│    └── profile/               # Saved plans, Offline downloads, Settings
└── main.dart                   # Application entrypoint & Riverpod Scope initialization
```

---

## 2. Layer Separation within Each Feature

Every feature directory strictly separates responsibilities into 3 distinct layers:

```text
features/<feature_name>/
├── data/
│    ├── models/                # Freezed / JSON serializable DTOs
│    ├── datasources/           # Remote Supabase datasource & Local cache
│    └── repositories/          # Concrete repository implementations
├── domain/
│    ├── entities/              # Pure Dart business objects
│    └── repositories/          # Abstract repository interfaces
└── presentation/
     ├── controllers/           # Riverpod AsyncNotifier providers
     ├── screens/               # Screen widgets (Stateless / ConsumerWidget)
     └── widgets/               # Feature-specific sub-widgets
```

---

## 3. State Management & Navigation Pattern

* **State**: **Riverpod (v2.x)** with code generation (`@riverpod`). Uses `AsyncNotifier` for automatic loading/error/data transitions.
* **Navigation**: **GoRouter (v14.x)** declarative routing with typed routes and reactive `refreshListenable` watching auth state.
