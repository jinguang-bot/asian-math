# Asiamath MVP PRD V3.2

> Status: Working Draft V3.2  
> Purpose: define the scope, boundaries, and success criteria of the first real MVP release.  
> This version keeps the major refinements from V3.1, while tightening alignment with the system map by clarifying **M2/M3/M7 boundaries**, strengthening **M4 as expert-registry + COI foundation**, making **Applicant Dashboard / My Applications** explicit, and adding **canonical objects/statuses**, **minimum permission rules**, and **M2-M7 dependency rules**.

---

## 1. Product Goal

Build a **real, deployable MVP** that proves Asiamath can support:

- a shared scholar profile foundation
- a real conference application flow
- a real travel grant flow
- a shared review / decision backbone
- a minimal public-facing entry point
- organizer / reviewer / admin operations
- persistent storage of real user, application, review, and decision data

The MVP should demonstrate that Asiamath is **not just a static site**, but a usable digital operating layer for academic opportunities and mobility funding.

---

## 2. MVP Thesis

The MVP validates this hypothesis:

> A unified scholar profile + shared application infrastructure can support multiple academic opportunity types without duplicating core workflow logic.

In practical terms, the MVP should prove that the same product foundation can support:

- **conference participation / admission**
- **conference travel grant funding**

while keeping:

- consistent identity
- reusable review workflow
- reusable decision workflow
- distinct application outcomes
- controlled result release to applicants

---

## 3. MVP Scope Summary

### 3.1 Included Modules / Capability Areas

- **M1-lite**: public entry and discovery surface
- **M2-lite**: conference opportunity and conference application flow
- **M4-lite**: scholar profile foundation and minimal expert registry
- **M7-lite**: conference travel grant flow
- **shared application / review / decision infrastructure** aligned with M3 direction
- **applicant dashboard / My Applications**
- **organizer / reviewer / admin workspace**
- **platform foundation capabilities** (auth, persistence, files, minimal admin operations)

### 3.2 Important framing

M3 remains important conceptually, but in MVP it is **not** delivered as:

- a generic workflow engine
- a no-code form builder
- a configurable multi-program orchestration platform

Instead, MVP implements a **shared application / review / decision backbone** reused by M2-lite and M7-lite.

At the **product-module level**:

- conference opportunity and conference application remain part of **M2-lite**
- grant opportunity and travel grant application remain part of **M7-lite**
- the shared backbone is **implementation-level reuse aligned with the M3 direction**
- this does **not** mean M2-lite or M7-lite are absorbed into M3

---

## 4. Target Users and Roles

### 4.1 Visitor
A visitor is a user who is not logged in.

Can:

- browse the public portal
- view conference list and conference detail pages
- view thin travel grant detail pages
- view public scholar profiles
- be guided to register / log in before applying

Cannot:

- create or edit profile
- submit applications
- access review or management functions

### 4.2 Applicant / Researcher
Can:

- register / log in
- build and edit scholar profile
- view conference opportunities
- apply to conferences
- apply to related travel grants
- view separate records in Applicant Dashboard / My Applications
- view application status and released results
- submit post-visit report for funded travel grant

### 4.3 Reviewer
Can:

- access assigned review tasks
- read application materials for assigned, non-conflicted tasks
- submit review recommendation and comments

Cannot:

- access unrelated applications
- issue or release decisions
- submit a review where the assignment is conflict-blocked

### 4.4 Organizer
Can:

- create and publish conference opportunities
- manage conference applications
- manage travel grant applications
- assign reviewers from M4-backed expert records
- issue final decisions
- control decision release

### 4.5 Admin
Can do everything organizer can do, and may additionally:

- perform minimal user / role administration
- seed scholar / reviewer profiles when needed
- correct operational data if needed
- resolve permission or workflow issues
- serve as final escalation owner

---

## 5. Platform Foundation Capabilities

These are not optional background assumptions. They are part of the MVP.

### In Scope
- account registration
- login / logout
- authenticated session handling
- basic role model
- route-level access control for public / applicant / reviewer / organizer / admin surfaces
- database persistence for users, profiles, applications, reviews, decisions, and files
- file upload support
- minimal admin operational access
- basic auditability through stored records and timestamps

### Out of Scope
- enterprise-grade IAM
- full fine-grained permission administration across all future modules
- sophisticated notification center
- full observability / analytics platform
- complex admin console across all future modules

---

## 6. MVP In Scope

## 6.1 M1-lite: Public Entry Layer

### In Scope
- public homepage / portal entry
- conference list page
- conference detail page
- related travel grant entry shown from conference detail page
- thin grant detail page
- links into login / application flow
- public scholar profile page entry points

### Out of Scope
- full public directory experience
- publication / newsletter / video integrations as full systems
- complex institution showcase
- advanced search across all modules

---

## 6.2 M4-lite: Scholar Profile Foundation

### Purpose
Provide a minimal but meaningful scholar identity layer that supports:

- reuse across applications
- basic reviewer / organizer context
- lightweight public scholar visibility
- reviewer / expert sourcing for M2-lite and M7-lite
- basic conflict-aware assignment support

### Required scholar profile fields
Each scholar profile should include:

- **name**
- **affiliation**
- **position**
- **research area tags**
- **MSC codes**
- **keywords**
- **personal page link**
- **ORCID link** (link only, no live integration in MVP)

### Additional internal platform fields
The platform should also maintain internal data such as:

- user id
- email
- role / roles
- visibility setting
- timestamps
- optional reviewer-eligibility / reviewer-source flags
- optional internal COI-related data

### In Scope
- create / edit own profile
- public profile page
- stable profile URL / slug
- profile reuse in application flow
- organizer / reviewer visibility into profile summary when reviewing applications
- admin can seed scholar / reviewer profiles when needed for review operations
- reviewers used in M2-lite and M7-lite should have an M4 profile record

### Minimum expert-registry / COI rules
- M4-lite acts as the minimal expert source for reviewer assignment in M2-lite and M7-lite
- reviewer assignment should surface a **basic conflict flag** and allow manual conflict note entry
- a reviewer with conflict flag on a given assignment cannot submit a review for that application
- organizer / admin can remove and replace a conflicted reviewer

### Out of Scope
- full directory browsing experience
- advanced scholar filtering
- profile claim workflow
- ORCID OAuth
- profile verification workflow
- graph/network visualization
- full automated network-wide COI detection engine

---

## 6.3 M2-lite: Conference Opportunity and Application

### Purpose
Provide a concrete flagship scenario through which the MVP becomes understandable and demonstrable.

### Conference lifecycle states
Conference status should be explicitly modeled as:

- `draft`
- `published`
- `closed`

### In Scope
- organizer creates conference opportunity
- organizer edits conference metadata
- organizer publishes conference
- organizer can later close conference
- public conference list and detail page
- applicant can start conference application
- applicant can save draft
- applicant can submit application
- attachments supported
- organizer application queue
- organizer application detail
- reviewer assignment
- reviewer submits review
- organizer issues final decision
- organizer releases final decision
- applicant sees released result

### Core conference fields (minimum)
- title
- slug
- description
- location
- start date
- end date
- application deadline
- status

### Out of Scope
- full microsite builder
- advanced schedule / program management
- dining or social matching
- payment
- certificate generation
- advanced communications automation

---

## 6.4 M7-lite: Conference Travel Grant

### Purpose
Represent Asiamath's mobility support logic as a **real but minimal** funding flow.

### Important positioning
M7-lite is an **independent lite module**, not merely a checkbox inside conference application.

It should have:

- its own **grant opportunity object**
- its own thin detail / apply page
- its own application
- its own decision
- its own lightweight post-visit report step

### Current MVP subtype
Only one subtype is implemented in MVP:

- **conference travel grant**

### Minimum grant opportunity fields
- title
- slug
- grant type
- linked conference id
- description
- eligibility summary
- coverage summary
- application deadline
- status
- report required

### In Scope
- conference detail page can show related travel grant entry
- grant detail page can be opened independently
- applicant can apply using shared scholar profile
- organizer can manage grant applications
- reviewer can review grant applications
- organizer / admin can issue final grant decision
- organizer / admin can release final grant decision
- funded applicant can submit post-visit report

### Lightweight post-visit report fields
- report title
- report text
- optional file upload
- submitted_at

### Out of Scope
- visiting researcher fellowships
- Research in Pairs / Groups
- early career / PhD support
- reimbursement workflow
- complex budget management
- disbursement tracking
- host institute logistics workflow

---

## 6.5 Shared Application / Review / Decision Backbone

### Core principle
Conference applications and travel grant applications should reuse the same backbone, but remain **distinct applications**.

That means:

- conference application = one application object
- travel grant application = another application object
- they may be linked
- they do not collapse into one single result record

### Why
This supports real scenarios such as:

- conference accepted + travel grant rejected
- conference accepted + travel grant waitlisted
- conference rejected + no grant progression

### Shared capabilities in scope
- authenticated application creation
- draft save
- submit action
- file attachment
- reviewer assignment
- reviewer recommendation
- formal decision by organizer / admin
- decision release control
- applicant-facing result display

---

## 6.6 Applicant Dashboard / My Applications

### Purpose
Provide the applicant-facing operational view that makes the shared backbone visible without collapsing conference and grant records together.

### In Scope
- authenticated applicant dashboard / My Applications page
- separate records for conference applications and travel grant applications
- visible current application status for each record
- visible released-result state for each record
- next-step CTA, where relevant, such as continue draft, view result, or submit post-visit report
- links from dashboard into application detail / result / post-visit report pages

### Out of Scope
- cross-program analytics
- advanced filtering across all future opportunity types
- notification inbox

---

## 7. MVP Core User Flows

## 7.1 Visitor Discovery Flow
1. Visitor opens public portal
2. Visitor browses conference opportunities
3. Visitor opens conference detail page
4. Visitor sees related travel grant entry if applicable
5. Visitor may open public scholar profile pages
6. Visitor is prompted to register / log in before applying

## 7.2 Scholar Profile Flow
1. User registers / logs in
2. User creates or updates scholar profile
3. Profile becomes available for reuse
4. Public profile page can be viewed if visibility allows

## 7.3 Conference Application Flow
1. User discovers conference
2. User opens conference detail page
3. User starts conference application
4. User saves draft and / or submits
5. Organizer sees submission
6. Reviewer is assigned
7. Reviewer submits review
8. Organizer issues final decision
9. Decision is released
10. Applicant sees released result

## 7.4 Travel Grant Flow
1. User sees related travel grant entry from conference detail page
2. User opens grant detail page
3. User applies for conference travel grant
4. Organizer sees submission
5. Reviewer is assigned if applicable
6. Organizer issues final grant decision
7. Decision is released
8. Applicant sees released result
9. If funded travel is completed, applicant submits post-visit report

## 7.5 Applicant Dashboard Flow
1. Applicant opens My Applications
2. Applicant sees conference application and travel grant application as separate records
3. Applicant can distinguish current application status from released-result visibility
4. Applicant opens result page or next-step CTA from the relevant record
5. If grant is funded, applicant sees post-visit report CTA

## 7.6 Reviewer Assignment and COI Flow
1. Organizer opens application detail
2. Organizer selects reviewer candidates from M4-backed records
3. System surfaces basic conflict flag and / or manual conflict note where applicable
4. Organizer avoids or removes conflicted reviewers
5. Only assigned, non-conflicted reviewer can submit review

---

## 8. Application, Review, and Dependency Model

## 8.1 Separate applications
The MVP should treat the following as distinct:

- conference application
- travel grant application

They may be linked at application level, for example via:
- related conference id
- linked conference application id

But they should not be merged into one application object.

## 8.2 Conference-grant dependency rule
For the **conference travel grant** subtype in MVP:

- the grant opportunity is linked to a specific conference via `linked_conference_id`
- grant detail page may be opened from conference detail or directly by URL
- grant submission requires an existing **submitted conference application** for the same linked conference
- the grant application should store `linked_conference_application_id`
- conference decision and grant decision remain separate records even when linked
- if the linked conference application is rejected before grant result release, the grant application cannot be released as awarded or waitlisted; it should still be resolved as a separate grant outcome, typically rejected with explanatory external note

## 8.3 Review vs decision
These must remain distinct.

### Review
- may have multiple records
- comes from reviewers
- is advisory

### Decision
- one current effective result per application
- issued by organizer / admin / panel owner
- is formal outcome

## 8.4 Minimal review assignment / COI handling
- review assignment is a separate record from review submission
- manual COI declaration and basic conflict flag are supported at assignment stage
- a conflicted assignment does not permit review submission
- organizer / admin can reassign the application to another reviewer
- MVP uses **basic manual / operational COI handling**, not a full automated COI engine

---

## 9. Decision Design Principles

Decision should be modeled as **application-based final outcome**, not as:

- a conference-only result object
- or a universal all-purpose decision table for the whole platform

### Recommended conceptual name
- **application_decisions**

### Supported decision kinds in current MVP
- `conference_admission`
- `travel_grant`

### Recommended final status enum
- `accepted`
- `rejected`
- `waitlisted`

UI wording can vary by decision kind. For example:

- conference admission + accepted -> Accepted
- travel grant + accepted -> Awarded

### Internal / external notes
The decision model should preserve both:

- **note_internal**: organizer / admin-facing reasoning and remarks
- **note_external**: applicant-facing result wording

### Release control
MVP should distinguish between:

- decision exists internally
- decision has been released to applicant

Recommended release fields:
- `release_status`
- `released_at`

Recommended release status enum:
- `unreleased`
- `released`

Unreleased decisions should be visible only to the organizer / admin side, not to applicants.

---

## 10. MVP Page / Route Expectations

This section exists to make design and implementation handoff more explicit.

### Public pages in scope
- home / portal
- conference list
- conference detail
- grant detail
- public scholar profile
- login / register

### Authenticated applicant pages in scope
- profile edit
- conference application form
- grant application form
- Applicant Dashboard / My Applications
- result view
- post-visit report

### Authenticated reviewer / organizer / admin pages in scope
- organizer application queue
- application detail
- reviewer task page
- decision / release surface
- minimal admin operational page

### Page clarity rule
Every in-scope page should make the current **object type** and **state** legible. In particular:

- conference application and travel grant application should not look like the same record
- unreleased decision and released result should not look identical
- dashboard should visibly distinguish current workflow state from next-step CTA

---

## 11. MVP Data / Object Expectations

At a product level, MVP expects at least the following object families to exist:

- **users**
- **scholar_profiles**
- **conferences**
- **grant_opportunities**
- **applications**
  - typed at minimum by conference application vs travel grant application
  - may carry `linked_conference_id` and `linked_conference_application_id`
- **review_assignments**
  - reviewer linkage, timestamps, and basic conflict flag / note support
- **reviews**
- **application_decisions**
  - application-linked, with `decision_kind`, `final_status`, and `release_status`
- **file_assets**
- **post_visit_reports**

This does not mean all future-domain complexity is required now.  
It means these are the minimum meaningful object families for the MVP experience.

---

## 12. Success Criteria

The MVP is successful if all of the following are true:

### 12.1 Visitor discovery works
- a visitor can browse public conference content
- a visitor can open grant detail pages
- a visitor can open public scholar profile pages
- the system clearly guides visitors into registration / login before apply actions

### 12.2 Scholar identity and expert-registry baseline work
- a researcher can create and update profile
- profile fields are reusable in applications
- public profile page is viewable
- organizer / reviewer can use profile summary in review context
- admin can seed reviewer profiles where needed for operations

### 12.3 Conference flow works
- organizer can create and publish conference
- conference lifecycle states are respected
- applicant can submit conference application
- reviewer can review
- organizer can decide and release
- applicant can see released outcome

### 12.4 Travel grant flow works
- conference page can lead to related grant
- grant detail page can also be opened directly
- applicant can submit grant application linked to conference application
- organizer / admin can decide grant result independently
- applicant can see released grant outcome
- funded applicant can submit post-visit report

### 12.5 Applicant dashboard works
- applicant can see conference and grant applications as separate records
- current application status is visible
- released result state is visible
- next-step CTA is understandable

### 12.6 Minimal permission and COI rules work
- applicants can see only their own applications and only released decisions
- reviewers can access only assigned, non-conflicted tasks
- organizer / admin can manage assignments and releases
- conflict flag blocks conflicted review submission

### 12.7 Shared backbone is real
- M2 and M7 reuse core application / review / decision structure
- but remain operationally distinct where needed

### 12.8 Platform foundation is real
- real authentication exists
- real persistence exists
- file upload works for required cases
- minimal admin operations are possible
- object timestamps and state transitions are stored

---

## 13. Appendix A: Canonical Objects and Statuses

This appendix exists to keep design, front-end, API, and schema discussions aligned.

### UI-only state
- `empty`
  - means no record yet or no meaningful data for the current surface
  - this is a UI state, not a required database enum

### Opportunity status
- `conference.status`: `draft | published | closed`
- `grant_opportunity.status`: `draft | published | closed`

### Application status
- `application.status`: `draft | submitted | under_review | decided`

### Decision status
- `decision.final_status`: `accepted | rejected | waitlisted`
- `decision.release_status`: `unreleased | released`

### Post-visit report status
- `post_visit_report.status`: `not_started | submitted`

### Naming rule
UI wording may vary by context, but the underlying state model should remain consistent. Example:

- `decision.final_status = accepted` may render as **Accepted** for conference admission
- `decision.final_status = accepted` may render as **Awarded** for travel grant

---

## 14. Appendix B: Minimum Permission and COI Rules

### Role baseline
- **Visitor**: public pages only
- **Applicant**: own profile, own application drafts/submissions, own released results, own post-visit report
- **Reviewer**: assigned, non-conflicted applications only; can submit reviews
- **Organizer**: managed conference / grant records and their linked applications; can assign reviewers, decide, and release
- **Admin**: all organizer capabilities plus minimal role correction, data correction, and reassignment override

### Minimum access expectations
- applicants cannot view other applicants' submissions
- applicants cannot view unreleased decisions
- reviewers cannot issue or release decisions
- reviewers cannot access unassigned applications
- organizer scope should be limited to records they manage, unless admin overrides
- admin acts as operational escalator rather than a substitute for full future governance tooling

### Minimum COI handling
- COI support in MVP is basic and operational, not fully automated
- organizer / admin can mark or record a conflict at assignment stage
- a conflicted reviewer assignment cannot submit a review
- organizer / admin can replace the reviewer while preserving auditability
- M4 remains the source layer for reviewer identity and expertise context

---

## 15. Appendix C: M2-M7 Dependency Rules

1. Conference application and travel grant application are two separate application records.
2. In MVP, the implemented M7 subtype is **conference travel grant** only.
3. A travel grant opportunity links to one conference via `linked_conference_id`.
4. A travel grant submission requires an existing submitted conference application for that conference.
5. The grant application stores `linked_conference_application_id`.
6. Conference decision and grant decision remain separate decision records.
7. Conference rejection blocks grant award in MVP.
8. If conference result is rejected before grant release, the grant application should still be resolved separately, typically with a grant rejection plus explanatory external note.
9. Post-visit report belongs to the funded grant record, not to the conference application.

---

## 16. Out of Scope for MVP

The following are explicitly out of scope:

- ORCID real integration
- generic workflow builder
- generic form builder
- full scholar directory search experience
- fully automated network-wide COI engine
- visiting researcher fellowships
- Research in Pairs / Groups
- early career / PhD support
- full school workflow
- governance workflow / voting system
- partner portal
- publication / newsletter / video systems as full products
- reimbursement and grant finance operations
- enterprise-grade permission administration
- sophisticated analytics

---

## 17. Risks and Scope Controls

### Risk 1: M3 expands into a generic platform
**Control:** keep it framed as shared backbone only.

### Risk 2: M7 becomes a full grant management platform
**Control:** only implement conference travel grant + lightweight post-visit report + explicit dependency rules.

### Risk 3: M4 becomes a full scholar directory product
**Control:** keep public profile page and expert-registry basics, but defer advanced browse / search / automation.

### Risk 4: Conference feature complexity explodes
**Control:** keep M2-lite focused on opportunity + application + review + decision + release.

### Risk 5: Foundation work becomes invisible and under-scoped
**Control:** explicitly keep auth, persistence, file handling, role access, dashboard, and admin basics inside MVP.

---

## 18. Release Strategy

### MVP release style
- internal / limited deployment first
- real database
- real authentication
- real application and decision flows
- demo can use the same contract with mock front-end paths where necessary

### Principle
The MVP must be **thin but real**.

---

## 19. Implementation Order Recommendation

Recommended delivery order:

1. visitor-facing public browsing surface
2. scholar account + profile foundation
3. admin-seeded reviewer / expert profile setup + basic role model
4. conference opportunity create / publish / close
5. conference application flow
6. review assignment + review + decision + release for conference
7. Applicant Dashboard / My Applications
8. conference-related travel grant object and pages
9. travel grant application flow with dependency link to conference application
10. travel grant decision flow
11. post-visit report
12. polish, permission checks, and operational COI handling

---

## 20. What this document does not define

This PRD defines:

- what should exist
- what should not exist
- what the MVP proves
- what minimum state / permission / dependency assumptions should remain stable

It does **not** fully define:

- API fields beyond minimum product-level expectations
- database columns
- route handler design
- front-end component structure
- final visual design system

Those belong in:

- design spec
- technical spec
- API spec
- database schema
