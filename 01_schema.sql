-- =============================================================================
-- FILE        : 01_schema.sql
-- PROJECT     : Bangladesh HR Application
-- PLATFORM    : Oracle APEX (Oracle Database 19c+)
-- DESCRIPTION : Comprehensive HR database schema supporting 50,000+ employees,
--               fully aligned with Bangladesh Labor Act 2006, NBR income tax
--               rules, and standard HR processes (recruitment, payroll, leave,
--               performance, training, compliance, RBAC).
-- VERSION     : 1.0.0
-- =============================================================================
-- BANGLADESH LABOR LAW REFERENCE:
--   Casual Leave       : 10 days / year
--   Earned Leave       : 1 day per 18 days worked (~14 days/year after 1 year)
--   Sick Leave         : 14 days / year
--   Maternity Leave    : 16 weeks (112 days) – fully paid
--   Notice Period      : 60 days for permanent employees
--   Probation Period   : Max 6 months per Bangladesh Labor Act 2006
--   Provident Fund     : 10% employee + 10% employer on basic salary
--   Gratuity           : 30 days wages per year of service (after 5 years)
--   Income Tax         : Progressive 0%–25% per NBR Bangladesh rates
--   Default Currency   : BDT (Bangladeshi Taka)
-- =============================================================================

-- =========================================================
-- SECTION 1: DROP DEPENDENT OBJECTS (safe re-run support)
-- =========================================================

-- Drop triggers
BEGIN EXECUTE IMMEDIATE 'DROP TRIGGER HR_EMPLOYEES_AUDIT_TRG';            EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TRIGGER HR_EMP_COMP_AUDIT_TRG';             EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TRIGGER HR_LEAVE_REQ_AUDIT_TRG';            EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TRIGGER HR_PAYSLIPS_AUDIT_TRG';             EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TRIGGER HR_CONTRACTS_AUDIT_TRG';            EXCEPTION WHEN OTHERS THEN NULL; END;
/

-- Drop tables in reverse dependency order
BEGIN EXECUTE IMMEDIATE 'DROP TABLE HR_APP_USERS              CASCADE CONSTRAINTS PURGE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE HR_INTEGRATION_LOG        CASCADE CONSTRAINTS PURGE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE HR_AUDIT_LOG              CASCADE CONSTRAINTS PURGE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE HR_NOTIFICATIONS          CASCADE CONSTRAINTS PURGE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE HR_CONTRACTS              CASCADE CONSTRAINTS PURGE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE HR_EMPLOYEE_DOCUMENTS     CASCADE CONSTRAINTS PURGE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE HR_DOCUMENT_TYPES         CASCADE CONSTRAINTS PURGE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE HR_TRAINING_ENROLLMENTS   CASCADE CONSTRAINTS PURGE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE HR_TRAINING_SESSIONS      CASCADE CONSTRAINTS PURGE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE HR_TRAINING_PROGRAMS      CASCADE CONSTRAINTS PURGE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE HR_PROVIDENT_FUND         CASCADE CONSTRAINTS PURGE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE HR_TAX_BRACKETS           CASCADE CONSTRAINTS PURGE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE HR_PAYSLIPS               CASCADE CONSTRAINTS PURGE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE HR_PAYROLL_RUNS           CASCADE CONSTRAINTS PURGE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE HR_PAYROLL_PERIODS        CASCADE CONSTRAINTS PURGE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE HR_APPLICATIONS           CASCADE CONSTRAINTS PURGE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE HR_CANDIDATES             CASCADE CONSTRAINTS PURGE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE HR_JOB_POSTINGS           CASCADE CONSTRAINTS PURGE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE HR_GOALS                  CASCADE CONSTRAINTS PURGE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE HR_APPRAISALS             CASCADE CONSTRAINTS PURGE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE HR_APPRAISAL_CYCLES       CASCADE CONSTRAINTS PURGE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE HR_LEAVE_REQUESTS         CASCADE CONSTRAINTS PURGE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE HR_LEAVE_BALANCES         CASCADE CONSTRAINTS PURGE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE HR_LEAVE_TYPES            CASCADE CONSTRAINTS PURGE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE HR_ATTENDANCE             CASCADE CONSTRAINTS PURGE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE HR_ATTENDANCE_POLICIES    CASCADE CONSTRAINTS PURGE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE HR_EMPLOYEE_BENEFITS      CASCADE CONSTRAINTS PURGE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE HR_BENEFITS               CASCADE CONSTRAINTS PURGE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE HR_EMPLOYEE_COMPENSATION  CASCADE CONSTRAINTS PURGE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE HR_SALARY_COMPONENTS      CASCADE CONSTRAINTS PURGE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE HR_EMPLOYMENT_HISTORY     CASCADE CONSTRAINTS PURGE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE HR_EMPLOYEES              CASCADE CONSTRAINTS PURGE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE HR_GRADES                 CASCADE CONSTRAINTS PURGE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE HR_POSITIONS              CASCADE CONSTRAINTS PURGE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE HR_DEPARTMENTS            CASCADE CONSTRAINTS PURGE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE HR_COMPANIES              CASCADE CONSTRAINTS PURGE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE HR_LOOKUP_VALUES          CASCADE CONSTRAINTS PURGE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE HR_LOOKUP_TYPES           CASCADE CONSTRAINTS PURGE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/

-- =========================================================
-- SECTION 2: DROP SEQUENCES (safe re-run support)
-- =========================================================

BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE HR_LOOKUP_TYPES_SEQ';          EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE HR_LOOKUP_VALUES_SEQ';         EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE HR_COMPANIES_SEQ';             EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE HR_DEPARTMENTS_SEQ';           EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE HR_POSITIONS_SEQ';             EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE HR_GRADES_SEQ';                EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE HR_EMPLOYEES_SEQ';             EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE HR_EMPLOYMENT_HISTORY_SEQ';    EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE HR_SALARY_COMPONENTS_SEQ';     EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE HR_EMPLOYEE_COMPENSATION_SEQ'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE HR_BENEFITS_SEQ';              EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE HR_EMPLOYEE_BENEFITS_SEQ';     EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE HR_ATTENDANCE_POLICIES_SEQ';   EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE HR_ATTENDANCE_SEQ';            EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE HR_LEAVE_TYPES_SEQ';           EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE HR_LEAVE_BALANCES_SEQ';        EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE HR_LEAVE_REQUESTS_SEQ';        EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE HR_APPRAISAL_CYCLES_SEQ';      EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE HR_APPRAISALS_SEQ';            EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE HR_GOALS_SEQ';                 EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE HR_JOB_POSTINGS_SEQ';          EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE HR_CANDIDATES_SEQ';            EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE HR_APPLICATIONS_SEQ';          EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE HR_PAYROLL_PERIODS_SEQ';       EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE HR_PAYROLL_RUNS_SEQ';          EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE HR_PAYSLIPS_SEQ';              EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE HR_TAX_BRACKETS_SEQ';          EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE HR_PROVIDENT_FUND_SEQ';        EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE HR_TRAINING_PROGRAMS_SEQ';     EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE HR_TRAINING_SESSIONS_SEQ';     EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE HR_TRAINING_ENROLLMENTS_SEQ';  EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE HR_DOCUMENT_TYPES_SEQ';        EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE HR_EMPLOYEE_DOCUMENTS_SEQ';    EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE HR_CONTRACTS_SEQ';             EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE HR_NOTIFICATIONS_SEQ';         EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE HR_AUDIT_LOG_SEQ';             EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE HR_INTEGRATION_LOG_SEQ';       EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE HR_APP_USERS_SEQ';             EXCEPTION WHEN OTHERS THEN NULL; END;
/

-- =========================================================
-- SECTION 3: CREATE SEQUENCES
-- =========================================================

CREATE SEQUENCE HR_LOOKUP_TYPES_SEQ          START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE HR_LOOKUP_VALUES_SEQ         START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE HR_COMPANIES_SEQ             START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE HR_DEPARTMENTS_SEQ           START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE HR_POSITIONS_SEQ             START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE HR_GRADES_SEQ                START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE HR_EMPLOYEES_SEQ             START WITH 1000 INCREMENT BY 1 CACHE 100 NOCYCLE;
CREATE SEQUENCE HR_EMPLOYMENT_HISTORY_SEQ    START WITH 1 INCREMENT BY 1 CACHE 20 NOCYCLE;
CREATE SEQUENCE HR_SALARY_COMPONENTS_SEQ     START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE HR_EMPLOYEE_COMPENSATION_SEQ START WITH 1 INCREMENT BY 1 CACHE 20 NOCYCLE;
CREATE SEQUENCE HR_BENEFITS_SEQ              START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE HR_EMPLOYEE_BENEFITS_SEQ     START WITH 1 INCREMENT BY 1 CACHE 20 NOCYCLE;
CREATE SEQUENCE HR_ATTENDANCE_POLICIES_SEQ   START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE HR_ATTENDANCE_SEQ            START WITH 1 INCREMENT BY 1 CACHE 100 NOCYCLE;
CREATE SEQUENCE HR_LEAVE_TYPES_SEQ           START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE HR_LEAVE_BALANCES_SEQ        START WITH 1 INCREMENT BY 1 CACHE 50 NOCYCLE;
CREATE SEQUENCE HR_LEAVE_REQUESTS_SEQ        START WITH 1 INCREMENT BY 1 CACHE 50 NOCYCLE;
CREATE SEQUENCE HR_APPRAISAL_CYCLES_SEQ      START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE HR_APPRAISALS_SEQ            START WITH 1 INCREMENT BY 1 CACHE 50 NOCYCLE;
CREATE SEQUENCE HR_GOALS_SEQ                 START WITH 1 INCREMENT BY 1 CACHE 50 NOCYCLE;
CREATE SEQUENCE HR_JOB_POSTINGS_SEQ          START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE HR_CANDIDATES_SEQ            START WITH 1 INCREMENT BY 1 CACHE 20 NOCYCLE;
CREATE SEQUENCE HR_APPLICATIONS_SEQ          START WITH 1 INCREMENT BY 1 CACHE 20 NOCYCLE;
CREATE SEQUENCE HR_PAYROLL_PERIODS_SEQ       START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE HR_PAYROLL_RUNS_SEQ          START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE HR_PAYSLIPS_SEQ              START WITH 1 INCREMENT BY 1 CACHE 100 NOCYCLE;
CREATE SEQUENCE HR_TAX_BRACKETS_SEQ          START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE HR_PROVIDENT_FUND_SEQ        START WITH 1 INCREMENT BY 1 CACHE 50 NOCYCLE;
CREATE SEQUENCE HR_TRAINING_PROGRAMS_SEQ     START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE HR_TRAINING_SESSIONS_SEQ     START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE HR_TRAINING_ENROLLMENTS_SEQ  START WITH 1 INCREMENT BY 1 CACHE 20 NOCYCLE;
CREATE SEQUENCE HR_DOCUMENT_TYPES_SEQ        START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE HR_EMPLOYEE_DOCUMENTS_SEQ    START WITH 1 INCREMENT BY 1 CACHE 50 NOCYCLE;
CREATE SEQUENCE HR_CONTRACTS_SEQ             START WITH 1 INCREMENT BY 1 CACHE 20 NOCYCLE;
CREATE SEQUENCE HR_NOTIFICATIONS_SEQ         START WITH 1 INCREMENT BY 1 CACHE 100 NOCYCLE;
CREATE SEQUENCE HR_AUDIT_LOG_SEQ             START WITH 1 INCREMENT BY 1 CACHE 100 NOCYCLE;
CREATE SEQUENCE HR_INTEGRATION_LOG_SEQ       START WITH 1 INCREMENT BY 1 CACHE 50 NOCYCLE;
CREATE SEQUENCE HR_APP_USERS_SEQ             START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

-- =========================================================
-- SECTION 4: CREATE TABLES
-- =========================================================

-- ---------------------------------------------------------
-- 4.1 LOOKUP / REFERENCE TABLES
-- ---------------------------------------------------------

CREATE TABLE HR_LOOKUP_TYPES (
    lookup_type_id    NUMBER          NOT NULL,
    lookup_type_code  VARCHAR2(50)    NOT NULL,
    lookup_type_name  VARCHAR2(200)   NOT NULL,
    description       VARCHAR2(500),
    is_active         CHAR(1)         DEFAULT 'Y' NOT NULL,
    -- Audit columns
    created_date      DATE            DEFAULT SYSDATE NOT NULL,
    created_by        VARCHAR2(100)   NOT NULL,
    updated_date      DATE,
    updated_by        VARCHAR2(100),
    -- Constraints
    CONSTRAINT HR_LOOKUP_TYPES_PK  PRIMARY KEY (lookup_type_id),
    CONSTRAINT HR_LOOKUP_TYPES_UC  UNIQUE (lookup_type_code),
    CONSTRAINT HR_LOOKUP_TYPES_ACT CHECK (is_active IN ('Y','N'))
);

CREATE TABLE HR_LOOKUP_VALUES (
    lookup_value_id   NUMBER          NOT NULL,
    lookup_type_id    NUMBER          NOT NULL,
    lookup_code       VARCHAR2(50)    NOT NULL,
    lookup_value      VARCHAR2(200)   NOT NULL,
    display_order     NUMBER          DEFAULT 0,
    is_active         CHAR(1)         DEFAULT 'Y' NOT NULL,
    attribute1        VARCHAR2(200),
    attribute2        VARCHAR2(200),
    attribute3        VARCHAR2(200),
    attribute4        VARCHAR2(200),
    attribute5        VARCHAR2(200),
    -- Audit columns
    created_date      DATE            DEFAULT SYSDATE NOT NULL,
    created_by        VARCHAR2(100)   NOT NULL,
    updated_date      DATE,
    updated_by        VARCHAR2(100),
    -- Constraints
    CONSTRAINT HR_LOOKUP_VALUES_PK  PRIMARY KEY (lookup_value_id),
    CONSTRAINT HR_LOOKUP_VALUES_UC  UNIQUE (lookup_type_id, lookup_code),
    CONSTRAINT HR_LOOKUP_VALUES_TYP FOREIGN KEY (lookup_type_id) REFERENCES HR_LOOKUP_TYPES (lookup_type_id),
    CONSTRAINT HR_LOOKUP_VALUES_ACT CHECK (is_active IN ('Y','N'))
);

-- ---------------------------------------------------------
-- 4.2 ORGANIZATION STRUCTURE
-- ---------------------------------------------------------

CREATE TABLE HR_COMPANIES (
    company_id          NUMBER          NOT NULL,
    company_code        VARCHAR2(20)    NOT NULL,
    company_name        VARCHAR2(300)   NOT NULL,
    registration_no     VARCHAR2(100),
    tax_id              VARCHAR2(50),
    address             VARCHAR2(500),
    city                VARCHAR2(100),
    country             VARCHAR2(100)   DEFAULT 'Bangladesh',
    phone               VARCHAR2(30),
    email               VARCHAR2(200),
    website             VARCHAR2(300),
    fiscal_year_start   DATE,
    fiscal_year_end     DATE,
    currency_code       VARCHAR2(10)    DEFAULT 'BDT',
    is_active           CHAR(1)         DEFAULT 'Y' NOT NULL,
    -- Audit columns
    created_date        DATE            DEFAULT SYSDATE NOT NULL,
    created_by          VARCHAR2(100)   NOT NULL,
    updated_date        DATE,
    updated_by          VARCHAR2(100),
    -- Constraints
    CONSTRAINT HR_COMPANIES_PK   PRIMARY KEY (company_id),
    CONSTRAINT HR_COMPANIES_UC   UNIQUE (company_code),
    CONSTRAINT HR_COMPANIES_ACT  CHECK (is_active IN ('Y','N'))
);

-- Departments: dept_head_emp_id FK to HR_EMPLOYEES added via ALTER after employee table creation
CREATE TABLE HR_DEPARTMENTS (
    dept_id             NUMBER          NOT NULL,
    company_id          NUMBER          NOT NULL,
    dept_code           VARCHAR2(20)    NOT NULL,
    dept_name           VARCHAR2(200)   NOT NULL,
    parent_dept_id      NUMBER,
    dept_head_emp_id    NUMBER,
    cost_center         VARCHAR2(50),
    is_active           CHAR(1)         DEFAULT 'Y' NOT NULL,
    -- Audit columns
    created_date        DATE            DEFAULT SYSDATE NOT NULL,
    created_by          VARCHAR2(100)   NOT NULL,
    updated_date        DATE,
    updated_by          VARCHAR2(100),
    -- Constraints
    CONSTRAINT HR_DEPARTMENTS_PK     PRIMARY KEY (dept_id),
    CONSTRAINT HR_DEPARTMENTS_UC     UNIQUE (company_id, dept_code),
    CONSTRAINT HR_DEPARTMENTS_COMP   FOREIGN KEY (company_id)     REFERENCES HR_COMPANIES (company_id),
    CONSTRAINT HR_DEPARTMENTS_PARENT FOREIGN KEY (parent_dept_id) REFERENCES HR_DEPARTMENTS (dept_id),
    CONSTRAINT HR_DEPARTMENTS_ACT    CHECK (is_active IN ('Y','N'))
);

CREATE TABLE HR_POSITIONS (
    position_id         NUMBER          NOT NULL,
    company_id          NUMBER          NOT NULL,
    dept_id             NUMBER          NOT NULL,
    position_code       VARCHAR2(30)    NOT NULL,
    position_title      VARCHAR2(200)   NOT NULL,
    position_level      NUMBER,
    min_salary          NUMBER(15,2),
    max_salary          NUMBER(15,2),
    is_active           CHAR(1)         DEFAULT 'Y' NOT NULL,
    -- Audit columns
    created_date        DATE            DEFAULT SYSDATE NOT NULL,
    created_by          VARCHAR2(100)   NOT NULL,
    updated_date        DATE,
    updated_by          VARCHAR2(100),
    -- Constraints
    CONSTRAINT HR_POSITIONS_PK    PRIMARY KEY (position_id),
    CONSTRAINT HR_POSITIONS_UC    UNIQUE (company_id, position_code),
    CONSTRAINT HR_POSITIONS_COMP  FOREIGN KEY (company_id) REFERENCES HR_COMPANIES (company_id),
    CONSTRAINT HR_POSITIONS_DEPT  FOREIGN KEY (dept_id)    REFERENCES HR_DEPARTMENTS (dept_id),
    CONSTRAINT HR_POSITIONS_ACT   CHECK (is_active IN ('Y','N')),
    CONSTRAINT HR_POSITIONS_SAL   CHECK (max_salary IS NULL OR min_salary IS NULL OR max_salary >= min_salary)
);

CREATE TABLE HR_GRADES (
    grade_id            NUMBER          NOT NULL,
    company_id          NUMBER          NOT NULL,
    grade_code          VARCHAR2(20)    NOT NULL,
    grade_name          VARCHAR2(100)   NOT NULL,
    min_salary          NUMBER(15,2),
    max_salary          NUMBER(15,2),
    is_active           CHAR(1)         DEFAULT 'Y' NOT NULL,
    -- Audit columns
    created_date        DATE            DEFAULT SYSDATE NOT NULL,
    created_by          VARCHAR2(100)   NOT NULL,
    updated_date        DATE,
    updated_by          VARCHAR2(100),
    -- Constraints
    CONSTRAINT HR_GRADES_PK    PRIMARY KEY (grade_id),
    CONSTRAINT HR_GRADES_UC    UNIQUE (company_id, grade_code),
    CONSTRAINT HR_GRADES_COMP  FOREIGN KEY (company_id) REFERENCES HR_COMPANIES (company_id),
    CONSTRAINT HR_GRADES_ACT   CHECK (is_active IN ('Y','N')),
    CONSTRAINT HR_GRADES_SAL   CHECK (max_salary IS NULL OR min_salary IS NULL OR max_salary >= min_salary)
);

-- ---------------------------------------------------------
-- 4.3 EMPLOYEE MASTER
-- ---------------------------------------------------------

CREATE TABLE HR_EMPLOYEES (
    emp_id                      NUMBER          NOT NULL,
    company_id                  NUMBER          NOT NULL,
    emp_code                    VARCHAR2(20)    NOT NULL,
    first_name                  VARCHAR2(100)   NOT NULL,
    last_name                   VARCHAR2(100)   NOT NULL,
    full_name                   VARCHAR2(201)   GENERATED ALWAYS AS (first_name || ' ' || last_name) VIRTUAL,
    date_of_birth               DATE,
    gender                      VARCHAR2(10),
    national_id                 VARCHAR2(20),
    passport_no                 VARCHAR2(20),
    email_personal              VARCHAR2(200),
    email_official              VARCHAR2(200)   NOT NULL,
    phone_primary               VARCHAR2(20),
    phone_secondary             VARCHAR2(20),
    address_current             VARCHAR2(500),
    address_permanent           VARCHAR2(500),
    city                        VARCHAR2(100),
    district                    VARCHAR2(100),
    country                     VARCHAR2(100)   DEFAULT 'Bangladesh',
    blood_group                 VARCHAR2(5),
    marital_status              VARCHAR2(20),
    religion                    VARCHAR2(30),
    nationality                 VARCHAR2(50)    DEFAULT 'Bangladeshi',
    emergency_contact_name      VARCHAR2(200),
    emergency_contact_phone     VARCHAR2(20),
    emergency_contact_relation  VARCHAR2(50),
    -- Organizational placement
    dept_id                     NUMBER,
    position_id                 NUMBER,
    grade_id                    NUMBER,
    manager_id                  NUMBER,
    -- Employment details
    hire_date                   DATE            NOT NULL,
    confirmation_date           DATE,
    termination_date            DATE,
    employment_type             VARCHAR2(20)    NOT NULL,
    employment_status           VARCHAR2(20)    DEFAULT 'ACTIVE' NOT NULL,
    work_arrangement            VARCHAR2(20)    DEFAULT 'OFFICE',
    -- Bangladesh payroll & banking
    bank_name                   VARCHAR2(200),
    bank_account_no             VARCHAR2(50),
    bank_branch                 VARCHAR2(200),
    bank_routing_no             VARCHAR2(20),
    tin_number                  VARCHAR2(20),
    provident_fund_eligible     CHAR(1)         DEFAULT 'N' NOT NULL,
    provident_fund_no           VARCHAR2(30),
    gratuity_eligible           CHAR(1)         DEFAULT 'N' NOT NULL,
    probation_end_date          DATE,
    notice_period_days          NUMBER          DEFAULT 60,
    -- Profile photo (stored as BLOB for APEX compatibility)
    profile_photo               BLOB,
    profile_photo_mime          VARCHAR2(100),
    -- Audit columns
    created_date                DATE            DEFAULT SYSDATE NOT NULL,
    created_by                  VARCHAR2(100)   NOT NULL,
    updated_date                DATE,
    updated_by                  VARCHAR2(100),
    -- Constraints
    CONSTRAINT HR_EMPLOYEES_PK       PRIMARY KEY (emp_id),
    CONSTRAINT HR_EMPLOYEES_EMP_UC   UNIQUE (emp_code),
    CONSTRAINT HR_EMPLOYEES_EMAIL_UC UNIQUE (email_official),
    CONSTRAINT HR_EMPLOYEES_COMP     FOREIGN KEY (company_id)  REFERENCES HR_COMPANIES (company_id),
    CONSTRAINT HR_EMPLOYEES_DEPT     FOREIGN KEY (dept_id)     REFERENCES HR_DEPARTMENTS (dept_id),
    CONSTRAINT HR_EMPLOYEES_POS      FOREIGN KEY (position_id) REFERENCES HR_POSITIONS (position_id),
    CONSTRAINT HR_EMPLOYEES_GRADE    FOREIGN KEY (grade_id)    REFERENCES HR_GRADES (grade_id),
    CONSTRAINT HR_EMPLOYEES_MGR      FOREIGN KEY (manager_id)  REFERENCES HR_EMPLOYEES (emp_id),
    CONSTRAINT HR_EMPLOYEES_EMP_TYPE CHECK (employment_type IN ('PERMANENT','CONTRACT','PROBATIONARY','INTERN')),
    CONSTRAINT HR_EMPLOYEES_STATUS   CHECK (employment_status IN ('ACTIVE','TERMINATED','RESIGNED','SUSPENDED','ON_LEAVE')),
    CONSTRAINT HR_EMPLOYEES_WORK_ARR CHECK (work_arrangement IN ('REMOTE','HYBRID','OFFICE')),
    CONSTRAINT HR_EMPLOYEES_PF_ELIG  CHECK (provident_fund_eligible IN ('Y','N')),
    CONSTRAINT HR_EMPLOYEES_GR_ELIG  CHECK (gratuity_eligible IN ('Y','N')),
    CONSTRAINT HR_EMPLOYEES_GENDER   CHECK (gender IN ('MALE','FEMALE','OTHER'))
);

-- Add deferred FK: HR_DEPARTMENTS.dept_head_emp_id -> HR_EMPLOYEES
ALTER TABLE HR_DEPARTMENTS ADD CONSTRAINT HR_DEPARTMENTS_HEAD
    FOREIGN KEY (dept_head_emp_id) REFERENCES HR_EMPLOYEES (emp_id)
    DEFERRABLE INITIALLY DEFERRED;

-- ---------------------------------------------------------
-- 4.4 EMPLOYMENT HISTORY / CAREER PROGRESSION
-- ---------------------------------------------------------

CREATE TABLE HR_EMPLOYMENT_HISTORY (
    history_id            NUMBER          NOT NULL,
    emp_id                NUMBER          NOT NULL,
    event_type            VARCHAR2(30)    NOT NULL,
    effective_date        DATE            NOT NULL,
    old_dept_id           NUMBER,
    new_dept_id           NUMBER,
    old_position_id       NUMBER,
    new_position_id       NUMBER,
    old_grade_id          NUMBER,
    new_grade_id          NUMBER,
    old_salary            NUMBER(15,2),
    new_salary            NUMBER(15,2),
    old_employment_type   VARCHAR2(20),
    new_employment_type   VARCHAR2(20),
    remarks               VARCHAR2(1000),
    approved_by           NUMBER,
    -- Audit columns
    created_date          DATE            DEFAULT SYSDATE NOT NULL,
    created_by            VARCHAR2(100)   NOT NULL,
    updated_date          DATE,
    updated_by            VARCHAR2(100),
    -- Constraints
    CONSTRAINT HR_EMP_HIST_PK        PRIMARY KEY (history_id),
    CONSTRAINT HR_EMP_HIST_EMP       FOREIGN KEY (emp_id)          REFERENCES HR_EMPLOYEES (emp_id),
    CONSTRAINT HR_EMP_HIST_OLD_DEPT  FOREIGN KEY (old_dept_id)     REFERENCES HR_DEPARTMENTS (dept_id),
    CONSTRAINT HR_EMP_HIST_NEW_DEPT  FOREIGN KEY (new_dept_id)     REFERENCES HR_DEPARTMENTS (dept_id),
    CONSTRAINT HR_EMP_HIST_OLD_POS   FOREIGN KEY (old_position_id) REFERENCES HR_POSITIONS (position_id),
    CONSTRAINT HR_EMP_HIST_NEW_POS   FOREIGN KEY (new_position_id) REFERENCES HR_POSITIONS (position_id),
    CONSTRAINT HR_EMP_HIST_OLD_GRD   FOREIGN KEY (old_grade_id)    REFERENCES HR_GRADES (grade_id),
    CONSTRAINT HR_EMP_HIST_NEW_GRD   FOREIGN KEY (new_grade_id)    REFERENCES HR_GRADES (grade_id),
    CONSTRAINT HR_EMP_HIST_APPRVR    FOREIGN KEY (approved_by)     REFERENCES HR_EMPLOYEES (emp_id),
    CONSTRAINT HR_EMP_HIST_EVT_TYPE  CHECK (event_type IN (
        'HIRE','PROMOTION','TRANSFER','ROLE_CHANGE','SALARY_CHANGE',
        'CONFIRMATION','TERMINATION','SUSPENSION','REINSTATEMENT'))
);

-- ---------------------------------------------------------
-- 4.5 COMPENSATION & BENEFITS
-- ---------------------------------------------------------

CREATE TABLE HR_SALARY_COMPONENTS (
    component_id          NUMBER          NOT NULL,
    company_id            NUMBER          NOT NULL,
    component_code        VARCHAR2(30)    NOT NULL,
    component_name        VARCHAR2(200)   NOT NULL,
    component_type        VARCHAR2(20)    NOT NULL,
    is_taxable            CHAR(1)         DEFAULT 'N' NOT NULL,
    is_fixed              CHAR(1)         DEFAULT 'Y' NOT NULL,
    calculation_method    VARCHAR2(20),
    calculation_value     NUMBER(10,4),
    is_active             CHAR(1)         DEFAULT 'Y' NOT NULL,
    -- Audit columns
    created_date          DATE            DEFAULT SYSDATE NOT NULL,
    created_by            VARCHAR2(100)   NOT NULL,
    updated_date          DATE,
    updated_by            VARCHAR2(100),
    -- Constraints
    CONSTRAINT HR_SAL_COMP_PK       PRIMARY KEY (component_id),
    CONSTRAINT HR_SAL_COMP_UC       UNIQUE (company_id, component_code),
    CONSTRAINT HR_SAL_COMP_COMP     FOREIGN KEY (company_id) REFERENCES HR_COMPANIES (company_id),
    CONSTRAINT HR_SAL_COMP_TYPE     CHECK (component_type IN ('EARNING','DEDUCTION','STATUTORY')),
    CONSTRAINT HR_SAL_COMP_TAXABLE  CHECK (is_taxable IN ('Y','N')),
    CONSTRAINT HR_SAL_COMP_FIXED    CHECK (is_fixed IN ('Y','N')),
    CONSTRAINT HR_SAL_COMP_ACT      CHECK (is_active IN ('Y','N'))
);

CREATE TABLE HR_EMPLOYEE_COMPENSATION (
    comp_id                 NUMBER          NOT NULL,
    emp_id                  NUMBER          NOT NULL,
    effective_date          DATE            NOT NULL,
    end_date                DATE,
    basic_salary            NUMBER(15,2)    NOT NULL,
    house_rent_allowance    NUMBER(15,2)    DEFAULT 0,
    medical_allowance       NUMBER(15,2)    DEFAULT 0,
    transport_allowance     NUMBER(15,2)    DEFAULT 0,
    mobile_allowance        NUMBER(15,2)    DEFAULT 0,
    food_allowance          NUMBER(15,2)    DEFAULT 0,
    special_allowance       NUMBER(15,2)    DEFAULT 0,
    gross_salary            NUMBER(15,2),
    is_active               CHAR(1)         DEFAULT 'Y' NOT NULL,
    -- Audit columns
    created_date            DATE            DEFAULT SYSDATE NOT NULL,
    created_by              VARCHAR2(100)   NOT NULL,
    updated_date            DATE,
    updated_by              VARCHAR2(100),
    -- Constraints
    CONSTRAINT HR_EMP_COMP_PK      PRIMARY KEY (comp_id),
    CONSTRAINT HR_EMP_COMP_EMP     FOREIGN KEY (emp_id) REFERENCES HR_EMPLOYEES (emp_id),
    CONSTRAINT HR_EMP_COMP_ACT     CHECK (is_active IN ('Y','N')),
    CONSTRAINT HR_EMP_COMP_BASIC   CHECK (basic_salary > 0),
    CONSTRAINT HR_EMP_COMP_DATES   CHECK (end_date IS NULL OR end_date > effective_date)
);

CREATE TABLE HR_BENEFITS (
    benefit_id      NUMBER          NOT NULL,
    company_id      NUMBER          NOT NULL,
    benefit_code    VARCHAR2(30)    NOT NULL,
    benefit_name    VARCHAR2(200)   NOT NULL,
    benefit_type    VARCHAR2(50),
    description     VARCHAR2(1000),
    is_active       CHAR(1)         DEFAULT 'Y' NOT NULL,
    -- Audit columns
    created_date    DATE            DEFAULT SYSDATE NOT NULL,
    created_by      VARCHAR2(100)   NOT NULL,
    updated_date    DATE,
    updated_by      VARCHAR2(100),
    -- Constraints
    CONSTRAINT HR_BENEFITS_PK    PRIMARY KEY (benefit_id),
    CONSTRAINT HR_BENEFITS_UC    UNIQUE (company_id, benefit_code),
    CONSTRAINT HR_BENEFITS_COMP  FOREIGN KEY (company_id) REFERENCES HR_COMPANIES (company_id),
    CONSTRAINT HR_BENEFITS_ACT   CHECK (is_active IN ('Y','N'))
);

CREATE TABLE HR_EMPLOYEE_BENEFITS (
    enrollment_id       NUMBER          NOT NULL,
    emp_id              NUMBER          NOT NULL,
    benefit_id          NUMBER          NOT NULL,
    enrollment_date     DATE            NOT NULL,
    end_date            DATE,
    contribution_emp    NUMBER(15,2)    DEFAULT 0,
    contribution_company NUMBER(15,2)  DEFAULT 0,
    status              VARCHAR2(20)    DEFAULT 'ACTIVE',
    -- Audit columns
    created_date        DATE            DEFAULT SYSDATE NOT NULL,
    created_by          VARCHAR2(100)   NOT NULL,
    updated_date        DATE,
    updated_by          VARCHAR2(100),
    -- Constraints
    CONSTRAINT HR_EMP_BEN_PK      PRIMARY KEY (enrollment_id),
    CONSTRAINT HR_EMP_BEN_EMP     FOREIGN KEY (emp_id)      REFERENCES HR_EMPLOYEES (emp_id),
    CONSTRAINT HR_EMP_BEN_BEN     FOREIGN KEY (benefit_id)  REFERENCES HR_BENEFITS (benefit_id),
    CONSTRAINT HR_EMP_BEN_STATUS  CHECK (status IN ('ACTIVE','INACTIVE','EXPIRED'))
);

-- ---------------------------------------------------------
-- 4.6 ATTENDANCE
-- ---------------------------------------------------------

CREATE TABLE HR_ATTENDANCE_POLICIES (
    policy_id            NUMBER          NOT NULL,
    company_id           NUMBER          NOT NULL,
    policy_name          VARCHAR2(200)   NOT NULL,
    work_start_time      VARCHAR2(8),
    work_end_time        VARCHAR2(8),
    work_hours_per_day   NUMBER(4,2)     DEFAULT 8,
    work_days_per_week   NUMBER(2,1)     DEFAULT 5,
    grace_minutes        NUMBER          DEFAULT 15,
    is_active            CHAR(1)         DEFAULT 'Y' NOT NULL,
    -- Audit columns
    created_date         DATE            DEFAULT SYSDATE NOT NULL,
    created_by           VARCHAR2(100)   NOT NULL,
    updated_date         DATE,
    updated_by           VARCHAR2(100),
    -- Constraints
    CONSTRAINT HR_ATT_POL_PK    PRIMARY KEY (policy_id),
    CONSTRAINT HR_ATT_POL_COMP  FOREIGN KEY (company_id) REFERENCES HR_COMPANIES (company_id),
    CONSTRAINT HR_ATT_POL_ACT   CHECK (is_active IN ('Y','N'))
);

CREATE TABLE HR_ATTENDANCE (
    attendance_id       NUMBER          NOT NULL,
    emp_id              NUMBER          NOT NULL,
    attendance_date     DATE            NOT NULL,
    check_in_time       TIMESTAMP,
    check_out_time      TIMESTAMP,
    work_hours          NUMBER(5,2),
    overtime_hours      NUMBER(5,2)     DEFAULT 0,
    attendance_status   VARCHAR2(20)    NOT NULL,
    remarks             VARCHAR2(500),
    -- Audit columns
    created_date        DATE            DEFAULT SYSDATE NOT NULL,
    created_by          VARCHAR2(100)   NOT NULL,
    updated_date        DATE,
    updated_by          VARCHAR2(100),
    -- Constraints
    CONSTRAINT HR_ATTENDANCE_PK       PRIMARY KEY (attendance_id),
    CONSTRAINT HR_ATTENDANCE_UC       UNIQUE (emp_id, attendance_date),
    CONSTRAINT HR_ATTENDANCE_EMP      FOREIGN KEY (emp_id) REFERENCES HR_EMPLOYEES (emp_id),
    CONSTRAINT HR_ATTENDANCE_STATUS   CHECK (attendance_status IN (
        'PRESENT','ABSENT','LATE','HALF_DAY','ON_LEAVE','HOLIDAY','WEEKEND')),
    CONSTRAINT HR_ATTENDANCE_CHK_TM   CHECK (check_out_time IS NULL OR check_out_time > check_in_time)
);

-- ---------------------------------------------------------
-- 4.7 LEAVE MANAGEMENT
-- ---------------------------------------------------------

CREATE TABLE HR_LEAVE_TYPES (
    leave_type_id           NUMBER          NOT NULL,
    company_id              NUMBER          NOT NULL,
    leave_type_code         VARCHAR2(30)    NOT NULL,
    leave_type_name         VARCHAR2(200)   NOT NULL,
    leave_category          VARCHAR2(30)    NOT NULL,
    days_per_year           NUMBER          NOT NULL,
    max_carry_forward       NUMBER          DEFAULT 0,
    is_paid                 CHAR(1)         DEFAULT 'Y' NOT NULL,
    requires_approval       CHAR(1)         DEFAULT 'Y' NOT NULL,
    min_notice_days         NUMBER          DEFAULT 0,
    max_days_per_request    NUMBER,
    accrual_method          VARCHAR2(20)    DEFAULT 'ANNUAL',
    is_active               CHAR(1)         DEFAULT 'Y' NOT NULL,
    -- Audit columns
    created_date            DATE            DEFAULT SYSDATE NOT NULL,
    created_by              VARCHAR2(100)   NOT NULL,
    updated_date            DATE,
    updated_by              VARCHAR2(100),
    -- Constraints
    CONSTRAINT HR_LV_TYPES_PK       PRIMARY KEY (leave_type_id),
    CONSTRAINT HR_LV_TYPES_UC       UNIQUE (company_id, leave_type_code),
    CONSTRAINT HR_LV_TYPES_COMP     FOREIGN KEY (company_id) REFERENCES HR_COMPANIES (company_id),
    CONSTRAINT HR_LV_TYPES_CAT      CHECK (leave_category IN (
        'CASUAL','EARNED','SICK','MATERNITY','PATERNITY',
        'PUBLIC_HOLIDAY','UNPAID','COMPENSATORY')),
    CONSTRAINT HR_LV_TYPES_PAID     CHECK (is_paid IN ('Y','N')),
    CONSTRAINT HR_LV_TYPES_APPRV    CHECK (requires_approval IN ('Y','N')),
    CONSTRAINT HR_LV_TYPES_ACT      CHECK (is_active IN ('Y','N')),
    CONSTRAINT HR_LV_TYPES_ACCRUAL  CHECK (accrual_method IN ('ANNUAL','MONTHLY','DAILY'))
);

CREATE TABLE HR_LEAVE_BALANCES (
    balance_id        NUMBER          NOT NULL,
    emp_id            NUMBER          NOT NULL,
    leave_type_id     NUMBER          NOT NULL,
    fiscal_year       NUMBER(4)       NOT NULL,
    opening_balance   NUMBER(8,2)     DEFAULT 0 NOT NULL,
    accrued           NUMBER(8,2)     DEFAULT 0 NOT NULL,
    taken             NUMBER(8,2)     DEFAULT 0 NOT NULL,
    pending           NUMBER(8,2)     DEFAULT 0 NOT NULL,
    -- Computed closing balance: opening + accrued - taken - pending
    closing_balance   NUMBER(8,2)     GENERATED ALWAYS AS
                        (opening_balance + accrued - taken - pending) VIRTUAL,
    last_updated      DATE            DEFAULT SYSDATE,
    -- Audit columns
    created_date      DATE            DEFAULT SYSDATE NOT NULL,
    created_by        VARCHAR2(100)   NOT NULL,
    updated_date      DATE,
    updated_by        VARCHAR2(100),
    -- Constraints
    CONSTRAINT HR_LV_BAL_PK      PRIMARY KEY (balance_id),
    CONSTRAINT HR_LV_BAL_UC      UNIQUE (emp_id, leave_type_id, fiscal_year),
    CONSTRAINT HR_LV_BAL_EMP     FOREIGN KEY (emp_id)          REFERENCES HR_EMPLOYEES (emp_id),
    CONSTRAINT HR_LV_BAL_LV_TYP  FOREIGN KEY (leave_type_id)  REFERENCES HR_LEAVE_TYPES (leave_type_id)
);

CREATE TABLE HR_LEAVE_REQUESTS (
    request_id            NUMBER          NOT NULL,
    emp_id                NUMBER          NOT NULL,
    leave_type_id         NUMBER          NOT NULL,
    start_date            DATE            NOT NULL,
    end_date              DATE            NOT NULL,
    days_requested        NUMBER          NOT NULL,
    reason                VARCHAR2(1000),
    status                VARCHAR2(20)    DEFAULT 'PENDING' NOT NULL,
    applied_date          DATE            DEFAULT SYSDATE,
    approval_level        NUMBER          DEFAULT 0,
    -- Multi-level approvers
    current_approver_id   NUMBER,
    l1_approver_id        NUMBER,
    l1_approved_date      DATE,
    l1_remarks            VARCHAR2(500),
    l2_approver_id        NUMBER,
    l2_approved_date      DATE,
    l2_remarks            VARCHAR2(500),
    l3_approver_id        NUMBER,
    l3_approved_date      DATE,
    l3_remarks            VARCHAR2(500),
    final_approver_id     NUMBER,
    final_approved_date   DATE,
    final_remarks         VARCHAR2(500),
    rejection_reason      VARCHAR2(1000),
    -- Audit columns
    created_date          DATE            DEFAULT SYSDATE NOT NULL,
    created_by            VARCHAR2(100)   NOT NULL,
    updated_date          DATE,
    updated_by            VARCHAR2(100),
    -- Constraints
    CONSTRAINT HR_LV_REQ_PK         PRIMARY KEY (request_id),
    CONSTRAINT HR_LV_REQ_EMP        FOREIGN KEY (emp_id)              REFERENCES HR_EMPLOYEES (emp_id),
    CONSTRAINT HR_LV_REQ_LV_TYP     FOREIGN KEY (leave_type_id)       REFERENCES HR_LEAVE_TYPES (leave_type_id),
    CONSTRAINT HR_LV_REQ_CUR_APPR   FOREIGN KEY (current_approver_id) REFERENCES HR_EMPLOYEES (emp_id),
    CONSTRAINT HR_LV_REQ_L1_APPR    FOREIGN KEY (l1_approver_id)      REFERENCES HR_EMPLOYEES (emp_id),
    CONSTRAINT HR_LV_REQ_L2_APPR    FOREIGN KEY (l2_approver_id)      REFERENCES HR_EMPLOYEES (emp_id),
    CONSTRAINT HR_LV_REQ_L3_APPR    FOREIGN KEY (l3_approver_id)      REFERENCES HR_EMPLOYEES (emp_id),
    CONSTRAINT HR_LV_REQ_FINAL_APPR FOREIGN KEY (final_approver_id)   REFERENCES HR_EMPLOYEES (emp_id),
    CONSTRAINT HR_LV_REQ_STATUS     CHECK (status IN (
        'PENDING','APPROVED_L1','APPROVED_L2','APPROVED_L3',
        'APPROVED','REJECTED','CANCELLED')),
    CONSTRAINT HR_LV_REQ_DATES      CHECK (end_date >= start_date),
    CONSTRAINT HR_LV_REQ_DAYS       CHECK (days_requested > 0)
);

-- ---------------------------------------------------------
-- 4.8 PERFORMANCE MANAGEMENT
-- ---------------------------------------------------------

CREATE TABLE HR_APPRAISAL_CYCLES (
    cycle_id        NUMBER          NOT NULL,
    company_id      NUMBER          NOT NULL,
    cycle_name      VARCHAR2(200)   NOT NULL,
    cycle_year      NUMBER(4)       NOT NULL,
    start_date      DATE            NOT NULL,
    end_date        DATE            NOT NULL,
    status          VARCHAR2(20)    DEFAULT 'OPEN' NOT NULL,
    -- Audit columns
    created_date    DATE            DEFAULT SYSDATE NOT NULL,
    created_by      VARCHAR2(100)   NOT NULL,
    updated_date    DATE,
    updated_by      VARCHAR2(100),
    -- Constraints
    CONSTRAINT HR_APPR_CYC_PK      PRIMARY KEY (cycle_id),
    CONSTRAINT HR_APPR_CYC_COMP    FOREIGN KEY (company_id) REFERENCES HR_COMPANIES (company_id),
    CONSTRAINT HR_APPR_CYC_STATUS  CHECK (status IN ('OPEN','IN_PROGRESS','COMPLETED','CANCELLED')),
    CONSTRAINT HR_APPR_CYC_DATES   CHECK (end_date > start_date)
);

CREATE TABLE HR_APPRAISALS (
    appraisal_id            NUMBER          NOT NULL,
    emp_id                  NUMBER          NOT NULL,
    cycle_id                NUMBER          NOT NULL,
    appraiser_id            NUMBER          NOT NULL,
    appraisal_type          VARCHAR2(20)    DEFAULT 'ANNUAL',
    self_rating             NUMBER(3,1),
    manager_rating          NUMBER(3,1),
    final_rating            NUMBER(3,1),
    status                  VARCHAR2(20)    DEFAULT 'DRAFT' NOT NULL,
    self_review_comments    VARCHAR2(4000),
    manager_comments        VARCHAR2(4000),
    hr_comments             VARCHAR2(2000),
    review_date             DATE,
    approval_date           DATE,
    -- Audit columns
    created_date            DATE            DEFAULT SYSDATE NOT NULL,
    created_by              VARCHAR2(100)   NOT NULL,
    updated_date            DATE,
    updated_by              VARCHAR2(100),
    -- Constraints
    CONSTRAINT HR_APPRAISALS_PK       PRIMARY KEY (appraisal_id),
    CONSTRAINT HR_APPRAISALS_UC       UNIQUE (emp_id, cycle_id),
    CONSTRAINT HR_APPRAISALS_EMP      FOREIGN KEY (emp_id)      REFERENCES HR_EMPLOYEES (emp_id),
    CONSTRAINT HR_APPRAISALS_CYCLE    FOREIGN KEY (cycle_id)    REFERENCES HR_APPRAISAL_CYCLES (cycle_id),
    CONSTRAINT HR_APPRAISALS_APPRASR  FOREIGN KEY (appraiser_id) REFERENCES HR_EMPLOYEES (emp_id),
    CONSTRAINT HR_APPRAISALS_STATUS   CHECK (status IN (
        'DRAFT','SELF_REVIEW','MANAGER_REVIEW','HR_REVIEW','APPROVED','REJECTED')),
    CONSTRAINT HR_APPRAISALS_SELF_RTG CHECK (self_rating    IS NULL OR (self_rating    BETWEEN 0 AND 5)),
    CONSTRAINT HR_APPRAISALS_MGR_RTG  CHECK (manager_rating IS NULL OR (manager_rating BETWEEN 0 AND 5)),
    CONSTRAINT HR_APPRAISALS_FIN_RTG  CHECK (final_rating   IS NULL OR (final_rating   BETWEEN 0 AND 5))
);

CREATE TABLE HR_GOALS (
    goal_id             NUMBER          NOT NULL,
    emp_id              NUMBER          NOT NULL,
    appraisal_id        NUMBER          NOT NULL,
    goal_title          VARCHAR2(500)   NOT NULL,
    goal_description    VARCHAR2(4000),
    target_date         DATE,
    weightage           NUMBER(5,2)     DEFAULT 0,
    achievement_pct     NUMBER(5,2)     DEFAULT 0,
    status              VARCHAR2(20)    DEFAULT 'ACTIVE',
    -- Audit columns
    created_date        DATE            DEFAULT SYSDATE NOT NULL,
    created_by          VARCHAR2(100)   NOT NULL,
    updated_date        DATE,
    updated_by          VARCHAR2(100),
    -- Constraints
    CONSTRAINT HR_GOALS_PK        PRIMARY KEY (goal_id),
    CONSTRAINT HR_GOALS_EMP       FOREIGN KEY (emp_id)        REFERENCES HR_EMPLOYEES (emp_id),
    CONSTRAINT HR_GOALS_APPRAISAL FOREIGN KEY (appraisal_id)  REFERENCES HR_APPRAISALS (appraisal_id),
    CONSTRAINT HR_GOALS_STATUS    CHECK (status IN ('ACTIVE','ACHIEVED','NOT_ACHIEVED','CANCELLED')),
    CONSTRAINT HR_GOALS_WEIGHTAGE CHECK (weightage BETWEEN 0 AND 100),
    CONSTRAINT HR_GOALS_ACH_PCT   CHECK (achievement_pct BETWEEN 0 AND 100)
);

-- ---------------------------------------------------------
-- 4.9 RECRUITMENT
-- ---------------------------------------------------------

CREATE TABLE HR_JOB_POSTINGS (
    posting_id              NUMBER          NOT NULL,
    company_id              NUMBER          NOT NULL,
    dept_id                 NUMBER          NOT NULL,
    position_id             NUMBER          NOT NULL,
    posting_title           VARCHAR2(300)   NOT NULL,
    posting_description     CLOB,
    requirements            CLOB,
    min_experience_years    NUMBER,
    max_experience_years    NUMBER,
    min_salary              NUMBER(15,2),
    max_salary              NUMBER(15,2),
    posting_date            DATE,
    closing_date            DATE,
    status                  VARCHAR2(20)    DEFAULT 'DRAFT' NOT NULL,
    no_of_positions         NUMBER          DEFAULT 1,
    created_by_emp_id       NUMBER,
    approved_by_emp_id      NUMBER,
    -- Audit columns
    created_date            DATE            DEFAULT SYSDATE NOT NULL,
    created_by              VARCHAR2(100)   NOT NULL,
    updated_date            DATE,
    updated_by              VARCHAR2(100),
    -- Constraints
    CONSTRAINT HR_JOB_POST_PK       PRIMARY KEY (posting_id),
    CONSTRAINT HR_JOB_POST_COMP     FOREIGN KEY (company_id)          REFERENCES HR_COMPANIES (company_id),
    CONSTRAINT HR_JOB_POST_DEPT     FOREIGN KEY (dept_id)             REFERENCES HR_DEPARTMENTS (dept_id),
    CONSTRAINT HR_JOB_POST_POS      FOREIGN KEY (position_id)         REFERENCES HR_POSITIONS (position_id),
    CONSTRAINT HR_JOB_POST_CRTR     FOREIGN KEY (created_by_emp_id)   REFERENCES HR_EMPLOYEES (emp_id),
    CONSTRAINT HR_JOB_POST_APPR     FOREIGN KEY (approved_by_emp_id)  REFERENCES HR_EMPLOYEES (emp_id),
    CONSTRAINT HR_JOB_POST_STATUS   CHECK (status IN ('DRAFT','OPEN','CLOSED','CANCELLED','FILLED')),
    CONSTRAINT HR_JOB_POST_SAL      CHECK (max_salary IS NULL OR min_salary IS NULL OR max_salary >= min_salary),
    CONSTRAINT HR_JOB_POST_EXP      CHECK (max_experience_years IS NULL OR min_experience_years IS NULL OR
                                           max_experience_years >= min_experience_years)
);

CREATE TABLE HR_CANDIDATES (
    candidate_id            NUMBER          NOT NULL,
    first_name              VARCHAR2(100)   NOT NULL,
    last_name               VARCHAR2(100)   NOT NULL,
    email                   VARCHAR2(200)   NOT NULL,
    phone                   VARCHAR2(20),
    resume_file             BLOB,
    resume_filename         VARCHAR2(300),
    current_company         VARCHAR2(300),
    current_designation     VARCHAR2(200),
    total_experience_years  NUMBER(5,1),
    expected_salary         NUMBER(15,2),
    source                  VARCHAR2(30),
    status                  VARCHAR2(20)    DEFAULT 'ACTIVE',
    -- Audit columns
    created_date            DATE            DEFAULT SYSDATE NOT NULL,
    created_by              VARCHAR2(100)   NOT NULL,
    updated_date            DATE,
    updated_by              VARCHAR2(100),
    -- Constraints
    CONSTRAINT HR_CANDIDATES_PK      PRIMARY KEY (candidate_id),
    CONSTRAINT HR_CANDIDATES_EMAIL   UNIQUE (email),
    CONSTRAINT HR_CANDIDATES_STATUS  CHECK (status IN ('ACTIVE','INACTIVE','BLACKLISTED')),
    CONSTRAINT HR_CANDIDATES_SRC     CHECK (source IN ('JOB_PORTAL','REFERRAL','AGENCY',
        'LINKEDIN','WALK_IN','CAMPUS','SOCIAL_MEDIA','OTHER') OR source IS NULL)
);

CREATE TABLE HR_APPLICATIONS (
    application_id      NUMBER          NOT NULL,
    posting_id          NUMBER          NOT NULL,
    candidate_id        NUMBER          NOT NULL,
    applied_date        DATE            DEFAULT SYSDATE NOT NULL,
    current_stage       VARCHAR2(30)    DEFAULT 'APPLIED' NOT NULL,
    interview_date      DATE,
    interview_notes     VARCHAR2(4000),
    interviewer_id      NUMBER,
    offer_salary        NUMBER(15,2),
    offer_date          DATE,
    offer_status        VARCHAR2(20),
    rejection_reason    VARCHAR2(1000),
    -- Audit columns
    created_date        DATE            DEFAULT SYSDATE NOT NULL,
    created_by          VARCHAR2(100)   NOT NULL,
    updated_date        DATE,
    updated_by          VARCHAR2(100),
    -- Constraints
    CONSTRAINT HR_APPLICATIONS_PK      PRIMARY KEY (application_id),
    CONSTRAINT HR_APPLICATIONS_UC      UNIQUE (posting_id, candidate_id),
    CONSTRAINT HR_APPLICATIONS_POST    FOREIGN KEY (posting_id)    REFERENCES HR_JOB_POSTINGS (posting_id),
    CONSTRAINT HR_APPLICATIONS_CAND    FOREIGN KEY (candidate_id)  REFERENCES HR_CANDIDATES (candidate_id),
    CONSTRAINT HR_APPLICATIONS_INTRVR  FOREIGN KEY (interviewer_id) REFERENCES HR_EMPLOYEES (emp_id),
    CONSTRAINT HR_APPLICATIONS_STAGE   CHECK (current_stage IN (
        'APPLIED','SCREENING','INTERVIEW_L1','INTERVIEW_L2',
        'TECHNICAL_TEST','OFFER','HIRED','REJECTED','WITHDRAWN')),
    CONSTRAINT HR_APPLICATIONS_OFFER   CHECK (offer_status IN ('PENDING','ACCEPTED','DECLINED') OR offer_status IS NULL)
);

-- ---------------------------------------------------------
-- 4.10 PAYROLL
-- ---------------------------------------------------------

CREATE TABLE HR_PAYROLL_PERIODS (
    period_id       NUMBER          NOT NULL,
    company_id      NUMBER          NOT NULL,
    period_name     VARCHAR2(100)   NOT NULL,
    period_month    NUMBER(2)       NOT NULL,
    period_year     NUMBER(4)       NOT NULL,
    start_date      DATE            NOT NULL,
    end_date        DATE            NOT NULL,
    status          VARCHAR2(20)    DEFAULT 'OPEN' NOT NULL,
    -- Audit columns
    created_date    DATE            DEFAULT SYSDATE NOT NULL,
    created_by      VARCHAR2(100)   NOT NULL,
    updated_date    DATE,
    updated_by      VARCHAR2(100),
    -- Constraints
    CONSTRAINT HR_PAY_PERIODS_PK      PRIMARY KEY (period_id),
    CONSTRAINT HR_PAY_PERIODS_UC      UNIQUE (company_id, period_month, period_year),
    CONSTRAINT HR_PAY_PERIODS_COMP    FOREIGN KEY (company_id) REFERENCES HR_COMPANIES (company_id),
    CONSTRAINT HR_PAY_PERIODS_STATUS  CHECK (status IN ('OPEN','PROCESSING','APPROVED','CLOSED','CANCELLED')),
    CONSTRAINT HR_PAY_PERIODS_MONTH   CHECK (period_month BETWEEN 1 AND 12),
    CONSTRAINT HR_PAY_PERIODS_DATES   CHECK (end_date >= start_date)
);

CREATE TABLE HR_PAYROLL_RUNS (
    run_id              NUMBER          NOT NULL,
    period_id           NUMBER          NOT NULL,
    run_date            DATE            DEFAULT SYSDATE NOT NULL,
    run_by_emp_id       NUMBER,
    approved_by_emp_id  NUMBER,
    approval_date       DATE,
    status              VARCHAR2(20)    DEFAULT 'DRAFT' NOT NULL,
    total_employees     NUMBER          DEFAULT 0,
    total_gross         NUMBER(18,2)    DEFAULT 0,
    total_deductions    NUMBER(18,2)    DEFAULT 0,
    total_net           NUMBER(18,2)    DEFAULT 0,
    payment_date        DATE,
    remarks             VARCHAR2(1000),
    -- Audit columns
    created_date        DATE            DEFAULT SYSDATE NOT NULL,
    created_by          VARCHAR2(100)   NOT NULL,
    updated_date        DATE,
    updated_by          VARCHAR2(100),
    -- Constraints
    CONSTRAINT HR_PAY_RUNS_PK       PRIMARY KEY (run_id),
    CONSTRAINT HR_PAY_RUNS_PERIOD   FOREIGN KEY (period_id)          REFERENCES HR_PAYROLL_PERIODS (period_id),
    CONSTRAINT HR_PAY_RUNS_BY       FOREIGN KEY (run_by_emp_id)      REFERENCES HR_EMPLOYEES (emp_id),
    CONSTRAINT HR_PAY_RUNS_APPR     FOREIGN KEY (approved_by_emp_id) REFERENCES HR_EMPLOYEES (emp_id),
    CONSTRAINT HR_PAY_RUNS_STATUS   CHECK (status IN (
        'DRAFT','PROCESSING','PENDING_APPROVAL','APPROVED','PAID','CANCELLED'))
);

CREATE TABLE HR_PAYSLIPS (
    payslip_id          NUMBER          NOT NULL,
    run_id              NUMBER          NOT NULL,
    emp_id              NUMBER          NOT NULL,
    period_id           NUMBER          NOT NULL,
    -- Earnings
    basic_salary        NUMBER(15,2)    NOT NULL,
    house_rent          NUMBER(15,2)    DEFAULT 0,
    medical_allowance   NUMBER(15,2)    DEFAULT 0,
    transport_allowance NUMBER(15,2)    DEFAULT 0,
    other_allowances    NUMBER(15,2)    DEFAULT 0,
    gross_salary        NUMBER(15,2)    NOT NULL,
    -- Deductions
    pf_employee         NUMBER(15,2)    DEFAULT 0,
    pf_employer         NUMBER(15,2)    DEFAULT 0,
    income_tax          NUMBER(15,2)    DEFAULT 0,
    other_deductions    NUMBER(15,2)    DEFAULT 0,
    total_deductions    NUMBER(15,2)    DEFAULT 0,
    net_salary          NUMBER(15,2)    NOT NULL,
    -- Tax info
    tax_year            NUMBER(4),
    status              VARCHAR2(20)    DEFAULT 'GENERATED' NOT NULL,
    payment_status      VARCHAR2(20),
    payment_date        DATE,
    bank_reference      VARCHAR2(100),
    -- Audit columns
    created_date        DATE            DEFAULT SYSDATE NOT NULL,
    created_by          VARCHAR2(100)   NOT NULL,
    updated_date        DATE,
    updated_by          VARCHAR2(100),
    -- Constraints
    CONSTRAINT HR_PAYSLIPS_PK         PRIMARY KEY (payslip_id),
    CONSTRAINT HR_PAYSLIPS_UC         UNIQUE (run_id, emp_id),
    CONSTRAINT HR_PAYSLIPS_RUN        FOREIGN KEY (run_id)    REFERENCES HR_PAYROLL_RUNS (run_id),
    CONSTRAINT HR_PAYSLIPS_EMP        FOREIGN KEY (emp_id)    REFERENCES HR_EMPLOYEES (emp_id),
    CONSTRAINT HR_PAYSLIPS_PERIOD     FOREIGN KEY (period_id) REFERENCES HR_PAYROLL_PERIODS (period_id),
    CONSTRAINT HR_PAYSLIPS_STATUS     CHECK (status IN ('GENERATED','APPROVED','PAID','CANCELLED')),
    CONSTRAINT HR_PAYSLIPS_PAY_STATUS CHECK (payment_status IN ('PENDING','PAID','FAILED','REVERSED') OR payment_status IS NULL)
);

-- Bangladesh NBR income tax brackets (annual income in BDT)
CREATE TABLE HR_TAX_BRACKETS (
    bracket_id      NUMBER          NOT NULL,
    company_id      NUMBER          NOT NULL,
    tax_year        NUMBER(4)       NOT NULL,
    min_income      NUMBER(18,2)    NOT NULL,
    max_income      NUMBER(18,2),
    tax_rate        NUMBER(5,2)     NOT NULL,
    surcharge_rate  NUMBER(5,2)     DEFAULT 0,
    is_active       CHAR(1)         DEFAULT 'Y' NOT NULL,
    -- Audit columns
    created_date    DATE            DEFAULT SYSDATE NOT NULL,
    created_by      VARCHAR2(100)   NOT NULL,
    updated_date    DATE,
    updated_by      VARCHAR2(100),
    -- Constraints
    CONSTRAINT HR_TAX_BRACKETS_PK    PRIMARY KEY (bracket_id),
    CONSTRAINT HR_TAX_BRACKETS_COMP  FOREIGN KEY (company_id) REFERENCES HR_COMPANIES (company_id),
    CONSTRAINT HR_TAX_BRACKETS_ACT   CHECK (is_active IN ('Y','N')),
    CONSTRAINT HR_TAX_BRACKETS_RATE  CHECK (tax_rate BETWEEN 0 AND 100),
    CONSTRAINT HR_TAX_BRACKETS_SURQ  CHECK (surcharge_rate BETWEEN 0 AND 100)
);

-- Provident Fund: 10% employee + 10% employer on basic (Bangladesh standard)
CREATE TABLE HR_PROVIDENT_FUND (
    pf_id                       NUMBER          NOT NULL,
    emp_id                      NUMBER          NOT NULL,
    period_id                   NUMBER          NOT NULL,
    basic_salary                NUMBER(15,2)    NOT NULL,
    employee_contribution_rate  NUMBER(5,2)     DEFAULT 10,
    employer_contribution_rate  NUMBER(5,2)     DEFAULT 10,
    employee_contribution       NUMBER(15,2)    NOT NULL,
    employer_contribution       NUMBER(15,2)    NOT NULL,
    total_contribution          NUMBER(15,2)    NOT NULL,
    cumulative_balance          NUMBER(18,2)    DEFAULT 0,
    -- Audit columns
    created_date                DATE            DEFAULT SYSDATE NOT NULL,
    created_by                  VARCHAR2(100)   NOT NULL,
    updated_date                DATE,
    updated_by                  VARCHAR2(100),
    -- Constraints
    CONSTRAINT HR_PF_PK      PRIMARY KEY (pf_id),
    CONSTRAINT HR_PF_UC      UNIQUE (emp_id, period_id),
    CONSTRAINT HR_PF_EMP     FOREIGN KEY (emp_id)    REFERENCES HR_EMPLOYEES (emp_id),
    CONSTRAINT HR_PF_PERIOD  FOREIGN KEY (period_id) REFERENCES HR_PAYROLL_PERIODS (period_id),
    CONSTRAINT HR_PF_EMP_RT  CHECK (employee_contribution_rate BETWEEN 0 AND 100),
    CONSTRAINT HR_PF_COMP_RT CHECK (employer_contribution_rate BETWEEN 0 AND 100)
);

-- ---------------------------------------------------------
-- 4.11 TRAINING & DEVELOPMENT
-- ---------------------------------------------------------

CREATE TABLE HR_TRAINING_PROGRAMS (
    program_id          NUMBER          NOT NULL,
    company_id          NUMBER          NOT NULL,
    program_code        VARCHAR2(30)    NOT NULL,
    program_name        VARCHAR2(300)   NOT NULL,
    program_type        VARCHAR2(20)    NOT NULL,
    description         VARCHAR2(4000),
    duration_hours      NUMBER          DEFAULT 0,
    max_participants    NUMBER,
    is_active           CHAR(1)         DEFAULT 'Y' NOT NULL,
    -- Audit columns
    created_date        DATE            DEFAULT SYSDATE NOT NULL,
    created_by          VARCHAR2(100)   NOT NULL,
    updated_date        DATE,
    updated_by          VARCHAR2(100),
    -- Constraints
    CONSTRAINT HR_TRN_PROG_PK    PRIMARY KEY (program_id),
    CONSTRAINT HR_TRN_PROG_UC    UNIQUE (company_id, program_code),
    CONSTRAINT HR_TRN_PROG_COMP  FOREIGN KEY (company_id) REFERENCES HR_COMPANIES (company_id),
    CONSTRAINT HR_TRN_PROG_TYPE  CHECK (program_type IN ('INTERNAL','EXTERNAL','ONLINE','CERTIFICATION')),
    CONSTRAINT HR_TRN_PROG_ACT   CHECK (is_active IN ('Y','N'))
);

CREATE TABLE HR_TRAINING_SESSIONS (
    session_id          NUMBER          NOT NULL,
    program_id          NUMBER          NOT NULL,
    session_name        VARCHAR2(300)   NOT NULL,
    start_date          DATE            NOT NULL,
    end_date            DATE            NOT NULL,
    venue               VARCHAR2(500),
    instructor_name     VARCHAR2(200),
    cost                NUMBER(15,2)    DEFAULT 0,
    max_participants    NUMBER,
    status              VARCHAR2(20)    DEFAULT 'PLANNED',
    -- Audit columns
    created_date        DATE            DEFAULT SYSDATE NOT NULL,
    created_by          VARCHAR2(100)   NOT NULL,
    updated_date        DATE,
    updated_by          VARCHAR2(100),
    -- Constraints
    CONSTRAINT HR_TRN_SESS_PK      PRIMARY KEY (session_id),
    CONSTRAINT HR_TRN_SESS_PROG    FOREIGN KEY (program_id) REFERENCES HR_TRAINING_PROGRAMS (program_id),
    CONSTRAINT HR_TRN_SESS_STATUS  CHECK (status IN ('PLANNED','IN_PROGRESS','COMPLETED','CANCELLED')),
    CONSTRAINT HR_TRN_SESS_DATES   CHECK (end_date >= start_date)
);

CREATE TABLE HR_TRAINING_ENROLLMENTS (
    enrollment_id           NUMBER          NOT NULL,
    session_id              NUMBER          NOT NULL,
    emp_id                  NUMBER          NOT NULL,
    enrollment_date         DATE            DEFAULT SYSDATE NOT NULL,
    completion_date         DATE,
    score                   NUMBER(5,2),
    status                  VARCHAR2(20)    DEFAULT 'ENROLLED' NOT NULL,
    certificate_no          VARCHAR2(100),
    certificate_expiry_date DATE,
    remarks                 VARCHAR2(1000),
    -- Audit columns
    created_date            DATE            DEFAULT SYSDATE NOT NULL,
    created_by              VARCHAR2(100)   NOT NULL,
    updated_date            DATE,
    updated_by              VARCHAR2(100),
    -- Constraints
    CONSTRAINT HR_TRN_ENRL_PK      PRIMARY KEY (enrollment_id),
    CONSTRAINT HR_TRN_ENRL_UC      UNIQUE (session_id, emp_id),
    CONSTRAINT HR_TRN_ENRL_SESS    FOREIGN KEY (session_id) REFERENCES HR_TRAINING_SESSIONS (session_id),
    CONSTRAINT HR_TRN_ENRL_EMP     FOREIGN KEY (emp_id)     REFERENCES HR_EMPLOYEES (emp_id),
    CONSTRAINT HR_TRN_ENRL_STATUS  CHECK (status IN (
        'ENROLLED','IN_PROGRESS','COMPLETED','FAILED','WITHDRAWN')),
    CONSTRAINT HR_TRN_ENRL_SCORE   CHECK (score IS NULL OR score BETWEEN 0 AND 100)
);

-- ---------------------------------------------------------
-- 4.12 DOCUMENTS & COMPLIANCE
-- ---------------------------------------------------------

CREATE TABLE HR_DOCUMENT_TYPES (
    doc_type_id         NUMBER          NOT NULL,
    company_id          NUMBER          NOT NULL,
    doc_type_code       VARCHAR2(30)    NOT NULL,
    doc_type_name       VARCHAR2(200)   NOT NULL,
    is_mandatory        CHAR(1)         DEFAULT 'N' NOT NULL,
    expiry_tracking     CHAR(1)         DEFAULT 'N' NOT NULL,
    advance_alert_days  NUMBER          DEFAULT 30,
    is_active           CHAR(1)         DEFAULT 'Y' NOT NULL,
    -- Audit columns
    created_date        DATE            DEFAULT SYSDATE NOT NULL,
    created_by          VARCHAR2(100)   NOT NULL,
    updated_date        DATE,
    updated_by          VARCHAR2(100),
    -- Constraints
    CONSTRAINT HR_DOC_TYPES_PK      PRIMARY KEY (doc_type_id),
    CONSTRAINT HR_DOC_TYPES_UC      UNIQUE (company_id, doc_type_code),
    CONSTRAINT HR_DOC_TYPES_COMP    FOREIGN KEY (company_id) REFERENCES HR_COMPANIES (company_id),
    CONSTRAINT HR_DOC_TYPES_MAND    CHECK (is_mandatory IN ('Y','N')),
    CONSTRAINT HR_DOC_TYPES_EXPIRY  CHECK (expiry_tracking IN ('Y','N')),
    CONSTRAINT HR_DOC_TYPES_ACT     CHECK (is_active IN ('Y','N'))
);

CREATE TABLE HR_EMPLOYEE_DOCUMENTS (
    doc_id              NUMBER          NOT NULL,
    emp_id              NUMBER          NOT NULL,
    doc_type_id         NUMBER          NOT NULL,
    document_title      VARCHAR2(300)   NOT NULL,
    document_no         VARCHAR2(100),
    issue_date          DATE,
    expiry_date         DATE,
    document_file       BLOB,
    document_filename   VARCHAR2(300),
    document_mime       VARCHAR2(100),
    status              VARCHAR2(20)    DEFAULT 'ACTIVE',
    -- Audit columns
    created_date        DATE            DEFAULT SYSDATE NOT NULL,
    created_by          VARCHAR2(100)   NOT NULL,
    updated_date        DATE,
    updated_by          VARCHAR2(100),
    -- Constraints
    CONSTRAINT HR_EMP_DOCS_PK       PRIMARY KEY (doc_id),
    CONSTRAINT HR_EMP_DOCS_EMP      FOREIGN KEY (emp_id)      REFERENCES HR_EMPLOYEES (emp_id),
    CONSTRAINT HR_EMP_DOCS_TYPE     FOREIGN KEY (doc_type_id) REFERENCES HR_DOCUMENT_TYPES (doc_type_id),
    CONSTRAINT HR_EMP_DOCS_STATUS   CHECK (status IN ('ACTIVE','EXPIRED','REVOKED','ARCHIVED'))
);

-- ---------------------------------------------------------
-- 4.13 EMPLOYMENT CONTRACTS
-- ---------------------------------------------------------

CREATE TABLE HR_CONTRACTS (
    contract_id             NUMBER          NOT NULL,
    emp_id                  NUMBER          NOT NULL,
    contract_type           VARCHAR2(30)    NOT NULL,
    start_date              DATE            NOT NULL,
    end_date                DATE,
    probation_period_months NUMBER          DEFAULT 6,
    notice_period_days      NUMBER          DEFAULT 60,
    salary                  NUMBER(15,2),
    renewal_count           NUMBER          DEFAULT 0,
    status                  VARCHAR2(20)    DEFAULT 'ACTIVE',
    signed_date             DATE,
    -- Audit columns
    created_date            DATE            DEFAULT SYSDATE NOT NULL,
    created_by              VARCHAR2(100)   NOT NULL,
    updated_date            DATE,
    updated_by              VARCHAR2(100),
    -- Constraints
    CONSTRAINT HR_CONTRACTS_PK        PRIMARY KEY (contract_id),
    CONSTRAINT HR_CONTRACTS_EMP       FOREIGN KEY (emp_id) REFERENCES HR_EMPLOYEES (emp_id),
    CONSTRAINT HR_CONTRACTS_TYPE      CHECK (contract_type IN (
        'PERMANENT','FIXED_TERM','PROBATION','INTERNSHIP')),
    CONSTRAINT HR_CONTRACTS_STATUS    CHECK (status IN (
        'ACTIVE','EXPIRED','TERMINATED','RENEWED','CANCELLED')),
    CONSTRAINT HR_CONTRACTS_DATES     CHECK (end_date IS NULL OR end_date > start_date),
    -- Bangladesh Labor Act: probation max 6 months
    CONSTRAINT HR_CONTRACTS_PROB_MAX  CHECK (probation_period_months IS NULL OR probation_period_months <= 6)
);

-- ---------------------------------------------------------
-- 4.14 NOTIFICATIONS
-- ---------------------------------------------------------

CREATE TABLE HR_NOTIFICATIONS (
    notification_id     NUMBER          NOT NULL,
    emp_id              NUMBER          NOT NULL,
    notification_type   VARCHAR2(50)    NOT NULL,
    title               VARCHAR2(500)   NOT NULL,
    message             CLOB,
    reference_id        NUMBER,
    reference_table     VARCHAR2(50),
    is_read             CHAR(1)         DEFAULT 'N' NOT NULL,
    read_date           DATE,
    sent_via            VARCHAR2(20)    DEFAULT 'IN_APP',
    created_date        DATE            DEFAULT SYSDATE NOT NULL,
    -- Constraints
    CONSTRAINT HR_NOTIF_PK        PRIMARY KEY (notification_id),
    CONSTRAINT HR_NOTIF_EMP       FOREIGN KEY (emp_id) REFERENCES HR_EMPLOYEES (emp_id),
    CONSTRAINT HR_NOTIF_IS_READ   CHECK (is_read IN ('Y','N')),
    CONSTRAINT HR_NOTIF_SENT_VIA  CHECK (sent_via IN ('IN_APP','EMAIL','BOTH'))
);

-- ---------------------------------------------------------
-- 4.15 AUDIT & CHANGE LOG
-- ---------------------------------------------------------

CREATE TABLE HR_AUDIT_LOG (
    log_id           NUMBER          NOT NULL,
    table_name       VARCHAR2(100)   NOT NULL,
    record_id        VARCHAR2(100)   NOT NULL,
    operation        VARCHAR2(10)    NOT NULL,
    old_values       CLOB,
    new_values       CLOB,
    changed_columns  CLOB,
    changed_by       VARCHAR2(100)   NOT NULL,
    changed_date     TIMESTAMP       DEFAULT SYSTIMESTAMP NOT NULL,
    ip_address       VARCHAR2(50),
    session_id       VARCHAR2(100),
    -- Constraints
    CONSTRAINT HR_AUDIT_LOG_PK   PRIMARY KEY (log_id),
    CONSTRAINT HR_AUDIT_LOG_OP   CHECK (operation IN ('INSERT','UPDATE','DELETE'))
);

-- ---------------------------------------------------------
-- 4.16 INTEGRATION LOGGING
-- ---------------------------------------------------------

CREATE TABLE HR_INTEGRATION_LOG (
    log_id              NUMBER          NOT NULL,
    integration_type    VARCHAR2(50)    NOT NULL,
    direction           VARCHAR2(10)    NOT NULL,
    status              VARCHAR2(20)    DEFAULT 'PENDING' NOT NULL,
    request_payload     CLOB,
    response_payload    CLOB,
    error_message       VARCHAR2(4000),
    retry_count         NUMBER          DEFAULT 0,
    max_retries         NUMBER          DEFAULT 3,
    created_date        TIMESTAMP       DEFAULT SYSTIMESTAMP NOT NULL,
    completed_date      TIMESTAMP,
    -- Constraints
    CONSTRAINT HR_INTG_LOG_PK     PRIMARY KEY (log_id),
    CONSTRAINT HR_INTG_LOG_TYPE   CHECK (integration_type IN ('PAYROLL_SYNC','BANKING','ATS')),
    CONSTRAINT HR_INTG_LOG_DIR    CHECK (direction IN ('INBOUND','OUTBOUND')),
    CONSTRAINT HR_INTG_LOG_STATUS CHECK (status IN ('SUCCESS','FAILED','PENDING','RETRY'))
);

-- ---------------------------------------------------------
-- 4.17 APP USERS / RBAC
-- ---------------------------------------------------------

CREATE TABLE HR_APP_USERS (
    user_id         NUMBER          NOT NULL,
    emp_id          NUMBER,
    username        VARCHAR2(50)    NOT NULL,
    email           VARCHAR2(200)   NOT NULL,
    role_code       VARCHAR2(30)    NOT NULL,
    is_active       CHAR(1)         DEFAULT 'Y' NOT NULL,
    last_login_date DATE,
    password_hash   VARCHAR2(500),
    -- Audit columns
    created_date    DATE            DEFAULT SYSDATE NOT NULL,
    created_by      VARCHAR2(100)   NOT NULL,
    updated_date    DATE,
    updated_by      VARCHAR2(100),
    -- Constraints
    CONSTRAINT HR_APP_USERS_PK       PRIMARY KEY (user_id),
    CONSTRAINT HR_APP_USERS_USR_UC   UNIQUE (username),
    CONSTRAINT HR_APP_USERS_EMAIL_UC UNIQUE (email),
    CONSTRAINT HR_APP_USERS_EMP      FOREIGN KEY (emp_id) REFERENCES HR_EMPLOYEES (emp_id),
    CONSTRAINT HR_APP_USERS_ROLE     CHECK (role_code IN (
        'HR_ADMIN','MANAGER','FINANCE_OFFICER','RECRUITER','EMPLOYEE')),
    CONSTRAINT HR_APP_USERS_ACT      CHECK (is_active IN ('Y','N'))
);

-- =========================================================
-- SECTION 5: INDEXES
-- =========================================================

-- HR_EMPLOYEES
CREATE INDEX HR_EMP_EMP_CODE_IDX        ON HR_EMPLOYEES (emp_code);
CREATE INDEX HR_EMP_EMAIL_IDX           ON HR_EMPLOYEES (email_official);
CREATE INDEX HR_EMP_DEPT_IDX            ON HR_EMPLOYEES (dept_id);
CREATE INDEX HR_EMP_POSITION_IDX        ON HR_EMPLOYEES (position_id);
CREATE INDEX HR_EMP_GRADE_IDX           ON HR_EMPLOYEES (grade_id);
CREATE INDEX HR_EMP_MANAGER_IDX         ON HR_EMPLOYEES (manager_id);
CREATE INDEX HR_EMP_STATUS_IDX          ON HR_EMPLOYEES (employment_status);
CREATE INDEX HR_EMP_COMPANY_IDX         ON HR_EMPLOYEES (company_id);
CREATE INDEX HR_EMP_HIRE_DATE_IDX       ON HR_EMPLOYEES (hire_date);
CREATE INDEX HR_EMP_NATIONAL_ID_IDX     ON HR_EMPLOYEES (national_id);

-- HR_LOOKUP_VALUES
CREATE INDEX HR_LV_TYPE_ID_IDX          ON HR_LOOKUP_VALUES (lookup_type_id);

-- HR_DEPARTMENTS
CREATE INDEX HR_DEPT_COMPANY_IDX        ON HR_DEPARTMENTS (company_id);
CREATE INDEX HR_DEPT_PARENT_IDX         ON HR_DEPARTMENTS (parent_dept_id);
CREATE INDEX HR_DEPT_HEAD_IDX           ON HR_DEPARTMENTS (dept_head_emp_id);

-- HR_POSITIONS
CREATE INDEX HR_POS_COMPANY_IDX         ON HR_POSITIONS (company_id);
CREATE INDEX HR_POS_DEPT_IDX            ON HR_POSITIONS (dept_id);

-- HR_GRADES
CREATE INDEX HR_GRADES_COMPANY_IDX      ON HR_GRADES (company_id);

-- HR_EMPLOYMENT_HISTORY
CREATE INDEX HR_EMP_HIST_EMP_IDX        ON HR_EMPLOYMENT_HISTORY (emp_id);
CREATE INDEX HR_EMP_HIST_EFF_DATE_IDX   ON HR_EMPLOYMENT_HISTORY (effective_date);
CREATE INDEX HR_EMP_HIST_EVENT_IDX      ON HR_EMPLOYMENT_HISTORY (event_type);

-- HR_EMPLOYEE_COMPENSATION
CREATE INDEX HR_EMP_COMP_EMP_IDX        ON HR_EMPLOYEE_COMPENSATION (emp_id);
CREATE INDEX HR_EMP_COMP_EFF_DATE_IDX   ON HR_EMPLOYEE_COMPENSATION (effective_date);

-- HR_EMPLOYEE_BENEFITS
CREATE INDEX HR_EMP_BEN_EMP_IDX         ON HR_EMPLOYEE_BENEFITS (emp_id);
CREATE INDEX HR_EMP_BEN_BEN_IDX         ON HR_EMPLOYEE_BENEFITS (benefit_id);

-- HR_ATTENDANCE (composite unique already exists; add date-only index for range queries)
CREATE INDEX HR_ATT_DATE_IDX            ON HR_ATTENDANCE (attendance_date);
CREATE INDEX HR_ATT_EMP_IDX             ON HR_ATTENDANCE (emp_id);
CREATE INDEX HR_ATT_STATUS_IDX          ON HR_ATTENDANCE (attendance_status);

-- HR_LEAVE_TYPES
CREATE INDEX HR_LV_TYPES_COMP_IDX       ON HR_LEAVE_TYPES (company_id);

-- HR_LEAVE_BALANCES
CREATE INDEX HR_LV_BAL_EMP_IDX          ON HR_LEAVE_BALANCES (emp_id);
CREATE INDEX HR_LV_BAL_YEAR_IDX         ON HR_LEAVE_BALANCES (fiscal_year);

-- HR_LEAVE_REQUESTS
CREATE INDEX HR_LV_REQ_EMP_IDX          ON HR_LEAVE_REQUESTS (emp_id);
CREATE INDEX HR_LV_REQ_STATUS_IDX       ON HR_LEAVE_REQUESTS (status);
CREATE INDEX HR_LV_REQ_START_DATE_IDX   ON HR_LEAVE_REQUESTS (start_date);
CREATE INDEX HR_LV_REQ_LV_TYPE_IDX      ON HR_LEAVE_REQUESTS (leave_type_id);

-- HR_APPRAISALS
CREATE INDEX HR_APPR_EMP_IDX            ON HR_APPRAISALS (emp_id);
CREATE INDEX HR_APPR_CYCLE_IDX          ON HR_APPRAISALS (cycle_id);

-- HR_GOALS
CREATE INDEX HR_GOALS_EMP_IDX           ON HR_GOALS (emp_id);
CREATE INDEX HR_GOALS_APPR_IDX          ON HR_GOALS (appraisal_id);

-- HR_JOB_POSTINGS
CREATE INDEX HR_JOB_POST_COMP_IDX       ON HR_JOB_POSTINGS (company_id);
CREATE INDEX HR_JOB_POST_STATUS_IDX     ON HR_JOB_POSTINGS (status);
CREATE INDEX HR_JOB_POST_CLOSE_IDX      ON HR_JOB_POSTINGS (closing_date);

-- HR_APPLICATIONS
CREATE INDEX HR_APPLIC_POST_IDX         ON HR_APPLICATIONS (posting_id);
CREATE INDEX HR_APPLIC_CAND_IDX         ON HR_APPLICATIONS (candidate_id);
CREATE INDEX HR_APPLIC_STAGE_IDX        ON HR_APPLICATIONS (current_stage);

-- HR_PAYROLL_PERIODS
CREATE INDEX HR_PAY_PER_COMP_IDX        ON HR_PAYROLL_PERIODS (company_id);
CREATE INDEX HR_PAY_PER_YEAR_IDX        ON HR_PAYROLL_PERIODS (period_year, period_month);

-- HR_PAYROLL_RUNS
CREATE INDEX HR_PAY_RUN_PERIOD_IDX      ON HR_PAYROLL_RUNS (period_id);
CREATE INDEX HR_PAY_RUN_STATUS_IDX      ON HR_PAYROLL_RUNS (status);

-- HR_PAYSLIPS
CREATE INDEX HR_PAYSLIPS_EMP_IDX        ON HR_PAYSLIPS (emp_id);
CREATE INDEX HR_PAYSLIPS_RUN_IDX        ON HR_PAYSLIPS (run_id);
CREATE INDEX HR_PAYSLIPS_PERIOD_IDX     ON HR_PAYSLIPS (period_id);
CREATE INDEX HR_PAYSLIPS_STATUS_IDX     ON HR_PAYSLIPS (status);

-- HR_TAX_BRACKETS
CREATE INDEX HR_TAX_BRKT_COMP_YEAR_IDX  ON HR_TAX_BRACKETS (company_id, tax_year);

-- HR_PROVIDENT_FUND
CREATE INDEX HR_PF_EMP_IDX              ON HR_PROVIDENT_FUND (emp_id);
CREATE INDEX HR_PF_PERIOD_IDX           ON HR_PROVIDENT_FUND (period_id);

-- HR_TRAINING_SESSIONS
CREATE INDEX HR_TRN_SESS_PROG_IDX       ON HR_TRAINING_SESSIONS (program_id);
CREATE INDEX HR_TRN_SESS_DATE_IDX       ON HR_TRAINING_SESSIONS (start_date);

-- HR_TRAINING_ENROLLMENTS
CREATE INDEX HR_TRN_ENRL_SESS_IDX       ON HR_TRAINING_ENROLLMENTS (session_id);
CREATE INDEX HR_TRN_ENRL_EMP_IDX        ON HR_TRAINING_ENROLLMENTS (emp_id);

-- HR_EMPLOYEE_DOCUMENTS
CREATE INDEX HR_EMP_DOCS_EMP_IDX        ON HR_EMPLOYEE_DOCUMENTS (emp_id);
CREATE INDEX HR_EMP_DOCS_EXPIRY_IDX     ON HR_EMPLOYEE_DOCUMENTS (expiry_date);

-- HR_CONTRACTS
CREATE INDEX HR_CONTRACTS_EMP_IDX       ON HR_CONTRACTS (emp_id);
CREATE INDEX HR_CONTRACTS_STATUS_IDX    ON HR_CONTRACTS (status);

-- HR_NOTIFICATIONS
CREATE INDEX HR_NOTIF_EMP_IDX           ON HR_NOTIFICATIONS (emp_id);
CREATE INDEX HR_NOTIF_IS_READ_IDX       ON HR_NOTIFICATIONS (is_read);
CREATE INDEX HR_NOTIF_CREATED_IDX       ON HR_NOTIFICATIONS (created_date);

-- HR_AUDIT_LOG (high-volume: use compressed/function-based indexes)
CREATE INDEX HR_AUDIT_TABLE_REC_IDX     ON HR_AUDIT_LOG (table_name, record_id);
CREATE INDEX HR_AUDIT_CHANGED_DATE_IDX  ON HR_AUDIT_LOG (changed_date);
CREATE INDEX HR_AUDIT_CHANGED_BY_IDX    ON HR_AUDIT_LOG (changed_by);
CREATE INDEX HR_AUDIT_OPERATION_IDX     ON HR_AUDIT_LOG (operation);

-- HR_INTEGRATION_LOG
CREATE INDEX HR_INTG_TYPE_IDX           ON HR_INTEGRATION_LOG (integration_type);
CREATE INDEX HR_INTG_STATUS_IDX         ON HR_INTEGRATION_LOG (status);
CREATE INDEX HR_INTG_CREATED_IDX        ON HR_INTEGRATION_LOG (created_date);

-- HR_APP_USERS
CREATE INDEX HR_APP_USERS_EMP_IDX       ON HR_APP_USERS (emp_id);
CREATE INDEX HR_APP_USERS_ROLE_IDX      ON HR_APP_USERS (role_code);

-- =========================================================
-- SECTION 6: AUDIT TRIGGERS
-- =========================================================

-- Helper: Build a simple JSON-like key=value string from named columns
-- Each trigger captures changed rows and logs them to HR_AUDIT_LOG.

-- 6.1 HR_EMPLOYEES audit trigger
CREATE OR REPLACE TRIGGER HR_EMPLOYEES_AUDIT_TRG
    AFTER UPDATE OR DELETE ON HR_EMPLOYEES
    FOR EACH ROW
DECLARE
    v_operation   VARCHAR2(10);
    v_old_vals    CLOB;
    v_new_vals    CLOB;
    v_changed_col CLOB;
BEGIN
    IF DELETING THEN
        v_operation := 'DELETE';
    ELSE
        v_operation := 'UPDATE';
    END IF;

    -- Capture old values as JSON-style text
    v_old_vals :=
        '{"emp_id":' || :OLD.emp_id ||
        ',"emp_code":"' || :OLD.emp_code || '"' ||
        ',"full_name":"' || :OLD.first_name || ' ' || :OLD.last_name || '"' ||
        ',"employment_status":"' || :OLD.employment_status || '"' ||
        ',"employment_type":"' || :OLD.employment_type || '"' ||
        ',"dept_id":' || NVL(TO_CHAR(:OLD.dept_id), 'null') ||
        ',"position_id":' || NVL(TO_CHAR(:OLD.position_id), 'null') ||
        ',"grade_id":' || NVL(TO_CHAR(:OLD.grade_id), 'null') ||
        ',"manager_id":' || NVL(TO_CHAR(:OLD.manager_id), 'null') ||
        ',"termination_date":"' || NVL(TO_CHAR(:OLD.termination_date,'YYYY-MM-DD'), '') || '"' ||
        '}';

    IF NOT DELETING THEN
        v_new_vals :=
            '{"emp_id":' || :NEW.emp_id ||
            ',"emp_code":"' || :NEW.emp_code || '"' ||
            ',"full_name":"' || :NEW.first_name || ' ' || :NEW.last_name || '"' ||
            ',"employment_status":"' || :NEW.employment_status || '"' ||
            ',"employment_type":"' || :NEW.employment_type || '"' ||
            ',"dept_id":' || NVL(TO_CHAR(:NEW.dept_id), 'null') ||
            ',"position_id":' || NVL(TO_CHAR(:NEW.position_id), 'null') ||
            ',"grade_id":' || NVL(TO_CHAR(:NEW.grade_id), 'null') ||
            ',"manager_id":' || NVL(TO_CHAR(:NEW.manager_id), 'null') ||
            ',"termination_date":"' || NVL(TO_CHAR(:NEW.termination_date,'YYYY-MM-DD'), '') || '"' ||
            '}';

        -- Track which key columns changed
        v_changed_col := '';
        IF NVL(:OLD.employment_status,'X') != NVL(:NEW.employment_status,'X') THEN v_changed_col := v_changed_col || 'employment_status,'; END IF;
        IF NVL(:OLD.employment_type,'X')  != NVL(:NEW.employment_type,'X')  THEN v_changed_col := v_changed_col || 'employment_type,';  END IF;
        IF NVL(TO_CHAR(:OLD.dept_id),'-') != NVL(TO_CHAR(:NEW.dept_id),'-') THEN v_changed_col := v_changed_col || 'dept_id,';          END IF;
        IF NVL(TO_CHAR(:OLD.position_id),'-') != NVL(TO_CHAR(:NEW.position_id),'-') THEN v_changed_col := v_changed_col || 'position_id,'; END IF;
        IF NVL(TO_CHAR(:OLD.grade_id),'-') != NVL(TO_CHAR(:NEW.grade_id),'-') THEN v_changed_col := v_changed_col || 'grade_id,';      END IF;
        IF NVL(TO_CHAR(:OLD.manager_id),'-') != NVL(TO_CHAR(:NEW.manager_id),'-') THEN v_changed_col := v_changed_col || 'manager_id,'; END IF;
    END IF;

    INSERT INTO HR_AUDIT_LOG (
        log_id, table_name, record_id, operation,
        old_values, new_values, changed_columns,
        changed_by, changed_date
    ) VALUES (
        HR_AUDIT_LOG_SEQ.NEXTVAL,
        'HR_EMPLOYEES',
        TO_CHAR(:OLD.emp_id),
        v_operation,
        v_old_vals,
        v_new_vals,
        v_changed_col,
        NVL(SYS_CONTEXT('APEX$SESSION','APP_USER'), SYS_CONTEXT('USERENV','SESSION_USER')),
        SYSTIMESTAMP
    );
EXCEPTION
    WHEN OTHERS THEN NULL; -- Audit failures must never block business operations
END HR_EMPLOYEES_AUDIT_TRG;
/

-- 6.2 HR_EMPLOYEE_COMPENSATION audit trigger
CREATE OR REPLACE TRIGGER HR_EMP_COMP_AUDIT_TRG
    AFTER UPDATE OR DELETE ON HR_EMPLOYEE_COMPENSATION
    FOR EACH ROW
DECLARE
    v_operation VARCHAR2(10);
    v_old_vals  CLOB;
    v_new_vals  CLOB;
BEGIN
    v_operation := CASE WHEN DELETING THEN 'DELETE' ELSE 'UPDATE' END;

    v_old_vals :=
        '{"comp_id":' || :OLD.comp_id ||
        ',"emp_id":' || :OLD.emp_id ||
        ',"effective_date":"' || TO_CHAR(:OLD.effective_date,'YYYY-MM-DD') || '"' ||
        ',"basic_salary":' || :OLD.basic_salary ||
        ',"gross_salary":' || NVL(TO_CHAR(:OLD.gross_salary),'null') ||
        ',"is_active":"' || :OLD.is_active || '"' ||
        '}';

    IF NOT DELETING THEN
        v_new_vals :=
            '{"comp_id":' || :NEW.comp_id ||
            ',"emp_id":' || :NEW.emp_id ||
            ',"effective_date":"' || TO_CHAR(:NEW.effective_date,'YYYY-MM-DD') || '"' ||
            ',"basic_salary":' || :NEW.basic_salary ||
            ',"gross_salary":' || NVL(TO_CHAR(:NEW.gross_salary),'null') ||
            ',"is_active":"' || :NEW.is_active || '"' ||
            '}';
    END IF;

    INSERT INTO HR_AUDIT_LOG (
        log_id, table_name, record_id, operation,
        old_values, new_values, changed_columns,
        changed_by, changed_date
    ) VALUES (
        HR_AUDIT_LOG_SEQ.NEXTVAL,
        'HR_EMPLOYEE_COMPENSATION',
        TO_CHAR(:OLD.comp_id),
        v_operation,
        v_old_vals,
        v_new_vals,
        NULL,
        NVL(SYS_CONTEXT('APEX$SESSION','APP_USER'), SYS_CONTEXT('USERENV','SESSION_USER')),
        SYSTIMESTAMP
    );
EXCEPTION
    WHEN OTHERS THEN NULL;
END HR_EMP_COMP_AUDIT_TRG;
/

-- 6.3 HR_LEAVE_REQUESTS audit trigger
CREATE OR REPLACE TRIGGER HR_LEAVE_REQ_AUDIT_TRG
    AFTER UPDATE OR DELETE ON HR_LEAVE_REQUESTS
    FOR EACH ROW
DECLARE
    v_operation   VARCHAR2(10);
    v_old_vals    CLOB;
    v_new_vals    CLOB;
    v_changed_col CLOB;
BEGIN
    v_operation := CASE WHEN DELETING THEN 'DELETE' ELSE 'UPDATE' END;

    v_old_vals :=
        '{"request_id":' || :OLD.request_id ||
        ',"emp_id":' || :OLD.emp_id ||
        ',"status":"' || :OLD.status || '"' ||
        ',"start_date":"' || TO_CHAR(:OLD.start_date,'YYYY-MM-DD') || '"' ||
        ',"end_date":"' || TO_CHAR(:OLD.end_date,'YYYY-MM-DD') || '"' ||
        ',"days_requested":' || :OLD.days_requested ||
        '}';

    IF NOT DELETING THEN
        v_new_vals :=
            '{"request_id":' || :NEW.request_id ||
            ',"emp_id":' || :NEW.emp_id ||
            ',"status":"' || :NEW.status || '"' ||
            ',"start_date":"' || TO_CHAR(:NEW.start_date,'YYYY-MM-DD') || '"' ||
            ',"end_date":"' || TO_CHAR(:NEW.end_date,'YYYY-MM-DD') || '"' ||
            ',"days_requested":' || :NEW.days_requested ||
            '}';

        IF NVL(:OLD.status,'X') != NVL(:NEW.status,'X') THEN
            v_changed_col := 'status,';
        END IF;
    END IF;

    INSERT INTO HR_AUDIT_LOG (
        log_id, table_name, record_id, operation,
        old_values, new_values, changed_columns,
        changed_by, changed_date
    ) VALUES (
        HR_AUDIT_LOG_SEQ.NEXTVAL,
        'HR_LEAVE_REQUESTS',
        TO_CHAR(:OLD.request_id),
        v_operation,
        v_old_vals,
        v_new_vals,
        v_changed_col,
        NVL(SYS_CONTEXT('APEX$SESSION','APP_USER'), SYS_CONTEXT('USERENV','SESSION_USER')),
        SYSTIMESTAMP
    );
EXCEPTION
    WHEN OTHERS THEN NULL;
END HR_LEAVE_REQ_AUDIT_TRG;
/

-- 6.4 HR_PAYSLIPS audit trigger
CREATE OR REPLACE TRIGGER HR_PAYSLIPS_AUDIT_TRG
    AFTER UPDATE OR DELETE ON HR_PAYSLIPS
    FOR EACH ROW
DECLARE
    v_operation VARCHAR2(10);
    v_old_vals  CLOB;
    v_new_vals  CLOB;
BEGIN
    v_operation := CASE WHEN DELETING THEN 'DELETE' ELSE 'UPDATE' END;

    v_old_vals :=
        '{"payslip_id":' || :OLD.payslip_id ||
        ',"emp_id":' || :OLD.emp_id ||
        ',"run_id":' || :OLD.run_id ||
        ',"gross_salary":' || :OLD.gross_salary ||
        ',"net_salary":' || :OLD.net_salary ||
        ',"status":"' || :OLD.status || '"' ||
        ',"payment_status":"' || NVL(:OLD.payment_status,'') || '"' ||
        '}';

    IF NOT DELETING THEN
        v_new_vals :=
            '{"payslip_id":' || :NEW.payslip_id ||
            ',"emp_id":' || :NEW.emp_id ||
            ',"run_id":' || :NEW.run_id ||
            ',"gross_salary":' || :NEW.gross_salary ||
            ',"net_salary":' || :NEW.net_salary ||
            ',"status":"' || :NEW.status || '"' ||
            ',"payment_status":"' || NVL(:NEW.payment_status,'') || '"' ||
            '}';
    END IF;

    INSERT INTO HR_AUDIT_LOG (
        log_id, table_name, record_id, operation,
        old_values, new_values, changed_columns,
        changed_by, changed_date
    ) VALUES (
        HR_AUDIT_LOG_SEQ.NEXTVAL,
        'HR_PAYSLIPS',
        TO_CHAR(:OLD.payslip_id),
        v_operation,
        v_old_vals,
        v_new_vals,
        NULL,
        NVL(SYS_CONTEXT('APEX$SESSION','APP_USER'), SYS_CONTEXT('USERENV','SESSION_USER')),
        SYSTIMESTAMP
    );
EXCEPTION
    WHEN OTHERS THEN NULL;
END HR_PAYSLIPS_AUDIT_TRG;
/

-- 6.5 HR_CONTRACTS audit trigger
CREATE OR REPLACE TRIGGER HR_CONTRACTS_AUDIT_TRG
    AFTER UPDATE OR DELETE ON HR_CONTRACTS
    FOR EACH ROW
DECLARE
    v_operation   VARCHAR2(10);
    v_old_vals    CLOB;
    v_new_vals    CLOB;
    v_changed_col CLOB;
BEGIN
    v_operation := CASE WHEN DELETING THEN 'DELETE' ELSE 'UPDATE' END;

    v_old_vals :=
        '{"contract_id":' || :OLD.contract_id ||
        ',"emp_id":' || :OLD.emp_id ||
        ',"contract_type":"' || :OLD.contract_type || '"' ||
        ',"status":"' || :OLD.status || '"' ||
        ',"salary":' || NVL(TO_CHAR(:OLD.salary),'null') ||
        ',"start_date":"' || TO_CHAR(:OLD.start_date,'YYYY-MM-DD') || '"' ||
        ',"end_date":"' || NVL(TO_CHAR(:OLD.end_date,'YYYY-MM-DD'),'') || '"' ||
        '}';

    IF NOT DELETING THEN
        v_new_vals :=
            '{"contract_id":' || :NEW.contract_id ||
            ',"emp_id":' || :NEW.emp_id ||
            ',"contract_type":"' || :NEW.contract_type || '"' ||
            ',"status":"' || :NEW.status || '"' ||
            ',"salary":' || NVL(TO_CHAR(:NEW.salary),'null') ||
            ',"start_date":"' || TO_CHAR(:NEW.start_date,'YYYY-MM-DD') || '"' ||
            ',"end_date":"' || NVL(TO_CHAR(:NEW.end_date,'YYYY-MM-DD'),'') || '"' ||
            '}';

        IF NVL(:OLD.status,'X')        != NVL(:NEW.status,'X')        THEN v_changed_col := v_changed_col || 'status,'; END IF;
        IF NVL(TO_CHAR(:OLD.salary),'-') != NVL(TO_CHAR(:NEW.salary),'-') THEN v_changed_col := v_changed_col || 'salary,'; END IF;
    END IF;

    INSERT INTO HR_AUDIT_LOG (
        log_id, table_name, record_id, operation,
        old_values, new_values, changed_columns,
        changed_by, changed_date
    ) VALUES (
        HR_AUDIT_LOG_SEQ.NEXTVAL,
        'HR_CONTRACTS',
        TO_CHAR(:OLD.contract_id),
        v_operation,
        v_old_vals,
        v_new_vals,
        v_changed_col,
        NVL(SYS_CONTEXT('APEX$SESSION','APP_USER'), SYS_CONTEXT('USERENV','SESSION_USER')),
        SYSTIMESTAMP
    );
EXCEPTION
    WHEN OTHERS THEN NULL;
END HR_CONTRACTS_AUDIT_TRG;
/

-- =========================================================
-- SECTION 7: TABLE AND COLUMN COMMENTS
-- =========================================================

-- HR_LOOKUP_TYPES
COMMENT ON TABLE  HR_LOOKUP_TYPES                       IS 'Master list of lookup/reference categories used across the HR application.';
COMMENT ON COLUMN HR_LOOKUP_TYPES.lookup_type_id        IS 'Surrogate primary key.';
COMMENT ON COLUMN HR_LOOKUP_TYPES.lookup_type_code      IS 'Unique code used by application logic (e.g. GENDER, BLOOD_GROUP, RELIGION).';
COMMENT ON COLUMN HR_LOOKUP_TYPES.lookup_type_name      IS 'Human-readable name for the lookup category.';
COMMENT ON COLUMN HR_LOOKUP_TYPES.is_active             IS 'Y = active; N = inactive.';

-- HR_LOOKUP_VALUES
COMMENT ON TABLE  HR_LOOKUP_VALUES                      IS 'Individual values belonging to a lookup type; used to populate dropdowns in APEX.';
COMMENT ON COLUMN HR_LOOKUP_VALUES.lookup_code          IS 'Short code stored in transactional tables (e.g. M, F, O for gender).';
COMMENT ON COLUMN HR_LOOKUP_VALUES.lookup_value         IS 'Display label shown to end users.';
COMMENT ON COLUMN HR_LOOKUP_VALUES.display_order        IS 'Controls sort order in UI dropdowns.';
COMMENT ON COLUMN HR_LOOKUP_VALUES.attribute1           IS 'Flexible attribute 1 for extended metadata.';

-- HR_COMPANIES
COMMENT ON TABLE  HR_COMPANIES                          IS 'Top-level company/legal entity. Supports multi-company deployment.';
COMMENT ON COLUMN HR_COMPANIES.company_code             IS 'Short alphanumeric code uniquely identifying the company.';
COMMENT ON COLUMN HR_COMPANIES.currency_code            IS 'ISO 4217 currency code; defaults to BDT (Bangladeshi Taka).';
COMMENT ON COLUMN HR_COMPANIES.fiscal_year_start        IS 'Start date of the financial year (e.g. 01-JUL for Bangladesh NBR).';

-- HR_DEPARTMENTS
COMMENT ON TABLE  HR_DEPARTMENTS                        IS 'Organizational departments supporting hierarchical structure via parent_dept_id.';
COMMENT ON COLUMN HR_DEPARTMENTS.parent_dept_id         IS 'Self-referencing FK enabling tree-structured org chart.';
COMMENT ON COLUMN HR_DEPARTMENTS.dept_head_emp_id       IS 'FK to HR_EMPLOYEES (deferred); the head of this department.';
COMMENT ON COLUMN HR_DEPARTMENTS.cost_center            IS 'Cost center code for financial allocation.';

-- HR_POSITIONS
COMMENT ON TABLE  HR_POSITIONS                          IS 'Defined roles/positions within a department, with salary bands.';
COMMENT ON COLUMN HR_POSITIONS.position_level           IS 'Numeric level (e.g. 1=Junior, 5=Senior, 10=Director) for hierarchy ordering.';
COMMENT ON COLUMN HR_POSITIONS.min_salary               IS 'Minimum salary band for this position (BDT).';
COMMENT ON COLUMN HR_POSITIONS.max_salary               IS 'Maximum salary band for this position (BDT).';

-- HR_GRADES
COMMENT ON TABLE  HR_GRADES                             IS 'Pay grades used to standardize compensation across positions.';

-- HR_EMPLOYEES
COMMENT ON TABLE  HR_EMPLOYEES                          IS 'Core employee master table. Supports 50,000+ employees for Bangladesh companies.';
COMMENT ON COLUMN HR_EMPLOYEES.emp_code                 IS 'Human-readable employee code (e.g. BD-001234). Must be unique per company.';
COMMENT ON COLUMN HR_EMPLOYEES.full_name                IS 'Virtual computed column: first_name || '' '' || last_name.';
COMMENT ON COLUMN HR_EMPLOYEES.national_id              IS 'National ID card number (NID) — 10 or 17 digit Bangladesh NID.';
COMMENT ON COLUMN HR_EMPLOYEES.tin_number               IS 'Bangladesh Tax Identification Number (TIN) issued by NBR.';
COMMENT ON COLUMN HR_EMPLOYEES.provident_fund_eligible  IS 'Y = employee is enrolled in company Provident Fund scheme.';
COMMENT ON COLUMN HR_EMPLOYEES.gratuity_eligible        IS 'Y = employee is eligible for gratuity (typically after 5 years per BD Labor Act).';
COMMENT ON COLUMN HR_EMPLOYEES.notice_period_days       IS 'Contractual notice period in days. Default 60 per Bangladesh Labor Act 2006.';
COMMENT ON COLUMN HR_EMPLOYEES.probation_end_date       IS 'End date of probation period. Max 6 months per Bangladesh Labor Act 2006.';
COMMENT ON COLUMN HR_EMPLOYEES.work_arrangement         IS 'REMOTE | HYBRID | OFFICE.';

-- HR_EMPLOYMENT_HISTORY
COMMENT ON TABLE  HR_EMPLOYMENT_HISTORY                 IS 'Immutable log of all career events: hire, promotion, transfer, termination, etc.';
COMMENT ON COLUMN HR_EMPLOYMENT_HISTORY.event_type      IS 'Type of career event. Drives what old/new fields are populated.';
COMMENT ON COLUMN HR_EMPLOYMENT_HISTORY.effective_date  IS 'Date the change took effect (not the date it was recorded).';

-- HR_SALARY_COMPONENTS
COMMENT ON TABLE  HR_SALARY_COMPONENTS                  IS 'Configurable salary component catalogue (earnings, deductions, statutory).';
COMMENT ON COLUMN HR_SALARY_COMPONENTS.is_taxable       IS 'Y = component is included in taxable income computation.';
COMMENT ON COLUMN HR_SALARY_COMPONENTS.calculation_method IS 'FLAT = fixed amount; PERCENTAGE = % of basic salary.';

-- HR_EMPLOYEE_COMPENSATION
COMMENT ON TABLE  HR_EMPLOYEE_COMPENSATION              IS 'Point-in-time compensation record. Effective-dated; new row per salary revision.';
COMMENT ON COLUMN HR_EMPLOYEE_COMPENSATION.gross_salary IS 'Sum of basic + all allowances. Can be system-calculated or manually overridden.';

-- HR_LEAVE_TYPES
COMMENT ON TABLE  HR_LEAVE_TYPES                        IS 'Defines leave policies. Pre-seeded with Bangladesh standard leave types.';
COMMENT ON COLUMN HR_LEAVE_TYPES.leave_category         IS 'CASUAL(10d) | EARNED(~14d) | SICK(14d) | MATERNITY(112d) per BD Labor Act 2006.';
COMMENT ON COLUMN HR_LEAVE_TYPES.max_carry_forward      IS 'Maximum unused days that can be carried to next fiscal year. 0 = no carry forward.';
COMMENT ON COLUMN HR_LEAVE_TYPES.accrual_method         IS 'ANNUAL = credited once/year; MONTHLY = 1/12 per month; DAILY = 1/365 per day.';

-- HR_LEAVE_BALANCES
COMMENT ON TABLE  HR_LEAVE_BALANCES                     IS 'Per-employee, per-leave-type, per-fiscal-year balance tracker.';
COMMENT ON COLUMN HR_LEAVE_BALANCES.closing_balance     IS 'Virtual column: opening_balance + accrued - taken - pending.';
COMMENT ON COLUMN HR_LEAVE_BALANCES.pending             IS 'Days in PENDING or APPROVED_Ln state not yet deducted from balance.';

-- HR_LEAVE_REQUESTS
COMMENT ON TABLE  HR_LEAVE_REQUESTS                     IS 'Employee leave applications with up to 3-level approval workflow.';
COMMENT ON COLUMN HR_LEAVE_REQUESTS.approval_level      IS 'Current approval level reached: 0=not started, 1=L1 done, etc.';

-- HR_APPRAISAL_CYCLES
COMMENT ON TABLE  HR_APPRAISAL_CYCLES                   IS 'Annual or mid-year appraisal cycles defined per company.';

-- HR_APPRAISALS
COMMENT ON TABLE  HR_APPRAISALS                         IS 'Individual employee appraisal records tied to a cycle.';
COMMENT ON COLUMN HR_APPRAISALS.self_rating             IS 'Rating given by employee in self-review (0.0–5.0 scale).';
COMMENT ON COLUMN HR_APPRAISALS.manager_rating          IS 'Rating given by direct manager (0.0–5.0 scale).';
COMMENT ON COLUMN HR_APPRAISALS.final_rating            IS 'Finalized rating after HR calibration (0.0–5.0 scale).';

-- HR_GOALS
COMMENT ON TABLE  HR_GOALS                              IS 'Individual performance goals linked to an appraisal; supports weightage-based scoring.';

-- HR_JOB_POSTINGS
COMMENT ON TABLE  HR_JOB_POSTINGS                       IS 'Job vacancies published internally or externally.';

-- HR_CANDIDATES
COMMENT ON TABLE  HR_CANDIDATES                         IS 'External candidate profiles. Resume stored as BLOB.';

-- HR_APPLICATIONS
COMMENT ON TABLE  HR_APPLICATIONS                       IS 'Applications by candidates to specific job postings; tracks interview pipeline.';

-- HR_PAYROLL_PERIODS
COMMENT ON TABLE  HR_PAYROLL_PERIODS                    IS 'Monthly payroll periods per company. One period per company per month.';

-- HR_PAYROLL_RUNS
COMMENT ON TABLE  HR_PAYROLL_RUNS                       IS 'Payroll processing run tied to a period; tracks totals and approval status.';

-- HR_PAYSLIPS
COMMENT ON TABLE  HR_PAYSLIPS                           IS 'Individual employee payslips generated for a payroll run.';
COMMENT ON COLUMN HR_PAYSLIPS.pf_employee               IS 'Employee provident fund contribution (10% of basic per BD standard).';
COMMENT ON COLUMN HR_PAYSLIPS.pf_employer               IS 'Employer provident fund contribution (10% of basic per BD standard).';
COMMENT ON COLUMN HR_PAYSLIPS.income_tax                IS 'Monthly income tax deducted per NBR Bangladesh progressive tax slabs.';

-- HR_TAX_BRACKETS
COMMENT ON TABLE  HR_TAX_BRACKETS                       IS 'NBR Bangladesh income tax slabs. Rates: 0%-5%-10%-15%-20%-25% on annual income.';
COMMENT ON COLUMN HR_TAX_BRACKETS.max_income            IS 'NULL for the top slab (no upper limit).';
COMMENT ON COLUMN HR_TAX_BRACKETS.surcharge_rate        IS 'Net wealth surcharge rate applicable per NBR rules.';

-- HR_PROVIDENT_FUND
COMMENT ON TABLE  HR_PROVIDENT_FUND                     IS 'Monthly PF contribution records. Both employee and employer contribute 10% of basic.';
COMMENT ON COLUMN HR_PROVIDENT_FUND.cumulative_balance  IS 'Running total of PF balance as of this period.';

-- HR_TRAINING_PROGRAMS
COMMENT ON TABLE  HR_TRAINING_PROGRAMS                  IS 'Training program catalogue (internal, external, online, certification).';

-- HR_TRAINING_SESSIONS
COMMENT ON TABLE  HR_TRAINING_SESSIONS                  IS 'Scheduled instances of a training program.';

-- HR_TRAINING_ENROLLMENTS
COMMENT ON TABLE  HR_TRAINING_ENROLLMENTS               IS 'Employee enrollment and completion records for training sessions.';

-- HR_DOCUMENT_TYPES
COMMENT ON TABLE  HR_DOCUMENT_TYPES                     IS 'Configurable types of HR documents (NID, passport, academic certificates, etc.).';
COMMENT ON COLUMN HR_DOCUMENT_TYPES.advance_alert_days  IS 'Days before expiry to generate an alert notification. Default 30 days.';

-- HR_EMPLOYEE_DOCUMENTS
COMMENT ON TABLE  HR_EMPLOYEE_DOCUMENTS                 IS 'Uploaded employee compliance documents with expiry tracking.';

-- HR_CONTRACTS
COMMENT ON TABLE  HR_CONTRACTS                          IS 'Employment contracts aligned with Bangladesh Labor Act 2006.';
COMMENT ON COLUMN HR_CONTRACTS.probation_period_months  IS 'Probation period in months. Maximum 6 months per Bangladesh Labor Act 2006.';
COMMENT ON COLUMN HR_CONTRACTS.notice_period_days       IS 'Notice period in days. 60 days minimum for permanent employees per BD Labor Act.';
COMMENT ON COLUMN HR_CONTRACTS.renewal_count            IS 'Number of times this contract has been renewed (for fixed-term contracts).';

-- HR_NOTIFICATIONS
COMMENT ON TABLE  HR_NOTIFICATIONS                      IS 'In-app and email notifications for leave approvals, document expiry, payslips, etc.';

-- HR_AUDIT_LOG
COMMENT ON TABLE  HR_AUDIT_LOG                          IS 'Immutable change log for audited tables. Populated by AFTER UPDATE/DELETE triggers.';
COMMENT ON COLUMN HR_AUDIT_LOG.old_values               IS 'JSON-style text snapshot of key column values before the change.';
COMMENT ON COLUMN HR_AUDIT_LOG.new_values               IS 'JSON-style text snapshot of key column values after the change.';
COMMENT ON COLUMN HR_AUDIT_LOG.changed_by               IS 'Oracle session user or APEX app user who made the change.';

-- HR_INTEGRATION_LOG
COMMENT ON TABLE  HR_INTEGRATION_LOG                    IS 'Log of integration calls: payroll sync, bank payment files, ATS feeds.';

-- HR_APP_USERS
COMMENT ON TABLE  HR_APP_USERS                          IS 'APEX application users with role-based access control (RBAC).';
COMMENT ON COLUMN HR_APP_USERS.role_code                IS 'HR_ADMIN | MANAGER | FINANCE_OFFICER | RECRUITER | EMPLOYEE.';
COMMENT ON COLUMN HR_APP_USERS.password_hash            IS 'Bcrypt or PBKDF2 hash of password; never store plaintext.';

-- =========================================================
-- SECTION 8: COMMIT
-- =========================================================

COMMIT;

-- =============================================================================
-- END OF FILE: 01_schema.sql
-- Total tables   : 35
-- Total sequences: 38
-- Total indexes  : 65+
-- Audit triggers : 5  (HR_EMPLOYEES, HR_EMPLOYEE_COMPENSATION,
--                      HR_LEAVE_REQUESTS, HR_PAYSLIPS, HR_CONTRACTS)
-- =============================================================================
