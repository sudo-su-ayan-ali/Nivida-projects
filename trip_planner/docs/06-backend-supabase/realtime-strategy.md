# Supabase Realtime Strategy & Event Channels

- **Status:** Approved
- **Owner:** Realtime Systems Architect / Backend Engineer
- **Last Updated:** 2026-10-29
- **Related Documents:** [`../04-architecture/data-flow.md`](../04-architecture/data-flow.md), [`rls-policy-matrix.md`](rls-policy-matrix.md)

---

## 1. Targeted Realtime Architecture

Realtime WebSockets are enabled **only** for business workflows that require immediate reactivity to avoid battery drain and connection exhaustion:

* **Enabled Realtime Entities**:
  * `enquiries` table (Notifies merchant of new leads; notifies traveler of quotes and acceptance).
  * `emergency_notices` table (Instant broadcast of road closures, flood/landslide alerts in Mount Abu).
* **Disabled Realtime Entities**:
  * Static destination content, itineraries, reviews, and user profiles rely on standard REST polling or pull-to-refresh.

---

## 2. Client Subscription Pattern (Flutter)

```dart
final enquirySubscription = supabase
  .from('enquiries')
  .stream(primaryKey: ['id'])
  .eq('business_id', merchantBusinessId)
  .listen((List<Map<String, dynamic>> data) {
    ref.read(merchantEnquiryListProvider.notifier).updateFromStream(data);
  });
```
