# Scalability, Capacity Planning & Performance Bounds

- **Status:** Approved
- **Owner:** Performance Engineer / Cloud Architect
- **Last Updated:** 2026-10-29
- **Related Documents:** [`../01-product/non-functional-requirements.md`](../01-product/non-functional-requirements.md), [`backend-architecture.md`](backend-architecture.md)

---

## 1. Traffic Projections & Concurrency Bounds

* **Pilot Baseline (Mount Abu & Ambaji)**:
  * Expected Monthly Active Users (MAU): 15,000 – 25,000.
  * Normal Peak Concurrency: 500 – 1,000 concurrent active sessions.
* **Festival Spike Profile (Bhadarvi Poonam / Navratri in Ambaji)**:
  * Over 1.5 million physical pilgrims visit Ambaji during Bhadarvi Poonam.
  * Anticipated Peak Concurrency: **10,000 – 15,000 concurrent sessions**.

---

## 2. Horizontal & Vertical Scaling Architecture

1. **Read-Heavy Caching Layer**:
   * Destination profiles, Aarti timings, and static temple cards are cached at the edge CDN and in local Redis/in-memory PostgreSQL buffers.
   * Read queries bypass heavy computation using PostgREST indexes.
2. **Database Connection Pooling**:
   * Supabase **PgBouncer** / Supavisor connection pooler configured for transaction pooling to handle thousands of concurrent client connections without exhausting PostgreSQL process limits.
3. **Stateless Edge Compute**:
   * AI itinerary requests execute on distributed Deno Edge Functions, scaling horizontally on-demand without provisioning virtual machines.
