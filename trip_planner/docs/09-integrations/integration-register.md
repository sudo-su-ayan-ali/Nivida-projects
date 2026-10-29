# Master Integration Register & Service Governance

- **Status:** Approved
- **Owner:** Integration Architect / Lead Backend Engineer
- **Last Updated:** 2026-10-29
- **Related Documents:** [`../04-architecture/integration-architecture.md`](../04-architecture/integration-architecture.md), [`retry-and-failure-handling.md`](retry-and-failure-handling.md)

---

## 1. Master Integrations Inventory

| Service Category | Provider / Service | Protocol | Ownership & Execution Boundary | Purpose in Bharat Yatra |
| :--- | :--- | :--- | :--- | :--- |
| **AI LLM Engine** | OpenAI (GPT-4o-mini) / Anthropic (Claude 3.5) | HTTPS REST | Serverless (Deno Edge Functions) | Dynamic, constraint-grounded travel itinerary synthesis. |
| **Maps & Routing** | Mapbox GL & Vector Tiles / OSRM | HTTPS REST & Tiles | Client Vector SDK / Edge Proxy | Interactive circuit maps, turn-by-turn routes, distance matrix. |
| **Geocoding & Search**| Photon (OpenStreetMap) / Mapbox Geocoding | HTTPS REST | Server-side Edge Function Proxy | Transliterated place search across English, Hindi, and Gujarati. |
| **Push Notifications**| Firebase Cloud Messaging (FCM) | HTTP v1 REST | Serverless (Deno Edge Functions) | Instant lead dispatch to taxi operators; emergency temple notices. |
| **SMS & Phone OTP** | Twilio / Exotel | HTTPS REST | Supabase Auth SMS Hook | Vernacular OTP verification for travelers and transport providers. |
| **Payment Gateway** | Razorpay / Cashfree (Phase 2 Prep) | HTTPS Webhooks | Server-side Edge Function (HMAC) | Merchant booking fees and escrow payments. |
| **Official Portals** | Ambaji Devasthan Trust / ASI Portals | In-App Webview | Untrusted Client Browser Sandbox | Official pooja booking redirection without middleman scalping. |

---

## 2. Invariant Integration Rules

1. **Zero Client Secrets**: Privileged API keys for LLMs, FCM service accounts, and SMS gateways must never be bundled into the Flutter application.
2. **Deterministic Fallbacks**: Every billable or network-dependent third-party integration must have an automated, test-verified local fallback.
