# User Flows & Decision Trees

- **Status:** Approved
- **Owner:** Information Architect / Interaction Designer
- **Last Updated:** 2026-10-29
- **Related Documents:** [`user-journeys.md`](user-journeys.md), [`information-architecture.md`](information-architecture.md)

---

## 1. Flow 1: AI Itinerary Generation & Validation Loop

```mermaid
flowchart TD
    Start([User opens Trip Planner]) --> Input[Enter Destination, Dates, Party, Pace, Dietary]
    Input --> Submit{Click 'Plan My Trip'}
    Submit --> CallEdge[Supabase Edge Function: Generate Itinerary]
    CallEdge --> LLM[LLM Synthesizes Draft Itinerary]
    LLM --> Check{Deterministic Validator}
    
    Check -- Conflicts Detected (e.g. Stop closed) --> Repair[Repair with fallback POI / adjust timing]
    Check -- Valid & Verified --> ReturnJSON[Return Validated Itinerary JSON]
    
    CallEdge -- Timeout / Provider Error --> Fallback[Fetch Curated Circuit Template from Cache]
    Fallback --> ReturnJSON
    
    Repair --> ReturnJSON
    ReturnJSON --> RenderUI[Render Day-by-Day Schedule on Flutter Screen]
    RenderUI --> Action{User Action}
    Action -- Save Itinerary --> SaveDB[Sync to Supabase & Cache Locally]
    Action -- Edit Stop --> EditFlow[Swap / Delete Activity & Recalculate]
```

---

## 2. Flow 2: Local Merchant Lead & Enquiry Flow

```mermaid
sequenceDiagram
    autonumber
    actor Traveler as Traveler (Ananya)
    participant Client as Flutter Client
    participant Backend as Supabase (RLS)
    actor Merchant as Merchant (Vikram Taxi)

    Traveler->>Client: View Merchant Profile & Click 'Send Enquiry'
    Traveler->>Client: Fill Dates, Route, Passenger Count
    Client->>Backend: INSERT INTO enquiries (status: 'pending', phone_masked: true)
    Backend-->>Merchant: Realtime / Push Notification: 'New Booking Enquiry'
    Merchant->>Backend: Open Enquiry Dashboard (views dates, route, masked info)
    Merchant->>Backend: UPDATE enquiries SET status = 'accepted', quote_amount = 1400
    Backend-->>Client: Realtime Push: 'Enquiry Accepted with Quote'
    Traveler->>Client: Accepts Quote & Unlocks Mutual Contacts
    Backend-->>Client: Full Contact Revealed (Mutual Trust Established)
```

---

## 3. Flow 3: Temple Detail & Official Redirection Flow

```mermaid
flowchart LR
    A[Browse Temple Profile] --> B[View Aarti Timings & Guidelines]
    B --> C{User wants Special Pooja Pass?}
    C -- No --> D[View Map & Shoe Stand / Cloakroom Locations]
    C -- Yes --> E[Click 'Book via Official Trust Portal']
    E --> F[Show Trust & Non-Affiliation Disclaimer]
    F --> G[Open Official Portal in In-App Browser]
```
