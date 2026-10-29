# Push Notifications & Real-Time Alerts Integration (FCM)

- **Status:** Approved
- **Owner:** Mobile Infrastructure Lead / Backend Engineer
- **Last Updated:** 2026-10-29
- **Related Documents:** [`integration-register.md`](integration-register.md), [`../06-backend-supabase/edge-functions.md`](../06-backend-supabase/edge-functions.md)

---

## 1. Notification Infrastructure: Firebase Cloud Messaging (HTTP v1)

Push notifications are orchestrated via server-side Deno Edge Functions holding private service account credentials, interacting with the FCM HTTP v1 REST API.

---

## 2. Notification Channels & Message Types

| Channel ID | Priority | Target Audience | Trigger Event | Payload & Action |
| :--- | :---: | :--- | :--- | :--- |
| `enquiries` | High (Heads-up) | Local Taxi Drivers & Hoteliers | New traveler booking enquiry submitted. | Deep links to `/profile/business-dashboard/enquiry/:id`. |
| `quotes` | High | Travelers | Merchant responds with formal quote and availability. | Deep links to `/services/enquiry/status/:id`. |
| `pilgrim_alerts` | Urgent / Max | All active circuit visitors | Weather warnings, sudden temple schedule changes, or landslide alerts. | High-priority dialog pop-up with official civil instructions. |
| `reminders` | Normal | Travelers | Morning Aarti reminder (30 mins before scheduled Mangla Aarti). | Notification with direct directions link. |
