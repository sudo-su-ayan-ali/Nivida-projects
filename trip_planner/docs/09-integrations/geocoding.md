# Geocoding & Multilingual Place Search Integration

- **Status:** Approved
- **Owner:** Search Engineer / Localization Lead
- **Last Updated:** 2026-10-29
- **Related Documents:** [`maps-and-routing.md`](maps-and-routing.md), [`../02-ux-research/localization-research.md`](../02-ux-research/localization-research.md)

---

## 1. Multilingual Geocoding Engine

Search across the Mount Abu and Ambaji corridors must resolve regional script queries and common phonetics:
* E.g., Searching `"Ambaji"`, `"અંબાજી"`, or `"अम्बाजी"`.
* E.g., Searching `"Dilwara"`, `"દેલવાડા"`, or `"देवलवाड़ा"`.

---

## 2. Two-Stage Search Architecture

```text
Traveler Search Query ──► Stage 1: PostgreSQL Full-Text Search (Trigram / GIN Index)
                                     │
                                     ├── (Match Found) ──► Instant Verified Local POI Result (<30ms)
                                     │
                                     └── (No Local Match) ──► Stage 2: External Geocoding API (Mapbox/Photon)
```

1. **Stage 1 (Local First)**: Queries the local `destinations` and `attractions` tables across `name_en`, `name_hi`, and `name_gu` using PostgreSQL `pg_trgm` similarity. Zero external API cost.
2. **Stage 2 (External Fallback)**: For external towns, hotels, or railway stations outside our curated database, queries the serverless geocoding proxy with strict 5-result bounds restricted to India bounding box (`bbox: [68.1, 6.7, 97.4, 35.5]`).
