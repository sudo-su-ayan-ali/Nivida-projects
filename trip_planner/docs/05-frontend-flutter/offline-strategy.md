# Offline Strategy & Local Caching (Hive / SQLite)

- **Status:** Approved
- **Owner:** Mobile Performance Lead / Database Engineer
- **Last Updated:** 2026-10-29
- **Related Documents:** [`../02-ux-research/research-findings.md`](../02-ux-research/research-findings.md), [`error-handling.md`](error-handling.md)

---

## 1. Offline Storage Strategy

Pilgrimage corridors (e.g. Mount Abu ghat roads, Gabbar Hill foothills) frequently suffer from severe cellular connectivity drops. The Flutter client enforces a **Cache-First / Stale-While-Revalidate** policy for critical data:

```text
User Request ──► Check Local Hive Cache ──► Immediate UI Render (<100ms)
                        │
                        └──► Background Network Fetch ──► Update Local Cache & Notify UI
```

---

## 2. Cached Data Entities

| Data Entity | Local Storage Tech | TTL / Invalidation Policy | Offline Capability |
| :--- | :--- | :--- | :--- |
| **Saved Itineraries** | Hive Box (`itineraries_box`) | Permanent until deleted by user | Full view, stop details, directions. |
| **Circuit Destinations** | Hive Box (`destinations_box`) | 24 Hours | Full profile, offline Aarti times. |
| **Emergency Contacts** | Secure Storage (`emergency_box`) | Permanent (Updated on launch) | Instant one-tap phone dialer. |
| **User Profile / Auth** | Flutter Secure Storage | Until explicit sign-out | Offline session persistence. |

---

## 3. Offline UI Indicators

* When reading from local storage due to network unavailability, screens display a non-blocking `OfflineBanner`:
  *"Viewing offline cached yatra plan. Emergency contacts active."*
