# Coding Standards & Static Analysis Policy

- **Status:** Approved
- **Owner:** Quality Engineering Lead / Lead Flutter Architect
- **Last Updated:** 2026-10-29
- **Related Documents:** [`../00-governance/definition-of-done.md`](../00-governance/definition-of-done.md), [`project-structure.md`](project-structure.md)

---

## 1. Static Analysis & Lint Rules

The project enforces `flutter_lints` and strict compiler options in `analysis_options.yaml`:

```yaml
include: package:flutter_lints/flutter.yaml

analyzer:
  language:
    strict-casts: true
    strict-inference: true
    strict-raw-types: true
  errors:
    missing_required_param: error
    missing_return: error
    todo: ignore

linter:
  rules:
    - prefer_const_constructors
    - prefer_const_declarations
    - avoid_print
    - unawaited_futures
    - prefer_final_locals
    - use_super_parameters
```

---

## 2. Key Engineering Rules

1. **Zero Raw Prints**: Never use `print()`. Use an application logger (`AppLogger.debug()`, `AppLogger.error()`) that strips logs in production release builds.
2. **Immutable State**: State classes must be immutable, using `@freezed` or standard copy-with patterns.
3. **Async Safety**: Every asynchronous call in widgets must check `if (!mounted) return;` before updating UI state.
4. **Clean Null-Safety**: Avoid using force unwraps (`!`) unless guaranteed by prior null check or assert.
