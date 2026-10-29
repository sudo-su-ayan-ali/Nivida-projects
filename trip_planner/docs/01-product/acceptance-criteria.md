# Acceptance Criteria & Testing Gates

- **Status:** Approved
- **Owner:** QA Lead / Product Manager
- **Last Updated:** 2026-10-29
- **Related Documents:** [`user-stories.md`](user-stories.md), [`../00-governance/definition-of-done.md`](../00-governance/definition-of-done.md)

---

## Story Acceptance Criteria (Gherkin Syntax)

### US-DISC-01: Verified Temple Timings & Schedules
```gherkin
Scenario: Viewing Ambaji Temple timings with verified timestamp
  Given a user navigates to the "Ambaji Mata Temple" destination screen
  Then the system displays the morning Mangla Aarti, Afternoon Darshan, and Sandhya Aarti times
  And displays the "Last Verified On" date and source attribution ("Official Temple Trust")
  And if the current time falls during a scheduled temple closure/bhog break
  Then an alert badge displays "Currently Closed for Darshan - Reopens at [Time]"
```

### US-PLAN-01 & US-PLAN-02: AI Itinerary Generation & Validation
```gherkin
Scenario: Generating a 2-day Mount Abu and Ambaji itinerary for senior citizens
  Given a user enters Destination="Mount Abu & Ambaji", Duration="2 Days", Pacing="Relaxed", Party="Family with Elders"
  When the user submits the request
  Then the server-side validation checks each proposed stop against physical opening hours
  And verifies that high-step attractions (e.g. Guru Shikhar summit) include palanquin/doli or rest buffer warnings
  And returns a structured schedule in < 4.5 seconds
  And clearly tags all cost estimates with "Estimated Budget - Subject to Local Variation"
```

```gherkin
Scenario: AI LLM Provider Timeout or Failure
  Given the server-side LLM provider encounters a 504 timeout or quota limit
  When the user requests an itinerary
  Then the system immediately catches the exception
  And returns the pre-compiled deterministic "Curated Mount Abu - Ambaji Heritage Circuit"
  And displays an informational banner: "Generated using Bharat Yatra verified circuit template"
  And zero application crash or unhandled error occurs
```

### US-BIZ-02 & US-BIZ-05: Direct Business Enquiry & Privacy Masking
```gherkin
Scenario: Submitting an enquiry to a local Mount Abu taxi operator
  Given an authenticated user is on "Vikram Solanki - Mount Abu Cabs" profile
  When the user fills check-in date, passenger count="4", and clicks "Send Enquiry"
  Then the business owner receives an instant enquiry notification
  And the user's raw phone number remains masked as "XXXX-XX-1234" in the business inbox
  Until the business accepts the enquiry and initiates mutual communication
  And PostgreSQL RLS strictly prevents any other business from viewing this enquiry record
```

### US-DISC-04: Non-Affiliation and Official Trust Redirection
```gherkin
Scenario: Devotee clicks link to book Ambaji Aarti pass
  Given a user views the ritual details for "Special Aarti Pass"
  When the user clicks "Book via Official Trust"
  Then the app opens the authorized external URL in an in-app secure browser view
  And displays a non-affiliation notice: "Redirecting to Shri Arasuri Ambaji Mata Devasthan Trust official portal. Bharat Yatra does not charge fees or issue official passes directly."
```
