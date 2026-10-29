# Rate Limiting, Abuse Prevention & Scraping Defenses

- **Status:** Approved
- **Owner:** Infrastructure Security Lead
- **Last Updated:** 2026-10-29
- **Related Documents:** [`threat-model.md`](threat-model.md), [`../04-architecture/scalability-and-capacity.md`](../04-architecture/scalability-and-capacity.md)

---

## 1. Rate Limiting Policy Matrix

| Endpoint / Action | Throttle Limit (Per IP / User) | Window | Enforcement Point | Action on Breach |
| :--- | :---: | :---: | :--- | :--- |
| **Authentication (Login/OTP)** | 5 requests | 1 minute | Kong Gateway / Supabase Auth | Temporary 15-minute IP freeze + CAPTCHA. |
| **AI Trip Generation** | 5 generations | 1 hour | Edge Function (`generate-itinerary`) | HTTP 429 Too Many Requests; serve cached circuits. |
| **Business Enquiry Submission**| 10 enquiries | 1 hour | PostgreSQL RLS / API Gateway | HTTP 429 with cooldown countdown timer. |
| **Public Destination Discovery**| 120 requests | 1 minute | Cloudflare Edge CDN | Automated bot challenge / rate throttling. |

---

## 2. Scraping Defenses & Content Watermarking

* **Database Obfuscation**: Primary keys are non-sequential UUIDs (`gen_random_uuid()`), preventing attackers from enumerating destinations sequentially via `GET /destinations/1`, `/destinations/2`.
* **Dynamic Bot Detection**: Cloudflare Turnstile / Managed Challenges enabled for automated crawler detection.
