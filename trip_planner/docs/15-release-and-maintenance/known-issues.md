# Known Issues, Limitations & Workarounds

- **Status:** Approved
- **Owner:** Quality Assurance Lead & Field Operations Lead
- **Last Updated:** 2026-10-29
- **Related Requirements / ADRs:** [`defect-register.md`](../10-quality-and-testing/defect-register.md), [`risk-register.md`](../00-governance/risk-register.md)

---

## 1. Scope & Purpose

This register documents known product behaviors, platform limitations, and temporary workarounds in current production and staging releases. Tracking these prevents duplicate bug filings and guides support representatives.

---

## 2. Active Known Issues & Limitations Matrix

| Issue ID | Severity | Description / Symptom | Affected Component | Technical Root Cause | Recommended Workaround | Target Fix Release |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| **KI-101** | Medium | SMS OTP delivery delay on Airtel/BSNL in remote Gabbar Hill valley zones. | Supabase Auth / Twilio | Hilly terrain signal attenuation and local tower carrier queues. | Fall back to Email OTP or automated WhatsApp verification after 60s timeout. | v1.1.0 |
| **KI-102** | Low | Mapbox offline vector tiles occasionally fail to render water polygons on low-end Android Go devices ($< 2\text{GB}$ RAM). | Flutter Map / Offline Storage | GPU texture memory limits on budget Android Go chipsets. | App automatically detects available RAM and renders simplified 2D canvas tiles without elevation layers. | v1.0.1 |
| **KI-103** | Low | Ambaji Temple trust real-time queue estimates may report "Moderate" during unannounced VIP state visits. | Content Verification Engine | Official temple administration changes queue protocols without instant API notification. | Local content operations desk receives manual phone flash updates and forces a cache purge within 15 minutes. | Operational SLA |
| **KI-104** | Low | Gujarati text clipping on certain legacy Xiaomi devices running custom MIUI font scalers $> 1.4\text{x}$. | Flutter UI / Typography | Non-standard font metrics injected by OEM Android skin. | UI enforces `textScaler: TextScaler.linear(clamp(1.0, 1.25))` on critical attraction cards. | v1.0.1 |

---

## 3. Reporting New Issues

When identifying an unlisted issue:
1. Verify whether the issue is reproducible in clean offline mode.
2. File a bug ticket in the Defect Register (`docs/10-quality-and-testing/defect-register.md`) with device model, OS version, and network log trace.
