# ADR-0001: Core Architecture & Technology Stack Selection

- **Status:** Approved
- **Decider:** Enterprise Engineering & Architecture Team
- **Date:** 2026-10-28
- **Technical Story:** Selection of the foundational frontend, backend, database, and infrastructure stack for the India-Wide Tourism & Pilgrimage Platform.

---

## 1. Context & Problem Statement

The platform must support high-volume consumer traffic (travellers, pilgrims across India), business portal workflows (hotels, guides, taxi operators), and back-office administrative operations. The system requires cross-platform mobile support (Android/iOS), rapid iteration, strong relational integrity, granular data security (RLS), and support for geospatial queries and AI-driven planning.

---

## 2. Decision & Architecture Components

### Frontend: Flutter & Dart
* **Decision**: Adopt Flutter (v3.x) with Dart for Android, iOS, and responsive management web portals.
* **State Management**: **Riverpod** — Provides compile-time safety, testability, and decoupled business logic.
* **Navigation**: **GoRouter** — Declarative URL-based routing supporting deep linking, auth redirection guards, and responsive web integration.
* **Architecture Style**: Feature-first modular organization (`lib/features/...`, `lib/core/...`, `lib/data/...`).

### Backend & Database: Supabase & PostgreSQL
* **Decision**: Use Supabase as the managed backend platform, anchored on PostgreSQL.
* **Security & Authorization**: Mandatory PostgreSQL **Row-Level Security (RLS)** for all non-public tables. Client calls interact via Supabase Auth JWTs.
* **Geospatial Processing**: **PostGIS** extension for spatial indices, distance calculations, and proximity searches.
* **Privileged Logic & AI Orchestration**: **Supabase Edge Functions** (Deno/TypeScript) for server-side LLM calls, payment webhooks, and administrative actions requiring secret credentials.

### AI & Route Intelligence Layer
* **Decision**: Server-side orchestrated LLM pipeline using structured JSON schemas.
* **Grounding & Validation**: Prompts are grounded with verified destination data fetched from PostgreSQL. Output itineraries are deterministically validated for timing conflicts, travel distances, and budget feasibility before returning to the client.

---

## 3. Options Considered & Trade-offs

| Alternative | Pros | Cons / Reason for Rejection |
| :--- | :--- | :--- |
| **React Native** | Large JS ecosystem | Inconsistent map rendering performance on lower-tier Android devices common in Indian rural/semi-urban areas; Flutter's Skia/Impeller canvas gives consistent UI. |
| **Custom Node/Express microservices** | Maximum custom flexibility | High operational maintenance overhead, deployment complexity, and unnecessary infrastructure costs at early stage. |
| **Firebase / Firestore** | Fast prototyping | NoSQL lacks strict relational integrity, complex join performance for multi-stop circuits, and lacks mature PostGIS geospatial query support. |

---

## 4. Consequences & Follow-up Actions

* **Security**: Zero service-role keys or AI provider secrets will be included in the Flutter app bundle.
* **Migrations**: All database changes must be written as reversible SQL migrations under `supabase/migrations/`.
* **Testing**: Automated RLS tests must be written to verify cross-user isolation.
