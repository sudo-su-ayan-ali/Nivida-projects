# Authentication Architecture & Session Lifecycle

- **Status:** Approved
- **Owner:** Security Architect / Lead Backend Engineer
- **Last Updated:** 2026-10-29
- **Related Documents:** [`authorization.md`](authorization.md), [`../07-security-privacy/authentication-security.md`](../07-security-privacy/authentication-security.md)

---

## 1. Authentication Engine: Supabase Auth (GoTrue)

* **Identity Tokens**: Standard asymmetric RS256 / HS256 signed JSON Web Tokens (JWT).
* **Token Expiry**: Short-lived Access Tokens (1 hour), long-lived Refresh Tokens (30 days) stored securely in device hardware keychain (`flutter_secure_storage`).

---

## 2. Supported Auth Providers

1. **Email & Password**: Standard argon2 / bcrypt password hashing. Email verification enforced.
2. **Google OAuth 2.0**: Seamless native sign-in using Google Credential Manager API on Android and ASWebAuthenticationSession on iOS.
3. **Phone OTP (SMS)**: Native Indian mobile number (+91) OTP verification via SMS gateway (Twilio / Exotel) for frictionless pilgrim and driver onboarding.

---

## 3. Profile Auto-Creation Trigger

A database trigger automatically provisions a `profiles` record upon successful sign-up in `auth.users`:

```sql
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, full_name, role)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', 'Traveler'),
    COALESCE(NEW.raw_user_meta_data->>'role', 'traveller')
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
```
