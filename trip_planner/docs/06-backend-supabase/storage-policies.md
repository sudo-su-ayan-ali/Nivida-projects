# Supabase Storage Policies & Asset Security

- **Status:** Approved
- **Owner:** Security Engineer / Cloud Architect
- **Last Updated:** 2026-10-29
- **Related Documents:** [`rls-policy-matrix.md`](rls-policy-matrix.md), [`../07-security-privacy/upload-security.md`](../07-security-privacy/upload-security.md)

---

## 1. Storage Buckets Inventory

| Bucket Name | Visibility | Allowed MIME Types | Max Size | Intended Content |
| :--- | :---: | :--- | :---: | :--- |
| `destination-media` | Public | `image/jpeg`, `image/png`, `image/webp` | 5 MB | Verified temple, heritage, and scenery photography. |
| `merchant-documents`| Private | `image/jpeg`, `image/png`, `application/pdf` | 10 MB | Commercial licenses, taxi permits, and Aadhaar copies. |
| `user-avatars` | Public | `image/jpeg`, `image/png`, `image/webp` | 2 MB | Profile pictures of travelers and business owners. |

---

## 2. Storage Access Policies

1. **`destination-media` Bucket**:
   * `SELECT`: Public (`anon` and `authenticated`).
   * `INSERT/UPDATE/DELETE`: Restricted strictly to `public.is_admin() = TRUE`.
2. **`merchant-documents` Bucket**:
   * `SELECT`: Restricted to `auth.uid() = owner_id` OR `public.is_admin() = TRUE`.
   * `INSERT`: Authenticated users uploading to their own user-folder path (`merchant-documents/{user_id}/*`).
   * `DELETE`: Restricted to admins or the owning business owner.
