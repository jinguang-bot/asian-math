# Asiamath API Spec V2.1

> Status: Draft V2.1  
> Purpose: define the **interface contract that should actually be developed in the current phase**, aligned with the latest MVP / Design specifications.  
> Scope: covers the **main MVP closed loop**: M1-lite, M2-lite, M4-lite, M7-lite, the shared application/review/decision backbone, Applicant Dashboard, and post-visit report.  
> Principle: **Demo and MVP share the same contract**; database and implementation details may be phased in, but the fields, statuses, and permission semantics used for frontend-backend integration should follow this file.
> Canonical note: this English version is the canonical V2.1 API spec for current frontend-backend integration.

---

## 1. Relationship to Other Documents

- `docs/reference/asiamath_system_map.html`: the master baseline for module boundaries and inter-module relationships
- `docs/product/asiamath-mvp-prd-v3.2.md`: MVP scope, canonical statuses, M2-M7 dependency rules, and minimum permission/COI rules
- `docs/specs/asiamath-design-spec-v2.1.md`: shared IA, routes, page modes, object ownership, and viewer-safe status rules
- `docs/specs/asiamath-technical-spec-v2.1.md`: system boundaries, implementation principles, and service decomposition
- `docs/specs/asiamath-database-schema-v1.1.md` / `database/ddl/asiamath-database-ddl-v1.1.sql`: conceptual model and physical table design
- **`docs/specs/asiamath-api-spec-v2.1.md`**: the canonical file for current frontend-backend integration

### 1.1 Key Alignment Issues This Version Resolves

1. **Keep product ownership of M2 / M7 clear**  
   conference opportunity / conference application still belong to **M2-lite**; grant opportunity / travel grant application still belong to **M7-lite**. The shared application/review/decision layer is only implementation-level reuse and does not absorb M2/M7 into M3.

2. **M4 is not just an applicant profile**  
   In addition to “my profile,” the current contract must also support:
   - public scholar profile
   - reviewer candidate sourcing
   - basic conflict-aware review assignment
   - admin seed reviewer / scholar profile

3. **Conference application and grant application must be two separate records**  
   They may be linked, but they cannot be merged into a single application, nor can they share a single decision record.

4. **Application status and final result must be separated**  
   - `application.status` expresses only workflow state
   - `decision.final_status` expresses the final result
   - `decision.release_status` expresses whether the result is visible to the applicant

5. **The applicant side must use a viewer-safe contract**  
   Applicants must not be able to see internal unreleased decisions through `/me/*` endpoints.

---

## 2. Key Revisions in V2.1 Compared with V2

### 2.1 `application.status` Reverts to Canonical Workflow State
In V2, `application_status` mixed in:
- `accepted`
- `rejected`
- `waitlisted`

This mixes “workflow state” with “final result.”  
V2.1 standardizes it as:

- `draft`
- `submitted`
- `under_review`
- `decided`

The final result is uniformly stored in `decision.final_status`.

### 2.2 Adds Formal `decision.release_status`
V2 only had internal decisions, without an applicant-facing release gate.  
V2.1 adds:

- `decision.release_status`
- `decision.released_at`
- `POST /organizer/applications/:id/release-decision`

This is needed to support:
- organizers deciding results internally first
- applicants seeing results only after they are released

### 2.3 Travel Grant Changes from “Not Specified in Detail API” to Officially In Scope
V2 placed `standalone Travel Grants endpoints` out of scope.  
V2.1 formally includes:

- public grants list / detail
- organizer grant management
- grant application create / update / submit
- grant application list / detail
- post-visit report

### 2.4 Applicant Dashboard Becomes a Typed List Contract
`GET /me/applications` no longer returns only conference applications.  
In V2.1 it needs to return:
- `application_type`
- `source_module`
- `source_title`
- `viewer_status`
- `released_decision`
- `next_action`

to support separate records on the dashboard.

### 2.5 `needs_travel_support` Changes to the Weaker-Semantics `interested_in_travel_support`
It is acceptable to keep a lightweight field in the conference application, but it must not be misunderstood as the grant application itself.  
Therefore V2.1 uses:

- `interested_in_travel_support`

and explicitly states:

> This field does not create a grant record and does not replace the independent M7 application.

### 2.6 COI Contract Converges from Raw DB Style to Stable Frontend Semantics
V2 exposed:
- `conflict_check_status`
- `conflict_override_reason`

V2.1 exposes to the frontend in a unified way as:
- `conflict_state = clear | flagged`
- `conflict_note`

If the underlying database still uses old field names, mapping may be done in the service layer; the frontend contract should follow V2.1.

### 2.7 Adds M4-Backed Reviewer Sourcing
New additions:
- public scholar profile endpoint
- organizer reviewer candidates endpoint
- minimal admin profile seeding endpoint

---

## 3. Base Rules

### 3.1 Base URL
`/api/v1`

### 3.2 ID Rule
All resource IDs are currently treated as UUID strings.

### 3.3 Time Rule
All time fields use UTC ISO-8601 strings, for example:

`2026-04-18T08:00:00Z`

### 3.4 Success Response Format
```json
{
  "data": {},
  "meta": {}
}
```

### 3.5 Error Response Format
```json
{
  "error": {
    "code": "INVALID_INPUT",
    "message": "Validation failed",
    "details": {
      "field": "email"
    }
  }
}
```

### 3.6 Recommended Common Error Codes
- `UNAUTHENTICATED`
- `FORBIDDEN`
- `NOT_FOUND`
- `INVALID_INPUT`
- `CONFLICT`
- `UNPROCESSABLE_STATE`

### 3.7 Viewer-Safe Contract Rules
For applicant-facing endpoints:

- Do not return internal content of unreleased decisions
- Do not expose “internal decision already exists” in an applicant-visible way
- Use `viewer_status` + `released_decision` to express the applicant’s current visible state

For organizer / reviewer / admin endpoints:

- May return internal `application.status = decided`
- May return `decision.release_status = unreleased`

### 3.8 Demo / MVP Consistency
The frontend should always call the same interface:

- Demo: the mock provider returns the same field structure
- MVP: the real backend returns the same field structure

The frontend should not know:
- whether the data comes from mock or real sources
- whether future modules have been fully implemented in the backend

### 3.9 Union Object Rules
When an endpoint can return either a conference application or a grant application:

- `application_type` must be returned
- `source_module` must be returned
- type-specific fields must be returned
- the frontend must not assume all application structures are exactly the same

---

## 4. Permission Semantics

### 4.1 `public`
No login required.

### 4.2 `authenticated`
Any authenticated user.

### 4.3 `admin`
Global `admin` only.

### 4.4 `organizer_or_admin`
Any of the following conditions is sufficient:
- global `organizer`
- global `admin`

Mainly used for entry points that create the first managed object, such as creating a conference.

### 4.5 `conference_staff_or_admin`
Any of the following conditions is sufficient:
- global `admin`
- a `conference_staff` member of the conference, with `staff_role in ('owner', 'organizer')`

### 4.6 `grant_manager_or_admin`
Any of the following conditions is sufficient:
- global `admin`
- a `conference_staff` member of the conference referenced by the grant’s `linked_conference_id`, with `staff_role in ('owner', 'organizer')`

### 4.7 `application_manager_or_admin`
Determined dynamically by application type:
- if `application_type = conference_application`, require `conference_staff_or_admin`
- if `application_type = grant_application`, require `grant_manager_or_admin`
- global `admin` always has access

### 4.8 `assigned_reviewer_or_admin`
Any of the following conditions is sufficient:
- global `admin`
- the `review_assignment.reviewer_user_id = current_user.id`

### 4.9 `application_owner`
Any of the following conditions is sufficient:
- `application.applicant_user_id = current_user.id`
- global `admin` (for troubleshooting or operational fixes only, not as the normal applicant view)

### 4.10 M4 Expert Source Rules
- a user assigned as reviewer must have a corresponding M4 profile record
- organizers should obtain reviewer candidates through an M4-backed endpoint
- conflict-flagged assignments cannot submit reviews

---

## 5. Core Objects (API Representation)

## 5.1 User
```json
{
  "id": "5d37402f-f9fd-458c-8126-868f5503a005",
  "email": "alice@example.org",
  "status": "active",
  "roles": ["applicant", "reviewer"],
  "primary_role": "applicant",
  "conference_staff_memberships": [
    {
      "conference_id": "04cb9d06-8c49-4cf6-8948-d66c17b0c505",
      "staff_role": "owner"
    }
  ],
  "created_at": "2026-04-14T10:00:00Z",
  "last_login_at": "2026-04-14T10:05:00Z"
}
```

## 5.2 ScholarProfile（authenticated / internal shape）
```json
{
  "user_id": "5d37402f-f9fd-458c-8126-868f5503a005",
  "slug": "alice-chen",
  "full_name": "Alice Chen",
  "title": "Dr",
  "institution_id": null,
  "institution_name_raw": "National University of Singapore",
  "country_code": "SG",
  "career_stage": "phd",
  "bio": "Interested in algebraic geometry.",
  "personal_website": null,
  "research_keywords": ["algebraic geometry", "birational geometry"],
  "msc_codes": [
    {"code": "14J60", "is_primary": true}
  ],
  "orcid_id": null,
  "coi_declaration_text": "",
  "is_profile_public": true,
  "verification_status": "unverified",
  "verified_at": null,
  "updated_at": "2026-04-14T10:06:00Z"
}
```

#### Notes
- the current contract intentionally keeps the existing storage-facing field names for stability
- product/UI wording may map these fields as:
  - `institution_name_raw` -> affiliation
  - `title` -> position label placeholder
  - `research_keywords` -> keywords
  - `personal_website` -> personal page URL
  - `orcid_id` -> ORCID identifier / link placeholder

## 5.3 PublicScholarProfile
```json
{
  "slug": "alice-chen",
  "full_name": "Alice Chen",
  "title": "Dr",
  "institution_name_raw": "National University of Singapore",
  "country_code": "SG",
  "career_stage": "phd",
  "bio": "Interested in algebraic geometry.",
  "personal_website": null,
  "research_keywords": ["algebraic geometry", "birational geometry"],
  "msc_codes": [
    {"code": "14J60", "is_primary": true}
  ],
  "orcid_id": null,
  "updated_at": "2026-04-14T10:06:00Z"
}
```

## 5.4 Conference
```json
{
  "id": "04cb9d06-8c49-4cf6-8948-d66c17b0c505",
  "slug": "asiamath-2026-workshop",
  "title": "Asiamath 2026 Workshop",
  "short_name": "AM2026",
  "location_text": "Singapore",
  "start_date": "2026-08-10",
  "end_date": "2026-08-14",
  "description": "A regional workshop for young researchers.",
  "application_deadline": "2026-05-31T23:59:59Z",
  "status": "published",
  "published_at": "2026-04-20T10:00:00Z",
  "is_application_open": true,
  "related_grants": [
    {
      "id": "c5ca505a-7302-4cef-a393-536a64525d1d",
      "slug": "asiamath-2026-travel-grant",
      "title": "Asiamath 2026 Travel Grant",
      "grant_type": "conference_travel_grant",
      "application_deadline": "2026-06-05T23:59:59Z",
      "status": "published",
      "report_required": true,
      "is_application_open": true
    }
  ]
}
```

## 5.5 GrantOpportunity
```json
{
  "id": "c5ca505a-7302-4cef-a393-536a64525d1d",
  "slug": "asiamath-2026-travel-grant",
  "title": "Asiamath 2026 Travel Grant",
  "grant_type": "conference_travel_grant",
  "linked_conference_id": "04cb9d06-8c49-4cf6-8948-d66c17b0c505",
  "description": "Partial travel support for invited or accepted participants.",
  "eligibility_summary": "Open to eligible applicants attending Asiamath 2026 Workshop.",
  "coverage_summary": "Partial airfare and accommodation support.",
  "application_deadline": "2026-06-05T23:59:59Z",
  "status": "published",
  "report_required": true,
  "published_at": "2026-04-22T12:00:00Z",
  "is_application_open": true
}
```

## 5.6 ApplicantApplicationSummaryItem（dashboard / viewer-safe）
```json
{
  "id": "7301eb65-c8af-4f69-92ee-1304f2e2f8f0",
  "application_type": "conference_application",
  "source_module": "M2",
  "source_id": "04cb9d06-8c49-4cf6-8948-d66c17b0c505",
  "source_title": "Asiamath 2026 Workshop",
  "linked_conference_title": null,
  "viewer_status": "under_review",
  "submitted_at": "2026-04-14T10:10:00Z",
  "released_decision": null,
  "next_action": "view_submission",
  "post_visit_report_status": null
}
```

When a grant has been released and requires a report, the summary item may be:

```json
{
  "id": "94a69a4f-0b18-420c-a99a-3fa8ef6d7a1a",
  "application_type": "grant_application",
  "source_module": "M7",
  "source_id": "c5ca505a-7302-4cef-a393-536a64525d1d",
  "source_title": "Asiamath 2026 Travel Grant",
  "linked_conference_title": "Asiamath 2026 Workshop",
  "viewer_status": "result_released",
  "submitted_at": "2026-04-16T09:00:00Z",
  "released_decision": {
    "decision_kind": "travel_grant",
    "final_status": "accepted",
    "display_label": "Awarded",
    "released_at": "2026-05-02T12:00:00Z"
  },
  "next_action": "submit_post_visit_report",
  "post_visit_report_status": "not_started"
}
```

## 5.7 ConferenceApplication（internal / organizer-facing shape）
```json
{
  "id": "7301eb65-c8af-4f69-92ee-1304f2e2f8f0",
  "application_type": "conference_application",
  "source_module": "M2",
  "conference_id": "04cb9d06-8c49-4cf6-8948-d66c17b0c505",
  "conference_title": "Asiamath 2026 Workshop",
  "applicant_user_id": "5d37402f-f9fd-458c-8126-868f5503a005",
  "status": "submitted",
  "participation_type": "talk",
  "statement": "I would like to participate...",
  "abstract_title": "A note on ...",
  "abstract_text": "This talk discusses ...",
  "interested_in_travel_support": true,
  "extra_answers": {},
  "applicant_profile_snapshot": {
    "full_name": "Alice Chen",
    "institution_name_raw": "National University of Singapore",
    "country_code": "SG",
    "career_stage": "phd",
    "research_keywords": ["algebraic geometry"]
  },
  "files": [
    {
      "id": "8d1ea0e2-66c9-497c-9d7d-35b8b6ed4e76",
      "file_role": "cv",
      "original_name": "cv.pdf"
    }
  ],
  "submitted_at": "2026-04-14T10:10:00Z",
  "decided_at": null,
  "decision": null,
  "created_at": "2026-04-14T10:07:00Z",
  "updated_at": "2026-04-14T10:10:00Z"
}
```

## 5.8 GrantApplication（internal / organizer-facing shape）
```json
{
  "id": "94a69a4f-0b18-420c-a99a-3fa8ef6d7a1a",
  "application_type": "grant_application",
  "source_module": "M7",
  "grant_id": "c5ca505a-7302-4cef-a393-536a64525d1d",
  "grant_title": "Asiamath 2026 Travel Grant",
  "linked_conference_id": "04cb9d06-8c49-4cf6-8948-d66c17b0c505",
  "linked_conference_application_id": "7301eb65-c8af-4f69-92ee-1304f2e2f8f0",
  "applicant_user_id": "5d37402f-f9fd-458c-8126-868f5503a005",
  "status": "under_review",
  "statement": "I am requesting travel support to attend the workshop.",
  "travel_plan_summary": "Round trip from Singapore to Seoul with 4 nights lodging.",
  "funding_need_summary": "Airfare support requested; accommodation partially self-funded.",
  "extra_answers": {},
  "applicant_profile_snapshot": {
    "full_name": "Alice Chen",
    "institution_name_raw": "National University of Singapore",
    "country_code": "SG",
    "career_stage": "phd",
    "research_keywords": ["algebraic geometry"]
  },
  "files": [
    {
      "id": "12946f3e-29de-41d6-8a4a-f9d8f6dd3ae9",
      "file_role": "supporting_document",
      "original_name": "budget.pdf"
    }
  ],
  "submitted_at": "2026-04-16T09:00:00Z",
  "decided_at": null,
  "decision": null,
  "post_visit_report_status": null,
  "created_at": "2026-04-16T08:50:00Z",
  "updated_at": "2026-04-16T09:00:00Z"
}
```

## 5.9 ReviewAssignment
```json
{
  "id": "cf01413f-c37c-4306-9358-97d7c0e00d5c",
  "application_id": "7301eb65-c8af-4f69-92ee-1304f2e2f8f0",
  "application_type": "conference_application",
  "reviewer_user_id": "e4947750-4820-4f0c-bf4a-d14f717883ec",
  "assigned_by_user_id": "af4d98da-6870-4c0f-9cf5-38ce9330127d",
  "status": "assigned",
  "conflict_state": "clear",
  "conflict_note": null,
  "due_at": "2026-05-10T23:59:59Z",
  "assigned_at": "2026-04-15T09:00:00Z",
  "completed_at": null
}
```

## 5.10 Review
```json
{
  "id": "0ddbf60d-7112-479c-becd-3018f05fec21",
  "assignment_id": "cf01413f-c37c-4306-9358-97d7c0e00d5c",
  "score": 4,
  "recommendation": "accept",
  "comment": "Strong application.",
  "submitted_at": "2026-04-16T12:00:00Z"
}
```

## 5.11 Decision
```json
{
  "id": "63274d3c-dcff-41d0-a0e7-fb6f0887fb0d",
  "application_id": "7301eb65-c8af-4f69-92ee-1304f2e2f8f0",
  "application_type": "conference_application",
  "decision_kind": "conference_admission",
  "final_status": "accepted",
  "release_status": "unreleased",
  "note_internal": "Priority candidate",
  "note_external": "We are pleased to inform you that your application has been accepted.",
  "decided_by_user_id": "af4d98da-6870-4c0f-9cf5-38ce9330127d",
  "decided_at": "2026-04-18T08:00:00Z",
  "released_at": null
}
```

#### Notes
- this object is application-based in the current MVP contract
- it represents the formal result for one conference application or one grant application
- it is not intended to act as a universal cross-module decision object for unrelated future modules

## 5.12 PostVisitReport
```json
{
  "id": "5f281dc0-b9da-440f-8d9b-a6db3fc8db6b",
  "grant_application_id": "94a69a4f-0b18-420c-a99a-3fa8ef6d7a1a",
  "status": "submitted",
  "title": "Travel report for Asiamath 2026 Workshop",
  "report_text": "The travel grant enabled participation in the workshop...",
  "files": [
    {
      "id": "279d7f31-9e97-41c8-8d81-46449d530b6f",
      "file_role": "post_visit_report_attachment",
      "original_name": "report-appendix.pdf"
    }
  ],
  "submitted_at": "2026-08-25T10:00:00Z",
  "updated_at": "2026-08-25T10:00:00Z"
}
```

## 5.13 FileAsset
```json
{
  "id": "8d1ea0e2-66c9-497c-9d7d-35b8b6ed4e76",
  "owner_user_id": "5d37402f-f9fd-458c-8126-868f5503a005",
  "file_role": "cv",
  "visibility": "private",
  "original_name": "cv.pdf",
  "mime_type": "application/pdf",
  "size_bytes": 120344,
  "uploaded_at": "2026-04-14T10:05:00Z",
  "deleted_at": null
}
```

---

## 6. Enums (Currently Shared by Frontend and Backend)

### 6.1 `user_status`
- `active`
- `inactive`
- `suspended`

### 6.2 `user_role`
- `applicant`
- `reviewer`
- `organizer`
- `admin`

#### Notes
- `Visitor` is an unauthenticated product/viewer state and is not persisted as a `user_role`

### 6.3 `conference_staff_role`
- `owner`
- `organizer`

### 6.4 `profile_verification_status`
- `unverified`
- `pending_review`
- `verified`
- `rejected`

### 6.5 `conference_status`
- `draft`
- `published`
- `closed`

### 6.6 `grant_opportunity_status`
- `draft`
- `published`
- `closed`

### 6.7 `grant_type`
- `conference_travel_grant`

### 6.8 `application_type`
- `conference_application`
- `grant_application`

### 6.9 `application_status`
- `draft`
- `submitted`
- `under_review`
- `decided`

### 6.10 `applicant_viewer_status`
- `draft`
- `submitted`
- `under_review`
- `result_released`

### 6.11 `participation_type`
- `attendee`
- `talk`
- `poster`

### 6.12 `review_assignment_status`
- `assigned`
- `review_submitted`
- `cancelled`

### 6.13 `review_recommendation`
- `accept`
- `reject`
- `waitlist`

### 6.14 `decision_kind`
- `conference_admission`
- `travel_grant`

### 6.15 `decision_final_status`
- `accepted`
- `rejected`
- `waitlisted`

### 6.16 `decision_release_status`
- `unreleased`
- `released`

### 6.17 `conflict_state`
- `clear`
- `flagged`

### 6.18 `post_visit_report_status`
- `not_started`
- `submitted`

### 6.19 `next_action`
- `continue_draft`
- `view_submission`
- `view_result`
- `submit_post_visit_report`
- `view_report`

### 6.20 `file_role`
- `cv`
- `abstract_attachment`
- `supporting_document`
- `post_visit_report_attachment`

---

## 7. Endpoint Details

## 7.1 Auth

### 7.1.1 Register
**POST** `/api/v1/auth/register`  
Auth: `public`

#### Request
```json
{
  "email": "alice@example.org",
  "password": "strong-password",
  "full_name": "Alice Chen"
}
```

#### Side Effects
- Create `users`
- Create `user_roles`: `applicant`, with `is_primary = true`
- Create the initial `profiles` record

#### Response
```json
{
  "data": {
    "user": {
      "id": "5d37402f-f9fd-458c-8126-868f5503a005",
      "email": "alice@example.org",
      "status": "active",
      "roles": ["applicant"],
      "primary_role": "applicant",
      "conference_staff_memberships": [],
      "created_at": "2026-04-14T10:00:00Z",
      "last_login_at": null
    }
  }
}
```

---

### 7.1.2 Login
**POST** `/api/v1/auth/login`  
Auth: `public`

#### Request
```json
{
  "email": "alice@example.org",
  "password": "strong-password"
}
```

#### Response
```json
{
  "data": {
    "user": {
      "id": "5d37402f-f9fd-458c-8126-868f5503a005",
      "email": "alice@example.org",
      "status": "active",
      "roles": ["applicant", "reviewer"],
      "primary_role": "applicant",
      "conference_staff_memberships": [
        {
          "conference_id": "04cb9d06-8c49-4cf6-8948-d66c17b0c505",
          "staff_role": "owner"
        }
      ],
      "created_at": "2026-04-14T10:00:00Z",
      "last_login_at": "2026-04-14T10:05:00Z"
    }
  }
}
```

---

### 7.1.3 Logout
**POST** `/api/v1/auth/logout`  
Auth: `authenticated`

#### Request
```json
{}
```

#### Response
```json
{
  "data": {
    "success": true
  }
}
```

---

### 7.1.4 Me
**GET** `/api/v1/auth/me`  
Auth: `authenticated`

#### Response
```json
{
  "data": {
    "user": {
      "id": "5d37402f-f9fd-458c-8126-868f5503a005",
      "email": "alice@example.org",
      "status": "active",
      "roles": ["applicant", "reviewer"],
      "primary_role": "applicant",
      "conference_staff_memberships": [
        {
          "conference_id": "04cb9d06-8c49-4cf6-8948-d66c17b0c505",
          "staff_role": "owner"
        }
      ],
      "created_at": "2026-04-14T10:00:00Z",
      "last_login_at": "2026-04-14T10:05:00Z"
    }
  }
}
```

---

## 7.2 Scholar Profiles / M4-lite

### 7.2.1 Get My Profile
**GET** `/api/v1/profile/me`  
Auth: `authenticated`

#### Response
```json
{
  "data": {
    "profile": {
      "user_id": "5d37402f-f9fd-458c-8126-868f5503a005",
      "slug": "alice-chen",
      "full_name": "Alice Chen",
      "title": null,
      "institution_id": null,
      "institution_name_raw": "National University of Singapore",
      "country_code": "SG",
      "career_stage": "phd",
      "bio": "Interested in algebraic geometry.",
      "personal_website": null,
      "research_keywords": ["algebraic geometry", "birational geometry"],
      "msc_codes": [
        {"code": "14J60", "is_primary": true}
      ],
      "orcid_id": null,
      "coi_declaration_text": "",
      "is_profile_public": true,
      "verification_status": "unverified",
      "verified_at": null,
      "updated_at": "2026-04-14T10:06:00Z"
    }
  }
}
```

---

### 7.2.2 Update My Profile
**PUT** `/api/v1/profile/me`  
Auth: `authenticated`

#### Request
```json
{
  "full_name": "Alice Chen",
  "title": null,
  "institution_id": null,
  "institution_name_raw": "National University of Singapore",
  "country_code": "SG",
  "career_stage": "phd",
  "bio": "Interested in algebraic geometry.",
  "personal_website": null,
  "research_keywords": ["algebraic geometry", "birational geometry"],
  "msc_codes": [
    {"code": "14J60", "is_primary": true}
  ],
  "orcid_id": null,
  "coi_declaration_text": "",
  "is_profile_public": true
}
```

#### Required
- `full_name`
- `institution_name_raw` or `institution_id`
- `country_code`
- `career_stage`

#### Response
```json
{
  "data": {
    "profile": {
      "user_id": "5d37402f-f9fd-458c-8126-868f5503a005",
      "slug": "alice-chen",
      "full_name": "Alice Chen",
      "title": null,
      "institution_id": null,
      "institution_name_raw": "National University of Singapore",
      "country_code": "SG",
      "career_stage": "phd",
      "bio": "Interested in algebraic geometry.",
      "personal_website": null,
      "research_keywords": ["algebraic geometry", "birational geometry"],
      "msc_codes": [
        {"code": "14J60", "is_primary": true}
      ],
      "orcid_id": null,
      "coi_declaration_text": "",
      "is_profile_public": true,
      "verification_status": "unverified",
      "verified_at": null,
      "updated_at": "2026-04-14T10:06:00Z"
    }
  }
}
```

---

### 7.2.3 Public Scholar Profile
**GET** `/api/v1/scholars/:slug`  
Auth: `public`

#### Response
```json
{
  "data": {
    "profile": {
      "slug": "alice-chen",
      "full_name": "Alice Chen",
      "title": "Dr",
      "institution_name_raw": "National University of Singapore",
      "country_code": "SG",
      "career_stage": "phd",
      "bio": "Interested in algebraic geometry.",
      "personal_website": null,
      "research_keywords": ["algebraic geometry", "birational geometry"],
      "msc_codes": [
        {"code": "14J60", "is_primary": true}
      ],
      "orcid_id": null,
      "updated_at": "2026-04-14T10:06:00Z"
    }
  }
}
```

#### Notes
- Visible to visitors only when `is_profile_public = true`
- Internal fields such as email and COI text are not exposed to the public

---

### 7.2.4 Reviewer Candidates for an Application
**GET** `/api/v1/organizer/applications/:id/reviewer-candidates`  
Auth: `application_manager_or_admin`

#### Query Params
- `q`
- `page`
- `page_size`

#### Response
```json
{
  "data": {
    "items": [
      {
        "user_id": "e4947750-4820-4f0c-bf4a-d14f717883ec",
        "profile_slug": "bob-smith",
        "full_name": "Prof. Bob Smith",
        "institution_name_raw": "University of Tokyo",
        "research_keywords": ["algebraic geometry", "moduli"],
        "msc_codes": [
          {"code": "14D20", "is_primary": true}
        ],
        "eligible_for_review": true
      }
    ]
  },
  "meta": {
    "page": 1,
    "page_size": 20,
    "total": 1
  }
}
```

#### Notes
- This endpoint provides the M4-backed reviewer source
- Basic COI determination is still explicitly written into `conflict_state` at the assignment stage
- Reviewers without an M4 profile should not appear in the candidate list

---

### 7.2.5 Admin Seed Scholar / Reviewer Profile
**POST** `/api/v1/admin/profiles/seed`  
Auth: `admin`

#### Request
```json
{
  "email": "bob@example.org",
  "full_name": "Prof. Bob Smith",
  "roles_to_add": ["reviewer"],
  "title": "Professor",
  "institution_name_raw": "University of Tokyo",
  "country_code": "JP",
  "career_stage": "faculty",
  "research_keywords": ["algebraic geometry", "moduli"],
  "msc_codes": [
    {"code": "14D20", "is_primary": true}
  ],
  "is_profile_public": false
}
```

#### Response
```json
{
  "data": {
    "user": {
      "id": "e4947750-4820-4f0c-bf4a-d14f717883ec",
      "email": "bob@example.org",
      "status": "active",
      "roles": ["reviewer"],
      "primary_role": "reviewer",
      "conference_staff_memberships": [],
      "created_at": "2026-04-14T09:00:00Z",
      "last_login_at": null
    },
    "profile": {
      "user_id": "e4947750-4820-4f0c-bf4a-d14f717883ec",
      "slug": "bob-smith",
      "full_name": "Prof. Bob Smith",
      "institution_name_raw": "University of Tokyo",
      "country_code": "JP",
      "career_stage": "faculty",
      "research_keywords": ["algebraic geometry", "moduli"],
      "msc_codes": [
        {"code": "14D20", "is_primary": true}
      ],
      "is_profile_public": false,
      "verification_status": "unverified",
      "updated_at": "2026-04-14T09:00:00Z"
    }
  }
}
```

---

## 7.3 Public Conferences and Grants

### 7.3.1 Conference List
**GET** `/api/v1/conferences`  
Auth: `public`

#### Query Params
- `status` (default `published`)
- `q`
- `page`
- `page_size`

#### Response
```json
{
  "data": {
    "items": [
      {
        "id": "04cb9d06-8c49-4cf6-8948-d66c17b0c505",
        "slug": "asiamath-2026-workshop",
        "title": "Asiamath 2026 Workshop",
        "short_name": "AM2026",
        "location_text": "Singapore",
        "start_date": "2026-08-10",
        "end_date": "2026-08-14",
        "application_deadline": "2026-05-31T23:59:59Z",
        "status": "published",
        "is_application_open": true,
        "related_grant_count": 1
      }
    ]
  },
  "meta": {
    "page": 1,
    "page_size": 20,
    "total": 1
  }
}
```

---

### 7.3.2 Conference Detail
**GET** `/api/v1/conferences/:slug`  
Auth: `public`

#### Response
```json
{
  "data": {
    "conference": {
      "id": "04cb9d06-8c49-4cf6-8948-d66c17b0c505",
      "slug": "asiamath-2026-workshop",
      "title": "Asiamath 2026 Workshop",
      "short_name": "AM2026",
      "location_text": "Singapore",
      "start_date": "2026-08-10",
      "end_date": "2026-08-14",
      "description": "A regional workshop for young researchers.",
      "application_deadline": "2026-05-31T23:59:59Z",
      "status": "published",
      "published_at": "2026-04-20T10:00:00Z",
      "is_application_open": true,
      "related_grants": [
        {
          "id": "c5ca505a-7302-4cef-a393-536a64525d1d",
          "slug": "asiamath-2026-travel-grant",
          "title": "Asiamath 2026 Travel Grant",
          "grant_type": "conference_travel_grant",
          "application_deadline": "2026-06-05T23:59:59Z",
          "status": "published",
          "report_required": true,
          "is_application_open": true
        }
      ]
    }
  }
}
```

---

### 7.3.3 Conference Application Form
**GET** `/api/v1/conferences/:id/application-form`  
Auth: `public`

#### Response
```json
{
  "data": {
    "conference_id": "04cb9d06-8c49-4cf6-8948-d66c17b0c505",
    "schema": {
      "fields": [
        {"key": "participation_type", "type": "select", "required": true},
        {"key": "statement", "type": "textarea", "required": true},
        {"key": "abstract_title", "type": "text", "required": false},
        {"key": "abstract_text", "type": "textarea", "required": false},
        {"key": "interested_in_travel_support", "type": "checkbox", "required": false}
      ]
    }
  }
}
```

#### Notes
- At the current stage, fixed core fields remain primary
- `schema` is mainly used for dynamic frontend rendering and Demo/mock consistency
- `interested_in_travel_support` is only an intent field and will not automatically create a grant application

---

### 7.3.4 Grant List
**GET** `/api/v1/grants`  
Auth: `public`

#### Query Params
- `status` (default `published`)
- `q`
- `linked_conference_id`
- `page`
- `page_size`

#### Response
```json
{
  "data": {
    "items": [
      {
        "id": "c5ca505a-7302-4cef-a393-536a64525d1d",
        "slug": "asiamath-2026-travel-grant",
        "title": "Asiamath 2026 Travel Grant",
        "grant_type": "conference_travel_grant",
        "linked_conference_title": "Asiamath 2026 Workshop",
        "application_deadline": "2026-06-05T23:59:59Z",
        "status": "published",
        "report_required": true,
        "is_application_open": true
      }
    ]
  },
  "meta": {
    "page": 1,
    "page_size": 20,
    "total": 1
  }
}
```

---

### 7.3.5 Grant Detail
**GET** `/api/v1/grants/:slug`  
Auth: `public`

#### Response
```json
{
  "data": {
    "grant": {
      "id": "c5ca505a-7302-4cef-a393-536a64525d1d",
      "slug": "asiamath-2026-travel-grant",
      "title": "Asiamath 2026 Travel Grant",
      "grant_type": "conference_travel_grant",
      "linked_conference": {
        "id": "04cb9d06-8c49-4cf6-8948-d66c17b0c505",
        "slug": "asiamath-2026-workshop",
        "title": "Asiamath 2026 Workshop"
      },
      "description": "Partial travel support for invited or accepted participants.",
      "eligibility_summary": "Open to eligible applicants attending Asiamath 2026 Workshop.",
      "coverage_summary": "Partial airfare and accommodation support.",
      "application_deadline": "2026-06-05T23:59:59Z",
      "status": "published",
      "report_required": true,
      "is_application_open": true,
      "apply_requires_submitted_conference_application": true
    }
  }
}
```

---

### 7.3.6 Grant Application Form
**GET** `/api/v1/grants/:id/application-form`  
Auth: `public`

#### Response
```json
{
  "data": {
    "grant_id": "c5ca505a-7302-4cef-a393-536a64525d1d",
    "schema": {
      "fields": [
        {"key": "linked_conference_application_id", "type": "select", "required": true},
        {"key": "statement", "type": "textarea", "required": true},
        {"key": "travel_plan_summary", "type": "textarea", "required": true},
        {"key": "funding_need_summary", "type": "textarea", "required": true}
      ]
    }
  }
}
```

#### Notes
- The current MVP subtype supports only `conference_travel_grant`
- The frontend should let the applicant select a submitted conference application under the same linked conference

---

## 7.4 Organizer Conference Management

### 7.4.1 Create Conference
**POST** `/api/v1/organizer/conferences`  
Auth: `organizer_or_admin`

#### Request
```json
{
  "title": "Asiamath 2026 Workshop",
  "short_name": "AM2026",
  "slug": "asiamath-2026-workshop",
  "location_text": "Singapore",
  "start_date": "2026-08-10",
  "end_date": "2026-08-14",
  "description": "A regional workshop for young researchers.",
  "application_deadline": "2026-05-31T23:59:59Z",
  "application_form_schema": {
    "fields": [
      {"key": "participation_type", "type": "select", "required": true},
      {"key": "statement", "type": "textarea", "required": true}
    ]
  },
  "settings": {}
}
```

#### Side Effects
- Create `conferences`
- Create a `conference_staff` record for the current user with `staff_role = owner`

#### Response
```json
{
  "data": {
    "conference": {
      "id": "04cb9d06-8c49-4cf6-8948-d66c17b0c505",
      "slug": "asiamath-2026-workshop",
      "title": "Asiamath 2026 Workshop",
      "short_name": "AM2026",
      "location_text": "Singapore",
      "start_date": "2026-08-10",
      "end_date": "2026-08-14",
      "description": "A regional workshop for young researchers.",
      "application_deadline": "2026-05-31T23:59:59Z",
      "status": "draft",
      "published_at": null
    }
  }
}
```

---

### 7.4.2 Get Organizer Conference Detail
**GET** `/api/v1/organizer/conferences/:id`  
Auth: `conference_staff_or_admin`

#### Response
```json
{
  "data": {
    "conference": {
      "id": "04cb9d06-8c49-4cf6-8948-d66c17b0c505",
      "slug": "asiamath-2026-workshop",
      "title": "Asiamath 2026 Workshop",
      "short_name": "AM2026",
      "location_text": "Singapore",
      "start_date": "2026-08-10",
      "end_date": "2026-08-14",
      "description": "A regional workshop for young researchers.",
      "application_deadline": "2026-05-31T23:59:59Z",
      "status": "draft",
      "application_form_schema": {
        "fields": [
          {"key": "participation_type", "type": "select", "required": true},
          {"key": "statement", "type": "textarea", "required": true}
        ]
      },
      "settings": {},
      "staff": [
        {
          "user_id": "af4d98da-6870-4c0f-9cf5-38ce9330127d",
          "staff_role": "owner"
        }
      ]
    }
  }
}
```

---

### 7.4.3 Update Conference
**PUT** `/api/v1/organizer/conferences/:id`  
Auth: `conference_staff_or_admin`

#### Request
```json
{
  "title": "Asiamath 2026 Workshop",
  "short_name": "AM2026",
  "location_text": "Singapore",
  "start_date": "2026-08-10",
  "end_date": "2026-08-14",
  "description": "Updated description",
  "application_deadline": "2026-05-31T23:59:59Z",
  "application_form_schema": {
    "fields": [
      {"key": "participation_type", "type": "select", "required": true},
      {"key": "statement", "type": "textarea", "required": true}
    ]
  },
  "settings": {}
}
```

#### Response
```json
{
  "data": {
    "conference": {
      "id": "04cb9d06-8c49-4cf6-8948-d66c17b0c505",
      "slug": "asiamath-2026-workshop",
      "title": "Asiamath 2026 Workshop",
      "short_name": "AM2026",
      "location_text": "Singapore",
      "start_date": "2026-08-10",
      "end_date": "2026-08-14",
      "description": "Updated description",
      "application_deadline": "2026-05-31T23:59:59Z",
      "status": "draft",
      "application_form_schema": {
        "fields": [
          {"key": "participation_type", "type": "select", "required": true},
          {"key": "statement", "type": "textarea", "required": true}
        ]
      },
      "settings": {}
    }
  }
}
```

---

### 7.4.4 Publish Conference
**POST** `/api/v1/organizer/conferences/:id/publish`  
Auth: `conference_staff_or_admin`

#### Request
```json
{}
```

#### Publish Preconditions
- `title` has been filled in
- `slug` has been filled in
- `location_text` has been filled in
- `start_date` / `end_date` have been filled in
- `description` has been filled in
- `application_deadline` has been filled in

#### Response
```json
{
  "data": {
    "conference": {
      "id": "04cb9d06-8c49-4cf6-8948-d66c17b0c505",
      "status": "published",
      "published_at": "2026-04-20T10:00:00Z"
    }
  }
}
```

---

### 7.4.5 Close Conference
**POST** `/api/v1/organizer/conferences/:id/close`  
Auth: `conference_staff_or_admin`

#### Request
```json
{}
```

#### Response
```json
{
  "data": {
    "conference": {
      "id": "04cb9d06-8c49-4cf6-8948-d66c17b0c505",
      "status": "closed"
    }
  }
}
```

---

## 7.5 Organizer Grant Management

### 7.5.1 Create Grant under a Conference
**POST** `/api/v1/organizer/conferences/:conference_id/grants`  
Auth: `conference_staff_or_admin`

#### Request
```json
{
  "title": "Asiamath 2026 Travel Grant",
  "slug": "asiamath-2026-travel-grant",
  "grant_type": "conference_travel_grant",
  "description": "Partial travel support for eligible participants.",
  "eligibility_summary": "Open to eligible applicants attending Asiamath 2026 Workshop.",
  "coverage_summary": "Partial airfare and accommodation support.",
  "application_deadline": "2026-06-05T23:59:59Z",
  "report_required": true,
  "application_form_schema": {
    "fields": [
      {"key": "linked_conference_application_id", "type": "select", "required": true},
      {"key": "statement", "type": "textarea", "required": true},
      {"key": "travel_plan_summary", "type": "textarea", "required": true},
      {"key": "funding_need_summary", "type": "textarea", "required": true}
    ]
  },
  "settings": {}
}
```

#### Response
```json
{
  "data": {
    "grant": {
      "id": "c5ca505a-7302-4cef-a393-536a64525d1d",
      "slug": "asiamath-2026-travel-grant",
      "title": "Asiamath 2026 Travel Grant",
      "grant_type": "conference_travel_grant",
      "linked_conference_id": "04cb9d06-8c49-4cf6-8948-d66c17b0c505",
      "description": "Partial travel support for eligible participants.",
      "eligibility_summary": "Open to eligible applicants attending Asiamath 2026 Workshop.",
      "coverage_summary": "Partial airfare and accommodation support.",
      "application_deadline": "2026-06-05T23:59:59Z",
      "status": "draft",
      "report_required": true,
      "published_at": null
    }
  }
}
```

---

### 7.5.2 Get Organizer Grant Detail
**GET** `/api/v1/organizer/grants/:id`  
Auth: `grant_manager_or_admin`

#### Response
```json
{
  "data": {
    "grant": {
      "id": "c5ca505a-7302-4cef-a393-536a64525d1d",
      "slug": "asiamath-2026-travel-grant",
      "title": "Asiamath 2026 Travel Grant",
      "grant_type": "conference_travel_grant",
      "linked_conference_id": "04cb9d06-8c49-4cf6-8948-d66c17b0c505",
      "description": "Partial travel support for eligible participants.",
      "eligibility_summary": "Open to eligible applicants attending Asiamath 2026 Workshop.",
      "coverage_summary": "Partial airfare and accommodation support.",
      "application_deadline": "2026-06-05T23:59:59Z",
      "status": "draft",
      "report_required": true,
      "application_form_schema": {
        "fields": [
          {"key": "linked_conference_application_id", "type": "select", "required": true},
          {"key": "statement", "type": "textarea", "required": true},
          {"key": "travel_plan_summary", "type": "textarea", "required": true},
          {"key": "funding_need_summary", "type": "textarea", "required": true}
        ]
      },
      "settings": {}
    }
  }
}
```

---

### 7.5.3 Update Grant
**PUT** `/api/v1/organizer/grants/:id`  
Auth: `grant_manager_or_admin`

#### Request
```json
{
  "title": "Asiamath 2026 Travel Grant",
  "description": "Updated description",
  "eligibility_summary": "Updated eligibility",
  "coverage_summary": "Updated coverage",
  "application_deadline": "2026-06-05T23:59:59Z",
  "report_required": true,
  "application_form_schema": {
    "fields": [
      {"key": "linked_conference_application_id", "type": "select", "required": true},
      {"key": "statement", "type": "textarea", "required": true},
      {"key": "travel_plan_summary", "type": "textarea", "required": true},
      {"key": "funding_need_summary", "type": "textarea", "required": true}
    ]
  },
  "settings": {}
}
```

#### Response
```json
{
  "data": {
    "grant": {
      "id": "c5ca505a-7302-4cef-a393-536a64525d1d",
      "title": "Asiamath 2026 Travel Grant",
      "status": "draft",
      "description": "Updated description",
      "eligibility_summary": "Updated eligibility",
      "coverage_summary": "Updated coverage",
      "application_deadline": "2026-06-05T23:59:59Z",
      "report_required": true
    }
  }
}
```

---

### 7.5.4 Publish Grant
**POST** `/api/v1/organizer/grants/:id/publish`  
Auth: `grant_manager_or_admin`

#### Request
```json
{}
```

#### Publish Preconditions
- `title` has been filled in
- `slug` has been filled in
- `grant_type` has been filled in
- `linked_conference_id` has been filled in
- `description` has been filled in
- `eligibility_summary` has been filled in
- `coverage_summary` has been filled in
- `application_deadline` has been filled in

#### Response
```json
{
  "data": {
    "grant": {
      "id": "c5ca505a-7302-4cef-a393-536a64525d1d",
      "status": "published",
      "published_at": "2026-04-22T12:00:00Z"
    }
  }
}
```

---

### 7.5.5 Close Grant
**POST** `/api/v1/organizer/grants/:id/close`  
Auth: `grant_manager_or_admin`

#### Request
```json
{}
```

#### Response
```json
{
  "data": {
    "grant": {
      "id": "c5ca505a-7302-4cef-a393-536a64525d1d",
      "status": "closed"
    }
  }
}
```

---

## 7.6 Files

### 7.6.1 Upload File
**POST** `/api/v1/files`  
Auth: `authenticated`  
Content-Type: `multipart/form-data`

#### Form Data
- `file`
- `file_role`：`cv | abstract_attachment | supporting_document | post_visit_report_attachment`
- `visibility`: optional, defaults to `private`

#### Response
```json
{
  "data": {
    "file": {
      "id": "8d1ea0e2-66c9-497c-9d7d-35b8b6ed4e76",
      "owner_user_id": "5d37402f-f9fd-458c-8126-868f5503a005",
      "file_role": "cv",
      "visibility": "private",
      "original_name": "cv.pdf",
      "mime_type": "application/pdf",
      "size_bytes": 120344,
      "uploaded_at": "2026-04-14T10:05:00Z",
      "deleted_at": null
    }
  }
}
```

---

### 7.6.2 Delete File
**DELETE** `/api/v1/files/:id`  
Auth: `authenticated`

#### Behavior
- Only the owner or admin may delete
- Use soft delete (`deleted_at`)

#### Response
```json
{
  "data": {
    "success": true
  }
}
```

---

## 7.7 Applications（Applicant）

### 7.7.1 Create Draft Conference Application
**POST** `/api/v1/conferences/:id/applications`  
Auth: `authenticated`

#### Request
```json
{
  "participation_type": "talk",
  "statement": "I would like to participate...",
  "abstract_title": "A note on...",
  "abstract_text": "This talk discusses...",
  "interested_in_travel_support": true,
  "extra_answers": {},
  "file_ids": ["8d1ea0e2-66c9-497c-9d7d-35b8b6ed4e76"]
}
```

#### Notes
- The current user may have at most one application under the same conference
- If a draft already exists, return `CONFLICT`
- If a submitted / under_review / decided application already exists, also return `CONFLICT`

#### Response
```json
{
  "data": {
    "application": {
      "id": "7301eb65-c8af-4f69-92ee-1304f2e2f8f0",
      "application_type": "conference_application",
      "source_module": "M2",
      "conference_id": "04cb9d06-8c49-4cf6-8948-d66c17b0c505",
      "conference_title": "Asiamath 2026 Workshop",
      "applicant_user_id": "5d37402f-f9fd-458c-8126-868f5503a005",
      "status": "draft",
      "participation_type": "talk",
      "statement": "I would like to participate...",
      "abstract_title": "A note on...",
      "abstract_text": "This talk discusses...",
      "interested_in_travel_support": true,
      "extra_answers": {},
      "files": [
        {
          "id": "8d1ea0e2-66c9-497c-9d7d-35b8b6ed4e76",
          "file_role": "cv",
          "original_name": "cv.pdf"
        }
      ],
      "submitted_at": null,
      "decided_at": null,
      "decision": null,
      "created_at": "2026-04-14T10:07:00Z",
      "updated_at": "2026-04-14T10:07:00Z"
    }
  }
}
```

---

### 7.7.2 Create Draft Grant Application
**POST** `/api/v1/grants/:id/applications`  
Auth: `authenticated`

#### Request
```json
{
  "linked_conference_application_id": "7301eb65-c8af-4f69-92ee-1304f2e2f8f0",
  "statement": "I am requesting travel support to attend the workshop.",
  "travel_plan_summary": "Round trip from Singapore to Seoul with 4 nights lodging.",
  "funding_need_summary": "Airfare support requested; accommodation partially self-funded.",
  "extra_answers": {},
  "file_ids": ["12946f3e-29de-41d6-8a4a-f9d8f6dd3ae9"]
}
```

#### Preconditions
- The current grant must be in an appliable state
- `linked_conference_application_id` must belong to the current user
- The linked conference application must correspond to the grant’s `linked_conference_id`
- The linked conference application must not be `draft`
- The current user may have at most one application under the same grant

#### Response
```json
{
  "data": {
    "application": {
      "id": "94a69a4f-0b18-420c-a99a-3fa8ef6d7a1a",
      "application_type": "grant_application",
      "source_module": "M7",
      "grant_id": "c5ca505a-7302-4cef-a393-536a64525d1d",
      "grant_title": "Asiamath 2026 Travel Grant",
      "linked_conference_id": "04cb9d06-8c49-4cf6-8948-d66c17b0c505",
      "linked_conference_application_id": "7301eb65-c8af-4f69-92ee-1304f2e2f8f0",
      "applicant_user_id": "5d37402f-f9fd-458c-8126-868f5503a005",
      "status": "draft",
      "statement": "I am requesting travel support to attend the workshop.",
      "travel_plan_summary": "Round trip from Singapore to Seoul with 4 nights lodging.",
      "funding_need_summary": "Airfare support requested; accommodation partially self-funded.",
      "extra_answers": {},
      "files": [
        {
          "id": "12946f3e-29de-41d6-8a4a-f9d8f6dd3ae9",
          "file_role": "supporting_document",
          "original_name": "budget.pdf"
        }
      ],
      "submitted_at": null,
      "decided_at": null,
      "decision": null,
      "created_at": "2026-04-16T08:50:00Z",
      "updated_at": "2026-04-16T08:50:00Z"
    }
  }
}
```

---

### 7.7.3 Update Draft Application
**PUT** `/api/v1/me/applications/:id/draft`  
Auth: `authenticated`

#### Preconditions
- The current user must be the application owner
- `application.status = draft`

#### Conference request example
```json
{
  "participation_type": "talk",
  "statement": "Updated statement",
  "abstract_title": "Updated title",
  "abstract_text": "Updated abstract",
  "interested_in_travel_support": true,
  "extra_answers": {
    "preferred_arrival_date": "2026-08-09"
  },
  "file_ids": ["8d1ea0e2-66c9-497c-9d7d-35b8b6ed4e76"]
}
```

#### Grant request example
```json
{
  "linked_conference_application_id": "7301eb65-c8af-4f69-92ee-1304f2e2f8f0",
  "statement": "Updated funding request statement",
  "travel_plan_summary": "Updated travel plan",
  "funding_need_summary": "Updated funding summary",
  "extra_answers": {},
  "file_ids": ["12946f3e-29de-41d6-8a4a-f9d8f6dd3ae9"]
}
```

#### Response（conference example）
```json
{
  "data": {
    "application": {
      "id": "7301eb65-c8af-4f69-92ee-1304f2e2f8f0",
      "application_type": "conference_application",
      "status": "draft",
      "participation_type": "talk",
      "statement": "Updated statement",
      "abstract_title": "Updated title",
      "abstract_text": "Updated abstract",
      "interested_in_travel_support": true,
      "extra_answers": {
        "preferred_arrival_date": "2026-08-09"
      },
      "files": [
        {
          "id": "8d1ea0e2-66c9-497c-9d7d-35b8b6ed4e76",
          "file_role": "cv",
          "original_name": "cv.pdf"
        }
      ],
      "updated_at": "2026-04-14T10:08:00Z"
    }
  }
}
```

---

### 7.7.4 Submit Application
**POST** `/api/v1/me/applications/:id/submit`  
Auth: `authenticated`

#### Request
```json
{}
```

#### Preconditions
- The current user must be the application owner
- `application.status = draft`
- Required profile fields are complete

#### Type-specific validation
- If `application_type = conference_application`
  - `participation_type` has been filled in
  - `statement` has been filled in
  - If `participation_type = talk`, then `abstract_title` and `abstract_text` are required

- If `application_type = grant_application`
  - `linked_conference_application_id` has been filled in
  - The linked conference application belongs to the current user
  - The linked conference application corresponds to the grant’s `linked_conference_id`
  - the linked conference application must not be `draft`
  - `statement` / `travel_plan_summary` / `funding_need_summary` are required

#### Side Effects
- `applications.status` is changed to `submitted`
- Write `applications.submitted_at`
- Write `applications.applicant_profile_snapshot_json`
- Append one `application_status_history` record

#### Response（grant example）
```json
{
  "data": {
    "application": {
      "id": "94a69a4f-0b18-420c-a99a-3fa8ef6d7a1a",
      "application_type": "grant_application",
      "status": "submitted",
      "submitted_at": "2026-04-16T09:00:00Z",
      "applicant_profile_snapshot": {
        "full_name": "Alice Chen",
        "institution_name_raw": "National University of Singapore",
        "country_code": "SG",
        "career_stage": "phd",
        "research_keywords": ["algebraic geometry", "birational geometry"]
      }
    }
  }
}
```

---

### 7.7.5 My Applications List
**GET** `/api/v1/me/applications`  
Auth: `authenticated`

#### Response
```json
{
  "data": {
    "items": [
      {
        "id": "7301eb65-c8af-4f69-92ee-1304f2e2f8f0",
        "application_type": "conference_application",
        "source_module": "M2",
        "source_id": "04cb9d06-8c49-4cf6-8948-d66c17b0c505",
        "source_title": "Asiamath 2026 Workshop",
        "linked_conference_title": null,
        "viewer_status": "under_review",
        "submitted_at": "2026-04-14T10:10:00Z",
        "released_decision": null,
        "next_action": "view_submission",
        "post_visit_report_status": null
      },
      {
        "id": "94a69a4f-0b18-420c-a99a-3fa8ef6d7a1a",
        "application_type": "grant_application",
        "source_module": "M7",
        "source_id": "c5ca505a-7302-4cef-a393-536a64525d1d",
        "source_title": "Asiamath 2026 Travel Grant",
        "linked_conference_title": "Asiamath 2026 Workshop",
        "viewer_status": "result_released",
        "submitted_at": "2026-04-16T09:00:00Z",
        "released_decision": {
          "decision_kind": "travel_grant",
          "final_status": "accepted",
          "display_label": "Awarded",
          "released_at": "2026-05-02T12:00:00Z"
        },
        "next_action": "submit_post_visit_report",
        "post_visit_report_status": "not_started"
      }
    ]
  }
}
```

#### Notes
- The applicant sees a viewer-safe view
- If an internal decision already exists but has not been released, `viewer_status` should still remain `under_review`
- The dashboard must display conference and grant as separate records

---

### 7.7.6 My Application Detail
**GET** `/api/v1/me/applications/:id`  
Auth: `authenticated`

#### Response（grant example）
```json
{
  "data": {
    "application": {
      "id": "94a69a4f-0b18-420c-a99a-3fa8ef6d7a1a",
      "application_type": "grant_application",
      "source_module": "M7",
      "grant_id": "c5ca505a-7302-4cef-a393-536a64525d1d",
      "grant_title": "Asiamath 2026 Travel Grant",
      "linked_conference_id": "04cb9d06-8c49-4cf6-8948-d66c17b0c505",
      "linked_conference_title": "Asiamath 2026 Workshop",
      "linked_conference_application_id": "7301eb65-c8af-4f69-92ee-1304f2e2f8f0",
      "viewer_status": "result_released",
      "statement": "I am requesting travel support to attend the workshop.",
      "travel_plan_summary": "Round trip from Singapore to Seoul with 4 nights lodging.",
      "funding_need_summary": "Airfare support requested; accommodation partially self-funded.",
      "extra_answers": {},
      "applicant_profile_snapshot": {
        "full_name": "Alice Chen",
        "institution_name_raw": "National University of Singapore",
        "country_code": "SG",
        "career_stage": "phd",
        "research_keywords": ["algebraic geometry", "birational geometry"]
      },
      "files": [
        {
          "id": "12946f3e-29de-41d6-8a4a-f9d8f6dd3ae9",
          "file_role": "supporting_document",
          "original_name": "budget.pdf"
        }
      ],
      "submitted_at": "2026-04-16T09:00:00Z",
      "released_decision": {
        "decision_kind": "travel_grant",
        "final_status": "accepted",
        "display_label": "Awarded",
        "note_external": "We are pleased to offer you travel support.",
        "released_at": "2026-05-02T12:00:00Z"
      },
      "post_visit_report_status": "not_started"
    }
  }
}
```

#### Notes
- Applicant detail does not return internal `application.status`
- If not released, then `released_decision = null`

---

## 7.8 Organizer Application Operations

### 7.8.1 Organizer Conference Application List
**GET** `/api/v1/organizer/conferences/:id/applications`  
Auth: `conference_staff_or_admin`

#### Query Params
- `status`
- `page`
- `page_size`

#### Response
```json
{
  "data": {
    "items": [
      {
        "id": "7301eb65-c8af-4f69-92ee-1304f2e2f8f0",
        "application_type": "conference_application",
        "applicant_user_id": "5d37402f-f9fd-458c-8126-868f5503a005",
        "applicant_name": "Alice Chen",
        "status": "submitted",
        "participation_type": "talk",
        "submitted_at": "2026-04-14T10:10:00Z",
        "review_assignment_count": 1,
        "completed_review_count": 0,
        "decision_release_status": null
      }
    ]
  },
  "meta": {
    "page": 1,
    "page_size": 20,
    "total": 1
  }
}
```

---

### 7.8.2 Organizer Grant Application List
**GET** `/api/v1/organizer/grants/:id/applications`  
Auth: `grant_manager_or_admin`

#### Query Params
- `status`
- `page`
- `page_size`

#### Response
```json
{
  "data": {
    "items": [
      {
        "id": "94a69a4f-0b18-420c-a99a-3fa8ef6d7a1a",
        "application_type": "grant_application",
        "applicant_user_id": "5d37402f-f9fd-458c-8126-868f5503a005",
        "applicant_name": "Alice Chen",
        "status": "under_review",
        "linked_conference_application_id": "7301eb65-c8af-4f69-92ee-1304f2e2f8f0",
        "submitted_at": "2026-04-16T09:00:00Z",
        "review_assignment_count": 1,
        "completed_review_count": 0,
        "decision_release_status": "unreleased"
      }
    ]
  },
  "meta": {
    "page": 1,
    "page_size": 20,
    "total": 1
  }
}
```

---

### 7.8.3 Organizer Application Detail
**GET** `/api/v1/organizer/applications/:id`  
Auth: `application_manager_or_admin`

#### Response（conference example）
```json
{
  "data": {
    "application": {
      "id": "7301eb65-c8af-4f69-92ee-1304f2e2f8f0",
      "application_type": "conference_application",
      "source_module": "M2",
      "conference_id": "04cb9d06-8c49-4cf6-8948-d66c17b0c505",
      "conference_title": "Asiamath 2026 Workshop",
      "status": "submitted",
      "participation_type": "talk",
      "statement": "I would like to participate...",
      "abstract_title": "A note on...",
      "abstract_text": "This talk discusses...",
      "interested_in_travel_support": true,
      "extra_answers": {},
      "submitted_at": "2026-04-14T10:10:00Z",
      "applicant_profile_snapshot": {
        "full_name": "Alice Chen",
        "institution_name_raw": "National University of Singapore",
        "country_code": "SG",
        "career_stage": "phd",
        "research_keywords": ["algebraic geometry"]
      },
      "files": [
        {
          "id": "8d1ea0e2-66c9-497c-9d7d-35b8b6ed4e76",
          "file_role": "cv",
          "original_name": "cv.pdf"
        }
      ],
      "review_assignments": [
        {
          "id": "cf01413f-c37c-4306-9358-97d7c0e00d5c",
          "reviewer_user_id": "e4947750-4820-4f0c-bf4a-d14f717883ec",
          "reviewer_name": "Prof. Bob",
          "status": "assigned",
          "conflict_state": "clear",
          "conflict_note": null,
          "due_at": "2026-05-10T23:59:59Z",
          "assigned_at": "2026-04-15T09:00:00Z",
          "completed_at": null
        }
      ],
      "reviews": [],
      "decision": {
        "id": "63274d3c-dcff-41d0-a0e7-fb6f0887fb0d",
        "decision_kind": "conference_admission",
        "final_status": "accepted",
        "release_status": "unreleased",
        "note_internal": "Priority candidate",
        "note_external": "We are pleased to inform you that your application has been accepted.",
        "decided_by_user_id": "af4d98da-6870-4c0f-9cf5-38ce9330127d",
        "decided_at": "2026-04-18T08:00:00Z",
        "released_at": null
      }
    }
  }
}
```

---

### 7.8.4 Assign Reviewer
**POST** `/api/v1/organizer/applications/:id/assign-reviewer`  
Auth: `application_manager_or_admin`

#### Request
```json
{
  "reviewer_user_id": "e4947750-4820-4f0c-bf4a-d14f717883ec",
  "due_at": "2026-05-10T23:59:59Z",
  "conflict_state": "clear",
  "conflict_note": null
}
```

#### Validation
- The same reviewer may not be assigned to the same application more than once
- The reviewer must have the reviewer role
- The reviewer must have an M4 profile record
- `conflict_state` must be `clear | flagged`

#### Side Effects
- Create `review_assignments`
- If the current application is `submitted`, change it to `under_review`
- Append one `application_status_history` record

#### Response
```json
{
  "data": {
    "assignment": {
      "id": "cf01413f-c37c-4306-9358-97d7c0e00d5c",
      "application_id": "7301eb65-c8af-4f69-92ee-1304f2e2f8f0",
      "application_type": "conference_application",
      "reviewer_user_id": "e4947750-4820-4f0c-bf4a-d14f717883ec",
      "assigned_by_user_id": "af4d98da-6870-4c0f-9cf5-38ce9330127d",
      "status": "assigned",
      "conflict_state": "clear",
      "conflict_note": null,
      "due_at": "2026-05-10T23:59:59Z",
      "assigned_at": "2026-04-15T09:00:00Z",
      "completed_at": null
    },
    "application_status": "under_review"
  }
}
```

#### Notes
- If `conflict_state = flagged`, the assignment may still be created for recordkeeping, but the reviewer side cannot submit a review
- Organizers should resolve the conflict by removing/replacing the assignment

---

### 7.8.5 Remove Review Assignment
**POST** `/api/v1/organizer/review-assignments/:id/remove`  
Auth: `application_manager_or_admin`

#### Request
```json
{
  "reason": "Conflict of interest identified after assignment."
}
```

#### Side Effects
- `review_assignments.status` changes to `cancelled`
- Preserve the original assignment to maintain the audit trail

#### Response
```json
{
  "data": {
    "assignment": {
      "id": "cf01413f-c37c-4306-9358-97d7c0e00d5c",
      "status": "cancelled"
    }
  }
}
```

---

### 7.8.6 Upsert Internal Decision
**POST** `/api/v1/organizer/applications/:id/decision`  
Auth: `application_manager_or_admin`

#### Request（conference example）
```json
{
  "final_status": "accepted",
  "note_internal": "Priority candidate",
  "note_external": "We are pleased to inform you that your application has been accepted."
}
```

#### Validation
- `final_status`：`accepted | rejected | waitlisted`
- It is allowed to “create or overwrite an internal decision” for the same application, but if modification is allowed after release, it must go through an explicit operational process; overwriting after release is currently discouraged by default
- The current application status must be `submitted`, `under_review`, or `decided`

#### Side Effects
- Create or update `decisions`
- Update `applications.status` to `decided`
- Write `applications.decided_at`
- Append one `application_status_history` record

#### Response
```json
{
  "data": {
    "decision": {
      "id": "63274d3c-dcff-41d0-a0e7-fb6f0887fb0d",
      "application_id": "7301eb65-c8af-4f69-92ee-1304f2e2f8f0",
      "application_type": "conference_application",
      "decision_kind": "conference_admission",
      "final_status": "accepted",
      "release_status": "unreleased",
      "note_internal": "Priority candidate",
      "note_external": "We are pleased to inform you that your application has been accepted.",
      "decided_by_user_id": "af4d98da-6870-4c0f-9cf5-38ce9330127d",
      "decided_at": "2026-04-18T08:00:00Z",
      "released_at": null
    },
    "application_status": "decided",
    "decided_at": "2026-04-18T08:00:00Z"
  }
}
```

---

### 7.8.7 Release Decision
**POST** `/api/v1/organizer/applications/:id/release-decision`  
Auth: `application_manager_or_admin`

#### Request
```json
{}
```

#### Preconditions
- The application has an internal decision
- `decision.release_status = unreleased`

#### Additional Grant Validation
If `application_type = grant_application`:

- If the linked conference application already has a final result of `rejected`
- and the current grant decision `final_status` is `accepted` or `waitlisted`

then it must return:
- `UNPROCESSABLE_STATE`

This is the minimum MVP dependency rule:  
Once the conference is rejected, the grant cannot be released to the applicant as awarded / waitlisted.

#### Side Effects
- `decision.release_status = released`
- Write `decision.released_at`

#### Response
```json
{
  "data": {
    "decision": {
      "id": "63274d3c-dcff-41d0-a0e7-fb6f0887fb0d",
      "application_id": "7301eb65-c8af-4f69-92ee-1304f2e2f8f0",
      "decision_kind": "conference_admission",
      "final_status": "accepted",
      "release_status": "released",
      "released_at": "2026-04-20T12:00:00Z"
    }
  }
}
```

---

## 7.9 Reviewer

### 7.9.1 Reviewer Assignments List
**GET** `/api/v1/reviewer/assignments`  
Auth: `authenticated`

#### Notes
- The server must filter so that “the current user is the reviewer of that assignment”
- If administrators need cross-user viewing, do not reuse this endpoint; use an admin endpoint instead

#### Query Params
- `status`

#### Response
```json
{
  "data": {
    "items": [
      {
        "assignment_id": "cf01413f-c37c-4306-9358-97d7c0e00d5c",
        "application_id": "7301eb65-c8af-4f69-92ee-1304f2e2f8f0",
        "application_type": "conference_application",
        "source_title": "Asiamath 2026 Workshop",
        "applicant_name": "Alice Chen",
        "status": "assigned",
        "conflict_state": "clear",
        "due_at": "2026-05-10T23:59:59Z",
        "assigned_at": "2026-04-15T09:00:00Z"
      }
    ]
  }
}
```

---

### 7.9.2 Reviewer Assignment Detail
**GET** `/api/v1/reviewer/assignments/:id`  
Auth: `assigned_reviewer_or_admin`

#### Response
```json
{
  "data": {
    "assignment": {
      "id": "cf01413f-c37c-4306-9358-97d7c0e00d5c",
      "status": "assigned",
      "conflict_state": "clear",
      "conflict_note": null,
      "submission_blocked": false,
      "due_at": "2026-05-10T23:59:59Z",
      "application": {
        "id": "7301eb65-c8af-4f69-92ee-1304f2e2f8f0",
        "application_type": "conference_application",
        "source_title": "Asiamath 2026 Workshop",
        "participation_type": "talk",
        "statement": "I would like to participate...",
        "abstract_title": "A note on...",
        "abstract_text": "This talk discusses...",
        "applicant_profile_snapshot": {
          "full_name": "Alice Chen",
          "institution_name_raw": "National University of Singapore",
          "country_code": "SG",
          "career_stage": "phd",
          "research_keywords": ["algebraic geometry"]
        },
        "files": [
          {
            "id": "8d1ea0e2-66c9-497c-9d7d-35b8b6ed4e76",
            "file_role": "cv",
            "original_name": "cv.pdf"
          }
        ]
      }
    }
  }
}
```

#### Notes
- If `conflict_state = flagged`, then `submission_blocked = true`
- The reviewer may see the assigned materials, but cannot submit a review

---

### 7.9.3 Submit Review
**POST** `/api/v1/reviewer/assignments/:id/review`  
Auth: `assigned_reviewer_or_admin`

#### Request
```json
{
  "score": 4,
  "recommendation": "accept",
  "comment": "Strong application."
}
```

#### Validation
- `score`：1~5
- `recommendation`：`accept | reject | waitlist`
- At most one review may be submitted for one assignment
- `assignment.status` must be `assigned`
- `assignment.conflict_state` must not be `flagged`

#### Side Effects
- Create `reviews`
- `review_assignments.status` changes to `review_submitted`
- Write the timestamp to `review_assignments.completed_at`

#### Response
```json
{
  "data": {
    "review": {
      "id": "0ddbf60d-7112-479c-becd-3018f05fec21",
      "assignment_id": "cf01413f-c37c-4306-9358-97d7c0e00d5c",
      "score": 4,
      "recommendation": "accept",
      "comment": "Strong application.",
      "submitted_at": "2026-04-16T12:00:00Z"
    },
    "assignment_status": "review_submitted",
    "completed_at": "2026-04-16T12:00:00Z"
  }
}
```

---

## 7.10 Post-Visit Report

### 7.10.1 Get Post-Visit Report State
**GET** `/api/v1/me/applications/:id/post-visit-report`  
Auth: `authenticated`

#### Preconditions
- The current user must be the grant application owner
- `application_type = grant_application`

#### Response (Not Started)
```json
{
  "data": {
    "grant_application_id": "94a69a4f-0b18-420c-a99a-3fa8ef6d7a1a",
    "report_required": true,
    "eligible_to_submit": true,
    "post_visit_report_status": "not_started",
    "report": null
  }
}
```

#### Response (Submitted)
```json
{
  "data": {
    "grant_application_id": "94a69a4f-0b18-420c-a99a-3fa8ef6d7a1a",
    "report_required": true,
    "eligible_to_submit": true,
    "post_visit_report_status": "submitted",
    "report": {
      "id": "5f281dc0-b9da-440f-8d9b-a6db3fc8db6b",
      "status": "submitted",
      "title": "Travel report for Asiamath 2026 Workshop",
      "report_text": "The travel grant enabled participation in the workshop...",
      "files": [
        {
          "id": "279d7f31-9e97-41c8-8d81-46449d530b6f",
          "file_role": "post_visit_report_attachment",
          "original_name": "report-appendix.pdf"
        }
      ],
      "submitted_at": "2026-08-25T10:00:00Z",
      "updated_at": "2026-08-25T10:00:00Z"
    }
  }
}
```

#### Notes
- The minimum requirement for `eligible_to_submit` is: the grant decision has been released and `final_status = accepted`, and `report_required = true`

---

### 7.10.2 Submit / Update Post-Visit Report
**PUT** `/api/v1/me/applications/:id/post-visit-report`  
Auth: `authenticated`

#### Request
```json
{
  "title": "Travel report for Asiamath 2026 Workshop",
  "report_text": "The travel grant enabled participation in the workshop...",
  "file_ids": ["279d7f31-9e97-41c8-8d81-46449d530b6f"]
}
```

#### Validation
- The current user must be the grant application owner
- `application_type = grant_application`
- The grant decision has been released and `final_status = accepted`
- `report_required = true`

#### Side Effects
- Create or update `post_visit_reports`
- If this is the first submission, then `post_visit_report.status = submitted`

#### Response
```json
{
  "data": {
    "report": {
      "id": "5f281dc0-b9da-440f-8d9b-a6db3fc8db6b",
      "grant_application_id": "94a69a4f-0b18-420c-a99a-3fa8ef6d7a1a",
      "status": "submitted",
      "title": "Travel report for Asiamath 2026 Workshop",
      "report_text": "The travel grant enabled participation in the workshop...",
      "files": [
        {
          "id": "279d7f31-9e97-41c8-8d81-46449d530b6f",
          "file_role": "post_visit_report_attachment",
          "original_name": "report-appendix.pdf"
        }
      ],
      "submitted_at": "2026-08-25T10:00:00Z",
      "updated_at": "2026-08-25T10:00:00Z"
    }
  }
}
```

---

## 8. Page-to-Endpoint Mapping

### 8.1 Public / Visitor
- Home / discovery aggregation page → may compose higher-level content endpoints such as `GET /conferences`, `GET /grants`, `GET /newsletter*`
- Conference list page → `GET /conferences`
- Conference detail page → `GET /conferences/:slug`
- Conference application form page → `GET /conferences/:id/application-form`
- Grant list page → `GET /grants`
- Grant detail page → `GET /grants/:slug`
- Grant application form page → `GET /grants/:id/application-form`
- Public Scholar Profile → `GET /scholars/:slug`

### 8.2 Applicant
- Registration page → `POST /auth/register`
- Login page → `POST /auth/login`
- Profile page → `GET /profile/me`, `PUT /profile/me`
- Conference application create → `POST /conferences/:id/applications`
- Grant application create → `POST /grants/:id/applications`
- Draft editing → `PUT /me/applications/:id/draft`
- Submit → `POST /me/applications/:id/submit`
- My Applications page → `GET /me/applications`
- My Application Detail page → `GET /me/applications/:id`
- Post-Visit Report page → `GET /me/applications/:id/post-visit-report`, `PUT /me/applications/:id/post-visit-report`
- Attachment upload → `POST /files`

### 8.3 Organizer
- Conference creation page → `POST /organizer/conferences`
- Conference editing page → `GET /organizer/conferences/:id`, `PUT /organizer/conferences/:id`
- Publish / Close Conference → `POST /organizer/conferences/:id/publish`, `POST /organizer/conferences/:id/close`
- Grant creation page → `POST /organizer/conferences/:conference_id/grants`
- Grant editing page → `GET /organizer/grants/:id`, `PUT /organizer/grants/:id`
- Publish / Close Grant → `POST /organizer/grants/:id/publish`, `POST /organizer/grants/:id/close`
- Conference application list page → `GET /organizer/conferences/:id/applications`
- Grant application list page → `GET /organizer/grants/:id/applications`
- Generic application detail → `GET /organizer/applications/:id`
- Reviewer candidates → `GET /organizer/applications/:id/reviewer-candidates`
- Assign reviewer → `POST /organizer/applications/:id/assign-reviewer`
- Remove assignment → `POST /organizer/review-assignments/:id/remove`
- Internal decision → `POST /organizer/applications/:id/decision`
- Release decision → `POST /organizer/applications/:id/release-decision`

### 8.4 Reviewer
- Reviewer Task List → `GET /reviewer/assignments`
- Reviewer Assignment Detail → `GET /reviewer/assignments/:id`
- Review Submit → `POST /reviewer/assignments/:id/review`

### 8.5 Admin
- Admin seed scholar / reviewer profile → `POST /admin/profiles/seed`
- Other backend admin/ops endpoints may continue to be refined in an admin spec, but they should not conflict with the core contract in this file

---

## 9. Key API-to-Database Mappings (and What Must Be Synced in This Round)

> Note: this section expresses **contract-level expectations**. If the current schema/DDL still retains old names or old enums, they need to be synchronized and corrected in the next round.

| API field / semantics | Database source / sync note |
|---|---|
| `user.roles[]` | `user_roles.role` |
| `user.primary_role` | `user_roles.is_primary = true` |
| `conference_staff_memberships[]` | `conference_staff` |
| `profile.slug` | `profiles.slug` or an equivalent unique public identifier field |
| `profile.msc_codes[]` | `profile_msc_codes` + `msc_codes` |
| `conference.application_form_schema` | `conferences.application_form_schema_json` |
| `conference.settings` | `conferences.settings_json` |
| `grant.application_form_schema` | `grant_opportunities.application_form_schema_json` (or an equivalent table) |
| `grant.settings` | `grant_opportunities.settings_json` (or an equivalent table) |
| `application.application_type` | `applications.application_type` or an equivalent discriminator field |
| `application.extra_answers` | `applications.extra_answers_json` |
| `application.applicant_profile_snapshot` | `applications.applicant_profile_snapshot_json` |
| `application.files[]` | `application_files` + `file_assets` |
| `grant_application.linked_conference_application_id` | `applications.linked_conference_application_id` or a join relationship |
| `decision.final_status` | `decisions.final_status` |
| `decision.release_status` | `decisions.release_status` (should be added or aligned in this round) |
| `decision.released_at` | `decisions.released_at` (should be added or aligned in this round) |
| `assignment.conflict_state` | Can map to `review_assignments.conflict_state`; if the physical layer still uses `conflict_check_status`, it should be mapped in the service layer and scheduled for refactoring |
| `post_visit_report` | `post_visit_reports` (or an equivalent table) |
| Status change history | `application_status_history` |

### 9.1 Key Migration Items from V2
1. `applications.status` should no longer store `accepted / rejected / waitlisted`
2. `decisions` need explicit support for `release_status` / `released_at`
3. `Travel Grants` need a formal object layer (at minimum `grant_opportunities`, grant applications, and `post_visit_reports`)
4. `conflict_check_status / conflict_override_reason` should no longer be exposed to the frontend as the main contract
5. Applicant-facing APIs need viewer-safe semantics and must not leak unreleased decisions

---

## 10. Items Intentionally Excluded from the Detailed API Spec in This Phase

The following remain future extensions and are not included in the detailed V2.1 endpoints:

- ORCID OAuth
- Institution search and standardized matching workflows
- Conference schedule / sessions / speakers
- Microsite builder
- Payment
- Other Travel Grants subtypes (visiting researcher fellowships, Research in Pairs / Groups, early career / PhD support)
- Full Schools workflows
- Full CRUD for Newsletter / Video Library / Publications
- Governance / voting
- Partner portal
- Automatic COI inference
- Notification center / outbox API
- Fine-grained enterprise permission administration

---

## 11. Most Recommended Next Steps

### A. Priority
Strictly converge the current frontend and backend implementation to this `API Spec V2.1`:

- Update status enums
- Add grant and post-visit report endpoints
- Add the decision release gate
- Update the applicant dashboard contract
- Update the COI representation for review assignments

### B. Immediately After
Synchronize updates to:
- `docs/specs/asiamath-technical-spec-v2.1.md`
- `docs/specs/asiamath-database-schema-v1.1.md`
- `database/ddl/asiamath-database-ddl-v1.1.sql`

At minimum, ensure that object names, enum names, release fields, and dependency rules are consistent.

### C. Engineering Output
Add a more engineering-oriented interface file, for example:
- `openapi-v1.yaml`

### D. Minimum Test Checklist
It is recommended to cover at least these 4 test groups:
1. conference application submit → review → internal decision → release
2. grant application submit → linked conference prerequisite validation
3. after conference rejected, grant accepted/waitlisted release is blocked
4. conflict-flagged reviewer assignment cannot submit a review
