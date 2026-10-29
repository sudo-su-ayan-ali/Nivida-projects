# Entity Relationship Diagram (ERD)

- **Status:** Approved
- **Owner:** Database Architect
- **Last Updated:** 2026-10-29
- **Related Documents:** [`database-architecture.md`](database-architecture.md), [`data-dictionary.md`](data-dictionary.md)

---

## 1. Master Relational ERD (Mermaid)

```mermaid
erDiagram
    PROFILES ||--o{ ITINERARIES : "creates"
    PROFILES ||--o{ ENQUIRIES : "submits"
    PROFILES ||--o{ BUSINESSES : "owns"

    STATES ||--|{ DISTRICTS : "contains"
    DISTRICTS ||--|{ CITIES : "contains"
    CITIES ||--|{ DESTINATIONS : "hosts"
    
    DESTINATIONS ||--|{ ATTRACTIONS : "features"
    ATTRACTIONS ||--o{ RITUALS : "schedules"
    ATTRACTIONS ||--o{ ACCESSIBILITY_FEATURES : "defines"
    
    ITINERARIES ||--|{ ITINERARY_DAYS : "contains"
    ITINERARY_DAYS ||--|{ ITINERARY_STOPS : "includes"
    ATTRACTIONS ||--o{ ITINERARY_STOPS : "visited_at"
    
    BUSINESSES ||--|{ SERVICES : "offers"
    BUSINESSES ||--o{ ENQUIRIES : "receives"
    BUSINESSES ||--o{ BUSINESS_VERIFICATIONS : "validates"

    PROFILES {
        uuid id PK
        string email
        string full_name
        string phone
        string role
        timestamptz created_at
    }

    DESTINATIONS {
        uuid id PK
        uuid city_id FK
        string name_en
        string name_hi
        string name_gu
        geography coordinates
        string category
    }

    ATTRACTIONS {
        uuid id PK
        uuid destination_id FK
        string name_en
        string name_hi
        string name_gu
        geography coordinates
        time opening_time
        time closing_time
        int step_count
        boolean wheelchair_accessible
        boolean ropeway_available
        boolean doli_available
        text dress_code
        text photography_rules
        string official_portal_url
    }

    RITUALS {
        uuid id PK
        uuid attraction_id FK
        string ritual_name
        time start_time
        time end_time
        text notes
    }

    ITINERARIES {
        uuid id PK
        uuid user_id FK
        string title
        int duration_days
        string pacing
        string party_type
        numeric estimated_cost
        jsonb raw_schedule
    }

    BUSINESSES {
        uuid id PK
        uuid owner_id FK
        string business_name
        string category
        geography location
        boolean is_verified
        string phone_contact
    }

    ENQUIRIES {
        uuid id PK
        uuid customer_id FK
        uuid business_id FK
        string status
        date trip_date
        int passenger_count
        numeric quote_amount
        boolean customer_confirmed
    }
```
