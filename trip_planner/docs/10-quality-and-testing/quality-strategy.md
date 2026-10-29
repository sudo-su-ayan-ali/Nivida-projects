# Quality Engineering Strategy & Test Philosophy

- **Status:** Approved
- **Owner:** Quality Engineering Director / Lead QA Architect
- **Last Updated:** 2026-10-29
- **Related Documents:** [`../00-governance/definition-of-done.md`](../00-governance/definition-of-done.md), [`test-plan.md`](test-plan.md)

---

## 1. Quality Philosophy: Zero Broken Invariants

In **Bharat Yatra**, quality assurance is not an afterthought or manual manual clicking exercise. It is an automated engineering discipline built on the **Test Automation Pyramid**:

```text
               /\
              /  \      E2E User Journeys & Smoke Tests (5%)
             /----\
            /      \    Widget & Presentation State Tests (20%)
           /--------\
          /          \  Integration & Backend RLS Tests (25%)
         /------------\
        /              \ Unit Tests & Domain Deterministic Rules (50%)
       ------------------
```

---

## 2. Mandatory Quality Principles

1. **Shift-Left Security & Testing**: Security policies (RLS), input bounds, and negative permission tests are written alongside migrations, not after deployment.
2. **Deterministic Reproducibility**: Flaky tests are treated as production defects. Network calls are strictly mocked during unit and widget tests using `mocktail` or mock HTTP clients.
3. **No Phantom Passes**: Tests must verify both positive (happy path) and negative (permission denied, network dropped, timeout fallback) outcomes with explicit assertion matchers.
