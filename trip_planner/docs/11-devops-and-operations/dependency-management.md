# Dependency Management & Supply Chain Governance

- **Status:** Approved
- **Owner:** DevOps Security Lead / Lead Architect
- **Last Updated:** 2026-10-29
- **Related Documents:** [`../07-security-privacy/vulnerability-management.md`](../07-security-privacy/vulnerability-management.md), [`ci-cd.md`](ci-cd.md)

---

## 1. Third-Party Package Policy

To protect against software supply chain poisoning and dependency bloat:
1. **Zero Unvetted Libraries**: Do not add packages merely because they are popular. Every dependency added to `pubspec.yaml` requires architectural review against performance, package health score ($\ge 120/140$ on pub.dev), and licensing.
2. **Lockfile Enforcement**: `pubspec.lock` and Deno lockfiles are strictly committed to version control. CI builds execute `flutter pub get --enforce-lockfile`.

---

## 2. Automated SCA & License Auditing

* Weekly automated Dependabot PRs for security updates.
* Automated CI license compliance check ensuring zero copyleft (GPL-3.0) licenses contaminate the client application bundle (only MIT, Apache-2.0, and BSD-3-Clause permitted).
