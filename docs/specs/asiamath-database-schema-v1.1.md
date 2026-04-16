# Asiamath Database Schema V1.1

> Status: Draft V1.1  
> Reference database: PostgreSQL 15+  
> Alignment baseline: system map first, while remaining aligned with `MVP PRD v3.2`, `Design Spec v2.1`, `Technical Spec v2.1`, and `API Spec v2.1`.  
> Design principles: **clear product ownership, reusable shared foundations, and database semantics that do not conflict with front-end/back-end contracts.**

---

## 1. Positioning of this version

V1.1 is not a simple patch that adds a few columns. It formally tightens the database layer from a **conference-only workflow** into an implementation model based on **M2-lite + M7-lite + shared backbone**.

This version mainly fixes six things:

1. **Conference applications and grant applications are separated, while sharing the same workflow foundation**
   - conference applications belong to M2-lite
   - grant applications belong to M7-lite
   - the two must remain two independent records and cannot share a single application / decision row

2. **`applications.status` no longer carries final outcomes**
   - `applications.status` expresses workflow state only: `draft / submitted / under_review / decided`
   - `decisions.final_status` expresses the formal result: `accepted / rejected / waitlisted`
   - `decisions.release_status` expresses whether the result is visible to the applicant: `unreleased / released`

3. **M7-lite formally enters the physical model**
   - add `grant_opportunities`
   - add typed fields required by grant applications
   - add `post_visit_reports`

4. **M4-lite is no longer only an applicant profile**
   - add public unique identifier `slug` to `profiles`
   - allow admin-seeded reviewer / scholar profiles in the schema
   - require minimal conflict-aware semantics for review assignment

5. **Conference–Grant dependency has a real database implementation**
   - grant applications must bind to `linked_conference_application_id`
   - the linked conference application must belong to the same applicant and the same linked conference
   - conference rejection blocks grant-award release in the MVP

6. **Applicant Dashboard derived semantics are supported by the database**
   - allow typed dashboard items to be produced through views / services
   - `viewer_status`, `next_action`, and `post_visit_report_status` are derived read-model fields and should not directly pollute base tables

---

## 2. Overall modeling principles

### 2.1 First lock complete object boundaries, then decide what is actually persisted in this phase

The full product eventually covers 13 modules, but V1.1 only persists objects directly related to the MVP's primary closed loop:

- users, roles, institutions, scholar profiles, MSC
- conference
- grant opportunity (currently conference travel grant only)
- typed applications
- files
- reviewer assignment / review / decision
- post-visit report
- audit / status history

### 2.2 Product boundaries and technical reuse must both hold

At the database layer, it is acceptable to:
- use one `applications` table to carry both conference and grant applications
- use one `decisions` table to carry formal results for both types

At the database layer, it is not acceptable to:
- collapse conference applications and grant applications into a single record
- use `applications.status` to directly represent `accepted / rejected / waitlisted`
- replace M7's grant object with a single boolean field

### 2.3 Prefer structured fields; allow JSONB for fast-changing content

Must be structured:
- status
- type
- reviewer assignment
- decision
- release gate
- foreign keys
- timestamps

May initially be semi-structured:
- application form schema
- extra answers
- profile snapshot
- object settings

### 2.4 Prefer derived viewer-safe semantics over base-table storage

The following are better produced through views / service layers:
- `viewer_status`
- `source_module`
- `source_title`
- `released_decision.display_label`
- `next_action`
- `post_visit_report_status = not_started`

---

## 3. Canonical domain model (from the perspective of the full product)

### 3.1 Identity & Registry Layer
Core entities:
- `users`
- `user_roles`
- `profiles`
- `institutions`
- `msc_codes`
- `profile_msc_codes`
- `coi_relationships` (future)
- `profile_publications` (future)

Purpose:
- support M4 Academic Directory / Expertise Registry
- provide reviewer / expert sources for M2 / M3 / M6 / M7 / M14

### 3.2 Opportunity & Workflow Layer
Core entities:
- `conferences`
- `grant_opportunities`
- `applications`
- `application_files`
- `review_assignments`
- `reviews`
- `decisions`
- `post_visit_reports`
- `application_status_history`

Purpose:
- support the current real closed loop of M2 / M7
- carry forward the M3 direction through a shared backbone

### 3.3 Public & Content Layer (future)
- `videos`
- `publications`
- `newsletter_issues`
- `outreach_resources`

### 3.4 Governance & Partner Layer (future)
- `committees`
- `votes`
- `meetings`
- `partner_organizations`
- `industry_problem_submissions`

### 3.5 Cross-Cutting Layer
- `file_assets`
- `audit_logs`
- `notification_outbox` (future)
- `system_jobs` (future)

---

## 4. Actual persisted scope in V1.1

This version recommends physically persisting the following objects:

- `users`
- `user_roles`
- `institutions`
- `profiles`
- `msc_codes`
- `profile_msc_codes`
- `file_assets`
- `conferences`
- `conference_staff`
- `grant_opportunities`
- `applications`
- `application_files`
- `review_assignments`
- `reviews`
- `decisions`
- `post_visit_reports`
- `post_visit_report_files`
- `application_status_history`
- `audit_logs`

> Note: `grant_staff` is not modeled separately at this stage. During the MVP, grant managers inherit capabilities from the linked conference's `conference_staff`.

---

## 5. Core relationship diagram (text version)

- one `user` can have multiple `user_roles`
- one `user` maps to at most one `profile`
- one `institution` can be associated with multiple `profiles`
- one `profile` can be associated with multiple `msc_codes`
- one `conference` can have multiple `conference_staff`
- one `conference` can have multiple conference applications
- one `conference` can have multiple `grant_opportunities`
- one `grant_opportunity` can have multiple grant applications
- `applications` distinguishes conference / grant through `application_type`
- one grant application must point to one `linked_conference_application_id`
- one application can attach multiple `file_assets`
- one application can have multiple `review_assignments`
- one `review_assignment` has at most one `review`
- one application has at most one `decision`
- one funded grant application has at most one `post_visit_report`
- `application_status_history` records workflow-state changes for applications
- `audit_logs` records broader system actions

---

## 6. Enum design

### 6.1 Identity basics
- `user_status`: `active | inactive | suspended`
- `user_role`: `applicant | reviewer | organizer | admin`
- `institution_status`: `active | inactive | pending`
- `profile_verification_status`: `unverified | pending_review | verified | rejected`
- `career_stage`: `undergraduate | masters | phd | postdoc | faculty | other`

Note:
- `Visitor` remains an unauthenticated public-facing viewer state in product/design terms and is not persisted as a database `user_role`

### 6.2 Opportunity
- `conference_status`: `draft | published | closed`
- `grant_opportunity_status`: `draft | published | closed`
- `grant_type`: `conference_travel_grant`

### 6.3 Workflow
- `application_type`: `conference_application | grant_application`
- `application_status`: `draft | submitted | under_review | decided`
- `participation_type`: `attendee | talk | poster`
- `review_assignment_status`: `assigned | review_submitted | cancelled`
- `review_recommendation`: `accept | reject | waitlist`
- `decision_kind`: `conference_admission | travel_grant`
- `decision_final_status`: `accepted | rejected | waitlisted`
- `decision_release_status`: `unreleased | released`
- `conflict_state`: `clear | flagged`

### 6.4 File / Read Model
- `file_role`: `cv | abstract_attachment | supporting_document | post_visit_report_attachment`
- `file_visibility`: `private | internal | public`
- `post_visit_report_status`: `not_started | submitted`
- `applicant_viewer_status` (recommended for view / read-model use only):
  - `draft`
  - `submitted`
  - `under_review`
  - `result_released`
- `next_action` (recommended for view / read-model use only):
  - `continue_draft`
  - `view_submission`
  - `view_result`
  - `submit_post_visit_report`
  - `view_report`

---

## 7. Table design (V1.1)

## 7.1 `users`

Purpose: authentication subject.

Key fields:
- `id`
- `email`
- `password_hash`
- `auth_provider`
- `status`
- `email_verified_at`
- `last_login_at`
- `created_at`
- `updated_at`

Notes:
- the database does not store a single `role` directly on `users`
- the currently active role is handled by the API / session layer

---

## 7.2 `user_roles`

Purpose: support multi-role users.

Key fields:
- `id`
- `user_id`
- `role`
- `is_primary`
- `granted_by_user_id`
- `created_at`

Key constraints:
- `(user_id, role)` is unique
- each user may have at most one `is_primary = true`

---

## 7.3 `institutions`

Purpose: institution directory and profile affiliation.

Key fields:
- `id`
- `slug`
- `name`
- `country_code`
- `website`
- `contact_email`
- `is_member`
- `status`
- `created_at`
- `updated_at`

---

## 7.4 `profiles`

Purpose: the minimal expert-registry / scholar-profile foundation for M4-lite.

Key fields:
- `user_id`
- `slug`
- `full_name`
- `title`
- `institution_id`
- `institution_name_raw`
- `country_code`
- `career_stage`
- `bio`
- `personal_website`
- `research_keywords`
- `orcid_id`
- `coi_declaration_text`
- `is_profile_public`
- `verification_status`
- `verified_at`
- `verified_by_user_id`
- `created_at`
- `updated_at`

Notes:
- this table simultaneously supports:
  - my profile
  - public scholar profile
  - organizer reviewer-candidate sourcing
  - reviewer identity context
  - admin-seeded scholar / reviewer profiles
- `slug` is the stable path identifier for public profiles
- current physical field names intentionally retain a slightly older storage vocabulary; for product/UI wording, map them as follows:
  - `institution_name_raw` -> applicant/public-facing affiliation text
  - `title` -> current position label placeholder, pending a future cleanup to a clearer `position` field
  - `research_keywords` -> current product-layer keywords; if `research_area_tags` becomes distinct later, that should be added intentionally rather than inferred implicitly
  - `personal_website` -> personal page URL
  - `orcid_id` -> ORCID identifier/link placeholder; UI may render it as an ORCID link
- `research_keywords` stays as `text[]`, balancing simplicity and searchability
- `coi_declaration_text` only carries the MVP's minimum declaration and does not equal a full network-wide COI engine

Suggested indexes:
- case-insensitive unique index on `slug`
- index on `institution_id`
- index on `country_code`
- index on `verification_status`
- GIN index on `research_keywords`

---

## 7.5 `msc_codes`

Purpose: standardized research-classification dictionary.

Key fields:
- `code`
- `label`
- `parent_code`
- `level`
- `is_active`
- `created_at`

---

## 7.6 `profile_msc_codes`

Purpose: many-to-many relation between profiles and MSC codes.

Key fields:
- `user_id`
- `msc_code`
- `is_primary`
- `created_at`

Key constraints:
- `(user_id, msc_code)` is unique
- each user may have at most one primary MSC code

---

## 7.7 `file_assets`

Purpose: unified file metadata, while file bodies live in object storage.

Key fields:
- `id`
- `owner_user_id`
- `file_role`
- `visibility`
- `storage_provider`
- `storage_key`
- `original_name`
- `mime_type`
- `size_bytes`
- `checksum_sha256`
- `uploaded_at`
- `deleted_at`
- `created_at`
- `updated_at`

Notes:
- both applications and reports attach files through association tables
- future video / publication objects can also reuse this layer

---

## 7.8 `conferences`

Purpose: the conference opportunity object for M2-lite.

Key fields:
- `id`
- `slug`
- `title`
- `short_name`
- `location_text`
- `start_date`
- `end_date`
- `description`
- `application_deadline`
- `status`
- `application_form_schema_json`
- `settings_json`
- `published_at`
- `closed_at`
- `created_by_user_id`
- `created_at`
- `updated_at`

Notes:
- some fields may be null during the draft stage
- publish / close completeness checks should be enforced in the service layer
- `status` is the overall lifecycle and is no longer called `publication_status`

---

## 7.9 `conference_staff`

Purpose: conference-scoped organizer permissions.

Key fields:
- `id`
- `conference_id`
- `user_id`
- `staff_role`
- `created_at`

Key constraints:
- within the same conference, the same user may have only one staff record

---

## 7.10 `grant_opportunities`

Purpose: the independent grant object for M7-lite. The current subtype is conference travel grant only.

Key fields:
- `id`
- `linked_conference_id`
- `slug`
- `title`
- `grant_type`
- `description`
- `eligibility_summary`
- `coverage_summary`
- `application_deadline`
- `status`
- `report_required`
- `application_form_schema_json`
- `settings_json`
- `published_at`
- `closed_at`
- `created_by_user_id`
- `created_at`
- `updated_at`

Notes:
- the grant detail / apply page can be opened independently
- the current grant manager capability reuses the linked conference's `conference_staff`
- when `report_required = true`, a funded grant application must later provide a `post_visit_report`

---

## 7.11 `applications`

Purpose: typed main application table for the shared workflow backbone.

Key fields:
- `id`
- `application_type`
- `applicant_user_id`
- `conference_id`
- `grant_id`
- `linked_conference_id`
- `linked_conference_application_id`
- `status`
- `participation_type`
- `statement`
- `abstract_title`
- `abstract_text`
- `interested_in_travel_support`
- `travel_plan_summary`
- `funding_need_summary`
- `extra_answers_json`
- `applicant_profile_snapshot_json`
- `submitted_at`
- `decided_at`
- `created_at`
- `updated_at`

Key semantics:
- conference application:
  - `application_type = conference_application`
  - `conference_id` is not null
  - `grant_id / linked_conference_id / linked_conference_application_id` are null
- grant application:
  - `application_type = grant_application`
  - `grant_id` is not null
  - `linked_conference_id` is not null
  - `linked_conference_application_id` is not null
  - `conference_id` is null

Design notes:
- conference applications and grant applications must be two separate records
- `interested_in_travel_support` is only a weak-intent field in the conference application and must not automatically create a grant application
- the grant application's prerequisite is enforced through `linked_conference_application_id`
- `applicant_profile_snapshot_json` freezes review context at submission time
- `applications.status` expresses workflow only and never the final result

Suggested indexes:
- partial unique: one conference application per applicant per conference at most
- partial unique: one grant application per applicant per grant at most
- conference queue index
- grant queue index
- applicant list index

---

## 7.12 `application_files`

Purpose: many-to-many association between applications and files.

Key fields:
- `application_id`
- `file_asset_id`
- `display_order`
- `created_at`

---

## 7.13 `review_assignments`

Purpose: task table for organizer / admin reviewer assignment.

Key fields:
- `id`
- `application_id`
- `reviewer_user_id`
- `assigned_by_user_id`
- `status`
- `conflict_state`
- `conflict_note`
- `due_at`
- `assigned_at`
- `completed_at`
- `cancelled_at`
- `created_at`
- `updated_at`

Key notes:
- `conflict_state` is the minimum COI gate in the current MVP
- flagged assignments may exist, but they must not be allowed to submit reviews
- reviewers must have a reviewer/admin identity and must also have a profile record
- the partial unique strategy should allow reassigning the same reviewer after cancellation

---

## 7.14 `reviews`

Purpose: review submitted by a reviewer for an assignment.

Key fields:
- `id`
- `assignment_id`
- `score`
- `recommendation`
- `comment`
- `submitted_at`
- `created_at`
- `updated_at`

Notes:
- `score` may be null or used lightly in the MVP
- one assignment has at most one review

---

## 7.15 `decisions`

Purpose: formal application-based result record for M2/M7 workflow objects.

Key fields:
- `id`
- `application_id`
- `decision_kind`
- `final_status`
- `release_status`
- `note_internal`
- `note_external`
- `decided_by_user_id`
- `decided_at`
- `released_at`
- `created_at`
- `updated_at`

Design notes:
- this table is application-scoped in the current MVP and is not intended to be a universal all-platform decision engine
- a conference application's `decision_kind` must be `conference_admission`
- a grant application's `decision_kind` must be `travel_grant`
- `release_status` determines whether the applicant can see the result
- once a decision is created, the application workflow moves into `decided`
- in the MVP, conference rejection blocks grant-award release

---

## 7.16 `post_visit_reports`

Purpose: independent report object attached to a funded grant application.

Key fields:
- `id`
- `grant_application_id`
- `status`
- `title`
- `report_text`
- `submitted_at`
- `created_at`
- `updated_at`

Notes:
- it belongs only to grant applications, not conference applications
- `not_started` is better represented as a derived read-model state at the current stage
- when a base-table row exists, it should currently be treated as `submitted`

---

## 7.17 `post_visit_report_files`

Purpose: attachment association table for post-visit reports.

Key fields:
- `report_id`
- `file_asset_id`
- `display_order`
- `created_at`

---

## 7.18 `application_status_history`

Purpose: record workflow-state history for applications.

Key fields:
- `id`
- `application_id`
- `from_status`
- `to_status`
- `changed_by_user_id`
- `reason`
- `created_at`

Notes:
- this table tracks workflow state only
- it does not track `decision.final_status`
- it should not be fully replaced by `audit_logs`

---

## 7.19 `audit_logs`

Purpose: broader system-action audit.

Key fields:
- `id`
- `actor_user_id`
- `entity_type`
- `entity_id`
- `action`
- `payload_json`
- `created_at`

---

## 8. Recommended split between application layer and database layer

### 8.1 Rules recommended for strong database enforcement
1. grant applications must bind to a valid linked conference application
2. the linked conference of a grant application must match the grant object
3. conflict-flagged reviewer assignments must not be allowed to submit reviews
4. decision kind must match application type
5. `release_status` and `released_at` must remain consistent
6. post-visit reports may only attach to grant applications that are released + accepted + `report_required = true`
7. when `application.status` changes, write to `application_status_history`

### 8.2 Rules better enforced by the service layer
1. whether all required fields are complete before conference / grant publish
2. applicant profile completeness threshold
3. form-level required-field rules
4. organizer scope-permission checks
5. viewer-safe shaping (applicants cannot see unreleased decisions)
6. dashboard sorting / CTA copy
7. automated conflict rules (currently manual / operational only)

---

## 9. Recommended state transitions

### 9.1 Conference / Grant Opportunity
- `draft -> published -> closed`

### 9.2 Application
- `draft -> submitted -> under_review -> decided`

### 9.3 Decision
- `unreleased -> released`

### 9.4 Review Assignment
- `assigned -> review_submitted`
- `assigned -> cancelled`

### 9.5 Applicant-facing derived state
- `draft`
- `submitted`
- `under_review`
- `result_released`

### 9.6 Post-Visit Report
- `not_started` (derived by absence)
- `submitted` (physical row exists)

---

## 10. Key migration points from V1 to V1.1

1. **`applications.status` enum changes**
   - remove: `accepted / rejected / waitlisted`
   - add / retain: `draft / submitted / under_review / decided`

2. **Expanded `decisions` semantics**
   - add `decision_kind`
   - add `release_status`
   - add `released_at`

3. **New formal objects**
   - `grant_opportunities`
   - `post_visit_reports`
   - `post_visit_report_files`

4. **Public unique identifier added to `profiles`**
   - add `slug`

5. **Conflict fields in review assignment are normalized**
   - tighten from raw `conflict_check_status / conflict_override_reason` into the more stable `conflict_state / conflict_note`

6. **`applications` becomes a typed shared table**
   - add `application_type`
   - add `grant_id`
   - add `linked_conference_id`
   - add `linked_conference_application_id`
   - change `needs_travel_support` to `interested_in_travel_support`

> In implementation, pair this with a dedicated migration script rather than editing enums directly in a production database.

---

## 11. Objects already in the worldview but not yet physically modeled

### 11.1 Deeper M4
- `profile_affiliations`
- `coi_relationships`
- `profile_publications`
- `orcid_sync_runs`

### 11.2 M2 / M8 extensions
- `schools`
- `conference_registrations`
- `schedule_slots`
- `dining_matches`

### 11.3 M5 / M9 / M12 / M13
- `newsletter_issues`
- `videos`
- `publications`
- `outreach_resources`

### 11.4 M10 / M14
- `committees`
- `votes`
- `partner_organizations`
- `industry_problem_submissions`

---

## 12. Recommended follow-up artifacts

If implementation is going to continue, the most valuable next artifacts are:

1. **v1 -> v1.1 migration plan**
2. **ER diagram**
3. **SQL read-model draft for dashboard / organizer queues**
4. **seed data plan (conference accepted + grant rejected / waitlisted / unreleased / report-required)**
