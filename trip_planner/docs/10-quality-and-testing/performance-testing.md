# Performance, Profiling & Network Emulation Testing

- **Status:** Approved
- **Owner:** Performance Engineer / Mobile QA Lead
- **Last Updated:** 2026-10-29
- **Related Documents:** [`../01-product/non-functional-requirements.md`](../01-product/non-functional-requirements.md), [`../04-architecture/scalability-and-capacity.md`](../04-architecture/scalability-and-capacity.md)

---

## 1. Frame Rate & Memory Benchmarks

* **Target UI Performance**: Solid **60 FPS** (sub-16ms frame render time) during fast scrolling of destination feeds and itinerary timeline widgets.
* **Cold App Startup**: $< 2.0\text{ seconds}$ on mid-tier hardware (e.g. Snapdragon 680 / 4GB RAM).
* **Memory Footprint**: App memory consumption capped at $< 180\text{MB}$ in steady state; image cache auto-evicts decoded bitmap buffers when navigating away from destination galleries.

---

## 2. Network Emulation (Flaky 2G/3G & Offline Stress Tests)

Tests run under simulated bandwidth throttling using Charles Proxy / Android Network Profiler:
1. **Flaky Edge / 2G (50 kbps, 500ms latency)**: Confirms background retries execute with exponential backoff and do not freeze the main UI thread.
2. **Sudden Airplane Mode Toggle**: Confirms the app transitions gracefully to cached Hive data without displaying uncaught network exceptions or crashing.
