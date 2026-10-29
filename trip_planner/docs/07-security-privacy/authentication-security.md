# Authentication Security & Session Management

- **Status:** Approved
- **Owner:** Application Security Engineer
- **Last Updated:** 2026-10-29
- **Related Documents:** [`../06-backend-supabase/authentication.md`](../06-backend-supabase/authentication.md), [`secrets-management.md`](secrets-management.md)

---

## 1. Token Security & Cryptographic Invariants

* **Signing Algorithm**: Asymmetric RS256 / SHA-256 JWT signatures.
* **Token Lifetimes**:
  * **Access Token**: Short-lived (60 minutes). Used for all PostgREST and Edge Function requests.
  * **Refresh Token**: Long-lived (30 days) with strict single-use token rotation. If an old refresh token is reused, all tokens for that user session are automatically revoked.

---

## 2. Secure Client-Side Storage

* **Android**: Tokens stored in Android Keystore backed by hardware security module (KeyStore / EncryptedSharedPreferences via `flutter_secure_storage`).
* **iOS**: Tokens stored in the iOS Keychain with `kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly`.
* **Web**: Tokens stored in memory with HTTP-only secure cookie support to mitigate Cross-Site Scripting (XSS) risks.

---

## 3. Account Takeover (ATO) Prevention

* **Brute-Force Protection**: IP and account-level throttling via Kong Gateway (5 failed login attempts triggers a 15-minute temporary lockout).
* **Password Policy**: Minimum 8 characters, requiring at least one numeral, one uppercase letter, and one special symbol. Hashed using Argon2id.
