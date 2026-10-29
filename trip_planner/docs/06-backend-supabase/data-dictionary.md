# Data Dictionary & Schema Specifications

- **Status:** Approved
- **Owner:** Data Governance Specialist / Database Engineer
- **Last Updated:** 2026-10-29
- **Related Documents:** [`entity-relationship-diagram.md`](entity-relationship-diagram.md), [`database-architecture.md`](database-architecture.md)

---

## 1. Table: `profiles`
Links directly to Supabase Auth `auth.users` table via foreign key cascade.

| Column | Data Type | Nullable | Constraints & Description |
| :--- | :--- | :---: | :--- |
| `id` | `uuid` | No | Primary Key, references `auth.users(id) ON DELETE CASCADE`. |
| `email` | `text` | No | User login email. |
| `full_name` | `text` | Yes | Display name. |
| `phone` | `text` | Yes | Phone number for OTP / enquiry confirmations. |
| `role` | `text` | No | Default `'traveller'`. Check: `role IN ('traveller', 'pilgrim', 'business_owner', 'content_moderator', 'platform_admin')`. |
| `dietary_preference` | `text` | Yes | Default `'general'`. Check: `IN ('general', 'pure_veg', 'jain', 'satvik')`. |
| `created_at` | `timestamptz`| No | Default `now()`. |

---

## 2. Table: `attractions`
Core entity for physical attractions, temple sanctums, and heritage monuments.

| Column | Data Type | Nullable | Constraints & Description |
| :--- | :--- | :---: | :--- |
| `id` | `uuid` | No | Primary Key, default `gen_random_uuid()`. |
| `destination_id`| `uuid` | No | Foreign Key references `destinations(id) ON DELETE RESTRICT`. |
| `name_en` | `text` | No | Name in English (e.g. "Dilwara Jain Temples"). |
| `name_hi` | `text` | No | Name in Hindi (e.g. "दिलवाड़ा जैन मंदिर"). |
| `name_gu` | `text` | No | Name in Gujarati (e.g. "દેલવાડા જૈન મંદિર"). |
| `coordinates` | `geography` | No | PostGIS `geography(Point, 4326)` coordinate pair. |
| `opening_time` | `time` | Yes | Published opening hour (e.g. `12:00:00`). |
| `closing_time` | `time` | Yes | Published closing hour (e.g. `17:00:00`). |
| `step_count` | `int` | Yes | Number of physical steps required (e.g. `999` for Gabbar Hill). |
| `wheelchair_accessible`| `boolean`| No | Default `false`. |
| `ropeway_available` | `boolean`| No | Default `false`. |
| `doli_available`| `boolean` | No | Default `false`. Indicates palanquin porter availability. |
| `dress_code` | `text` | Yes | Strict guidelines (e.g. "Traditional Indian attire required"). |
| `photography_rules` | `text` | Yes | E.g. "Photography strictly banned inside temple sanctum". |
| `official_portal_url` | `text` | Yes | Authoritative temple trust URL for official pass bookings. |
| `last_verified_at` | `timestamptz` | No | Timestamp of last verified schedule audit. |

---

## 3. Table: `enquiries`
Direct business leads between travelers and local service providers.

| Column | Data Type | Nullable | Constraints & Description |
| :--- | :--- | :---: | :--- |
| `id` | `uuid` | No | Primary Key, default `gen_random_uuid()`. |
| `customer_id` | `uuid` | No | References `profiles(id) ON DELETE CASCADE`. |
| `business_id` | `uuid` | No | References `businesses(id) ON DELETE CASCADE`. |
| `status` | `text` | No | Default `'pending'`. Check: `IN ('pending', 'accepted', 'rejected', 'completed', 'cancelled')`. |
| `trip_date` | `date` | No | Target service / travel date. |
| `passenger_count`| `int` | No | Default `1`. |
| `quote_amount` | `numeric(10,2)`| Yes | Quoted rate in INR submitted by merchant. |
| `customer_confirmed`| `boolean`| No | Default `false`. Unlocks unmasked contact phone. |
| `created_at` | `timestamptz`| No | Default `now()`. |
