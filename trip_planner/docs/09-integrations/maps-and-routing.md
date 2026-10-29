# Maps & Routing Provider Integration Specification

- **Status:** Approved
- **Owner:** Navigation Specialist / Frontend Engineer
- **Last Updated:** 2026-10-29
- **Related Documents:** [`integration-register.md`](integration-register.md), [`../08-ai-and-data/routing-and-geospatial.md`](../08-ai-and-data/routing-and-geospatial.md)

---

## 1. Map Rendering Engine (Flutter)

* **Client SDK**: `flutter_map` (OpenStreetMap / Mapbox Vector Tiles) or `mapbox_maps_flutter`.
* **Tile Caching Strategy**: Vector and raster tiles are cached locally in device SQLite cache (`flutter_map_cache`) with a 14-day expiration window. This enables seamless offline navigation through network-blind ghat roads between Abu Road and Mount Abu.

---

## 2. Road Routing Protocol & Fallback Hierarchy

1. **Primary Online Routing**:
   * Client calls our serverless routing proxy endpoint: `POST /functions/v1/get-route`.
   * Proxy queries Mapbox Directions API using scoped server-side tokens, returning GeoJSON route geometry, distance, and duration.
2. **Offline Fallback (Pre-Computed Distance Matrix)**:
   * If mobile connection is unavailable, the client reads the pre-computed circuit road segments stored in the local SQLite database.
3. **Emergency Fallback (Haversine Distance)**:
   * Straight-line geodesic distance calculated locally in Dart with a terrain factor of **1.45×** for mountain terrain.
