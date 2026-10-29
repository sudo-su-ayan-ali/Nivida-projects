# Error Handling & Resilience Architecture

- **Status:** Approved
- **Owner:** Quality Engineering Lead / Lead Flutter Architect
- **Last Updated:** 2026-10-29
- **Related Documents:** [`state-management.md`](state-management.md), [`../04-architecture/reliability-and-failure-modes.md`](../04-architecture/reliability-and-failure-modes.md)

---

## 1. Domain Failure Hierarchy

All lower-level network, database, and JSON decoding errors are mapped into domain-level `Failure` objects before reaching UI state notifiers:

```dart
sealed class Failure {
  final String message;
  final String? code;
  const Failure(this.message, [this.code]);
}

class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'Unable to connect. Showing offline data.']) : super(message, 'NET_001');
}

class ServerFailure extends Failure {
  const ServerFailure([String message = 'Service temporarily unavailable. Please try again.']) : super(message, 'SRV_001');
}

class AuthFailure extends Failure {
  const AuthFailure(super.message, [super.code]);
}
```

---

## 2. Standardized Error Presentation

* Errors are presented via the design system's `YatraErrorView` widget with:
  1. A clear human-readable message.
  2. A friendly illustrative icon.
  3. A prominent "Try Again" retry callback button.
* Never show raw stack traces or database exception text to the end user.
