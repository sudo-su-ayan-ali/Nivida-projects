# Sprint 6: Commercial Bookings & Payments — Detailed Task Breakdown

- **Sprint Code:** `SPRINT-06`
- **Milestone Target:** `M3: Verified Local Commerce & Booking Engine`
- **Committed Story Points:** 54 pts
- **Status:** ⏳ Queued (Pre-requisites: Sprints 1–5)
- **Primary References:** [`docs/13-business-workflows/booking-lifecycle.md`](../../13-business-workflows/booking-lifecycle.md), [`docs/09-integrations/payments.md`](../../09-integrations/payments.md)

---

## 1. Sprint Objective

Implement the commercial booking state machine with atomic concurrency locks, integrate Razorpay payment gateway (UPI intent and cards), build webhook signature reconciliation, implement automated cancellation and refund calculations, and build customer dispute resolution workflows.

---

## 2. Granular Task & User Story Breakdown

### Task 6.1: Commercial Booking State Machine & Atomic Concurrency
- **Backlog Ref:** `PB-0402`
- **Story Points:** 13 pts | **Assignee:** Lead Backend Architect
- **Detailed Implementation Steps:**
  1. Create `bookings` table: booking UUID, customer user ID, merchant ID, service date/time, total amount, currency (`INR`), state enum (`draft`, `pending_payment`, `confirmed`, `completed`, `cancelled`, `refunded`).
  2. Implement PostgreSQL stored procedure `create_booking_reservation()`:
     - Uses `SELECT FOR UPDATE` to lock service slot.
     - Checks if requested date/slot is already reserved.
     - Creates temporary hold with 15-minute expiration timestamp.
  3. Set up scheduled database cron / background trigger to release expired `pending_payment` reservations automatically.
- **Exit Criteria / DoD:**
  - High-concurrency automated tests demonstrate zero double-bookings under simultaneous checkout attempts.

---

### Task 6.2: Razorpay Payment Gateway & Checkout SDK Integration
- **Backlog Ref:** `PB-0403`
- **Story Points:** 8 pts | **Assignee:** Full-Stack Payment Engineer
- **Detailed Implementation Steps:**
  1. Build Supabase Edge Function `create-razorpay-order`:
     - Creates order via Razorpay REST API with amount in paise, currency `INR`, and booking ID in metadata.
     - Returns `order_id` to client.
  2. Integrate `razorpay_flutter` SDK in client application.
  3. Implement checkout drawer supporting UPI intent (Google Pay, PhonePe, Paytm), NetBanking, and credit/debit cards.
  4. Handle payment cancellation and user drop-off gracefully with retry action.
- **Exit Criteria / DoD:**
  - End-to-end simulated transaction in Razorpay Test Mode completes and produces verified transaction receipt.

---

### Task 6.3: Cryptographic Webhook Reconciliation Engine
- **Backlog Ref:** `PB-0403`
- **Story Points:** 5 pts | **Assignee:** Security & Backend Engineer
- **Detailed Implementation Steps:**
  1. Create Edge Function `razorpay-webhook` listening for `payment.captured` and `refund.processed` events.
  2. Verify HMAC SHA256 signature using `x-razorpay-signature` and secret key.
  3. Update `bookings` status to `confirmed` upon verified payment capture.
  4. Emit CloudEvent trigger sending confirmation SMS / WhatsApp message to user and merchant.
- **Exit Criteria / DoD:**
  - Webhook rejects invalid HMAC signatures; successfully updates booking records on valid events.

---

### Task 6.4: Automated Cancellation Engine & Dispute Resolution Desk
- **Backlog Ref:** `PB-0404` / `PB-0602`
- **Story Points:** 5 pts | **Assignee:** Product Backend Engineer
- **Detailed Implementation Steps:**
  1. Implement cancellation rules:
     - Free cancellation $>24$ hours prior to scheduled journey (100% refund).
     - 50% refund between 12–24 hours.
     - 0% refund $<12$ hours.
  2. Trigger automated Razorpay refund API when eligible cancellation is requested.
  3. Build customer dispute submission form (`disputes` table) for grievances (driver no-show, overcharging).
- **Exit Criteria / DoD:**
  - Cancellation triggers correct refund percentage and logs complete audit trail.

---

### Task 6.5: Transactional Edge Case Tests & Sprint Buffer
- **Points:** 23 pts | Payment network drops, bank timeout reconciliation tests, and sprint regression buffer.
