# Event Contracts & Asynchronous Webhook Schemas

- **Status:** Approved
- **Owner:** Systems Architect / Event-Driven Lead
- **Last Updated:** 2026-10-29
- **Related Documents:** [`api-conventions.md`](api-conventions.md), [`../09-integrations/notifications.md`](../09-integrations/notifications.md)

---

## 1. Internal CloudEvents Standard

All asynchronous events emitted via Supabase Database Webhooks, Edge Functions, or message queues follow the **CloudEvents v1.0** specification:

```json
{
  "specversion": "1.0",
  "type": "app.bharatyatra.enquiry.created",
  "source": "https://api.bharatyatra.app/services/enquiries",
  "id": "evt-77a1b2c3-44d5-6e7f-8899-001122334455",
  "time": "2026-10-29T12:00:00.000Z",
  "datacontenttype": "application/json",
  "data": {
    "enquiry_id": "e3a1b2c4-55d6-4e7f-a88b-999888777666",
    "business_id": "8f3b2a1c-99d8-4f2a-b44c-123456789abc",
    "customer_id": "c1a2b3c4-9988-7766-5544-33221100aabb",
    "trip_date": "2026-11-05",
    "passenger_count": 4,
    "status": "pending"
  }
}
```

---

## 2. Event Registry & Subscription Matrix

| Event Type | Producer Subsystem | Consumer Subsystems | Delivery SLA |
| :--- | :--- | :--- | :---: |
| `app.bharatyatra.enquiry.created` | PostgreSQL `enquiries` table trigger | Edge Function (`dispatch-enquiry-alert`) $\to$ FCM | $< 3.0\text{ seconds}$ |
| `app.bharatyatra.enquiry.accepted` | Merchant API endpoint | Edge Function $\to$ Traveler Push Notification | $< 3.0\text{ seconds}$ |
| `app.bharatyatra.circuit.alert` | Moderator Admin CMS | Realtime WebSocket broadcast to circuit visitors | $< 1.5\text{ seconds}$ |
