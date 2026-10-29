# Security Testing, Fuzzing & Abuse Verification

- **Status:** Approved
- **Owner:** Application Security Engineer / QA Specialist
- **Last Updated:** 2026-10-29
- **Related Documents:** [`../07-security-privacy/security-test-plan.md`](../07-security-privacy/security-test-plan.md), [`../07-security-privacy/threat-model.md`](../07-security-privacy/threat-model.md)

---

## 1. Automated Dynamic Application Security Testing (DAST)

* OWASP ZAP automated security scans run against staging API endpoints to test for:
  * Insecure Direct Object References (IDOR).
  * CORS misconfigurations on Kong Gateway.
  * Rate-limiting enforcement under burst request loads.

---

## 2. API Fuzzing & Malformed Input Tests

* Automated fuzzers inject malformed payloads into Edge Functions:
  * SQL injection strings (`' OR 1=1 --`).
  * Malformed JSON structures.
  * Extremely large text blobs ($> 50\text{KB}$) in traveler note fields.
* **Success Criteria**: 100% of malformed requests return HTTP 400 Bad Request or HTTP 422 Unprocessable Entity with structured JSON error bodies. Zero server 500 crashes or raw stack trace leakage.
