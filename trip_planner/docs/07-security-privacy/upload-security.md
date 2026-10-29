# Storage Upload Security & Malicious Media Prevention

- **Status:** Approved
- **Owner:** Application Security Engineer
- **Last Updated:** 2026-10-29
- **Related Documents:** [`../06-backend-supabase/storage-policies.md`](../06-backend-supabase/storage-policies.md), [`security-policy.md`](security-policy.md)

---

## 1. Upload Attack Surface & Mitigations

| Attack Vector | Risk | Primary Mitigation |
| :--- | :--- | :--- |
| **Malicious Executables (Polyglots)** | Attacker uploads an `.exe` or `.sh` script disguised as an image (`.jpg`). | Server-side MIME-type magic byte validation in Edge Function / Storage hooks; rejection of non-conforming file headers. |
| **Storage Denial of Service** | Flooding buckets with massive 1GB video files to exhaust quotas. | Strict file size enforcement (Images $\le 5\text{MB}$, PDFs $\le 10\text{MB}$) enforced at API Gateway. |
| **Path Traversal Attacks** | Uploading filenames like `../../system/file.png` to overwrite assets. | Supabase automatically strips client-provided filenames and replaces them with cryptographically generated UUIDs (`${uuidv4()}.webp`). |
| **EXIF Metadata Leakage** | Photos revealing traveler home GPS coordinates or personal identity. | Automatic server-side EXIF/geotag stripping during image optimization before moving to public CDN. |
