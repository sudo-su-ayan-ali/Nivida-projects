# Product Release Notes & Changelog

- **Status:** Approved
- **Owner:** Technical Product Manager & Release Lead
- **Last Updated:** 2026-10-29
- **Related Requirements / ADRs:** [`versioning.md`](../12-api-and-data-contracts/versioning.md), [`milestone-plan.md`](../14-project-management/milestone-plan.md)

---

## 1. Versioning Standard

Bharat Yatra follows strict **Semantic Versioning 2.0.0** (`MAJOR.MINOR.PATCH+BUILD`):
- **MAJOR**: Incompatible API contract changes or fundamental navigation overhauls.
- **MINOR**: Backward-compatible new features (e.g. new destination circuit added, new language introduced).
- **PATCH**: Backward-compatible bug fixes, performance tuning, and minor copy updates.

---

## 2. Release History

### Version 1.0.0+100 (Pilot Production Release) — 2026-10-29

#### 🌟 Highlights & New Features
- **Mount Abu & Ambaji Pilgrimage Circuits**: Complete curated directory of over 45 sacred points of interest, including Dilwara Jain Temples, Nakki Lake, Guru Shikhar, Ambaji Shaktipeeth, Gabbar Hill, and Koteshwar.
- **AI Pilgrimage Engine**: Intelligent multi-day itinerary generation tailored to devotee pace, senior citizen stair limitations, and strict aarti/darshan ritual schedules.
- **Vernacular Trilingual Support**: Native language interfaces in **English**, **Hindi (हिन्दी)**, and **Gujarati (ગુજરાતી)** with instant in-app switching.
- **Offline Survival Pack**: Local SQLite vector data caching and pre-cached road maps for network blackspots in the Aravalli hills and ghat passes.
- **Verified Local Services**: Directory of certified taxi operators and licensed regional guides with authentic transparent pricing and hill-route safety endorsements.
- **Direct Official Portals**: One-click redirection to official Temple Trust portals (Ambaji Devasthan, ASI Dilwara) for legitimate VIP darshan passes.

#### 🛡️ Security, Privacy & Performance
- Zero-PII storage policy with automated client-side masking for telephone numbers.
- Full compliance with India's Digital Personal Data Protection (DPDP) Act.
- Sub-1.5 second cold-start rendering and smooth 60 FPS scrolling on Android and iOS.

#### 🐛 Bug Fixes & Stability
- Resolved race condition during rapid offline-to-online network reconnection.
- Corrected font-metric clipping on Gujarati complex conjunct glyphs on low-DPI Android devices.
- Hardened token expiration handlers to prevent session lockouts during intermittent 2G hill network drops.

---

### Version 0.9.0+90 (Release Candidate Staging) — 2026-10-22
- Staging beta deployment for internal alpha field testing in Mount Abu and Ambaji.
- Integrated Razorpay sandbox payment webhooks and automated refund testing.
- Hardened PostGIS geo-radius bounding boxes for crowd wait-time verification.
