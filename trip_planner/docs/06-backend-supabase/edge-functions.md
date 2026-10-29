# Supabase Edge Functions Architecture (Deno Runtime)

- **Status:** Approved
- **Owner:** Serverless Architect / Backend Engineer
- **Last Updated:** 2026-10-29
- **Related Documents:** [`../04-architecture/backend-architecture.md`](../04-architecture/backend-architecture.md), [`../08-ai-and-data/itinerary-generation.md`](../08-ai-and-data/itinerary-generation.md)

---

## 1. Edge Function Directory & Inventory

```text
supabase/functions/
├── generate-itinerary/             # AI prompt orchestration & deterministic validation
│    ├── index.ts                   # Handler entrypoint & JWT verification
│    ├── prompt-builder.ts          # Grounded context injection from PostgreSQL
│    ├── validator.ts               # Feasibility & opening hours conflict checks
│    └── fallback.ts                # Deterministic circuit templates
│
├── dispatch-enquiry-alert/         # Push & SMS notification dispatch
│    └── index.ts                   # Formats lead payload & calls FCM/Twilio
│
└── audit-logger/                   # Privileged security and admin audit events
     └── index.ts                   # Writes to immutable audit_events table
```

---

## 2. Standard Handler Structure (`generate-itinerary`)

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

serve(async (req: Request) => {
  // CORS check
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  try {
    const supabase = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_ANON_KEY") ?? "",
      { global: { headers: { Authorization: req.headers.get("Authorization")! } } }
    );

    const { destinationId, durationDays, partyType, pacing, dietary } = await req.json();

    // 1. Fetch grounded destination context from DB
    const { data: pois } = await supabase.from("attractions").select("*").eq("destination_id", destinationId);

    // 2. Synthesize with LLM via private API key
    // 3. Execute deterministic validation checks
    // 4. Return validated JSON

    return new Response(JSON.stringify(validatedResult), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 200,
    });
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 500,
    });
  }
});
```
