# End-to-End Data Flow Architecture

- **Status:** Approved
- **Owner:** Data Architect / Integration Engineer
- **Last Updated:** 2026-10-29
- **Related Documents:** [`backend-architecture.md`](backend-architecture.md), [`../08-ai-and-data/itinerary-generation.md`](../08-ai-and-data/itinerary-generation.md)

---

## 1. Flow 1: AI Itinerary Synthesis & Validation Data Flow

```mermaid
sequenceDiagram
    autonumber
    actor User as Traveler
    participant App as Flutter Client
    participant Edge as Edge Function (generate-itinerary)
    participant DB as PostgreSQL (PostGIS)
    participant LLM as External AI LLM API

    User->>App: Submits Trip Parameters (Abu/Ambaji, 2 Days, Elders)
    App->>Edge: POST /functions/v1/generate-itinerary (Bearer JWT)
    Edge->>DB: Query Verified POIs, Aarti Schedules & Distances
    DB-->>Edge: Returns Grounded POI Context JSON
    Edge->>LLM: Prompt with Grounded Context & Strict JSON Schema
    LLM-->>Edge: Returns Draft Itinerary JSON
    Edge->>Edge: Execute Deterministic Rules (Pacing, Hours, Steps)
    alt Validation Failed (Conflict / Timeout)
        Edge->>DB: Fetch Curated Fallback Template
        DB-->>Edge: Returns Curated Fallback JSON
    end
    Edge->>DB: INSERT INTO itineraries (user_id, validated_json)
    DB-->>Edge: Confirmed ID
    Edge-->>App: Returns Validated Itinerary JSON
    App->>App: Cache to Local Hive Storage & Render Timeline
```

---

## 2. Flow 2: Enquiry Lifecycle & Contact Masking Data Flow

```mermaid
sequenceDiagram
    autonumber
    actor Traveler as Traveler
    participant AppT as Traveler App
    participant PostgREST as Supabase API (Kong + RLS)
    participant DB as PostgreSQL
    actor Merchant as Local Taxi Driver
    participant AppM as Merchant App

    Traveler->>AppT: Click 'Send Enquiry' on Taxi Profile
    AppT->>PostgREST: POST /enquiries (merchant_id, dates, masked_phone)
    PostgREST->>DB: INSERT with RLS validation (auth.uid() = user_id)
    DB-->>PostgREST: Success
    DB--)Merchant: Database Trigger -> Supabase Realtime / FCM Push
    Merchant->>AppM: Open Merchant Portal
    AppM->>PostgREST: GET /enquiries (RLS allows only merchant's enquiries)
    PostgREST-->>AppM: Returns Enquiry (Customer Phone Masked)
    Merchant->>AppM: Accept Enquiry & Provide Quote (₹1400)
    AppM->>PostgREST: PATCH /enquiries (status: 'accepted', quote: 1400)
    PostgREST->>DB: UPDATE enquiry
    DB--)Traveler: Realtime Notification: Quote Received
    Traveler->>AppT: Accept Quote & Confirm Booking
    AppT->>PostgREST: PATCH /enquiries (customer_confirmed: true)
    Note over PostgREST,DB: RLS Policy now exposes unmasked phone to both parties
    PostgREST-->>AppM: Unmasked Contact Revealed
```
