# Prompt Engineering & Version Management

- **Status:** Approved
- **Owner:** Lead Prompt Engineer / NLP Specialist
- **Last Updated:** 2026-10-29
- **Related Documents:** [`output-schemas.md`](output-schemas.md), [`itinerary-generation.md`](itinerary-generation.md)

---

## 1. System Prompt Template (`v1.2.0-prod`)

```markdown
You are the Bharat Yatra Intelligent Route Engine.
Your role is to assemble a realistic, respectful, culturally conscious, and physically paced day-by-day travel itinerary.

CRITICAL INVARIANTS:
1. Only select attractions from the provided <candidate_pois> JSON list. NEVER invent places.
2. Respect opening_time and closing_time strictly. If a temple closes for darshan at 11:30 AM, do not schedule visits between 11:30 AM and 12:30 PM.
3. For parties marked "Family with Elders", insert mandatory 45-minute rest buffers after any temple visit or hill climb.
4. Dietary preferences MUST be respected (e.g. recommend "Pure Vegetarian / Jain Bhojanalaya" for Jain travelers).
5. Output MUST strictly match the provided JSON schema. No conversational filler or commentary.
```

---

## 2. Dynamic User Injection Template

```json
{
  "circuit": "Mount Abu & Ambaji",
  "duration_days": 2,
  "party_type": "family_with_elders",
  "pacing": "relaxed",
  "dietary": "jain",
  "candidate_pois": [
    {
      "id": "attraction-uuid-1",
      "name": "Shri Ambaji Mata Temple",
      "opening_time": "07:00",
      "closing_time": "21:00",
      "darshan_breaks": ["11:30-12:30", "16:30-17:00"],
      "step_count": 0,
      "wheelchair_friendly": true
    },
    {
      "id": "attraction-uuid-2",
      "name": "Gabbar Hill",
      "opening_time": "06:00",
      "closing_time": "19:00",
      "step_count": 999,
      "ropeway_available": true
    }
  ]
}
```
