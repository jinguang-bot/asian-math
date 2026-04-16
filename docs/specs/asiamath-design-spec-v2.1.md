# Asiamath Design Spec V2.1

> Status: Draft V2.1  
> Goal: Define the shared product skeleton for the Demo and MVP, including information architecture, pages, flows, states, permissions, and module touchpoints.  
> Alignment baseline: The system map is primary; the design skeleton must be compatible with the current MVP / Demo direction.  
> Principle: **The product skeleton is shared; Demo and MVP diverge only in data source, page mode, and implementation depth.**

---

## 1. Overall Design Principles

1. **Shared IA first**: Keep the information architecture, routing, page IDs, and core component naming consistent.
2. **Module ownership clear**:
   - conference opportunity / conference application still belong to **M2-lite**;
   - grant opportunity / travel grant application still belong to **M7-lite**;
   - the shared application / review / decision page skeleton is **implementation-level reuse aligned with the M3 direction**, and does not change the product ownership of M2 / M7.
3. **Story-first**: Support the primary narrative first, then add breadth modules; do not build isolated pages detached from the main storyline.
4. **State-rich with canonical semantics**: Key pages must distinguish empty state, in-progress state, internal-result state, and externally visible released-result state.
5. **Role-explicit + permission-explicit**: Distinguish not only Visitor / Applicant / Organizer / Reviewer / Admin, but also clearly define what each role can see and cannot do.
6. **Demo-ready**: Even if the backend is not fully connected, key pages must still support a complete walkthrough; however, the page structure, naming, and state semantics must not diverge from the MVP.
7. **Page-mode explicit**: Demo pages must explicitly label `Real-aligned / Hybrid / Static preview`, so the audience can understand the depth of the demo.

---

## 2. Information Architecture

> Note: The IA below is the shared skeleton. The MVP does not need to implement every public module as a full system, but the Demo should provide a clear entry point or touchpoint for all 13 modules as much as possible.

### 2.1 Public Layer
- Home
- About / Network
- Institutions
- Events (aggregate page; can serve as a discovery entry)
- Opportunities (aggregate page; can serve as a discovery entry)
- Conferences
- Conference Detail
- Schools
- School Detail
- Grants
- Grant Detail
- Prizes
- Prize Detail / Archive Preview
- Videos
- Video Detail
- Publications
- Publication Detail
- Newsletter
- Newsletter Detail
- Outreach
- Industry & Partners
- Public Scholar Profile

### 2.2 Account Layer (Applicant / Identity Layer)
- Register
- Login
- My Dashboard (light summary page; can be `/me`)
- My Profile
- My Applications (main applicant work page)
- My Application Detail / Result
- Post-Visit Report

### 2.3 Workspace Layer
- Organizer Dashboard
- Reviewer Dashboard
- Admin Dashboard
- Governance Preview (in the Demo, this can serve as an admin / authenticated preview)

### 2.4 Module Touchpoint Mapping (13 modules → first entry / touchpoint)

| Module | Module Name | Primary Entry / Touchpoint | Default Page Mode |
|---|---|---|---|
| M1 | Public Portal | Home | Real-aligned / Hybrid |
| M2 | Conference Organisation | Conference list / detail / apply / organizer queue | Real-aligned |
| M3 | Application System | application form shell / My Applications / reviewer task / decision panels | Shared backbone representation |
| M4 | Academic Directory & Expertise Registry | Profile edit / public scholar profile / reviewer source chip | Real-aligned / Hybrid |
| M5 | Newsletter | newsletter list / detail | Static / Hybrid |
| M6 | Prizes & Awards | prize archive / detail / nomination preview | Static / Hybrid |
| M7 | Travel Grants & Fellowships | grant list / detail / apply / post-visit report | Real-aligned / Hybrid |
| M8 | Schools & Training | school list / detail / travel-support teaser | Static / Hybrid |
| M9 | Video Library | video list / detail | Static / Hybrid |
| M10 | Governance | admin nav / governance preview | Static / Hybrid |
| M12 | Publications | publication list / detail | Static / Hybrid |
| M13 | Outreach | outreach landing / resources | Static / Hybrid |
| M14 | Industry & Partners | partners landing / expert-matching teaser | Static / Hybrid |

### 2.5 Surfacing Rules
- **Home / M1** must explicitly surface: M2, M6, M8, M13; and provide content-type entry points to M5, M9, and M12.
- **Conference detail / M2** is the anchor of the primary narrative and must bring forward: M4 scholar context, M7 related grant, and output-layer teasers (M5 / M9 / M12).
- **School detail / M8** must include a `travel support available`-type cue so that the M8 ↔ M7 relationship is visible.
- **Governance / M10** should not be designed as a normal public page; it is more suitable as an admin / authenticated preview.
- **Industry & Partners / M14** must connect with M4 through the concept of scholar / expertise matching.

---

## 3. Routing Strategy

### 3.1 Public Routes
- `/`
- `/about`
- `/institutions`
- `/events`
- `/opportunities`
- `/conferences`
- `/conferences/:slug`
- `/conferences/:slug/apply`
- `/schools`
- `/schools/:slug`
- `/grants`
- `/grants/:slug`
- `/grants/:slug/apply`
- `/prizes`
- `/prizes/:slug`
- `/videos`
- `/videos/:id`
- `/publications`
- `/publications/:id`
- `/newsletter`
- `/newsletter/:slug`
- `/outreach`
- `/partners`
- `/scholars/:slug`

### 3.2 Account / Applicant Routes
- `/register`
- `/login`
- `/me`
- `/me/profile`
- `/me/applications`
- `/me/applications/:id`
- `/me/applications/:id/post-visit-report`

### 3.3 Workspace Routes
- `/organizer`
- `/organizer/conferences/:id`
- `/organizer/conferences/:id/applications`
- `/organizer/grants/:id`
- `/organizer/grants/:id/applications`
- `/organizer/applications/:id`
- `/reviewer`
- `/reviewer/assignments/:id`
- `/admin`
- `/admin/users`
- `/admin/profiles`
- `/admin/conferences`
- `/admin/grants`
- `/admin/governance`

### 3.4 Route Naming Rules
1. **Module ownership takes priority over shared implementation**:
   - the conference apply entry should remain at `/conferences/:slug/apply`;
   - the grant apply entry should remain at `/grants/:slug/apply`;
   - it is not recommended to design these two user-side entries so that they can only be reached through one generic `/applications/new`.
2. **The shared backbone may appear in the back office / applicant workspace**:
   - `/me/applications/:id`
   - `/organizer/applications/:id`
   - `/reviewer/assignments/:id`
   These may use a shared application detail shell, but the page must display both `application type` and `source module`.
3. **Grant is not a subfield route under conference**: grant detail / apply should be independently openable, even if its opportunity object is associated with a conference.

---

## 4. Canonical Objects & Status Semantics

### 4.1 Core Objects
- `scholar_profile` (M4-lite)
- `conference` (M2-lite)
- `grant_opportunity` (M7-lite)
- `conference_application` (M2-owned application object)
- `grant_application` (M7-owned application object)
- `review_assignment`
- `review`
- `decision`
- `post_visit_report`

### 4.2 Object Ownership Notes
- `conference_application` and `grant_application` may share the form / review / decision UI skeleton, but in product semantics they must remain **two separate records**.
- Under the current MVP subtype, `grant_application` should be associated with a conference, but it must not be merged in the UI into the conference application itself.
- `decision` is an application-level object, not a conference-level unified result slot.

### 4.3 Canonical Status Model

**UI-only empty state**
- `empty` only means "there is currently no record / no data"; it is not a business-object status enum.

**Opportunity status**
- `conference.status = draft | published | closed`
- `grant_opportunity.status = draft | published | closed`

**Application status**
- `application.status = draft | submitted | under_review | decided`

**Decision**
- `decision.final_status = accepted | rejected | waitlisted`
- `decision.release_status = unreleased | released`

**Post-visit report**
- `post_visit_report.status = not_started | submitted`

**Assignment conflict state (minimum version)**
- `assignment.conflict_state = clear | flagged`
- When `flagged`, the review submit action must be blocked until the organizer / admin reassigns the task or removes the block.

### 4.4 UI Display Rules
- Applicant-facing pages may show: the applicant's own application status, released result, and next-step CTA.
- Applicant-facing pages **must not** show: unreleased final conclusions.
- Organizer / Admin pages may show: internal decision and release controls.
- Reviewer pages may show: assigned materials and the review action available to the reviewer; if the task is conflict-flagged, the blocking reason must be shown.
- UI copy may use natural-language phrasing, but the underlying status semantics must not conflict with the canonical model above.

---

## 5. Roles and Permissions

| Role | Visible Content | Core Actions | Explicit Restrictions |
|---|---|---|---|
| Visitor | Public pages, public scholar profile, conference / grant / school / content pages | Browse opportunities and content, be guided to register/login | Cannot submit applications, cannot access workspaces, cannot view internal results |
| Applicant | Public layer + `/me` personal area | Edit profile, submit conference application, submit grant application, view released result, submit post-visit report | Can only view their own records; cannot view reviewer/organizer internal information; cannot view unreleased decisions |
| Organizer | Conference / grant workspace within their scope | Create / edit / publish opportunities, view application queues, assign reviewers, make internal decisions, release results | Should not be designed to access all unrelated records; submitting reviews is not an organizer action |
| Reviewer | Reviewer dashboard and assignment pages assigned to them | View materials, submit review recommendation | Can only handle assigned and non-conflicted tasks; cannot release decisions |
| Admin | System management pages + necessary operational override pages | User/role management, seed reviewer/scholar profiles, correct data, handle exceptions, open governance preview | Does not equal a full governance engine; governance flow is preview-only in the Demo |

### 5.1 Minimum Permission Rules
- Reviewers participating in M2 / M7 review should have a corresponding `M4 profile record`.
- During assignment, organizers should select reviewers from `M4-backed expert records`.
- A conflict-flagged reviewer cannot submit a review.
- The applicant dashboard must display conference applications and grant applications separately.
- The organizer workspace needs to clearly separate `internal decision` from `released to applicant`.

---

## 6. Page Inventory and Key States

## 6.1 Home (M1)
**Purpose**: Build network-level understanding and organize the main entry points of the 13 modules into an understandable public portal.  
**Core sections**:
- Hero / Network positioning
- Featured conferences / grants
- School / training teaser
- Prize / outreach teaser
- Member institutions
- Latest newsletter / video / publication teaser

**Key states**:
- default
- empty dataset
- demo highlight mode

**Design requirements**:
- Must explicitly surface M2, M6, M8, and M13.
- Should link to the content-type pages of M5, M9, and M12.

## 6.2 Conference Detail (M2-lite)
**Purpose**: Carry the flagship opportunity object in the primary narrative.  
**Core sections**:
- title / date / location / organizer
- description / themes / deadlines
- CTA: Apply / Register
- related travel grant teaser / CTA
- public scholar context (organizer / speaker / applicant examples may be hybrid)
- related outputs (video / publication / newsletter teaser)

**Key states**:
- published open
- published closed
- application unavailable
- already applied
- related grant available / unavailable

**Design requirements**:
- conference detail is the entry point for the `conference application`.
- the travel grant may only be introduced through a teaser and should not be visually merged into a single application form.

## 6.3 Grant Detail (M7-lite)
**Purpose**: Present an independent but related mobility support object.  
**Core sections**:
- title
- linked conference summary
- description
- eligibility summary
- coverage summary
- deadline
- report requirement note
- CTA: Apply

**Key states**:
- published open
- published closed
- prerequisite missing (for example, no submitted conference application yet)
- already applied
- report required

**Design requirements**:
- grant detail should be independently openable.
- if the current grant subtype depends on an already submitted conference application, the CTA must clearly explain the prerequisite instead of failing silently.

## 6.4 Register / Login
**Purpose**: Convert visitors into platform users.  
**Key states**:
- default
- invalid credential
- verification pending
- success

## 6.5 Profile Edit (M4-lite)
**Purpose**: Build a reusable scholar identity and provide a minimum expert source for review / assignment.  
**Fields**:
- name
- email
- affiliation / institution
- position / career stage
- country / region
- research area tags / keywords
- MSC codes
- bio
- personal page
- ORCID (reserved as link)
- COI declaration (minimum version)

**Key states**:
- incomplete
- saved
- validation error

**Design requirements**:
- the profile summary should be reusable in the application form, reviewer view, and organizer view.
- the public scholar profile must share the same field definitions as the edit page.

## 6.6 Public Scholar Profile (M4-lite public surface)
**Purpose**: Establish minimum public scholar visibility and prove that the profile is not just internal form data.  
**Core sections**:
- scholar header
- affiliation / position
- research interests / MSC / keywords
- bio
- external links

**Key states**:
- public visible
- limited visibility / hidden preview

## 6.7 Application Form (shared application shell; M2 / M7 owned objects)
**Purpose**: Complete a real submission.  
**Sections**:
- prefilled profile summary
- module-specific form sections
- attachments
- save draft / submit
- prerequisite note (when needed in the grant scenario)

**Key states**:
- not started
- draft saved
- validation error
- submitted

**Design requirements**:
- the conference application form and grant application form may share layout / components.
- however, the page title, breadcrumbs, and source module label must clearly distinguish them.
- the grant application form needs to support prerequisite checking and explanation for `linked_conference_application_id`.

## 6.8 Applicant Dashboard / My Applications
**Purpose**: Let the applicant see "two separate records + a shared backbone" from an operational point of view.  
**Sections**:
- application cards / table
- application type chip
- status chip
- released result summary (if already released)
- next-step CTA

**Key states**:
- none
- draft exists
- submitted
- under review / pending release
- released result
- report due / report submitted

**Design requirements**:
- conference applications and grant applications must be **separate records**.
- if the conference has already been accepted but the grant has not yet been released, the results must not be mixed together in one merged card.

## 6.9 Applicant Application Detail / Result
**Purpose**: Carry the viewing, result, and next-step actions for a single applicant record.  
**Sections**:
- application summary
- submitted payload snapshot
- status
- released decision banner
- next-step CTA (such as continue draft, view result, submit report)

**Key states**:
- draft editable
- submitted read-only
- under review / pending release
- released result

**Design requirements**:
- before release, the page must not expose the internal final_status.

## 6.10 Organizer Dashboard
**Purpose**: Workspace for an organizer to manage a conference / grant family.  
**Sections**:
- conference or grant summary
- separate application queues
- status filters
- review progress
- internal decision counts
- release queue

**Key states**:
- no applications
- has queue
- review in progress
- internal decisions pending release
- released decisions available

**Design requirements**:
- it must support the distinction between conference and grant; do not build only a conference queue.
- if the grant is associated with a conference, the design should still preserve clear boundaries between the two management objects.

## 6.11 Application Detail Shell (Organizer / Reviewer)
**Purpose**: View a single application and allow role-based actions.  
**Shared sections**:
- applicant snapshot
- full application payload
- attachments
- source module / application type indicator

**Organizer panels**:
- reviewer assignment panel
- conflict flag / note
- review summary
- decision panel
- release control

**Reviewer panels**:
- assignment status
- conflict state
- review form / submit CTA

**Key states**:
- unassigned
- assigned
- conflict flagged
- partial reviews
- ready for decision
- decided but unreleased
- released

**Design requirements**:
- this is a shared detail shell, not a case where "all roles see the same buttons."
- the reviewer view and organizer view must be permission-trimmed.

## 6.12 Reviewer Dashboard
**Purpose**: Focus on the reviewer's minimum workflow.  
**Sections**:
- assigned list
- due date
- status
- conflict flag
- review CTA

**Key states**:
- none assigned
- pending
- conflict blocked
- submitted

## 6.13 Post-Visit Report (M7 follow-up)
**Purpose**: Complete the minimum closed loop for a funded travel grant.  
**Sections**:
- award / grant summary
- report title
- report text
- optional file upload
- submit CTA

**Key states**:
- not available
- not started
- submitted

## 6.14 School Detail / Preview (M8)
**Purpose**: Show that M8 is not another name for conference, and explicitly surface the travel-support relationship.  
**Core sections**:
- school summary
- training / pedagogical positioning
- audience / program outline
- travel support available teaser / CTA
- outputs teaser (video / publication / newsletter)

**Key states**:
- preview only
- travel support available
- travel support unavailable

## 6.15 Breadth Module Preview Pages (M5 / M6 / M9 / M10 / M12 / M13 / M14)
**Purpose**: Give the platform real breadth touchpoints without weakening the primary narrative.  
**Suggested modes**:
- Newsletter: archive list + issue detail
- Prizes: archive + nomination/review concept preview
- Videos: video list + detail
- Governance: authenticated governance preview (documents / policy / voting concept)
- Publications: list + detail
- Outreach: landing + resources
- Industry & Partners: landing + expert matching teaser

**Key states**:
- static preview
- hybrid preview
- empty / coming soon (use only when truly necessary)

**Design requirements**:
- these pages may not need full real functionality, but they should not be dead ends; at minimum, they need clear context, entry, and return paths.

---

## 7. Core User Flows

## 7.1 Applicant Primary Flow
1. Enter Conference detail from Home / Opportunities.
2. View the related travel grant teaser.
3. Click Conference Apply.
4. Register / Login.
5. Complete Profile.
6. Submit the conference application.
7. Enter grant detail / apply and submit the travel grant application.
8. See **two separate records** in My Applications.
9. Wait for organizer / reviewer processing.
10. See the released result.
11. If the grant is funded, enter post-visit report.

## 7.2 Organizer Primary Flow
1. Create a conference.
2. Publish the conference.
3. View conference applications.
4. Select reviewers from M4-backed records.
5. See the basic conflict flag / note during assignment.
6. Record the internal decision after receiving reviews.
7. Control release.
8. Handle related grant applications separately.

## 7.3 Reviewer Primary Flow
1. Log in to the reviewer dashboard.
2. View assigned items.
3. If the task is conflict-flagged, see the blocked state and reason.
4. If the task is clear, open application detail.
5. Fill in and submit the review.

## 7.4 Decision Release Flow
1. The organizer records the internal decision in application detail.
2. On the applicant side, the UI still shows `under review / pending release`.
3. The organizer performs the release action.
4. The applicant sees the released result banner in My Applications / detail.

## 7.5 Demo Extended Flows
- Schools browsing and travel-support teaser
- Prize archive and nomination preview
- Newsletter / Video / Publication content browsing
- Governance preview
- Industry & Partners expert-matching teaser

---

## 8. Component Recommendations

### 8.1 Global Components
- top nav
- side nav (workspace)
- role badge / role switcher (usable in Demo)
- page mode badge (`Real-aligned / Hybrid / Static preview`)
- status badge / chip
- decision visibility banner
- info card
- data table
- empty state
- timeline / activity log
- file uploader
- conflict flag chip

### 8.2 Reusable Components
- profile summary card
- public scholar card
- opportunity card
- grant teaser card
- application record card
- application status chip
- decision banner
- next-step CTA card
- review score / recommendation block
- module teaser block

### 8.3 Shared Page Shells
- opportunity detail shell
- application form shell
- application detail shell
- workspace dashboard shell
- module preview shell

### 8.4 Component Usage Rules
- shared shells may be reused, but the header / breadcrumb / chips must expose the source module.
- `conference application` and `grant application` must not be visually merged just because they share components.
- `decision banner` and `application status chip` must be two different semantic layers and must not be mixed.

---

## 9. Visual and Interaction Guidelines

- The public layer should emphasize trust, clarity, and an academic-institution feel.
- The workspace layer should emphasize efficiency, readability, and information density.
- Keep the number of CTAs restrained; ideally each page should have only one main button.
- Avoid overly long form flows; use sections and fixed progress indicators.
- Role and page mode must be visible, not just mentioned in the spoken walkthrough.
- Blocked actions must explain the reason, such as prerequisite missing or conflict blocked.
- `release` should be shown through a clear banner / state change, not by silently letting the applicant see a new result.
- Even the Demo's static / hybrid pages should simulate real system feedback and should not use fake buttons.
- The travel-support teaser on the School detail page needs to become a fixed design pattern, not a temporary piece of copy.

---

## 10. Rules for Handling Demo / MVP Divergence

### 10.1 Allowed Divergences
- data source: mock vs real
- content volume: static samples vs real records
- page mode: `Real-aligned / Hybrid / Static preview`
- certain complex functions: placeholder, read-only, or preview-only
- implementation depth of breadth modules: the Demo may first show entry points and page skeletons, while the MVP may temporarily not implement real functionality

### 10.2 Disallowed Divergences
- page structure
- routing and module ownership
- field naming
- state naming / state semantics
- main CTA placement
- role entry logic
- object independence of M2 / M7
- design semantics of release control
- basic COI blocking logic

### 10.3 Page-mode Labeling Rules
- Every key page in the Demo should display its page mode.
- Key pages include at least: Home, Conference detail, Grant detail, My Applications, Organizer Dashboard, Reviewer Dashboard, Application Detail, School detail, Governance preview.
- If a page is `Hybrid`, the UI should make it clear which areas are real-aligned and which are mock / preview.

---

## 11. Appendix

### 11.1 M2 ↔ M7 Dependency Notes
- Under the current MVP subtype, grant application depends on an already submitted conference application.
- This dependency should be explicitly expressed in the UI rather than hidden in backend logic.
- The grant result and conference result are still two separate decision records.

### 11.2 Minimal COI / Assignment Notes
- A minimum version of manual COI handling is allowed.
- The assignment stage should show conflict flag / note.
- The submit CTA of a conflict-flagged reviewer must be disabled.

### 11.3 Naming Notes
- On the user side, prefer natural-language labels: Conference Application, Travel Grant Application.
- In the back office and technical implementation, a shared application shell may be reused, but the product naming must preserve the `conference` / `grant` distinction.
