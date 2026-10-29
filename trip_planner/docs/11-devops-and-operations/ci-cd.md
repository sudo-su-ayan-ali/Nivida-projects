# CI/CD Pipeline & GitHub Actions Automation

- **Status:** Approved
- **Owner:** DevOps Engineer / Release Manager
- **Last Updated:** 2026-10-29
- **Related Documents:** [`environment-strategy.md`](environment-strategy.md), [`../10-quality-and-testing/release-quality-gates.md`](../10-quality-and-testing/release-quality-gates.md)

---

## 1. Automated Pipeline Architecture

The CI/CD pipeline is implemented via GitHub Actions workflows triggered on every pull request and push to `main`:

```mermaid
flowchart TD
    Push[Git Push / PR Open] --> Lint[1. Static Analysis: flutter analyze]
    Lint --> SecScan[2. Security: Gitleaks & TruffleHog]
    SecScan --> UnitTests[3. Unit & Widget Tests: flutter test]
    UnitTests --> DBLint[4. Supabase DB Reset & Migration Lint]
    DBLint --> RLSCheck[5. pgTAP Automated RLS Tests]
    
    RLSCheck --> Merge{Merged to main?}
    Merge -- Yes --> StagingDeploy[Deploy Migrations & Edge Functions to Staging]
    StagingDeploy --> NightlyE2E[Run E2E Smoke Tests on Staging]
    NightlyE2E --> TagCheck{Release Tag Pushed?}
    TagCheck -- Yes (vX.Y.Z) --> ProdDeploy[Manual Approval -> Deploy to Production]
    ProdDeploy --> AppBuild[Build Android AAB & iOS IPA]
```

---

## 2. GitHub Actions Workflow Configuration (`.github/workflows/ci.yml`)

```yaml
name: Continuous Integration & Verification

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  verify:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.22.x'
          channel: 'stable'
      - name: Install dependencies
        run: flutter pub get
      - name: Verify static analysis
        run: flutter analyze --fatal-infos
      - name: Run unit & widget tests
        run: flutter test --coverage
      - name: Verify secret leakage
        uses: gitleaks/gitleaks-action@v2
```
