# Input Validation, SQL Injection & XSS Defenses

- **Status:** Approved
- **Owner:** Application Security Architect
- **Last Updated:** 2026-10-29
- **Related Documents:** [`security-policy.md`](security-policy.md), [`../06-backend-supabase/validation-and-transactions.md`](../06-backend-supabase/validation-and-transactions.md)

---

## 1. SQL Injection Prevention

* **Parameterized Queries Only**: PostgREST and Supabase client libraries strictly construct parameterized queries under the hood. No raw string interpolation (e.g. `"SELECT * FROM destinations WHERE name = '" + input + "'"` is strictly forbidden in codebase).
* **Database Stored Procedures**: All PL/pgSQL functions use typed parameters with strict scalar type casting.

---

## 2. Cross-Site Scripting (XSS) & Injection Defenses

* **Flutter Native Canvas Immunity**: Flutter mobile and CanvasKit web render widgets directly to a graphics canvas (Skia/Impeller) rather than injecting HTML into the DOM, inherently eliminating classic DOM-based XSS vectors.
* **Rich Text Sanitization**: In Markdown rendering screens (e.g., historical descriptions or terms of service), HTML tags are strictly stripped or escaped before passing to presentation widgets.
* **Input Length Boundaries**: String inputs (names, feedback, special requests) have strict database schema length boundaries (e.g., `VARCHAR(500)`).
