# Asiamath Technical Spec V2.1

> Status: Draft V2.1  
> Goal: define a **parallelizable technical backbone that does not cause conflicts across workstreams**, so that Demo, Design, API, and Database share the same implementation boundaries.  
> Alignment baseline: **system map first**; also aligned with the latest MVP / Design / API definitions.  
> Principles: **clear product ownership, strong technical reuse, stable front-end/back-end contracts, and an evolvable database.**

---

## 1. Where this document sits in the overall document system

This document does not replace:
- the PRD's definition of scope
- the Design Spec's definition of IA / routes / page states
- the API Spec's definition of front-end/back-end field contracts
- the Database Schema / DDL's definition of the actual persisted model

It addresses the middle layer:

1. **How module boundaries become implementation boundaries**
2. **How the shared backbone is reused without blurring product ownership**
3. **How responsibilities are divided across front end, BFF, service layer, and database**
4. **Which rules must be enforced in the service layer instead of relying only on UI hints**

### 1.1 Main fixes in V2.1

Compared with V2, this version mainly fixes the following:

1. **Tightened M2 / M3 / M7 boundaries**  
   Conference opportunity / conference application still belong to **M2-lite**; grant opportunity / grant application still belong to **M7-lite**. Shared application/review/decision reuse happens only at the implementation layer and does not mean the conference flow is product-wise absorbed into M3.

2. **M4 is upgraded from an "applicant profile" to a minimal expert registry**  
   In addition to applicant-managed profiles, the system must support reviewer candidate sourcing, admin-seeded scholar / reviewer profiles, and minimal conflict-aware assignment.

3. **`application.status` is fully separated from decision outcome semantics**  
   - `application.status` expresses workflow state only  
   - `decision.final_status` expresses the formal result  
   - `decision.release_status` expresses whether the result is visible to the applicant

4. **Travel Grant formally enters the technical backbone**  
   The current MVP subtype is conference travel grant, but the technical backbone must formally accommodate:
   - grant opportunity
   - grant application
   - grant review / decision
   - post-visit report

5. **Applicant Dashboard becomes a typed aggregation**  
   `/me/applications` can no longer default to returning only conference applications. It must support both conference and grant records side by side.

---

## 2. Technical goals

1. Support **Demo static presentation** and **MVP real implementation** in parallel  
2. Ensure the front end always calls the same contract, without depending on "real API vs mock API" differences  
3. Allow the current MVP to form a real closed loop without blocking future evolution for M7 / M8 / M6 / M10  
4. Ensure key rules are enforced in the service layer / DB guard layer rather than only described in documents  
5. Make task breakdown support multi-session work, structured handoff, E2E validation, and clean-state transitions

---

## 3. Reference architecture

### 3.1 Front end
- single web app
- shared IA / routes / page shell / component naming
- provider / adapter pattern for reading mock or real data
- role-aware navigation
- page modes explicitly distinguished as: `Real-aligned / Hybrid / Static preview`

### 3.2 BFF / API layer
- expose a unified `/api/v1` contract to the front end
- responsible for viewer-safe shaping, permission filtering, and union-object normalization
- hide lower-layer storage naming differences and future schema evolution details

### 3.3 Domain service layer (recommended logical split)
- `auth-service`: registration, login, session, current user
- `profile-directory-service`: profiles, institutions, MSC, public scholar profile, reviewer sourcing
- `conference-service`: conference create/edit/publish/close, public list/detail
- `grant-service`: grant opportunity create/edit/publish/close, linked-conference rules, post-visit report
- `workflow-service`: application draft/submit, review assignment, review, decision, release control
- `file-service`: file upload, access control, binding relationships
- `admin-service`: role management, profile seeding, exception handling, basic override

> These can initially live in one repo / one backend physically, but logically they should be separated along the service boundaries above.

### 3.4 Data layer
- relational database stores core objects and states
- object storage stores attachments
- audit logs record key state changes
- both service and DB layers must guarantee:
  - applicants cannot see unreleased results
  - conflict-flagged reviewers cannot submit reviews
  - conference and grant remain separate application / decision records

---

## 4. Shared contract and routing principles

### 4.1 The front end should always call a unified contract
Do not write two separate front-end flows such as:
- `fetchDemoConference()`
- `fetchRealConference()`

The data source should be selected via provider / environment config:
- mock provider
- api provider

### 4.2 API versioning
Key resources should consistently use `v1` semantics, for example:
- `GET /api/v1/conferences`
- `POST /api/v1/conferences/:id/applications`
- `POST /api/v1/grants/:id/applications`
- `POST /api/v1/organizer/applications/:id/decision`
- `POST /api/v1/organizer/applications/:id/release-decision`

### 4.3 Product ownership takes precedence over shared implementation
- the conference apply entry should remain at `/conferences/:slug/apply`
- the grant apply entry should remain at `/grants/:slug/apply`
- it is not recommended to expose only one generic `/applications/new` entry on the user side
- `/me/applications/:id`, `/organizer/applications/:id`, and `/reviewer/assignments/:id` may reuse a shared application-detail shell, but they must display:
  - `application_type`
  - `source_module`
  - `source_title`

### 4.4 Viewer-safe shaping is an API-layer responsibility
Applicant-facing contracts must:
- not return internal details of unreleased decisions
- not leak, through applicant-visible fields, that an internal result already exists
- use `viewer_status`, `released_decision`, and `next_action` to express the user's currently visible state

### 4.5 Stable fields first
Even during the Demo phase, the following should be locked:
- object ids
- status enums
- role enums
- route params
- timestamps
- file metadata
- union discriminators for typed application lists

---

## 5. Canonical domain model

## 5.1 Identity & registry layer (M4-lite foundation)

### User / Role
At the database layer, a single-role design such as `users.role` is not recommended as the final design. Recommended structure:
- `users`
- `user_roles`
- `conference_staff`
- `grant_staff` (future option only; current MVP reuses `conference_staff` for grant management)

The API layer may return the current active role, but the underlying model should allow one person to be an applicant / reviewer / organizer / admin at the same time.

### Scholar Profile / Expert Registry
The minimal profile must support:
- public scholar page
- applicant application prefill
- organizer / reviewer access to a profile summary in application detail
- reviewer candidate sourcing
- basic COI / conflict-aware assignment
- admin-seeded scholar / reviewer profiles

The profile layer should at minimum include:
- full_name
- institution / country
- career_stage
- research_keywords
- MSC codes
- ORCID placeholder field
- public visibility
- minimal COI declaration text

---

## 5.2 Opportunity layer

### Conference (M2-lite)
Minimal conference object:
- id
- slug
- title
- location
- start_date
- end_date
- description
- application_deadline
- status
- published_at

### Grant Opportunity (M7-lite)
The current MVP only supports conference travel grants, but the object itself must still be an independent grant opportunity:
- id
- slug
- title
- grant_type
- linked_conference_id
- description
- eligibility_summary
- coverage_summary
- application_deadline
- status
- report_required
- published_at

> `linked_conference_id` indicates that the grant is related to a conference, but the grant detail / apply page should still be independently accessible.

---

## 5.3 Shared workflow backbone (implementation-layer reuse)

### Application
A **shared workflow backbone + typed application** design is recommended:
- `application_type = conference | grant`
- `source_module = M2 | M7`
- `source_id` / typed foreign key points to the specific opportunity object

But regardless of whether the database ultimately uses a typed shared table or separate physical tables, the implementation must satisfy:
- conference applications and grant applications are **two separate records**
- each has an independent decision
- they may be linked, but may not be merged into a single record

Minimal application-level fields:
- id
- application_type
- source_module
- applicant_user_id
- status
- submitted_at
- decided_at
- payload / extra answers
- profile snapshot

### Review Assignment
Minimal assignment fields:
- id
- application_id
- reviewer_user_id
- assigned_by_user_id
- status
- conflict_state
- conflict_note
- assigned_at
- completed_at

### Review
- assignment_id
- recommendation
- score (optional or lightweight)
- comment
- submitted_at

### Decision
- application_id
- final_status
- release_status
- note_internal
- note_external
- decided_by_user_id
- decided_at
- released_at
- optional decision payload

### Post-Visit Report
M7-lite requires an independent object:
- grant_application_id
- status
- report_title
- report_text
- optional file
- submitted_at

---

## 5.4 Canonical status semantics

### UI-only
- `empty` only represents a UI no-record state; it is not a database enum

### Opportunity
- `conference.status = draft | published | closed`
- `grant_opportunity.status = draft | published | closed`

### Application
- `application.status = draft | submitted | under_review | decided`

### Decision
- `decision.final_status = accepted | rejected | waitlisted`
- `decision.release_status = unreleased | released`

### Post-Visit Report
- `post_visit_report.status = not_started | submitted`

### Assignment Conflict
- `assignment.conflict_state = clear | flagged`

> `accepted / rejected / waitlisted` should no longer be placed in `application.status`.

---

## 6. API / BFF shape recommendations

This section does not replace the API Spec; it only defines how the technical layer should organize interface groups.

### 6.1 Auth
- `/auth/register`
- `/auth/login`
- `/auth/logout`
- `/auth/me`

### 6.2 Profile / Directory
- `/profile/me`
- `/scholars/:slug`
- organizer reviewer-candidate sourcing endpoint
- admin profile seed / correction endpoint

### 6.3 Public opportunity surface
- `/conferences`
- `/conferences/:slug`
- `/grants`
- `/grants/:slug`

### 6.4 Applicant workflow
- `POST /conferences/:id/applications`
- `POST /grants/:id/applications`
- `PUT /me/applications/:id/draft`
- `POST /me/applications/:id/submit`
- `GET /me/applications`
- `GET /me/applications/:id`
- `GET /me/applications/:id/post-visit-report`
- `PUT /me/applications/:id/post-visit-report`

### 6.5 Organizer workflow
- conference create / edit / publish / close
- grant create / edit / publish / close
- organizer queues for conference / grant
- application detail
- assign reviewer
- make decision
- release decision

### 6.6 Reviewer workflow
- reviewer assignments list
- reviewer assignment detail
- review submit
- blocked-state read model when conflict flagged

### 6.7 Admin workflow
- user / role management
- profile seeding / correction
- conference / grant exception handling
- governance preview entry (not a full governance engine)

---

## 7. Permissions and security rules (must be enforced in implementation)

### 7.1 Applicant
- can only view their own application / report
- can only view released decisions
- cannot obtain internal decisions / unreleased results through `/me/*` endpoints

### 7.2 Organizer
- can only access conferences / grants within their management scope
- can create internal decisions
- can control release
- cannot submit reviews on behalf of reviewers

### 7.3 Reviewer
- can only view assigned applications
- when `conflict_state = flagged`, the review-submit action must be blocked
- reviewers must not release decisions

### 7.4 Admin
- can manage users / roles / profile seeding / exception correction
- is not equivalent to a full governance engine
- M10 is only a preview / minimal operational support layer at the current stage

### 7.5 File access
- applicant files are private by default
- organizers / reviewers can only access files tied to applications they are authorized to view
- public scholar profiles must not leak private application attachments

---

## 8. Demo / MVP data modes

### 8.1 Demo
- local mock JSON / fixtures
- static sample attachments
- role switcher
- preconfigured conference / grant / review / decision / release states
- pages explicitly labeled as `Real-aligned / Hybrid / Static preview`

### 8.2 MVP
- real API
- real DB
- real file upload
- real role permissions
- real viewer-safe result release
- minimal COI / conflict guard

### 8.3 Hybrid strategy
- some pages may initially be driven by a mock provider
- contract fields remain unchanged; only the provider is swapped
- BFF output shape remains consistent between Demo and MVP

### 8.4 Minimum Demo sample-data requirements
At minimum, prepare the following samples so both pages and rules can be demonstrated:
- conference accepted + grant rejected
- conference accepted + grant waitlisted
- one internal but unreleased decision
- one conflict-flagged reviewer assignment
- one funded grant application eligible to submit a post-visit report

---

## 9. Data-layer implementation guidance and next-step schema constraints

This section provides constraints for the next round of database schema / DDL revisions.

### 9.1 Core semantics that must be reflected in the database
1. `application.status` must no longer carry final admission outcomes  
2. `decisions` must include `release_status` and `released_at`  
3. `grant_opportunities` must become a formal object rather than a boolean extension on conference  
4. `post_visit_reports` must become a formal object  
5. reviewer assignments must have conflict-aware fields and must be able to block review submission  
6. global roles and scoped staff must not be collapsed into a single field

### 9.2 Recommended physicalized direction
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
- `grant_staff` (future option only; current MVP reuses `conference_staff` for grant management)
- `applications` (typed shared workflow table recommended)
- `application_files`
- `review_assignments`
- `reviews`
- `decisions`
- `post_visit_reports`
- `application_status_history`
- `audit_logs`

### 9.3 Allow some implementation freedom at the database layer
The database layer may:
- adopt a typed shared `applications` table, or
- adopt a more complex physical split plus service-layer aggregation

But it must not violate the following contracts:
- the applicant dashboard must list both conference and grant records
- application detail must have a stable `application_type`
- conference and grant must keep separate result records
- unreleased decisions must never be visible to applicants

---

## 10. ORCID and COI strategy

### 10.1 ORCID
Current recommendation:
- V1: keep the `orcid_id` field and UI placeholder
- V1.1: integrate OAuth
- V2: support deeper publication sync / profile enrichment

### 10.2 COI
The system map treats COI as M4's network-level infrastructure, so at the current stage the system must at least support:
- manual COI declaration field
- minimal conflict state visible during organizer assignment
- conflict-flagged tasks blocking review submission
- reviewer / expert sourcing traceable back to M4-backed profiles

Automated COI rules, graph relationships, and institution-level auto-filtering can be deferred to later versions.

---

## 11. Testing strategy

### 11.1 Minimum test pyramid
- contract checks
- integration checks
- end-to-end happy path
- rule-guard checks (release gate / COI block / permission boundary)

### 11.2 Required MVP E2E flows
#### Conference main loop
1. register
2. log in
3. complete profile
4. browse conferences
5. submit conference application
6. organizer views application
7. organizer assigns reviewer
8. reviewer submits review
9. organizer makes internal decision
10. organizer releases result
11. applicant views released result

#### Travel Grant main loop
1. applicant enters grant detail from conference detail or grants list
2. submit grant application
3. organizer / reviewer completes grant review
4. organizer makes grant decision
5. organizer releases grant result
6. funded applicant submits post-visit report

#### Rule verification
- a conflict-flagged reviewer cannot submit a review
- the applicant cannot see unreleased decisions through `/me/*`
- when the conference is rejected, the linked grant must not be released as accepted / waitlisted (if the schema / service layer adopts this guard)

### 11.3 Session-start smoke test
Before each new development session starts, verify:
- the development environment can boot
- login still works
- the conference list can open
- the grant list or linked-grant teaser can open
- `/me/applications` can return a typed list

---

## 12. Feature splitting and handoff mechanism

### 12.1 Feature-first
One development session should focus on a single feature and should not span multiple highly coupled goals.

### 12.2 Feature contract
Before implementation begins, each feature must define:
- scope in
- scope out
- done definition
- e2e steps
- handoff artifacts
- affected contracts (API / schema / permission / status)

### 12.3 Clean state
A feature is considered complete only when all of the following are true:
- the page can open
- the main path works end to end
- data persistence is correct
- permissions and viewer-safe rules are correct
- there is no obvious dirty state
- progress is documented

### 12.4 Handoff artifacts
At minimum include:
- `feature-list.json` update
- `progress-log.md` entry
- related API / schema change notes
- contract snapshot / sample payload
- commit message / changelog

---

## 13. Recommended milestones

### Milestone 1: Identity + Public Surface
- Auth
- Profile / M4-lite base
- Public portal skeleton
- Conference detail
- Linked grant teaser entry

### Milestone 2: Conference Workflow
- Conference create / edit / publish / close
- Conference application form
- File upload
- Applicant dashboard typed list (conference subtype first)
- Organizer queue / reviewer queue

### Milestone 3: Decision / Release / COI Guard
- Review assignment
- Review submit
- Internal decision
- Decision release control
- Conflict-aware assignment / blocked submit

### Milestone 4: Grant Workflow + Report
- Grant opportunity object
- Grant detail / apply
- Grant application queue
- Grant decision + release
- Post-visit report

### Milestone 5: Demo Support / Hardening
- Mock provider parity
- Demo page-mode markers
- Sample-data hardening
- QA hardening
- Deployment prep

---

## 14. Recommended revision order (based on current file state)

1. **Technical Spec (this document)**  
   Lock the implementation boundaries and core rules first, so API / DB do not each invent their own model later.

2. **Database Schema**  
   Use this document plus the API contract to turn the concept model, tables, states, and constraints into concrete definitions.

3. **Database DDL**  
   Only then translate the schema precisely into SQL, avoiding repeated rewrites of enums / foreign keys / trigger design.

---

## 15. What this document does not define

This document defines:
- technical boundaries
- service decomposition
- the relationship between contracts and implementation
- rules such as permission / release / COI that must be enforced
- constraints that the next schema / DDL must carry forward

It does not by itself replace:
- the detailed API field dictionary
- the final column-level database definition
- OpenAPI
- front-end visual and interaction design

Those still belong to:
- API spec
- database schema / DDL
- design spec
