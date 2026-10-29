# Unit Testing Architecture & Coverage Standards

- **Status:** Approved
- **Owner:** Quality Engineering Lead / Lead Flutter Architect
- **Last Updated:** 2026-10-29
- **Related Documents:** [`test-plan.md`](test-plan.md), [`../05-frontend-flutter/error-handling.md`](../05-frontend-flutter/error-handling.md)

---

## 1. Unit Test Scope & Coverage Target

* **Target Coverage**: Minimum **80% line and branch coverage** across all pure domain logic:
  * Budget calculation engine (`BudgetCalculator`).
  * Time and slot conflict detection algorithms.
  * Domain failure mappers.
  * DTO JSON serialization and deserialization (`fromJson` / `toJson`).

---

## 2. Sample Unit Test (`budget_calculator_test.dart`)

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:bharat_yatra/features/trip_planner/domain/budget_calculator.dart';

void main() {
  group('BudgetCalculator Tests', () {
    test('computes correct budget tier estimates for 2-day family trip', () {
      final calculator = BudgetCalculator();
      final result = calculator.calculateEstimate(
        days: 2,
        passengerCount: 4,
        tier: BudgetTier.midRange,
      );

      expect(result.currency, equals('INR'));
      expect(result.stayEstimate, inInclusiveRange(7000, 14000));
      expect(result.transitEstimate, inInclusiveRange(3000, 4400));
      expect(result.totalEstimate, greaterThan(15000));
    });

    test('enforces zero negative costs on zero-day invalid inputs', () {
      final calculator = BudgetCalculator();
      expect(
        () => calculator.calculateEstimate(days: 0, passengerCount: 1, tier: BudgetTier.budget),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
```
