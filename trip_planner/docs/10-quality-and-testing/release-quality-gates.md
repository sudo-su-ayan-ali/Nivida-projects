# Release Quality Gates & Go/No-Go Checklist

- **Status:** Approved
- **Owner:** Quality Engineering Director / Product Director
- **Last Updated:** 2026-10-29
- **Related Documents:** [`../00-governance/definition-of-done.md`](../00-governance/definition-of-done.md), [`defect-register.md`](defect-register.md)

---

## 1. Mandatory Release Quality Gates (Go / No-Go)

A release candidate build is approved for production deployment **only** if all 8 criteria below evaluate to **PASS**:

- [ ] **Gate 1: Static Analysis Clean**: `flutter analyze` returns zero errors and zero warnings.
- [ ] **Gate 2: Unit & Widget Test Pass**: 100% of unit and widget tests pass with $\ge 80\%$ domain code coverage.
- [ ] **Gate 3: Backend & RLS Tests Pass**: 100% of pgTAP RLS authorization tests pass.
- [ ] **Gate 4: AI Benchmark Quality**: 50 golden circuit scenarios achieve $\ge 95\%$ accuracy score.
- [ ] **Gate 5: Zero S1/S2 Defects**: Defect register has zero unresolved Blocker or Critical defects.
- [ ] **Gate 6: Secret & Vulnerability Free**: Zero leaked keys in Gitleaks scan; zero high/critical CVEs in SCA.
- [ ] **Gate 7: Accessibility & Localization Verified**: WCAG AA touch targets verified; Hindi and Gujarati scripts render without conjunct clipping.
- [ ] **Gate 8: Offline Smoke Test**: Saved itineraries render cleanly in offline airplane mode test.
