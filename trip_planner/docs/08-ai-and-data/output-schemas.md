# AI Output Schemas & JSON Contract Specifications

- **Status:** Approved
- **Owner:** AI Lead / Senior Backend Engineer
- **Last Updated:** 2026-10-29
- **Related Documents:** [`itinerary-generation.md`](itinerary-generation.md), [`itinerary-validation.md`](itinerary-validation.md)

---

## 1. JSON Schema Contract (`ItineraryPlanResponse`)

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "ItineraryPlanResponse",
  "type": "object",
  "properties": {
    "circuit_name": { "type": "string" },
    "total_days": { "type": "integer", "minimum": 1, "maximum": 14 },
    "pacing": { "type": "string", "enum": ["relaxed", "moderate", "active"] },
    "estimated_budget": {
      "type": "object",
      "properties": {
        "currency": { "type": "string", "default": "INR" },
        "stay_estimate": { "type": "number" },
        "transit_estimate": { "type": "number" },
        "meals_estimate": { "type": "number" },
        "activities_estimate": { "type": "number" },
        "total_estimate": { "type": "number" }
      },
      "required": ["currency", "total_estimate"]
    },
    "days": {
      "type": "array",
      "items": {
        "type": "object",
        "properties": {
          "day_number": { "type": "integer" },
          "date_title": { "type": "string" },
          "slots": {
            "type": "array",
            "items": {
              "type": "object",
              "properties": {
                "attraction_id": { "type": "string" },
                "attraction_name": { "type": "string" },
                "start_time": { "type": "string", "pattern": "^[0-2][0-9]:[0-5][0-9]$" },
                "end_time": { "type": "string", "pattern": "^[0-2][0-9]:[0-5][0-9]$" },
                "activity_type": { "type": "string", "enum": ["temple_darshan", "sightseeing", "meal_break", "rest_buffer", "transit"] },
                "notes": { "type": "string" },
                "accessibility_note": { "type": "string" }
              },
              "required": ["attraction_id", "attraction_name", "start_time", "end_time", "activity_type"]
            }
          }
        },
        "required": ["day_number", "slots"]
      }
    }
  },
  "required": ["circuit_name", "total_days", "estimated_budget", "days"]
}
```
