# External API Contracts & Schema Definitions

- **Status:** Approved
- **Owner:** API Architect / Integration Engineer
- **Last Updated:** 2026-10-29
- **Related Documents:** [`integration-register.md`](integration-register.md), [`../12-api-and-data-contracts/api-conventions.md`](../12-api-and-data-contracts/api-conventions.md)

---

## 1. Routing Proxy API Contract (`POST /functions/v1/get-route`)

### Request Payload
```json
{
  "origin": { "lat": 24.4764, "lng": 72.7758 },
  "destination": { "lat": 24.3333, "lng": 72.8500 },
  "profile": "driving",
  "avoid_ghat": false
}
```

### Response Payload
```json
{
  "distance_meters": 50400,
  "duration_seconds": 5100,
  "has_ghat_road": true,
  "warning": "Steep hill descent between Mount Abu and Abu Road. Drive cautiously.",
  "geometry": "polyline6_encoded_string_here"
}
```

---

## 2. Notification Dispatch API Contract (`POST /functions/v1/dispatch-push`)

### Request Payload (Server-to-Server Only)
```json
{
  "recipient_user_id": "8f3b2a1c-99d8-4f2a-b44c-123456789abc",
  "channel": "enquiries",
  "title": "New Booking Enquiry Received",
  "body": "Traveler requested 4 seats from Abu Road to Mount Abu on Nov 5.",
  "data": {
    "enquiry_id": "e3a1b2c4-55d6-4e7f-a88b-999888777666",
    "route": "/profile/business-dashboard/enquiry/e3a1b2c4-55d6-4e7f-a88b-999888777666"
  }
}
```
