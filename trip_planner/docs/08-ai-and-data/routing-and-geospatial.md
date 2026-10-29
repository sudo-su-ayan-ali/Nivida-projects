# Routing, Distance Matrix & Geospatial Intelligence

- **Status:** Approved
- **Owner:** Geospatial Engineer / Navigation Specialist
- **Last Updated:** 2026-10-29
- **Related Documents:** [`itinerary-validation.md`](itinerary-validation.md), [`../04-architecture/backend-architecture.md`](../04-architecture/backend-architecture.md)

---

## 1. Geospatial Routing Hierarchy

Road calculations across interstate routes (e.g. Abu Road $\to$ Mount Abu ghat roads, Mount Abu $\to$ Ambaji highway) use a 3-tier routing hierarchy:

```text
Tier 1: High-Precision Routing API (Mapbox / OSRM REST)
 └── Fallback Tier 2: Pre-computed Interstate Distance Matrix (PostgreSQL Table)
      └── Emergency Tier 3: Geodesic Haversine Calculation with 1.4x Winding Factor
```

---

## 2. Pre-Computed Pilot Distance Matrix (`route_matrices`)

To eliminate runtime routing API costs and latency during peak season, key circuit segments are pre-calculated in PostgreSQL:

| Origin Hub | Destination Hub | Driving Distance | Mountain Ghat Factor | Typical Driving Time |
| :--- | :--- | :---: | :---: | :---: |
| **Abu Road Rly Station** | **Mount Abu Town (Nakki Lake)** | 28.5 km | High (Steep hill curves) | ~55 minutes |
| **Mount Abu Town** | **Guru Shikhar Summit** | 15.2 km | High (Single lane hill road) | ~40 minutes |
| **Abu Road Rly Station** | **Ambaji Temple Town** | 22.0 km | Low/Moderate (Highway) | ~35 minutes |
| **Ambaji Temple Town** | **Gabbar Hill Foothills** | 4.8 km | Low (City connection) | ~12 minutes |
| **Mount Abu Town** | **Ambaji Temple Town** | 50.4 km | Moderate (Interstate highway) | ~1 hour 25 mins |
