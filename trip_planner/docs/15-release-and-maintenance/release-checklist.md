# Production Release Verification Checklist

- **Status:** Approved
- **Owner:** Release Manager & QA Lead
- **Last Updated:** 2026-10-29
- **Related Requirements / ADRs:** [`release-quality-gates.md`](../10-quality-and-testing/release-quality-gates.md), [`operational-readiness.md`](../11-devops-and-operations/operational-readiness.md), [`build-and-release-process.md`](../11-devops-and-operations/build-and-release-process.md)

---

## 1. Purpose & Enforcement

This document serves as the mandatory, executable **Go / No-Go Launch Gate Checklist** that must be fulfilled and signed off by stakeholders prior to releasing any mobile bundle (Android AAB / iOS IPA) or backend migration to production.

---

## 2. Pre-Release Verification Checklist

### A. Code Quality & Automated Testing Gates
- [ ] **Repository State**: `main` branch is clean; all feature branches merged via approved PR with $\ge 2$ peer approvals.
- [ ] **Static Analysis**: `flutter analyze` passes with **0 errors and 0 warnings**.
- [ ] **Automated Unit Tests**: `flutter test` passes with $\ge 80\%$ line coverage across domain/core modules.
- [ ] **Widget & Golden Tests**: 100% pass rate on pixel regression tests across phone and tablet viewports.
- [ ] **Database & RLS Tests**: pgTAP test suite passes with 0 failures on staging PostgreSQL instance.
- [ ] **Dependency Audit**: `npm audit` (Edge Functions) and `dart pub audit` show zero high or critical CVE vulnerabilities.

### B. Security & Privacy Controls
- [ ] **Secret Sanitization**: Automated GitGuardian / Trufflehog scan confirms **no hardcoded API keys, Supabase service roles, or JWT secrets** in Flutter assets.
- [ ] **SSL / TLS Pinning**: Release builds verify TLS 1.3 encryption on all Edge Function and gateway endpoints.
- [ ] **Data Classification Audit**: Customer phone numbers and PII are masked in analytics, crash reports, and logging streams.
- [ ] **Location Permissions**: App manifests explain background/foreground location justification compliant with Google Play and Apple policies.

### C. Build Packaging & Code Signing
- [ ] **Version Synchronization**: `pubspec.yaml` version code and build number incremented cleanly per SemVer (e.g., `1.0.0+100`).
- [ ] **Android Artifact**: Android App Bundle (`.aab`) signed using Google Play App Signing production keystore via secure CI runner.
- [ ] **iOS Artifact**: Production IPA signed with valid Apple Distribution Certificate and active Provisioning Profile.
- [ ] **ProGuard / R8 Obfuscation**: Android code minification enabled and verified; mapping files uploaded to Sentry / Firebase Crashlytics.

### D. Cloud Infrastructure & Database Migrations
- [ ] **Migration Dry-Run**: Database migrations executed against Staging clone with zero lock contention or timeouts.
- [ ] **Rollback Script Verified**: Corresponding down-migration SQL script tested and verified.
- [ ] **Edge Functions Deployed**: All Supabase Edge Functions deployed with validated environment secrets (`SUPABASE_ENV=production`).
- [ ] **Readiness Health Check**: `/v1/health` endpoint responds with HTTP 200 OK across all database replicas.

### E. Store Operations & Legal Compliance
- [ ] **Store Metadata**: Google Play Store and Apple App Store listings updated with accurate vernacular screenshots (English, Hindi, Gujarati).
- [ ] **Privacy Policy & Terms**: Public URLs for Privacy Policy and Terms of Service live and compliant with Indian DPDP Act.
- [ ] **Grievance Contact**: Statutory Grievance Officer email and address published in app settings and store listings.

---

## 3. Go / No-Go Sign-Off Register

| Role | Sign-Off Authority | Status | Date & Timestamp |
| :--- | :--- | :---: | :---: |
| **Release Manager** | Lead DevOps Engineer | Approved | 2026-10-29 |
| **Engineering Lead** | Principal Systems Architect | Approved | 2026-10-29 |
| **Quality Lead** | QA Automation Lead | Approved | 2026-10-29 |
| **Security Reviewer**| Information Security Officer | Approved | 2026-10-29 |
| **Product Sponsor** | VP Product Operations | Approved | 2026-10-29 |
