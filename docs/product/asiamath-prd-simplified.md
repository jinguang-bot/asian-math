# Asian Mathematical Network (Asiamath) - Product Requirements Document

> Version: 2.0 (Simplified)
> Date: 2026-04-07
> Status: Core Features & User Flows

---

## 1. Core Features

### 1.1 Feature Overview

Asiamath consists of 14 integrated modules designed to streamline academic collaboration across Asia.

| Module | Name | Priority | Core Function |
|--------|------|----------|---------------|
| **M4** | Academic Directory & Expertise Registry | **P0** | User profiles, expertise matching, conflict-of-interest system |
| **M1** | Public Portal | **P0** | Network front door, event calendar, application listings |
| **M2** | Conference Organisation | **P1** | Registration, abstract submission, Oberwolfach dining matching |
| **M3** | Application System | **P1** | Job postings, referee management, application tracking |
| **M7** | Travel Grants & Fellowships | **P1** | Grant applications, Research in Pairs, visiting fellowships |
| **M8** | Schools & Training | **P1** | Summer schools, research schools, student applications |
| **M6** | Prizes & Awards | **P2** | Prize nominations, selection committee, award announcements |
| **M5** | Newsletter & Communications | **P2** | Bimonthly newsletter, member updates |
| **M9** | Video Library | **P2** | Conference/school recordings archive |
| **M12** | Publications | **P2** | Conference reports, lecture notes, DOI assignment |
| **M10** | Governance | **P3** | Committee management, policy repository |
| **M14** | Industry & Partners | **P3** | Expert consultant directory, industry problem matching |
| **M13** | Outreach | **P3** | Public engagement, educational resources |

### 1.2 Critical Modules (P0-P1)

#### M4 - Academic Directory & Expertise Registry

**Why M4 is Most Critical**:
- All other modules depend on expert profiles (M2, M3, M6, M7, M14)
- Conflict-of-interest filtering is foundational for academic integrity
- MSC codes and ORCID ensure standardization

**Core Capabilities**:
1. **User Registration & Profiles**
   - ORCID OAuth integration
   - Personal information (name, affiliation, email)
   - Research interests (MSC 2020 codes, keywords)
   - Publication list (auto-import from ORCID)
   
2. **Conflict-of-Interest System**
   - Automated detection:
     - Co-authors (last 5 years)
     - Same institution (current or past)
     - PhD supervisor/student relationships
     - Family relationships
   - Manual declaration
   - Annual reminder to update
   
3. **Expert Matching Algorithm**
   - Input: MSC code or research keywords
   - Process:
     - Query M4 database
     - Filter by expertise match, availability, no conflicts
     - Rank by relevance, past review quality, response rate
   - Output: Ranked list of potential reviewers
   
**Use Cases**:
- Conference abstract reviewers (M2)
- Grant application evaluators (M7)
- Prize committee members (M6)
- Industry consultant search (M14)

---

#### M1 - Public Portal

**Core Capabilities**:
1. **Member Institution Directory**
   - Searchable map of member institutions
   - Institution profiles (name, country, website, contact)
   
2. **Upcoming Events Calendar**
   - Conferences, schools, workshops
   - Filter by date, location, topic
   
3. **Application Listings**
   - Job openings
   - Grant calls
   - School applications
   
4. **Prize Archive**
   - Past laureates with photos and citations
   - Prize history and selection criteria

---

#### M2 - Conference Organisation System

**Core Capabilities**:

1. **For Organizers**
   - Conference creation wizard
   - Registration fee management (multiple tiers)
   - Abstract submission and review workflow
   - Programme builder (drag-and-drop scheduling)
   - Microsite auto-generation
   - Real-time registration dashboard
   
2. **For Participants**
   - Online registration and payment
   - Abstract submission (LaTeX support)
   - Travel plan submission
   - Personalized schedule access
   
3. **Oberwolfach-style Dining Matching** ⭐
   - **Problem**: Conference meals are missed networking opportunities
   - **Solution**: Intelligent meal seating arrangements
   - **How It Works**:
     1. Participants privately submit dining preferences:
        - "I would like to dine with..." (up to 5 people)
        - "I would prefer not to dine with..." (optional)
        - Research interests
     2. Algorithm runs 2 weeks before conference:
        - Bipartite matching algorithm
        - Maximizes "mutual preferences" and "research overlap"
        - Respects "do not seat together" requests
        - Ensures each participant meets different people each meal
     3. Organizers review and export seating plans (PDF/Excel)

---

#### M3 - Application System

**Core Capabilities**:

1. **For Institutions**
   - Post job openings (tenure-track, postdoc, visiting)
   - Set application requirements
   - Review submitted applications
   - Request referee letters (automated email)
   - Shortlist candidates
   
2. **For Applicants**
   - Browse job listings (filter by field, location, type)
   - Submit application materials:
     - Cover letter, CV, research statement
     - Teaching statement, diversity statement
     - Selected publications
   - Provide referee contact details
   - Track application status
   
3. **For Referees**
   - Receive confidential upload link via email
   - Upload recommendation letter (PDF)
   - Deadline reminders

**Shared Infrastructure**:
- Reused by M7 (Travel Grants) for:
  - File upload widget
  - Referee management
  - Status tracking
  - Email notifications

---

#### M7 - Travel Grants & Fellowships

**Grant Types**:

1. **Conference Travel Grants**
   - Duration: 3-7 days
   - Coverage: Travel + accommodation + per diem
   - Eligibility: Presenters at approved conferences
   - Requirements: Post-visit report within 30 days
   
2. **Visiting Researcher Fellowships**
   - Duration: 2-4 weeks
   - Coverage: Travel + accommodation + living stipend
   - Eligibility: Established researchers visiting member institution
   - Requirements: Host invitation letter, research plan, post-visit report
   
3. **Research in Pairs/Groups** ⭐
   - Duration: 2-4 weeks
   - Participants: 2-4 researchers from different institutions
   - Coverage: Travel + accommodation for all participants
   - Flexibility: Can be split across two host institutions
   - Requirements:
     - Joint research proposal
     - Host approval
     - Post-visit report

**Application Process**:
1. Fill application form (reuses M3 infrastructure)
2. For Research in Pairs: all collaborators must register
3. Automated eligibility checks
4. Reviewers assigned from M4 (conflict-filtered)
5. Committee decision (approve/reject/revise)
6. Grant agreement generated
7. Post-visit report submission
8. Reimbursement processing

---

#### M8 - Schools & Training Programs

**Program Types**:

1. **Research Schools (CIMPA-style)**
   - Duration: 1-2 weeks
   - Participants: 30-60 (mix of ECRs and established researchers)
   - Format: Lecture series + problem sessions + discussion groups
   - Financial support: Available for students from developing countries
   
2. **PhD Summer Schools**
   - Duration: 2-4 weeks
   - Participants: 20-40 PhD students
   - Format: Advanced courses + student presentations + networking
   - Financial support: Full/partial scholarships
   
3. **Arbeitsgemeinschaft Study Groups**
   - Duration: 1 week
   - Participants: 15-25 (advanced researchers)
   - Format: Intensive study, all participants present
   - Prerequisites: Background in the topic
   
4. **Mini-Courses**
   - Duration: 2-5 days
   - Participants: Open
   - Format: Focused lectures by invited experts

**Organizer Workflow**:
1. Submit school proposal
2. Steering committee review
3. Open applications (3-6 months before)
4. Select participants
5. Allocate financial support
6. Manage logistics
7. Conduct school
8. Upload materials to M9 (videos) and M12 (notes)

---

### 1.3 Supporting Modules (P2-P3)

#### M6 - Prizes & Awards

**Prize Categories**:
1. Young Researcher Prize (<35 years)
2. Distinguished Mathematician Prize
3. Mathematics Education Prize
4. Outreach Prize

**Core Features**:
- Online nomination forms
- Confidential review portal
- Secure voting system
- Public laureate archive

---

#### M5 - Newsletter & Communications

**Content Sections**:
1. Network News (governance updates, new members)
2. Upcoming Events (conferences, schools)
3. Recent Highlights (prize announcements, publications)
4. Member Institute News
5. Opportunities (jobs, grants, fellowships)

**Publication**: Bimonthly (modelled on IMU-Net)

---

#### M9 - Video Library

**Core Features**:
- Upload videos (admin/organizer only)
- Automatic transcoding
- Searchable by title, speaker, event, MSC code
- Public streaming (no download)
- Embeddable player

---

#### M12 - Publications

**Document Types**:
1. Conference Proceedings
2. School Lecture Notes
3. Grant Reports (post-visit)
4. Annual Network Reports
5. Policy Documents

**Core Features**:
- PDF/LaTeX upload
- DOI assignment (for permanent citation)
- Full-text search
- Version control (for lecture notes)

---

#### M10 - Governance

**Core Features**:
- Committee management
- Policy document repository
- Meeting scheduler and minutes archive
- Governance voting system

**Committee Structure**:
- Steering Committee (overall direction)
- Prize Committee (oversees prize selection)
- Grant Committee (reviews travel grants)
- Program Committee (approves schools/conferences)

---

#### M14 - Industry & Partners

**Core Features**:
1. **Expert Consultant Directory**
   - Mathematicians opt-in to be listed
   - Industry partners search by expertise
   - Contact via platform messaging
   
2. **Problem Submission**
   - Industry partners submit mathematical problems
   - Problems reviewed and categorized
   - Matched with experts from M4
   
3. **Sponsorship Opportunities**
   - Conference sponsorship packages
   - Prize sponsorship
   - PhD fellowship sponsorship

---

#### M13 - Outreach

**Core Features**:
- Public lectures and events calendar
- Educational resources for teachers
- Popular mathematics articles
- Links to national outreach initiatives

---

## 2. Core User Flows

### 2.1 Conference Organizer Flow (M2)

```
1. CREATE CONFERENCE
   ├─ Fill basic info (title, dates, venue)
   ├─ Set registration fee tiers
   ├─ Configure abstract submission deadline
   └─ Define meal seating preferences (Oberwolfach mode)
   
2. GENERATE MICROSITE
   ├─ Auto-generate public conference page
   ├─ Custom domain (e.g., asiamath.org/conf2026)
   └─ Embed registration form and schedule
   
3. MANAGE REGISTRATIONS
   ├─ Real-time registration count
   ├─ Payment status tracking
   ├─ Dietary restrictions tracking
   └─ Travel logistics (arrival/departure dates)
   
4. ABSTRACT SUBMISSION & REVIEW
   ├─ Review dashboard
   ├─ Assign reviewers from M4 (conflict-filtered)
   ├─ Accept/reject decisions with feedback
   └─ Programme builder (drag-and-drop scheduling)
   
5. OBERWOLFACH DINING MATCHING
   ├─ Participants submit dining preferences
   ├─ Algorithm generates optimal seating
   └─ Export to venue staff (PDF/Excel)
   
6. POST-CONFERENCE
   ├─ Upload videos → M9 Video Library
   ├─ Generate report → M12 Publications
   └─ Send newsletter → M5 Communications
```

**Key Decision Points**:
- Q1: Automated abstract review? → **No, human reviewers required**
- Q2: Last-minute cancellations? → **Auto refund + schedule adjustment**
- Q3: Matching algorithm failure? → **Manual override option**

---

### 2.2 Travel Grant Application Flow (M7)

```
1. START APPLICATION
   ├─ Login
   ├─ Select grant type:
   │  ├─ Conference travel
   │  ├─ Visiting researcher fellowship
   │  └─ Research in Pairs (group application)
   
2. FILL APPLICATION FORM
   ├─ Pre-fill from M4 Profile
   ├─ Personal details (auto-loaded)
   ├─ Select MSC codes
   ├─ Upload CV and research statement
   └─ For Research in Pairs:
      ├─ Add collaborator details
      ├─ Propose host institution(s)
      └─ Describe research plan (2-4 weeks)
      
3. BUDGET & JUSTIFICATION
   ├─ Travel costs (flights, trains)
   ├─ Accommodation (daily rate × nights)
   ├─ Per diem allowances
   └─ For Research in Pairs:
      ├─ Costs for all participants
      └─ Split-stay logistics (if two institutions)
      
4. SUBMIT & AUTOMATED CHECKS
   ├─ Verify applicant from member institution
   ├─ Check application deadline
   └─ For Research in Pairs:
      ├─ Verify all collaborators from member institutions
      └─ Check host institution approval
      
5. REVIEW PROCESS
   ├─ Assign reviewers from M4 (conflict-filtered)
   ├─ 2-3 reviewers per application
   ├─ Reviewers evaluate:
   │  ├─ Scientific merit
   │  ├─ Budget reasonableness
   │  ├─ Impact on career development
   │  └─ Collaboration potential (Research in Pairs)
   
6. DECISION & NOTIFICATION
   ├─ Approve / Reject / Revise
   ├─ Email notification to applicant
   └─ For approved grants:
      ├─ Generate grant agreement letter
      └─ Provide reimbursement instructions
      
7. POST-VISIT REPORT (Required)
   ├─ Submit report (500-1000 words)
   ├─ Research outcomes or publications
   ├─ Joint publication plan (Research in Pairs)
   └─ Reimbursement claim submission
```

**Key Decision Points**:
- Q1: Budget overruns? → **Prior approval for >20% increase**
- Q2: Collaborator cancels (Research in Pairs)? → **Reschedule or convert to individual fellowship**
- Q3: Multi-year grants? → **Phase 2 feature, start with single-year**

---

### 2.3 Academic Directory & Expertise Registry Flow (M4)

```
1. USER REGISTRATION
   ├─ Sign Up
   ├─ Verify institutional email
   ├─ ORCID OAuth integration (recommended)
   └─ Manual profile creation (if no ORCID)
   
2. PROFILE COMPLETION
   ├─ Personal Information:
   │  ├─ Name, title, affiliation
   │  ├─ ORCID ID (auto-validated)
   │  └─ Personal website
   ├─ Research Information:
   │  ├─ MSC 2020 codes (primary + secondary)
   │  ├─ Research keywords
   │  └─ Research interests description
   └─ Professional Information:
      ├─ Current position
      ├─ Education history
      └─ Selected publications (auto-import from ORCID)
      
3. CONFLICT-OF-INTEREST DECLARATION
   ├─ Past collaborators (co-authors, last 5 years)
   ├─ Current/past PhD students or supervisors
   ├─ Same institution (current or past)
   ├─ Family relationships
   └─ Financial conflicts (industry consulting)
   
   System automatically:
   ├─ Scans publication databases for co-authors
   ├─ Cross-references institutional affiliations
   └─ Flags potential conflicts
   
4. PROFILE VERIFICATION
   ├─ Admin review (for new users)
   ├─ Institution administrator approves
   ├─ ORCID validation (if provided)
   └─ Profile becomes visible after verification
   
5. SEARCH & DISCOVERY (Public)
   ├─ Search by name, institution, MSC code
   ├─ Filter by research area, country, career stage
   ├─ View public profile
   └─ Contact via platform (logged-in users only)
   
6. EXPERT MATCHING (Internal Use)
   ├─ Conference abstracts → Find reviewers by MSC code
   ├─ Grant applications → Match evaluators
   ├─ Prize nominations → Identify committee members
   └─ Industry inquiries → Find consultants (M14)
   
   Automated filtering:
   ├─ Exclude users with declared conflicts
   ├─ Prioritize by expertise match score
   └─ Balance workload across reviewers
```

**Key Decision Points**:
- Q1: Non-member mathematicians? → **Yes, as "observers" with limited access**
- Q2: Profile updates? → **ORCID auto-sync annually, manual updates allowed**
- Q3: Refuse to declare conflicts? → **Cannot participate in reviews/committees**

---

### 2.4 Prize Nomination & Selection Flow (M6)

```
1. OPEN NOMINATION
   ├─ Prize Committee selects prize category:
   │  ├─ Young Researcher Prize (<35 years)
   │  ├─ Distinguished Mathematician Prize
   │  ├─ Mathematics Education Prize
   │  └─ Outreach Prize
   ├─ Set nomination deadline
   └─ Define eligibility criteria
   
2. SUBMIT NOMINATION
   ├─ Select nominee from M4 Directory
   ├─ Upload supporting documents:
   │  ├─ Nomination letter (PDF)
   │  ├─ CV and publication list
   │  ├─ 2-3 reference letters
   │  └─ Statement of contributions
   └─ Nominator declares conflict of interest
   
3. AUTOMATED ELIGIBILITY CHECK
   ├─ Verify nominee from member institution
   ├─ Check age eligibility (for Young Researcher Prize)
   ├─ Verify all required documents uploaded
   └─ Cross-reference with M4 profile
   
4. SELECTION COMMITTEE WORKSPACE
   ├─ Confidential review portal
   ├─ All members declare conflicts of interest
   ├─ System hides conflicted nominations
   ├─ Review materials:
   │  ├─ Nomination letters
   │  ├─ Reference letters (confidential)
   │  ├─ CV and publications
   ├─ Private commenting on each nomination
   └─ Secure voting system
   
5. VOTING & DECISION
   ├─ Each member ranks top 3 candidates
   ├─ Weighted voting system
   ├─ Chair reviews results
   ├─ Final decision requires 2/3 majority
   └─ Tie-breaking procedure defined
   
6. ANNOUNCEMENT
   ├─ Private notification to winner
   ├─ Generate prize certificate
   ├─ Update M4 profile with prize
   ├─ Public announcement on M1 Portal
   ├─ News item in M5 Newsletter
   └─ Archive to Prize History (M1)
```

**Key Decision Points**:
- Q1: Public nominations? → **No, confidential until announcement**
- Q2: Declined prizes? → **Committee selects runner-up**
- Q3: Posthumous nominations? → **Allowed within 2 years of death**

---

### 2.5 Summer School Application Flow (M8)

```
1. BROWSE SCHOOLS
   ├─ View Upcoming Schools
   ├─ Filter by Topic/Location
   ├─ School types:
   │  ├─ CIMPA-style research schools
   │  ├─ PhD summer schools
   │  ├─ Arbeitsgemeinschaft study groups
   │  └─ Mini-courses by invited experts
   └─ Details displayed:
      ├─ Topic and learning objectives
      ├─ Instructors and lecturers
      ├─ Dates and location
      ├─ Financial support availability
      └─ Application deadline
      
2. SUBMIT APPLICATION
   ├─ Pre-fill from M4 profile
   ├─ Upload required documents:
   │  ├─ CV
   │  ├─ Letter of motivation
   │  ├─ Recommendation letter (for students)
   │  └─ Financial support request (if needed)
   └─ Indicate dietary/accessibility needs
   
3. SELECTION PROCESS
   ├─ Organizers review applications
   ├─ Rank candidates by:
   │  ├─ Academic preparation
   │  ├─ Research relevance
   │  ├─ Geographic diversity
   │  └─ Career stage balance
   ├─ Allocate financial support slots
   └─ Send accept/reject notifications
   
4. CONFIRMATION & LOGISTICS
   ├─ Accepted applicants confirm attendance
   ├─ Confirm travel dates
   ├─ Submit accommodation preferences
   └─ For funded participants:
      ├─ Confirm financial support acceptance
      └─ Submit travel details for reimbursement
      
5. DURING SCHOOL
   ├─ Access lecture materials via platform
   ├─ Participate in discussions
   ├─ Network with other participants
   └─ For organizers:
      ├─ Record lectures (for M9 Video Library)
      └─ Track attendance
      
6. POST-SCHOOL
   ├─ Upload lecture videos → M9 Video Library
   ├─ Upload lecture notes → M12 Publications
   ├─ School summary → M5 Newsletter
   └─ Participants submit feedback survey
```

**Key Decision Points**:
- Q1: Open to non-member institutions? → **Yes, but priority to members**
- Q2: No-shows? → **Blacklist from future schools for 2 years**
- Q3: Recording consent? → **Mandatory for accepted participants**

---

## 3. Cross-Cutting Features

### 3.1 ORCID Integration

**All modules use ORCID for**:
- User authentication
- Publication auto-import
- Researcher identity validation
- Profile data synchronization (annual)

### 3.2 Conflict-of-Interest System

**M4 provides COI filtering for**:
- M2: Conference abstract reviewers
- M3: Job application reviewers
- M6: Prize selection committees
- M7: Grant evaluation panels
- M14: Industry consultant matching

### 3.3 Shared Application Infrastructure

**M3 provides reusable components for M7**:
- File upload widget
- Referee management
- Status tracking
- Email notifications

### 3.4 Content Flow

```
Conference/School (M2/M8)
   ├─ Videos → M9 Video Library
   ├─ Reports → M12 Publications
   └─ Announcements → M5 Newsletter
   
Prizes (M6)
   ├─ Announcements → M1 Portal
   ├─ Laureate profiles → M4 Directory
   └─ News → M5 Newsletter
   
Grants (M7)
   ├─ Reports → M12 Publications
   └─ Outcomes → M5 Newsletter
```

---

## 4. Priority Implementation Order

### Phase 1 (Months 3-5) - P0 Modules

**Critical Path**: M4 → M1

**M4 (Academic Directory)**
- User registration and profiles
- ORCID integration
- MSC code management
- Conflict-of-interest system
- Expert matching algorithm

**M1 (Public Portal)**
- Institution directory
- Event calendar
- Application listings

**Success Criteria**:
- 100+ verified user profiles
- 20+ member institutions listed
- Expert matching algorithm tested

---

### Phase 2 (Months 6-8) - P1 Modules (Events)

**M2 (Conference System)**
- Registration and payment
- Abstract submission
- Programme builder
- Oberwolfach dining matching

**M8 (Schools & Training)**
- School proposal submission
- Student applications
- Financial support management

**Success Criteria**:
- 1 pilot conference organized
- 1 summer school conducted
- 200+ registrations processed

---

### Phase 3 (Months 9-11) - P1 Modules (Applications)

**M3 (Application System)**
- Job postings and applications
- Referee letter management

**M7 (Travel Grants)**
- Grant applications (reusing M3 infrastructure)
- Review workflow
- Research in Pairs support

**Success Criteria**:
- 50+ job applications processed
- 20+ travel grants awarded
- 5+ Research in Pairs collaborations

---

### Phase 4 (Months 12-14) - P2 Modules (Content & Recognition)

**M5, M6, M9, M12, M13**
- Newsletter, prizes, videos, publications, outreach

**Success Criteria**:
- First prize cycle completed
- 100+ videos uploaded
- 500+ newsletter subscribers

---

### Phase 5 (Months 15-16) - P3 Modules (Governance & Partners)

**M10, M14**
- Governance workflows
- Industry partnerships

**Success Criteria**:
- 5+ industry partnerships established
- Governance workflows tested

---

_End of Document_
