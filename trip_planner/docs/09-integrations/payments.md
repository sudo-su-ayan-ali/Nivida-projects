# Payment Gateway Integration Architecture (Phase 2 Commercial Prep)

- **Status:** Approved
- **Owner:** Payment Systems Architect / Compliance Officer
- **Last Updated:** 2026-10-29
- **Related Documents:** [`../00-governance/scope-and-non-goals.md`](../00-governance/scope-and-non-goals.md), [`../01-product/business-requirements.md`](../01-product/business-requirements.md)

---

## 1. Compliance Standard: PCI-DSS Zero-Footprint

In strict accordance with our core governance non-goals:
* **Zero Card Storage**: The Flutter client and PostgreSQL backend **never** collect, transmit, or store raw debit/credit card numbers or CVVs.
* **Hosted Payment Engine**: All monetary transactions use Level-1 PCI-DSS compliant payment gateways (Razorpay / Cashfree) using UPI Intent, NetBanking, and Tokenized Cards.

---

## 2. Server-to-Server Webhook Reconciliation Flow

```mermaid
sequenceDiagram
    autonumber
    actor User as Traveler
    participant App as Flutter Client
    participant Edge as Edge Function (create-order)
    participant PG as Payment Gateway (Razorpay)
    participant Webhook as Edge Function (webhook-listener)
    participant DB as PostgreSQL (escrow_ledger)

    User->>App: Initiates Booking Payment (₹1400)
    App->>Edge: POST /functions/v1/create-payment-order
    Edge->>PG: Create Order ID (with metadata: enquiry_id)
    PG-->>Edge: Returns order_id & signature token
    Edge-->>App: Return order_id
    App->>PG: Open Native UPI Intent / Checkout Sheet
    User->>PG: Authorizes UPI PIN
    PG-->>App: Payment Success Callback
    Note over PG,Webhook: Asynchronous Server Webhook
    PG->>Webhook: POST /functions/v1/payment-webhook (HMAC Signed)
    Webhook->>Webhook: Verify SHA256 HMAC Signature
    Webhook->>DB: INSERT INTO payments (status: 'captured', escrow: true)
    Webhook->>DB: UPDATE enquiries SET payment_status = 'paid'
    Webhook-->>PG: HTTP 200 OK
```
