# Asiamath Demo PRD V3.1

> Status: Working Draft V3.1  
> Purpose: define the **Demo track** for Asiamath.  
> This document focuses on how to **tell the full product story clearly and convincingly**, without requiring all capabilities to be fully implemented.  
> It is aligned with the current MVP direction in **MVP PRD V3.2** and should remain consistent with the system map: **M1-lite + M2-lite + M4-lite + M7-lite + shared application/review/decision backbone aligned with the M3 direction**.

---

## 1. Demo Goal

The Demo is not meant to show a few isolated pages.  
It should show Asiamath as a **network-level digital platform** for:

- public discovery
- scholar identity
- academic opportunity workflows
- mobility funding
- long-term knowledge and institutional accumulation

The Demo should make the platform feel:

- coherent
- product-like
- role-aware
- believable
- broader than the MVP, while remaining consistent with it

---

## 2. Relationship Between Demo and MVP

### 2.1 One front-end product shape, two delivery tracks

The project follows a **dual-track delivery model**:

- **Demo track**: broader visual and interaction coverage, using mock/static data where needed
- **MVP track**: thinner but real implementation, with real auth, data persistence, applications, reviews, and decisions

### 2.2 Shared constraints

Demo and MVP must share the same:

- product information architecture
- page map
- route logic
- object naming
- status semantics
- M2-M7 dependency logic
- role boundaries
- API contract direction

The Demo must **not** invent a different product shape from the MVP.

### 2.3 M3 framing in the Demo

M3 remains important conceptually, but the Demo should frame it correctly:

- **conference opportunity + conference application** remain part of **M2-lite**
- **grant opportunity + travel grant application** remain part of **M7-lite**
- the shared application / review / decision backbone is **implementation-level reuse aligned with the M3 direction**
- the Demo may surface this shared backbone through application pages, dashboards, review tasks, and decision states
- the Demo should **not** imply that conference flow has been absorbed into M3 as a separate end-user module

### 2.4 Practical distinction

The Demo may show:

- full-page previews
- mock states
- hybrid pages
- non-implemented but navigable modules

The MVP must only implement the real thin core.

---

## 3. Demo Success Criteria

The Demo is successful if:

1. the platform clearly feels like **one integrated system**
2. all **13 modules** have visible entry points or meaningful touchpoints, and these are traceable in the Demo coverage map
3. at least one **full end-to-end primary story** can be demonstrated smoothly
4. at least three **secondary stories** show breadth
5. the audience can understand:
   - public discovery
   - scholar profile reuse
   - conference workflow
   - travel grant workflow
   - school/training extensibility
   - role-specific operations
   - long-term content / governance / partner expansion
6. the Demo can be delivered in roughly **8-12 minutes**
7. the presenter does not need to explain missing logic verbally for core pages; the UI itself should make the story understandable
8. the audience can tell **which role** and **which page mode** is currently being shown
9. the Demo never contradicts MVP boundaries, object naming, or status semantics

---

## 4. Demo Narrative Strategy

### 4.1 Primary story

The primary story should be:

**Visitor -> Conference Discovery -> Public Scholar Context -> Register/Login -> Complete Scholar Profile -> Submit Conference Application -> Submit Related Travel Grant Application -> Applicant Dashboard Shows Two Separate Records -> Organizer Review Queue -> Reviewer Assignment with Basic COI Check -> Reviewer Evaluation -> Internal Decision -> Release -> Applicant Sees Distinct Results -> Funded Applicant Submits Post-Visit Report**

This story is strong because it demonstrates:

- **M1**: public discovery surface
- **M2**: flagship conference object and conference application flow
- **M4**: scholar profile reuse plus reviewer / expert source layer
- **shared application / review / decision backbone aligned with M3 direction**
- **M7**: independent but connected mobility funding flow
- **role-based operations**: organizer / reviewer / applicant
- **release control**: decision exists before it becomes visible to applicant
- **basic COI awareness**: reviewer assignment is not purely generic; conflict can block review submission

Important framing for the Demo:

- the **conference application** shown in the primary story is still an **M2-lite application object**
- the **travel grant application** shown in the primary story is still an **M7-lite application object**
- the Demo uses shared backbone language to explain reuse, not to collapse the two records into one

### 4.2 Secondary stories

Recommended secondary stories:

### A. Schools & Training (M8)
Show that the platform supports another opportunity family beyond conferences.  
The preferred Demo move is:

- show school listing/detail
- show that the school is distinct from a conference
- show a **travel support available** badge, CTA, or teaser to make the M8 <-> M7 relationship visible

### B. Prizes & Awards (M6)
Show confidential nomination/review logic and the value of scholar identity + governance.

### C. Newsletter / Video / Publications (M5 / M9 / M12)
Show that conferences and schools become long-term network assets.

### D. Governance (M10)
Show that the platform is not just operational, but institutional.  
This should be framed as a **governance preview**, not a full governance engine.

### E. Industry & Partners (M14)
Show future-facing external collaboration potential, including expert matching concepts that rely on M4.

---

## 5. Demo Audience Assumption

The Demo should be understandable to:

- project sponsors
- academic organizers
- institutional partners
- faculty / committee stakeholders
- non-technical reviewers

So the Demo should prioritize:

- clarity over technical detail
- coherent product logic over implementation detail
- realistic flow over feature quantity

---

## 6. Target Roles in the Demo

### 6.1 Visitor
A non-logged-in user.

Can:
- browse homepage
- open conference pages
- open grant pages
- open public scholar profiles
- open school pages
- open public content pages such as newsletter / video / publications / outreach previews

### 6.2 Applicant / Researcher
A logged-in scholar.

Can:
- maintain scholar profile
- submit conference application
- submit travel grant application
- view released outcomes
- view separate application records in Applicant Dashboard / My Applications
- submit post-visit report

### 6.3 Reviewer
Can:
- access assigned, non-conflicted applications
- read profile/materials
- submit review recommendation

Should also visibly encounter:
- blocked submission if a review task is conflict-flagged

### 6.4 Organizer
Can:
- create/publish conference
- manage conference and grant applications
- assign reviewers from M4-backed expert records
- see basic conflict flags / notes during assignment
- issue and release decisions

### 6.5 Admin
Can:
- do organizer actions
- perform minimal operational correction / override
- resolve role or workflow issues in the Demo story if needed
- open governance-preview pages when helpful for the Demo narrative

---

## 7. Demo Design Principles

### 7.1 Demo must feel like a real product
Avoid dead-end pages and disconnected mockups.

### 7.2 Every important CTA should lead somewhere meaningful
Even if the destination is static or hybrid, it should feel intentional.

### 7.3 Use canonical states, not ad-hoc wording
At minimum, important flows should clearly distinguish:

- **UI-only empty state**: no record yet
- **opportunity status**: `draft / published / closed`
- **application status**: `draft / submitted / under_review / decided`
- **decision visibility**: internal but unreleased vs released to applicant
- **post-visit report state**: not started vs submitted

UI copy may vary, but the Demo should not invent a status model that conflicts with the MVP.

### 7.4 Keep role switching understandable
The Demo should clearly indicate:

- which role is being shown
- which actions are allowed for that role
- when the presenter has switched context

### 7.5 Keep page mode understandable
Every non-trivial page should visibly indicate whether it is:

- **Real-aligned**
- **Hybrid**
- **Static preview**

The audience should not have to guess which parts are fully real versus demonstrative.

### 7.6 Show breadth without overloading the main story
The primary story should stay focused; breadth can be shown through controlled branching.

### 7.7 Every surfaced module should be traceable
If a module is counted as covered in the Demo, it should have:

- a clear first entry point, or
- a meaningful touchpoint connected to a real page in the story

### 7.8 Do not over-promise hidden complexity
The Demo may preview future capability, but should not rely on presenter explanation to hide product-model inconsistencies.

---

## 8. Module-Level Demo Coverage Strategy

| Module | Name | Demo Coverage | Delivery Mode | Demo Focus |
|---|---|---|---|---|
| M1 | Public Portal | High | Hybrid | homepage, entry points, browsing |
| M2 | Conference Organisation | High | Hybrid / Real-aligned | conference detail, conference apply, organizer queue |
| M3 | Application System | High | Shared infrastructure touchpoints aligned with M3 direction | application detail, dashboard, review and decision states |
| M4 | Academic Directory | High | Hybrid / Real-aligned | public profile, profile edit, reviewer source, conflict-aware assignment context |
| M5 | Newsletter | Medium | Static / Hybrid | archive and article detail |
| M6 | Prizes & Awards | Medium | Static / Hybrid | archive and selection-process concept preview |
| M7 | Travel Grants & Fellowships | High | Hybrid / Real-aligned | independent travel grant detail/apply/result/report |
| M8 | Schools & Training | Medium | Static / Hybrid | listing, detail, application preview, travel-support teaser |
| M9 | Video Library | Medium | Static / Hybrid | video list and detail |
| M10 | Governance | Low-Medium | Static / Hybrid | committee / policy / oversight preview, not full engine |
| M12 | Publications | Medium | Static / Hybrid | publication list and detail |
| M13 | Outreach | Low-Medium | Static | public outreach articles / resources |
| M14 | Industry & Partners | Low-Medium | Static / Auth-gated preview | partner-facing preview and expert matching concept |

### Important note on M7
In the Demo, M7 should be shown as a **real module family**, not just one field inside conference apply.

However:
- only **conference travel grant** needs full detailed flow alignment with MVP
- other mobility/funding types can appear as mock cards, previews, or future-facing stubs
- the Demo should also make visible that M7 relates not only to **conferences (M2)** but also to **schools and training (M8)**

---

## 9. Primary Demo Script

### 9.1 Portal entry (M1)
- open homepage
- show Asiamath positioning
- show that M1 surfaces:
  - featured conference / conference listing entry (M2)
  - prize archive entry (M6)
  - school / training entry (M8)
  - outreach entry (M13)
- show visible links or teasers to:
  - newsletter (M5)
  - video library (M9)
  - publications (M12)
- click into a featured conference

### 9.2 Conference detail (M2)
- show title, time, location, description, deadline
- show clear CTA for **conference application**
- show related travel grant entry
- show scholar links or organizer/speaker context
- optionally show output preview area that later connects to M5 / M9 / M12

### 9.3 Public scholar context (M4)
- open a public scholar profile
- show:
  - name
  - affiliation
  - position
  - research area tags
  - MSC codes
  - keywords
  - personal page / ORCID links
- explain that the same scholar profile is reused throughout the platform
- make clear that M4 is not just a public profile page; it also underpins reviewer / expert sourcing behind the scenes

### 9.4 Register / login + profile completion
- switch to applicant role
- show registration/login
- show profile edit page
- complete / preview scholar profile
- keep role label visible while switching from public browsing to authenticated flow

### 9.5 Conference application (M2 application object)
- start conference application
- profile-derived fields appear consistently
- fill in statement / abstract / attachment
- save draft / submit
- applicant dashboard shows **conference application** state as its own record
- use status language aligned with the MVP, for example `draft -> submitted`

### 9.6 Travel grant application (M7 application object)
- return to related travel grant entry
- open thin grant detail page
- show that it is independent but connected
- make visible that this grant is linked to the current conference
- if useful, note or show that grant submission depends on an existing **submitted conference application** for the linked conference
- start travel grant application
- submit grant application
- applicant dashboard shows a **separate grant record**, not a merged record

### 9.7 Organizer operations
- switch to organizer role
- show conference application queue
- show grant application queue
- open one application detail
- assign reviewer from M4-backed expert records
- show one candidate with a **basic conflict flag** or note
- assign a non-conflicted reviewer
- highlight again that conference and grant are separate application objects

### 9.8 Reviewer operations
- switch to reviewer role
- show assigned tasks
- if useful, show that a conflict-flagged assignment is blocked from review submission
- open a valid non-conflicted task
- read application + profile context
- submit recommendation/comment

### 9.9 Decision and release
- switch back to organizer/admin
- show **internal decision state** before applicant visibility
- issue conference decision and grant decision as **separate decision records**
- release result
- demonstrate that applicant only sees results after release
- show distinct outcomes, for example:
  - conference: accepted
  - travel grant: awarded / waitlisted / rejected

### 9.10 Applicant dashboard / result view
- switch back to applicant role
- open Applicant Dashboard / My Applications
- show conference application and travel grant application as two separate records
- show current workflow state and next-step CTA for each record
- open result view
- make unreleased vs released distinction legible in the Demo narrative

### 9.11 Post-visit report
- for a funded grant case, open post-visit report page
- show:
  - report title
  - report text
  - optional file upload
- demonstrate that mobility support has a post-award lifecycle

### 9.12 Long-term asset layer
From the conference or result context, pivot to:
- M5 newsletter item
- M9 video recording
- M12 publication / report

This closes the story:  
the platform is not only for applying and deciding, but for accumulating network value.

### 9.13 Quick breadth pass after the main story
After the primary story, do a short breadth pass to show:

- **M8** school detail page with travel-support teaser
- **M6** prize archive / process preview
- **M10** governance preview page
- **M14** partner-facing preview linked to expert matching direction

---

## 10. Recommended Secondary Page Coverage

### 10.1 High-priority pages (should feel polished)
- home
- conference list
- conference detail
- login / register
- profile edit
- public profile
- conference application
- travel grant detail
- travel grant application
- applicant dashboard / My Applications
- organizer application queues
- application detail
- reviewer task page
- result page
- post-visit report page

### 10.2 Medium-priority pages (must be navigable and coherent)
- school listing/detail
- school travel-support teaser / CTA
- prize archive/detail
- newsletter archive/article
- video list/detail
- publication list/detail
- outreach landing or resource page

### 10.3 Low-priority pages (can be static preview pages)
- governance pages
- policy pages
- committee pages
- partner portal preview
- outreach resource detail pages

### 10.4 Entry-point rule
Any page counted in Demo coverage should be reachable from a visible CTA, nav item, teaser block, or role-based workspace link.  
Coverage should not rely on hidden routes only the presenter knows.

---

## 11. Demo Data Requirements

### 11.1 Core sample data
- 1 main conference with complete metadata
- 1 related conference travel grant
- 1 school entry with travel-support teaser or badge
- 8-15 scholar profiles
- at least 2 reviewer-eligible scholar profiles
- 3-5 conference applications
- 2-3 travel grant applications linked to conference applications
- 2-3 review assignments
- at least 1 conflict-flagged reviewer assignment example
- 2-3 review records
- at least 1 internal but unreleased decision
- 2-3 released decisions
- 1 funded grant case with post-visit report example
- 3 newsletter items
- 3 videos
- 3 publications
- 2 prize examples
- 3 member institutions / partner examples

### 11.2 Recommended Demo cases
To make the story concrete, sample data should support at least these cases:

- **Case A**: conference application submitted, grant application submitted
- **Case B**: conference accepted, grant waitlisted
- **Case C**: conference accepted, grant rejected
- **Case D**: one internal decision exists but is not yet released to applicant
- **Case E**: one reviewer candidate is conflict-flagged and cannot complete review submission

### 11.3 Demo roles / accounts
- Visitor
- Applicant
- Reviewer
- Organizer
- Admin

---

## 12. Demo Scope Rules

### 12.1 Page mode labels are required
Every important Demo page should show a page-mode marker:

- **Real-aligned**
- **Hybrid**
- **Static preview**

### 12.2 Must look real
These areas should feel real enough that the presenter does not need to explain basic missing logic:

- public browsing
- scholar profile
- conference detail
- conference application
- travel grant application
- applicant dashboard
- organizer/reviewer states
- result/release states

### 12.3 Can be hybrid
These can mix real structure with mock data:

- queues with mock data
- linked outputs
- secondary module details
- school detail / teaser flows
- some review-assignment states

### 12.4 Can be static preview
These can be visually coherent preview pages without full workflow depth:

- governance
- partner portal
- outreach
- some archive pages

### 12.5 Permission and status semantics must still be respected
Even when data is mocked or hybrid:

- applicants should only appear to see their own records
- applicants should not appear to see unreleased decisions
- reviewers should only appear to act on assigned, non-conflicted tasks
- organizers / admins should be the ones issuing and releasing decisions

---

## 13. What Demo Must Not Imply Incorrectly

The Demo should not accidentally suggest that the following are already fully real if they are not:

- ORCID live integration
- full scholar directory search
- full mobility grant family implementation
- reimbursement workflow
- generic workflow builder
- governance voting engine
- full committee/workflow governance automation
- publication/DOI production pipeline
- advanced analytics

Additional framing guardrails:

- M10 pages in the Demo are **governance preview surfaces**, not proof that full governance tooling is already implemented
- M14 pages in the Demo are **partner / collaboration previews**, not proof that a full partner portal is already live
- M3 should be framed as shared application infrastructure direction, not as a separate end-user product experience that replaces M2 or M7

The UI may preview these directions, but should not confuse them with current MVP reality.

---

## 14. Demo-Specific Messaging

The Demo should communicate three layers clearly:

### Layer 1: Public discoverability
People can find opportunities, scholars, and outputs.

### Layer 2: Shared operational backbone
Conference and travel grant flows reuse shared profile/application/review/decision logic while remaining separate opportunity and application records.

### Layer 3: Institutional maturity
The platform can grow into governance, publications, partner collaboration, and long-term network memory.

---

## 15. What This Demo PRD Does Not Define

This document defines:

- the Demo story
- coverage priorities
- role visibility
- page expectations
- narrative structure
- module entry / touchpoint logic
- page-mode labeling requirements

It does **not** fully define:

- API fields
- database columns
- exact route handler logic
- implementation status by feature
- final front-end component inventory

Those should be aligned later through:

- MVP PRD
- design spec
- technical spec
- API spec
- database schema

---

## 16. Appendix A: Canonical Objects and Statuses for Demo Alignment

The Demo should inherit the MVP's canonical object and status language.

### 16.1 UI-only state
- `empty`
  - means no record yet or no meaningful data for the current surface
  - this is a UI state, not a required database enum

### 16.2 Opportunity status
- `conference.status`: `draft | published | closed`
- `grant_opportunity.status`: `draft | published | closed`

### 16.3 Application status
- `application.status`: `draft | submitted | under_review | decided`

### 16.4 Decision status
- `decision.final_status`: `accepted | rejected | waitlisted`
- `decision.release_status`: `unreleased | released`

### 16.5 Post-visit report status
- `post_visit_report.status`: `not_started | submitted`

### 16.6 Naming rule
UI wording may vary by context, but the underlying state model should remain consistent. Example:

- `decision.final_status = accepted` may render as **Accepted** for conference admission
- `decision.final_status = accepted` may render as **Awarded** for travel grant

---

## 17. Appendix B: 13 Modules -> Demo Entry / Touchpoint Map

| Module | First entry / touchpoint in Demo | Typical surface |
|---|---|---|
| M1 | Homepage / portal | public home |
| M2 | Featured conference card or conference list item | conference detail |
| M3 | Applicant Dashboard / application detail / reviewer task | authenticated workflow pages |
| M4 | Scholar name link from conference, application, or reviewer picker | public profile / profile edit / reviewer assignment |
| M5 | Newsletter teaser from home or output layer | archive / article |
| M6 | Prize card / archive entry from home or nav | prize archive / detail |
| M7 | Related travel grant CTA from conference detail, plus direct grant URL | grant detail / grant apply / result / post-visit report |
| M8 | School card from home or program section | school list / school detail / travel-support teaser |
| M9 | Video teaser from conference or school outputs | video list / detail |
| M10 | Admin nav or governance teaser | governance preview pages |
| M12 | Publication teaser from conference or school outputs | publication list / detail |
| M13 | Outreach block or nav entry on homepage | outreach landing |
| M14 | Partner teaser from footer/nav or partner block | partner preview / auth-gated concept page |

### Mapping rule
If a module appears in the Demo coverage table, at least one of these entry points should be visibly reachable during the Demo or in a backup branch the presenter can open quickly.

---

## 18. Appendix C: Role Switch / Page-Mode Labeling Rules

### 18.1 Role label
Every authenticated screen used in the Demo should visibly show the current role:

- Visitor
- Applicant
- Reviewer
- Organizer
- Admin

### 18.2 Page-mode label
Every important screen should visibly show one of:

- Real-aligned
- Hybrid
- Static preview

### 18.3 Suggested placement
For consistency, place role label and page-mode label in the same predictable area, such as:

- page header
- top toolbar
- environment ribbon

### 18.4 Sample-data label
Where appropriate, pages may also show a small indicator such as:

- Demo data
- Sample record
- Preview state

### 18.5 Interpretation rule
These labels exist to prevent confusion. They should make it obvious when:

- the presenter has changed role
- the page is partly mocked
- the user should interpret a page as narrative coverage rather than proof of full implementation
