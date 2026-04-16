-- Asiamath Database DDL V1.1
-- Reference database: PostgreSQL 15+
-- Aligned with system map + MVP PRD v3.2 + Technical Spec v2.1 + API Spec v2.1
-- Notes:
--   1) This is a full aligned DDL file, not an incremental migration script.
--   2) application.status is workflow-only.
--   3) decisions.final_status + decisions.release_status carry formal results.
--   4) conference application and grant application remain separate records in one typed shared table.

CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE EXTENSION IF NOT EXISTS citext;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'user_status') THEN
        CREATE TYPE user_status AS ENUM ('active', 'inactive', 'suspended');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'user_role') THEN
        CREATE TYPE user_role AS ENUM ('applicant', 'reviewer', 'organizer', 'admin');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'institution_status') THEN
        CREATE TYPE institution_status AS ENUM ('active', 'inactive', 'pending');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'profile_verification_status') THEN
        CREATE TYPE profile_verification_status AS ENUM ('unverified', 'pending_review', 'verified', 'rejected');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'career_stage') THEN
        CREATE TYPE career_stage AS ENUM ('undergraduate', 'masters', 'phd', 'postdoc', 'faculty', 'other');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'conference_status') THEN
        CREATE TYPE conference_status AS ENUM ('draft', 'published', 'closed');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'grant_opportunity_status') THEN
        CREATE TYPE grant_opportunity_status AS ENUM ('draft', 'published', 'closed');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'grant_type') THEN
        CREATE TYPE grant_type AS ENUM ('conference_travel_grant');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'conference_staff_role') THEN
        CREATE TYPE conference_staff_role AS ENUM ('owner', 'organizer');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'application_type') THEN
        CREATE TYPE application_type AS ENUM ('conference_application', 'grant_application');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'application_status') THEN
        CREATE TYPE application_status AS ENUM ('draft', 'submitted', 'under_review', 'decided');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'participation_type') THEN
        CREATE TYPE participation_type AS ENUM ('attendee', 'talk', 'poster');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'file_role') THEN
        CREATE TYPE file_role AS ENUM ('cv', 'abstract_attachment', 'supporting_document', 'post_visit_report_attachment');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'file_visibility') THEN
        CREATE TYPE file_visibility AS ENUM ('private', 'internal', 'public');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'review_assignment_status') THEN
        CREATE TYPE review_assignment_status AS ENUM ('assigned', 'review_submitted', 'cancelled');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'review_recommendation') THEN
        CREATE TYPE review_recommendation AS ENUM ('accept', 'reject', 'waitlist');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'decision_kind') THEN
        CREATE TYPE decision_kind AS ENUM ('conference_admission', 'travel_grant');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'decision_final_status') THEN
        CREATE TYPE decision_final_status AS ENUM ('accepted', 'rejected', 'waitlisted');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'decision_release_status') THEN
        CREATE TYPE decision_release_status AS ENUM ('unreleased', 'released');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'conflict_state') THEN
        CREATE TYPE conflict_state AS ENUM ('clear', 'flagged');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'post_visit_report_status') THEN
        CREATE TYPE post_visit_report_status AS ENUM ('not_started', 'submitted');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'applicant_viewer_status') THEN
        CREATE TYPE applicant_viewer_status AS ENUM ('draft', 'submitted', 'under_review', 'result_released');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'next_action') THEN
        CREATE TYPE next_action AS ENUM ('continue_draft', 'view_submission', 'view_result', 'submit_post_visit_report', 'view_report');
    END IF;
END $$;

CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS trigger AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TABLE IF NOT EXISTS users (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    email citext NOT NULL UNIQUE,
    password_hash text NULL,
    auth_provider text NOT NULL DEFAULT 'local',
    status user_status NOT NULL DEFAULT 'active',
    email_verified_at timestamptz NULL,
    last_login_at timestamptz NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS institutions (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    slug text NOT NULL,
    name text NOT NULL,
    country_code char(2) NULL,
    website text NULL,
    contact_email citext NULL,
    is_member boolean NOT NULL DEFAULT false,
    status institution_status NOT NULL DEFAULT 'active',
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT chk_institutions_slug_not_blank CHECK (btrim(slug) <> '')
);

CREATE UNIQUE INDEX IF NOT EXISTS uq_institutions_slug_ci
ON institutions (lower(slug));

CREATE INDEX IF NOT EXISTS idx_institutions_member_status
ON institutions (is_member, status);

CREATE TABLE IF NOT EXISTS user_roles (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role user_role NOT NULL,
    is_primary boolean NOT NULL DEFAULT false,
    granted_by_user_id uuid NULL REFERENCES users(id) ON DELETE SET NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_user_role UNIQUE (user_id, role)
);

CREATE UNIQUE INDEX IF NOT EXISTS uq_user_primary_role
ON user_roles (user_id)
WHERE is_primary = true;

CREATE TABLE IF NOT EXISTS profiles (
    user_id uuid PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    slug text NOT NULL,
    full_name text NOT NULL,
    title text NULL,
    institution_id uuid NULL REFERENCES institutions(id) ON DELETE SET NULL,
    institution_name_raw text NULL,
    country_code char(2) NULL,
    career_stage career_stage NULL,
    bio text NULL,
    personal_website text NULL,
    research_keywords text[] NOT NULL DEFAULT '{}',
    orcid_id varchar(19) NULL UNIQUE,
    coi_declaration_text text NOT NULL DEFAULT '',
    is_profile_public boolean NOT NULL DEFAULT true,
    verification_status profile_verification_status NOT NULL DEFAULT 'unverified',
    verified_at timestamptz NULL,
    verified_by_user_id uuid NULL REFERENCES users(id) ON DELETE SET NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT chk_profiles_slug_not_blank CHECK (btrim(slug) <> '')
);

CREATE UNIQUE INDEX IF NOT EXISTS uq_profiles_slug_ci
ON profiles (lower(slug));

CREATE INDEX IF NOT EXISTS idx_profiles_institution_id
ON profiles (institution_id);

CREATE INDEX IF NOT EXISTS idx_profiles_country_code
ON profiles (country_code);

CREATE INDEX IF NOT EXISTS idx_profiles_verification_status
ON profiles (verification_status);

CREATE INDEX IF NOT EXISTS idx_profiles_research_keywords_gin
ON profiles USING gin (research_keywords);

CREATE TABLE IF NOT EXISTS msc_codes (
    code varchar(10) PRIMARY KEY,
    label text NOT NULL,
    parent_code varchar(10) NULL REFERENCES msc_codes(code) ON DELETE SET NULL,
    level smallint NULL,
    is_active boolean NOT NULL DEFAULT true,
    created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_msc_codes_parent_code
ON msc_codes (parent_code);

CREATE TABLE IF NOT EXISTS profile_msc_codes (
    user_id uuid NOT NULL REFERENCES profiles(user_id) ON DELETE CASCADE,
    msc_code varchar(10) NOT NULL REFERENCES msc_codes(code) ON DELETE RESTRICT,
    is_primary boolean NOT NULL DEFAULT false,
    created_at timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY (user_id, msc_code)
);

CREATE INDEX IF NOT EXISTS idx_profile_msc_codes_msc_code
ON profile_msc_codes (msc_code);

CREATE UNIQUE INDEX IF NOT EXISTS uq_profile_primary_msc
ON profile_msc_codes (user_id)
WHERE is_primary = true;

CREATE TABLE IF NOT EXISTS file_assets (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_user_id uuid NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    file_role file_role NOT NULL,
    visibility file_visibility NOT NULL DEFAULT 'private',
    storage_provider text NOT NULL DEFAULT 'object_storage',
    storage_key text NOT NULL UNIQUE,
    original_name text NOT NULL,
    mime_type text NOT NULL,
    size_bytes bigint NOT NULL CHECK (size_bytes >= 0),
    checksum_sha256 text NULL,
    uploaded_at timestamptz NOT NULL DEFAULT now(),
    deleted_at timestamptz NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_file_assets_owner_uploaded_at
ON file_assets (owner_user_id, uploaded_at DESC);

CREATE TABLE IF NOT EXISTS conferences (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    slug text NOT NULL,
    title text NOT NULL,
    short_name text NULL,
    location_text text NULL,
    start_date date NULL,
    end_date date NULL,
    description text NULL,
    application_deadline timestamptz NULL,
    status conference_status NOT NULL DEFAULT 'draft',
    application_form_schema_json jsonb NOT NULL DEFAULT '{}'::jsonb,
    settings_json jsonb NOT NULL DEFAULT '{}'::jsonb,
    published_at timestamptz NULL,
    closed_at timestamptz NULL,
    created_by_user_id uuid NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT chk_conferences_slug_not_blank CHECK (btrim(slug) <> ''),
    CONSTRAINT chk_conference_dates CHECK (
        start_date IS NULL OR end_date IS NULL OR end_date >= start_date
    ),
    CONSTRAINT chk_conference_form_schema_is_object CHECK (
        jsonb_typeof(application_form_schema_json) = 'object'
    ),
    CONSTRAINT chk_conference_settings_is_object CHECK (
        jsonb_typeof(settings_json) = 'object'
    )
);

CREATE UNIQUE INDEX IF NOT EXISTS uq_conferences_slug_ci
ON conferences (lower(slug));

CREATE INDEX IF NOT EXISTS idx_conferences_status_start_date
ON conferences (status, start_date);

CREATE INDEX IF NOT EXISTS idx_conferences_application_deadline
ON conferences (application_deadline);

CREATE TABLE IF NOT EXISTS conference_staff (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    conference_id uuid NOT NULL REFERENCES conferences(id) ON DELETE CASCADE,
    user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    staff_role conference_staff_role NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_conference_staff UNIQUE (conference_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_conference_staff_user_conference
ON conference_staff (user_id, conference_id);

CREATE TABLE IF NOT EXISTS grant_opportunities (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    linked_conference_id uuid NOT NULL REFERENCES conferences(id) ON DELETE CASCADE,
    slug text NOT NULL,
    title text NOT NULL,
    grant_type grant_type NOT NULL DEFAULT 'conference_travel_grant',
    description text NULL,
    eligibility_summary text NULL,
    coverage_summary text NULL,
    application_deadline timestamptz NULL,
    status grant_opportunity_status NOT NULL DEFAULT 'draft',
    report_required boolean NOT NULL DEFAULT false,
    application_form_schema_json jsonb NOT NULL DEFAULT '{}'::jsonb,
    settings_json jsonb NOT NULL DEFAULT '{}'::jsonb,
    published_at timestamptz NULL,
    closed_at timestamptz NULL,
    created_by_user_id uuid NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT chk_grants_slug_not_blank CHECK (btrim(slug) <> ''),
    CONSTRAINT chk_grant_form_schema_is_object CHECK (
        jsonb_typeof(application_form_schema_json) = 'object'
    ),
    CONSTRAINT chk_grant_settings_is_object CHECK (
        jsonb_typeof(settings_json) = 'object'
    )
);

CREATE UNIQUE INDEX IF NOT EXISTS uq_grant_opportunities_slug_ci
ON grant_opportunities (lower(slug));

CREATE UNIQUE INDEX IF NOT EXISTS uq_grant_id_linked_conference
ON grant_opportunities (id, linked_conference_id);

CREATE INDEX IF NOT EXISTS idx_grant_opportunities_conf_status_deadline
ON grant_opportunities (linked_conference_id, status, application_deadline);

CREATE TABLE IF NOT EXISTS applications (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    application_type application_type NOT NULL,
    applicant_user_id uuid NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    conference_id uuid NULL REFERENCES conferences(id) ON DELETE CASCADE,
    grant_id uuid NULL,
    linked_conference_id uuid NULL,
    linked_conference_application_id uuid NULL REFERENCES applications(id) ON DELETE RESTRICT,
    status application_status NOT NULL DEFAULT 'draft',
    participation_type participation_type NULL,
    statement text NULL,
    abstract_title text NULL,
    abstract_text text NULL,
    interested_in_travel_support boolean NOT NULL DEFAULT false,
    travel_plan_summary text NULL,
    funding_need_summary text NULL,
    extra_answers_json jsonb NOT NULL DEFAULT '{}'::jsonb,
    applicant_profile_snapshot_json jsonb NOT NULL DEFAULT '{}'::jsonb,
    submitted_at timestamptz NULL,
    decided_at timestamptz NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT chk_applications_extra_answers_is_object CHECK (
        jsonb_typeof(extra_answers_json) = 'object'
    ),
    CONSTRAINT chk_applications_profile_snapshot_is_object CHECK (
        jsonb_typeof(applicant_profile_snapshot_json) = 'object'
    ),
    CONSTRAINT chk_applications_type_object_consistency CHECK (
        (
            application_type = 'conference_application'
            AND conference_id IS NOT NULL
            AND grant_id IS NULL
            AND linked_conference_id IS NULL
            AND linked_conference_application_id IS NULL
        )
        OR
        (
            application_type = 'grant_application'
            AND conference_id IS NULL
            AND grant_id IS NOT NULL
            AND linked_conference_id IS NOT NULL
            AND linked_conference_application_id IS NOT NULL
        )
    ),
    CONSTRAINT chk_applications_type_field_hygiene CHECK (
        (
            application_type = 'conference_application'
            AND travel_plan_summary IS NULL
            AND funding_need_summary IS NULL
        )
        OR
        (
            application_type = 'grant_application'
            AND participation_type IS NULL
            AND abstract_title IS NULL
            AND abstract_text IS NULL
            AND interested_in_travel_support = false
        )
    ),
    CONSTRAINT fk_applications_grant_link FOREIGN KEY (grant_id, linked_conference_id)
        REFERENCES grant_opportunities (id, linked_conference_id)
        ON DELETE CASCADE
);

CREATE UNIQUE INDEX IF NOT EXISTS uq_applications_one_conference_per_user
ON applications (applicant_user_id, conference_id)
WHERE application_type = 'conference_application';

CREATE UNIQUE INDEX IF NOT EXISTS uq_applications_one_grant_per_user
ON applications (applicant_user_id, grant_id)
WHERE application_type = 'grant_application';

CREATE INDEX IF NOT EXISTS idx_applications_by_applicant
ON applications (applicant_user_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_applications_conference_queue
ON applications (conference_id, status, submitted_at DESC)
WHERE application_type = 'conference_application';

CREATE INDEX IF NOT EXISTS idx_applications_grant_queue
ON applications (grant_id, status, submitted_at DESC)
WHERE application_type = 'grant_application';

CREATE INDEX IF NOT EXISTS idx_applications_linked_conference_application
ON applications (linked_conference_application_id)
WHERE application_type = 'grant_application';

CREATE TABLE IF NOT EXISTS application_files (
    application_id uuid NOT NULL REFERENCES applications(id) ON DELETE CASCADE,
    file_asset_id uuid NOT NULL REFERENCES file_assets(id) ON DELETE RESTRICT,
    display_order smallint NOT NULL DEFAULT 0,
    created_at timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY (application_id, file_asset_id)
);

CREATE INDEX IF NOT EXISTS idx_application_files_file_asset_id
ON application_files (file_asset_id);

CREATE TABLE IF NOT EXISTS review_assignments (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    application_id uuid NOT NULL REFERENCES applications(id) ON DELETE CASCADE,
    reviewer_user_id uuid NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    assigned_by_user_id uuid NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    status review_assignment_status NOT NULL DEFAULT 'assigned',
    conflict_state conflict_state NOT NULL DEFAULT 'clear',
    conflict_note text NULL,
    due_at timestamptz NULL,
    assigned_at timestamptz NOT NULL DEFAULT now(),
    completed_at timestamptz NULL,
    cancelled_at timestamptz NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT chk_review_assignments_completed_requires_status CHECK (
        completed_at IS NULL OR status = 'review_submitted'
    ),
    CONSTRAINT chk_review_assignments_cancelled_requires_status CHECK (
        cancelled_at IS NULL OR status = 'cancelled'
    ),
    CONSTRAINT chk_review_assignments_not_both_completed_and_cancelled CHECK (
        NOT (completed_at IS NOT NULL AND cancelled_at IS NOT NULL)
    )
);

CREATE UNIQUE INDEX IF NOT EXISTS uq_review_assignments_active_reviewer_per_application
ON review_assignments (application_id, reviewer_user_id)
WHERE status IN ('assigned', 'review_submitted');

CREATE INDEX IF NOT EXISTS idx_review_assignments_reviewer_status
ON review_assignments (reviewer_user_id, status, due_at);

CREATE INDEX IF NOT EXISTS idx_review_assignments_application
ON review_assignments (application_id, status);

CREATE TABLE IF NOT EXISTS reviews (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    assignment_id uuid NOT NULL UNIQUE REFERENCES review_assignments(id) ON DELETE CASCADE,
    score smallint NULL CHECK (score IS NULL OR score BETWEEN 1 AND 5),
    recommendation review_recommendation NOT NULL,
    comment text NULL,
    submitted_at timestamptz NOT NULL DEFAULT now(),
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_reviews_recommendation
ON reviews (recommendation);

CREATE TABLE IF NOT EXISTS decisions (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    application_id uuid NOT NULL UNIQUE REFERENCES applications(id) ON DELETE CASCADE,
    decision_kind decision_kind NOT NULL,
    final_status decision_final_status NOT NULL,
    release_status decision_release_status NOT NULL DEFAULT 'unreleased',
    note_internal text NULL,
    note_external text NULL,
    decided_by_user_id uuid NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    decided_at timestamptz NOT NULL DEFAULT now(),
    released_at timestamptz NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT chk_decisions_release_consistency CHECK (
        (release_status = 'unreleased' AND released_at IS NULL)
        OR
        (release_status = 'released' AND released_at IS NOT NULL)
    )
);

CREATE INDEX IF NOT EXISTS idx_decisions_release_status_decided_at
ON decisions (release_status, decided_at DESC);

CREATE INDEX IF NOT EXISTS idx_decisions_final_status_decided_at
ON decisions (final_status, decided_at DESC);

CREATE TABLE IF NOT EXISTS post_visit_reports (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    grant_application_id uuid NOT NULL UNIQUE REFERENCES applications(id) ON DELETE CASCADE,
    status post_visit_report_status NOT NULL DEFAULT 'submitted',
    title text NOT NULL,
    report_text text NOT NULL,
    submitted_at timestamptz NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS post_visit_report_files (
    report_id uuid NOT NULL REFERENCES post_visit_reports(id) ON DELETE CASCADE,
    file_asset_id uuid NOT NULL REFERENCES file_assets(id) ON DELETE RESTRICT,
    display_order smallint NOT NULL DEFAULT 0,
    created_at timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY (report_id, file_asset_id)
);

CREATE INDEX IF NOT EXISTS idx_post_visit_report_files_file_asset_id
ON post_visit_report_files (file_asset_id);

CREATE TABLE IF NOT EXISTS application_status_history (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    application_id uuid NOT NULL REFERENCES applications(id) ON DELETE CASCADE,
    from_status application_status NULL,
    to_status application_status NOT NULL,
    changed_by_user_id uuid NULL REFERENCES users(id) ON DELETE SET NULL,
    reason text NULL,
    created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_application_status_history_app_created
ON application_status_history (application_id, created_at);

CREATE INDEX IF NOT EXISTS idx_application_status_history_to_status_created
ON application_status_history (to_status, created_at);

CREATE TABLE IF NOT EXISTS audit_logs (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    actor_user_id uuid NULL REFERENCES users(id) ON DELETE SET NULL,
    entity_type text NOT NULL,
    entity_id uuid NOT NULL,
    action text NOT NULL,
    payload_json jsonb NOT NULL DEFAULT '{}'::jsonb,
    created_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT chk_audit_logs_payload_is_object CHECK (
        jsonb_typeof(payload_json) = 'object'
    )
);

CREATE INDEX IF NOT EXISTS idx_audit_logs_entity_created
ON audit_logs (entity_type, entity_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_audit_logs_actor_created
ON audit_logs (actor_user_id, created_at DESC);

CREATE OR REPLACE FUNCTION log_application_status_change()
RETURNS trigger AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO application_status_history (
            application_id,
            from_status,
            to_status,
            changed_by_user_id,
            reason,
            created_at
        ) VALUES (
            NEW.id,
            NULL,
            NEW.status,
            NULL,
            'initial status',
            now()
        );
        RETURN NEW;
    END IF;

    IF TG_OP = 'UPDATE' AND OLD.status IS DISTINCT FROM NEW.status THEN
        INSERT INTO application_status_history (
            application_id,
            from_status,
            to_status,
            changed_by_user_id,
            reason,
            created_at
        ) VALUES (
            NEW.id,
            OLD.status,
            NEW.status,
            NULL,
            'status changed',
            now()
        );
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION validate_grant_application_link()
RETURNS trigger AS $$
DECLARE
    v_grant_linked_conference_id uuid;
    v_linked_application record;
BEGIN
    IF NEW.application_type <> 'grant_application' THEN
        RETURN NEW;
    END IF;

    SELECT linked_conference_id
    INTO v_grant_linked_conference_id
    FROM grant_opportunities
    WHERE id = NEW.grant_id;

    IF v_grant_linked_conference_id IS NULL THEN
        RAISE EXCEPTION 'Grant opportunity % not found or has no linked conference', NEW.grant_id;
    END IF;

    IF NEW.linked_conference_id IS DISTINCT FROM v_grant_linked_conference_id THEN
        RAISE EXCEPTION 'Grant application linked_conference_id must match grant_opportunities.linked_conference_id';
    END IF;

    SELECT
        id,
        application_type,
        applicant_user_id,
        conference_id,
        status
    INTO v_linked_application
    FROM applications
    WHERE id = NEW.linked_conference_application_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Linked conference application % not found', NEW.linked_conference_application_id;
    END IF;

    IF v_linked_application.application_type <> 'conference_application' THEN
        RAISE EXCEPTION 'linked_conference_application_id must point to a conference application';
    END IF;

    IF v_linked_application.applicant_user_id <> NEW.applicant_user_id THEN
        RAISE EXCEPTION 'Grant application owner must match linked conference application owner';
    END IF;

    IF v_linked_application.conference_id <> NEW.linked_conference_id THEN
        RAISE EXCEPTION 'Linked conference application must belong to linked_conference_id';
    END IF;

    IF v_linked_application.status = 'draft' THEN
        RAISE EXCEPTION 'Grant application requires an existing submitted conference application';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION validate_review_assignment()
RETURNS trigger AS $$
DECLARE
    v_application record;
    v_has_profile boolean;
    v_has_reviewer_role boolean;
BEGIN
    SELECT applicant_user_id, status
    INTO v_application
    FROM applications
    WHERE id = NEW.application_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Application % not found', NEW.application_id;
    END IF;

    IF v_application.status NOT IN ('submitted', 'under_review') THEN
        RAISE EXCEPTION 'Review assignment requires application status submitted or under_review';
    END IF;

    IF v_application.applicant_user_id = NEW.reviewer_user_id THEN
        RAISE EXCEPTION 'Applicant cannot be assigned as reviewer to their own application';
    END IF;

    SELECT EXISTS (
        SELECT 1
        FROM profiles
        WHERE user_id = NEW.reviewer_user_id
    ) INTO v_has_profile;

    IF NOT v_has_profile THEN
        RAISE EXCEPTION 'Reviewer % must have a profile record', NEW.reviewer_user_id;
    END IF;

    SELECT EXISTS (
        SELECT 1
        FROM user_roles
        WHERE user_id = NEW.reviewer_user_id
          AND role IN ('reviewer', 'admin')
    ) INTO v_has_reviewer_role;

    IF NOT v_has_reviewer_role THEN
        RAISE EXCEPTION 'Reviewer % must have reviewer or admin role', NEW.reviewer_user_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sync_application_under_review_after_assignment()
RETURNS trigger AS $$
BEGIN
    UPDATE applications
    SET status = 'under_review',
        updated_at = now()
    WHERE id = NEW.application_id
      AND status = 'submitted';

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION validate_review_insert()
RETURNS trigger AS $$
DECLARE
    v_assignment record;
BEGIN
    SELECT status, conflict_state
    INTO v_assignment
    FROM review_assignments
    WHERE id = NEW.assignment_id
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Review assignment % not found', NEW.assignment_id;
    END IF;

    IF v_assignment.status <> 'assigned' THEN
        RAISE EXCEPTION 'Review can only be submitted for assignment in status assigned';
    END IF;

    IF v_assignment.conflict_state = 'flagged' THEN
        RAISE EXCEPTION 'Cannot submit review for conflict-flagged assignment %', NEW.assignment_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sync_assignment_after_review()
RETURNS trigger AS $$
BEGIN
    UPDATE review_assignments
    SET status = 'review_submitted',
        completed_at = COALESCE(NEW.submitted_at, now()),
        updated_at = now()
    WHERE id = NEW.assignment_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION validate_decision()
RETURNS trigger AS $$
DECLARE
    v_application record;
    v_linked_conference_decision record;
BEGIN
    SELECT
        application_type,
        status,
        linked_conference_application_id
    INTO v_application
    FROM applications
    WHERE id = NEW.application_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Application % not found', NEW.application_id;
    END IF;

    IF v_application.status = 'draft' THEN
        RAISE EXCEPTION 'Cannot create decision for draft application %', NEW.application_id;
    END IF;

    IF v_application.application_type = 'conference_application'
       AND NEW.decision_kind <> 'conference_admission' THEN
        RAISE EXCEPTION 'Conference application decision_kind must be conference_admission';
    END IF;

    IF v_application.application_type = 'grant_application'
       AND NEW.decision_kind <> 'travel_grant' THEN
        RAISE EXCEPTION 'Grant application decision_kind must be travel_grant';
    END IF;

    IF NEW.release_status = 'released' AND NEW.released_at IS NULL THEN
        NEW.released_at = now();
    END IF;

    IF NEW.release_status = 'unreleased' THEN
        NEW.released_at = NULL;
    END IF;

    IF v_application.application_type = 'grant_application'
       AND NEW.release_status = 'released'
       AND NEW.final_status IN ('accepted', 'waitlisted') THEN

        SELECT final_status
        INTO v_linked_conference_decision
        FROM decisions
        WHERE application_id = v_application.linked_conference_application_id;

        IF FOUND AND v_linked_conference_decision.final_status = 'rejected' THEN
            RAISE EXCEPTION 'Conference rejection blocks grant award release in MVP';
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sync_application_after_decision()
RETURNS trigger AS $$
BEGIN
    UPDATE applications
    SET status = 'decided',
        decided_at = COALESCE(NEW.decided_at, now()),
        updated_at = now()
    WHERE id = NEW.application_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION validate_post_visit_report()
RETURNS trigger AS $$
DECLARE
    v_application record;
    v_decision record;
    v_report_required boolean;
BEGIN
    SELECT application_type, grant_id
    INTO v_application
    FROM applications
    WHERE id = NEW.grant_application_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Grant application % not found', NEW.grant_application_id;
    END IF;

    IF v_application.application_type <> 'grant_application' THEN
        RAISE EXCEPTION 'Post-visit report can only attach to grant application';
    END IF;

    SELECT final_status, release_status
    INTO v_decision
    FROM decisions
    WHERE application_id = NEW.grant_application_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Grant application % has no decision', NEW.grant_application_id;
    END IF;

    IF v_decision.release_status <> 'released' OR v_decision.final_status <> 'accepted' THEN
        RAISE EXCEPTION 'Post-visit report requires released accepted grant decision';
    END IF;

    SELECT report_required
    INTO v_report_required
    FROM grant_opportunities
    WHERE id = v_application.grant_id;

    IF COALESCE(v_report_required, false) <> true THEN
        RAISE EXCEPTION 'Grant opportunity % does not require post-visit report', v_application.grant_id;
    END IF;

    NEW.status = 'submitted';

    IF NEW.submitted_at IS NULL THEN
        NEW.submitted_at = now();
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_users_set_updated_at ON users;
CREATE TRIGGER trg_users_set_updated_at
BEFORE UPDATE ON users
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

DROP TRIGGER IF EXISTS trg_institutions_set_updated_at ON institutions;
CREATE TRIGGER trg_institutions_set_updated_at
BEFORE UPDATE ON institutions
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

DROP TRIGGER IF EXISTS trg_profiles_set_updated_at ON profiles;
CREATE TRIGGER trg_profiles_set_updated_at
BEFORE UPDATE ON profiles
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

DROP TRIGGER IF EXISTS trg_file_assets_set_updated_at ON file_assets;
CREATE TRIGGER trg_file_assets_set_updated_at
BEFORE UPDATE ON file_assets
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

DROP TRIGGER IF EXISTS trg_conferences_set_updated_at ON conferences;
CREATE TRIGGER trg_conferences_set_updated_at
BEFORE UPDATE ON conferences
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

DROP TRIGGER IF EXISTS trg_grant_opportunities_set_updated_at ON grant_opportunities;
CREATE TRIGGER trg_grant_opportunities_set_updated_at
BEFORE UPDATE ON grant_opportunities
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

DROP TRIGGER IF EXISTS trg_applications_set_updated_at ON applications;
CREATE TRIGGER trg_applications_set_updated_at
BEFORE UPDATE ON applications
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

DROP TRIGGER IF EXISTS trg_review_assignments_set_updated_at ON review_assignments;
CREATE TRIGGER trg_review_assignments_set_updated_at
BEFORE UPDATE ON review_assignments
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

DROP TRIGGER IF EXISTS trg_reviews_set_updated_at ON reviews;
CREATE TRIGGER trg_reviews_set_updated_at
BEFORE UPDATE ON reviews
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

DROP TRIGGER IF EXISTS trg_decisions_set_updated_at ON decisions;
CREATE TRIGGER trg_decisions_set_updated_at
BEFORE UPDATE ON decisions
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

DROP TRIGGER IF EXISTS trg_post_visit_reports_set_updated_at ON post_visit_reports;
CREATE TRIGGER trg_post_visit_reports_set_updated_at
BEFORE UPDATE ON post_visit_reports
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

DROP TRIGGER IF EXISTS trg_applications_validate_grant_link ON applications;
CREATE TRIGGER trg_applications_validate_grant_link
BEFORE INSERT OR UPDATE OF application_type, applicant_user_id, grant_id, linked_conference_id, linked_conference_application_id
ON applications
FOR EACH ROW EXECUTE FUNCTION validate_grant_application_link();

DROP TRIGGER IF EXISTS trg_applications_status_history_insert ON applications;
CREATE TRIGGER trg_applications_status_history_insert
AFTER INSERT ON applications
FOR EACH ROW EXECUTE FUNCTION log_application_status_change();

DROP TRIGGER IF EXISTS trg_applications_status_history_update ON applications;
CREATE TRIGGER trg_applications_status_history_update
AFTER UPDATE OF status ON applications
FOR EACH ROW EXECUTE FUNCTION log_application_status_change();

DROP TRIGGER IF EXISTS trg_review_assignments_validate ON review_assignments;
CREATE TRIGGER trg_review_assignments_validate
BEFORE INSERT OR UPDATE OF application_id, reviewer_user_id
ON review_assignments
FOR EACH ROW EXECUTE FUNCTION validate_review_assignment();

DROP TRIGGER IF EXISTS trg_review_assignments_sync_application ON review_assignments;
CREATE TRIGGER trg_review_assignments_sync_application
AFTER INSERT ON review_assignments
FOR EACH ROW EXECUTE FUNCTION sync_application_under_review_after_assignment();

DROP TRIGGER IF EXISTS trg_reviews_validate_insert ON reviews;
CREATE TRIGGER trg_reviews_validate_insert
BEFORE INSERT ON reviews
FOR EACH ROW EXECUTE FUNCTION validate_review_insert();

DROP TRIGGER IF EXISTS trg_reviews_sync_assignment ON reviews;
CREATE TRIGGER trg_reviews_sync_assignment
AFTER INSERT ON reviews
FOR EACH ROW EXECUTE FUNCTION sync_assignment_after_review();

DROP TRIGGER IF EXISTS trg_decisions_validate ON decisions;
CREATE TRIGGER trg_decisions_validate
BEFORE INSERT OR UPDATE OF decision_kind, final_status, release_status, released_at
ON decisions
FOR EACH ROW EXECUTE FUNCTION validate_decision();

DROP TRIGGER IF EXISTS trg_decisions_sync_application ON decisions;
CREATE TRIGGER trg_decisions_sync_application
AFTER INSERT OR UPDATE OF final_status, release_status, decided_at
ON decisions
FOR EACH ROW EXECUTE FUNCTION sync_application_after_decision();

DROP TRIGGER IF EXISTS trg_post_visit_reports_validate ON post_visit_reports;
CREATE TRIGGER trg_post_visit_reports_validate
BEFORE INSERT OR UPDATE ON post_visit_reports
FOR EACH ROW EXECUTE FUNCTION validate_post_visit_report();

CREATE OR REPLACE VIEW applicant_visible_decisions_v AS
SELECT
    d.application_id,
    d.decision_kind,
    d.final_status,
    d.note_external,
    d.released_at
FROM decisions d
WHERE d.release_status = 'released';

CREATE OR REPLACE VIEW applicant_dashboard_items_v AS
SELECT
    a.id AS application_id,
    a.applicant_user_id,
    a.application_type,
    CASE
        WHEN a.application_type = 'conference_application' THEN 'M2'
        ELSE 'M7'
    END AS source_module,
    CASE
        WHEN a.application_type = 'conference_application' THEN a.conference_id
        ELSE a.grant_id
    END AS source_id,
    CASE
        WHEN a.application_type = 'conference_application' THEN c.title
        ELSE g.title
    END AS source_title,
    gc.title AS linked_conference_title,
    CASE
        WHEN a.status = 'draft' THEN 'draft'::applicant_viewer_status
        WHEN d.release_status = 'released' THEN 'result_released'::applicant_viewer_status
        WHEN a.status IN ('under_review', 'decided') THEN 'under_review'::applicant_viewer_status
        ELSE 'submitted'::applicant_viewer_status
    END AS viewer_status,
    a.submitted_at,
    CASE WHEN d.release_status = 'released' THEN d.decision_kind ELSE NULL END AS released_decision_kind,
    CASE WHEN d.release_status = 'released' THEN d.final_status ELSE NULL END AS released_decision_final_status,
    CASE WHEN d.release_status = 'released' THEN d.note_external ELSE NULL END AS released_decision_note_external,
    CASE WHEN d.release_status = 'released' THEN d.released_at ELSE NULL END AS released_at,
    CASE
        WHEN a.status = 'draft' THEN 'continue_draft'::next_action
        WHEN a.application_type = 'grant_application'
             AND d.release_status = 'released'
             AND d.final_status = 'accepted'
             AND COALESCE(g.report_required, false) = true
             AND pvr.id IS NULL
            THEN 'submit_post_visit_report'::next_action
        WHEN a.application_type = 'grant_application'
             AND pvr.id IS NOT NULL
            THEN 'view_report'::next_action
        WHEN d.release_status = 'released'
            THEN 'view_result'::next_action
        ELSE 'view_submission'::next_action
    END AS next_action,
    CASE
        WHEN a.application_type <> 'grant_application' THEN NULL
        WHEN pvr.id IS NOT NULL THEN 'submitted'::post_visit_report_status
        WHEN d.release_status = 'released'
             AND d.final_status = 'accepted'
             AND COALESCE(g.report_required, false) = true
            THEN 'not_started'::post_visit_report_status
        ELSE NULL
    END AS post_visit_report_status
FROM applications a
LEFT JOIN conferences c
    ON c.id = a.conference_id
LEFT JOIN grant_opportunities g
    ON g.id = a.grant_id
LEFT JOIN conferences gc
    ON gc.id = a.linked_conference_id
LEFT JOIN decisions d
    ON d.application_id = a.id
LEFT JOIN post_visit_reports pvr
    ON pvr.grant_application_id = a.id;

COMMENT ON TABLE applications IS
'Shared typed workflow table. application.status is workflow only; final result lives in decisions.';

COMMENT ON TABLE decisions IS
'Application-based formal result table for M2/M7 workflow objects. release_status controls applicant visibility.';

COMMENT ON TABLE review_assignments IS
'Minimum MVP conflict-aware assignment table. conflict_state = flagged blocks review submission.';

COMMENT ON TABLE post_visit_reports IS
'Report object for funded grant applications when report_required = true. not_started is derived by row absence.';
