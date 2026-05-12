-- =============================================================================
-- FILE: 02_hr_support_objects.sql
-- PURPOSE: APEX support objects (data generation config, onboarding workflow,
--          compliance query catalog, unified report views, manager visibility)
-- =============================================================================

BEGIN EXECUTE IMMEDIATE 'DROP VIEW HR_MANAGER_DEPT_EMP_V'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP VIEW HR_QRY_SALARY_AUDIT'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP VIEW HR_QRY_TURNOVER_ANALYSIS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP VIEW HR_QRY_NBR_TAX_VALIDATION'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP VIEW HR_QRY_GRATUITY_ELIGIBILITY'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE HR_COMPLIANCE_QUERY_CATALOG CASCADE CONSTRAINTS PURGE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE HR_ONBOARDING_CASE_STEPS CASCADE CONSTRAINTS PURGE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE HR_ONBOARDING_CASES CASCADE CONSTRAINTS PURGE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE HR_ONBOARDING_STEP_CONFIG CASCADE CONSTRAINTS PURGE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE HR_DATA_GEN_RUN_AUDIT CASCADE CONSTRAINTS PURGE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE HR_DATA_GEN_PROGRESS CASCADE CONSTRAINTS PURGE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE HR_DATA_GEN_GRADE_SALARY CASCADE CONSTRAINTS PURGE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE HR_DATA_GEN_CONFIG CASCADE CONSTRAINTS PURGE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE HR_ONBOARDING_STEP_CFG_SEQ'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE HR_ONBOARDING_CASES_SEQ'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE HR_ONBOARDING_CASE_STEPS_SEQ'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE HR_DATA_GEN_RUN_AUDIT_SEQ'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE HR_DATA_GEN_PROGRESS_SEQ'; EXCEPTION WHEN OTHERS THEN NULL; END;
/

CREATE TABLE HR_DATA_GEN_CONFIG (
    config_id                 NUMBER         NOT NULL,
    config_name               VARCHAR2(200)  NOT NULL,
    target_employee_count     NUMBER         DEFAULT 50000 NOT NULL,
    default_batch_size        NUMBER         DEFAULT 1000  NOT NULL,
    min_salary_bdt            NUMBER(15,2)   DEFAULT 15000 NOT NULL,
    max_salary_bdt            NUMBER(15,2)   DEFAULT 550000 NOT NULL,
    pct_active                NUMBER(5,2)    DEFAULT 95 NOT NULL,
    pct_on_leave              NUMBER(5,2)    DEFAULT 2  NOT NULL,
    pct_probation             NUMBER(5,2)    DEFAULT 2  NOT NULL,
    pct_terminated            NUMBER(5,2)    DEFAULT 1  NOT NULL,
    contract_date_mode        VARCHAR2(20)   DEFAULT 'VARIED' NOT NULL,
    fixed_hire_date           DATE           DEFAULT DATE '2024-01-01',
    leave_balance_mode        VARCHAR2(20)   DEFAULT 'REALISTIC' NOT NULL,
    department_dist_json      CLOB,
    salary_by_grade_json      CLOB,
    is_active                 CHAR(1)        DEFAULT 'Y' NOT NULL,
    created_date              DATE           DEFAULT SYSDATE NOT NULL,
    created_by                VARCHAR2(100)  NOT NULL,
    updated_date              DATE,
    updated_by                VARCHAR2(100),
    CONSTRAINT HR_DGEN_CFG_PK        PRIMARY KEY (config_id),
    CONSTRAINT HR_DGEN_CFG_ACT       CHECK (is_active IN ('Y','N')),
    CONSTRAINT HR_DGEN_CFG_DT_MODE   CHECK (contract_date_mode IN ('FIXED','VARIED')),
    CONSTRAINT HR_DGEN_CFG_LV_MODE   CHECK (leave_balance_mode IN ('FULL','REALISTIC')),
    CONSTRAINT HR_DGEN_CFG_PCT_SUM   CHECK (ABS((pct_active + pct_on_leave + pct_probation + pct_terminated) - 100) < 0.01)
);

CREATE TABLE HR_DATA_GEN_GRADE_SALARY (
    grade_id                  NUMBER         NOT NULL,
    base_salary_bdt           NUMBER(15,2)   NOT NULL,
    created_date              DATE           DEFAULT SYSDATE NOT NULL,
    created_by                VARCHAR2(100)  NOT NULL,
    updated_date              DATE,
    updated_by                VARCHAR2(100),
    CONSTRAINT HR_DGEN_GSAL_PK      PRIMARY KEY (grade_id),
    CONSTRAINT HR_DGEN_GSAL_GRADE   FOREIGN KEY (grade_id) REFERENCES HR_GRADES (grade_id)
);

CREATE TABLE HR_DATA_GEN_PROGRESS (
    progress_id               NUMBER         NOT NULL,
    config_id                 NUMBER         NOT NULL,
    target_employee_count     NUMBER         NOT NULL,
    generated_employee_count  NUMBER         DEFAULT 0 NOT NULL,
    last_batch_size           NUMBER         DEFAULT 0 NOT NULL,
    last_run_at               TIMESTAMP,
    status                    VARCHAR2(20)   DEFAULT 'NOT_STARTED' NOT NULL,
    created_date              DATE           DEFAULT SYSDATE NOT NULL,
    created_by                VARCHAR2(100)  NOT NULL,
    updated_date              DATE,
    updated_by                VARCHAR2(100),
    CONSTRAINT HR_DGEN_PRG_PK       PRIMARY KEY (progress_id),
    CONSTRAINT HR_DGEN_PRG_CFG      FOREIGN KEY (config_id) REFERENCES HR_DATA_GEN_CONFIG (config_id),
    CONSTRAINT HR_DGEN_PRG_STATUS   CHECK (status IN ('NOT_STARTED','IN_PROGRESS','COMPLETED','FAILED','RESET'))
);

CREATE TABLE HR_DATA_GEN_RUN_AUDIT (
    run_audit_id              NUMBER         NOT NULL,
    progress_id               NUMBER,
    action_type               VARCHAR2(30)   NOT NULL,
    summary_text              VARCHAR2(1000),
    generated_count           NUMBER         DEFAULT 0,
    snapshot_json             CLOB,
    run_status                VARCHAR2(20)   DEFAULT 'SUCCESS' NOT NULL,
    run_started_at            TIMESTAMP      DEFAULT SYSTIMESTAMP NOT NULL,
    run_finished_at           TIMESTAMP,
    executed_by               VARCHAR2(100)  NOT NULL,
    CONSTRAINT HR_DGEN_AUD_PK        PRIMARY KEY (run_audit_id),
    CONSTRAINT HR_DGEN_AUD_PRG       FOREIGN KEY (progress_id) REFERENCES HR_DATA_GEN_PROGRESS (progress_id),
    CONSTRAINT HR_DGEN_AUD_ACTION    CHECK (action_type IN ('INIT_DEFAULTS','GENERATE_BATCH','GENERATE_BULK','RESET_TRANSACTIONS','REGENERATE_EMPLOYEES','REVERT_SNAPSHOT','SEED_RECRUITMENT','SEED_TRAINING')),
    CONSTRAINT HR_DGEN_AUD_STATUS    CHECK (run_status IN ('SUCCESS','FAILED','WARNING'))
);

CREATE TABLE HR_ONBOARDING_STEP_CONFIG (
    step_cfg_id               NUMBER         NOT NULL,
    company_id                NUMBER         NOT NULL,
    step_code                 VARCHAR2(30)   NOT NULL,
    step_name                 VARCHAR2(200)  NOT NULL,
    document_type             VARCHAR2(50),
    sequence_no               NUMBER         DEFAULT 1 NOT NULL,
    enforce_sequence          CHAR(1)        DEFAULT 'Y' NOT NULL,
    allow_manual_override     CHAR(1)        DEFAULT 'Y' NOT NULL,
    is_active                 CHAR(1)        DEFAULT 'Y' NOT NULL,
    created_date              DATE           DEFAULT SYSDATE NOT NULL,
    created_by                VARCHAR2(100)  NOT NULL,
    updated_date              DATE,
    updated_by                VARCHAR2(100),
    CONSTRAINT HR_ONB_STEP_CFG_PK      PRIMARY KEY (step_cfg_id),
    CONSTRAINT HR_ONB_STEP_CFG_UC      UNIQUE (company_id, step_code),
    CONSTRAINT HR_ONB_STEP_CFG_COMP    FOREIGN KEY (company_id) REFERENCES HR_COMPANIES (company_id),
    CONSTRAINT HR_ONB_STEP_CFG_ENF     CHECK (enforce_sequence IN ('Y','N')),
    CONSTRAINT HR_ONB_STEP_CFG_OVR     CHECK (allow_manual_override IN ('Y','N')),
    CONSTRAINT HR_ONB_STEP_CFG_ACT     CHECK (is_active IN ('Y','N'))
);

CREATE TABLE HR_ONBOARDING_CASES (
    case_id                   NUMBER         NOT NULL,
    emp_id                    NUMBER         NOT NULL,
    start_date                DATE           DEFAULT SYSDATE NOT NULL,
    target_completion_date    DATE,
    case_status               VARCHAR2(20)   DEFAULT 'IN_PROGRESS' NOT NULL,
    sequence_enforced         CHAR(1)        DEFAULT 'Y' NOT NULL,
    sequence_override_reason  VARCHAR2(1000),
    completed_date            DATE,
    created_date              DATE           DEFAULT SYSDATE NOT NULL,
    created_by                VARCHAR2(100)  NOT NULL,
    updated_date              DATE,
    updated_by                VARCHAR2(100),
    CONSTRAINT HR_ONB_CASES_PK       PRIMARY KEY (case_id),
    CONSTRAINT HR_ONB_CASES_EMP      FOREIGN KEY (emp_id) REFERENCES HR_EMPLOYEES (emp_id),
    CONSTRAINT HR_ONB_CASES_STATUS   CHECK (case_status IN ('IN_PROGRESS','COMPLETED','ON_HOLD','CANCELLED')),
    CONSTRAINT HR_ONB_CASES_ENF      CHECK (sequence_enforced IN ('Y','N'))
);

CREATE TABLE HR_ONBOARDING_CASE_STEPS (
    case_step_id              NUMBER         NOT NULL,
    case_id                   NUMBER         NOT NULL,
    step_cfg_id               NUMBER         NOT NULL,
    step_status               VARCHAR2(20)   DEFAULT 'PENDING' NOT NULL,
    assigned_to_emp_id        NUMBER,
    completed_by_emp_id       NUMBER,
    due_date                  DATE,
    completed_date            DATE,
    override_applied          CHAR(1)        DEFAULT 'N' NOT NULL,
    override_reason           VARCHAR2(1000),
    remarks                   VARCHAR2(1000),
    created_date              DATE           DEFAULT SYSDATE NOT NULL,
    created_by                VARCHAR2(100)  NOT NULL,
    updated_date              DATE,
    updated_by                VARCHAR2(100),
    CONSTRAINT HR_ONB_CASE_STEPS_PK      PRIMARY KEY (case_step_id),
    CONSTRAINT HR_ONB_CASE_STEPS_CASE    FOREIGN KEY (case_id) REFERENCES HR_ONBOARDING_CASES (case_id),
    CONSTRAINT HR_ONB_CASE_STEPS_CFG     FOREIGN KEY (step_cfg_id) REFERENCES HR_ONBOARDING_STEP_CONFIG (step_cfg_id),
    CONSTRAINT HR_ONB_CASE_STEPS_ASGN    FOREIGN KEY (assigned_to_emp_id) REFERENCES HR_EMPLOYEES (emp_id),
    CONSTRAINT HR_ONB_CASE_STEPS_CMPL    FOREIGN KEY (completed_by_emp_id) REFERENCES HR_EMPLOYEES (emp_id),
    CONSTRAINT HR_ONB_CASE_STEPS_STATUS  CHECK (step_status IN ('PENDING','IN_PROGRESS','COMPLETED','SKIPPED','BLOCKED')),
    CONSTRAINT HR_ONB_CASE_STEPS_OVR     CHECK (override_applied IN ('Y','N'))
);

CREATE TABLE HR_COMPLIANCE_QUERY_CATALOG (
    query_id                  NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY,
    query_code                VARCHAR2(50)   NOT NULL,
    query_name                VARCHAR2(200)  NOT NULL,
    query_category            VARCHAR2(30)   NOT NULL,
    query_mode                VARCHAR2(20)   NOT NULL,
    sql_text                  CLOB           NOT NULL,
    is_active                 CHAR(1)        DEFAULT 'Y' NOT NULL,
    created_date              DATE           DEFAULT SYSDATE NOT NULL,
    created_by                VARCHAR2(100)  NOT NULL,
    updated_date              DATE,
    updated_by                VARCHAR2(100),
    CONSTRAINT HR_COMP_QRY_CAT_PK        PRIMARY KEY (query_id),
    CONSTRAINT HR_COMP_QRY_CAT_UC        UNIQUE (query_code, query_mode),
    CONSTRAINT HR_COMP_QRY_CAT_MODE      CHECK (query_mode IN ('STATIC','PARAMETERIZED')),
    CONSTRAINT HR_COMP_QRY_CAT_CAT       CHECK (query_category IN ('GRATUITY','NBR_TAX','TURNOVER','SALARY_AUDIT')),
    CONSTRAINT HR_COMP_QRY_CAT_ACT       CHECK (is_active IN ('Y','N'))
);

CREATE SEQUENCE HR_ONBOARDING_STEP_CFG_SEQ START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE HR_ONBOARDING_CASES_SEQ START WITH 1 INCREMENT BY 1 CACHE 20 NOCYCLE;
CREATE SEQUENCE HR_ONBOARDING_CASE_STEPS_SEQ START WITH 1 INCREMENT BY 1 CACHE 50 NOCYCLE;
CREATE SEQUENCE HR_DATA_GEN_PROGRESS_SEQ START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE HR_DATA_GEN_RUN_AUDIT_SEQ START WITH 1 INCREMENT BY 1 CACHE 20 NOCYCLE;

CREATE OR REPLACE VIEW HR_QRY_GRATUITY_ELIGIBILITY AS
SELECT e.emp_id,
       e.emp_code,
       e.full_name,
       e.dept_id,
       e.grade_id,
       e.hire_date,
       ROUND(MONTHS_BETWEEN(TRUNC(SYSDATE), e.hire_date) / 12, 2) service_years,
       CASE WHEN MONTHS_BETWEEN(TRUNC(SYSDATE), e.hire_date) >= 60 THEN 'Y' ELSE 'N' END gratuity_eligible
  FROM HR_EMPLOYEES e;

CREATE OR REPLACE VIEW HR_QRY_NBR_TAX_VALIDATION AS
SELECT p.payslip_id,
       p.emp_id,
       e.full_name,
       e.dept_id,
       e.grade_id,
       p.tax_year,
       p.gross_salary,
       p.income_tax,
       ROUND(p.income_tax * 12,2) annualized_tax
  FROM HR_PAYSLIPS p
  JOIN HR_EMPLOYEES e ON e.emp_id = p.emp_id;

CREATE OR REPLACE VIEW HR_QRY_TURNOVER_ANALYSIS AS
SELECT e.dept_id,
       e.grade_id,
       COUNT(*) total_employees,
       SUM(CASE WHEN e.employment_status IN ('TERMINATED','RESIGNED') THEN 1 ELSE 0 END) exits,
       ROUND((SUM(CASE WHEN e.employment_status IN ('TERMINATED','RESIGNED') THEN 1 ELSE 0 END) / NULLIF(COUNT(*),0)) * 100,2) turnover_pct
  FROM HR_EMPLOYEES e
 GROUP BY e.dept_id, e.grade_id;

CREATE OR REPLACE VIEW HR_QRY_SALARY_AUDIT AS
SELECT eh.history_id,
       eh.emp_id,
       e.full_name,
       e.dept_id,
       e.grade_id,
       eh.effective_date,
       eh.old_salary,
       eh.new_salary,
       (eh.new_salary - eh.old_salary) salary_delta
  FROM HR_EMPLOYMENT_HISTORY eh
  JOIN HR_EMPLOYEES e ON e.emp_id = eh.emp_id
 WHERE eh.event_type = 'SALARY_CHANGE';

CREATE OR REPLACE VIEW HR_MANAGER_DEPT_EMP_V AS
SELECT m.user_id AS manager_user_id,
       m.username AS manager_username,
       e.emp_id,
       e.emp_code,
       e.full_name,
       e.dept_id,
       e.position_id,
       e.grade_id,
       e.employment_status
  FROM HR_APP_USERS m
  JOIN HR_EMPLOYEES me ON me.emp_id = m.emp_id
  JOIN HR_EMPLOYEES e ON e.dept_id = me.dept_id
 WHERE m.role_code = 'MANAGER';

BEGIN
    EXECUTE IMMEDIATE 'ALTER TABLE HR_INTEGRATION_LOG DROP CONSTRAINT HR_INTG_LOG_TYPE';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/
ALTER TABLE HR_INTEGRATION_LOG ADD CONSTRAINT HR_INTG_LOG_TYPE
CHECK (integration_type IN ('PAYROLL_SYNC','BANKING','ATS','BIOMETRIC','NBR_TAX'));
/

MERGE INTO HR_COMPLIANCE_QUERY_CATALOG q
USING (
    SELECT 'GRATUITY' query_code, 'Gratuity Eligibility Verification' query_name, 'GRATUITY' cat, 'STATIC' mode_name, 'select * from HR_QRY_GRATUITY_ELIGIBILITY' sql_text from dual UNION ALL
    SELECT 'NBR_TAX', 'NBR Tax Validation', 'NBR_TAX', 'STATIC', 'select * from HR_QRY_NBR_TAX_VALIDATION' from dual UNION ALL
    SELECT 'TURNOVER', 'Turnover Analysis', 'TURNOVER', 'STATIC', 'select * from HR_QRY_TURNOVER_ANALYSIS' from dual UNION ALL
    SELECT 'SALARY_AUDIT', 'Salary Audit', 'SALARY_AUDIT', 'STATIC', 'select * from HR_QRY_SALARY_AUDIT' from dual UNION ALL
    SELECT 'GRATUITY', 'Gratuity Eligibility Verification (Parameterized)', 'GRATUITY', 'PARAMETERIZED', 'BEGIN :P_RESULTSET := HR_COMPLIANCE_PKG.GET_COMPLIANCE_REFCURSOR(''GRATUITY'', :P_FROM_DATE,:P_TO_DATE,:P_DEPT_ID,:P_GRADE_ID); END;' from dual UNION ALL
    SELECT 'NBR_TAX', 'NBR Tax Validation (Parameterized)', 'NBR_TAX', 'PARAMETERIZED', 'BEGIN :P_RESULTSET := HR_COMPLIANCE_PKG.GET_COMPLIANCE_REFCURSOR(''NBR_TAX'', :P_FROM_DATE,:P_TO_DATE,:P_DEPT_ID,:P_GRADE_ID); END;' from dual UNION ALL
    SELECT 'TURNOVER', 'Turnover Analysis (Parameterized)', 'TURNOVER', 'PARAMETERIZED', 'BEGIN :P_RESULTSET := HR_COMPLIANCE_PKG.GET_COMPLIANCE_REFCURSOR(''TURNOVER'', :P_FROM_DATE,:P_TO_DATE,:P_DEPT_ID,:P_GRADE_ID); END;' from dual UNION ALL
    SELECT 'SALARY_AUDIT', 'Salary Audit (Parameterized)', 'SALARY_AUDIT', 'PARAMETERIZED', 'BEGIN :P_RESULTSET := HR_COMPLIANCE_PKG.GET_COMPLIANCE_REFCURSOR(''SALARY_AUDIT'', :P_FROM_DATE,:P_TO_DATE,:P_DEPT_ID,:P_GRADE_ID); END;' from dual
) s
ON (q.query_code = s.query_code AND q.query_mode = s.mode_name)
WHEN MATCHED THEN UPDATE SET
    q.query_name = s.query_name,
    q.query_category = s.cat,
    q.sql_text = s.sql_text,
    q.updated_date = SYSDATE,
    q.updated_by = NVL(SYS_CONTEXT('APEX$SESSION','APP_USER'), SYS_CONTEXT('USERENV','SESSION_USER'))
WHEN NOT MATCHED THEN INSERT (
    query_code, query_name, query_category, query_mode,
    sql_text, is_active, created_by
) VALUES (
    s.query_code, s.query_name, s.cat, s.mode_name,
    s.sql_text, 'Y', NVL(SYS_CONTEXT('APEX$SESSION','APP_USER'), SYS_CONTEXT('USERENV','SESSION_USER'))
);

DECLARE
    v_company_id NUMBER;
    v_user VARCHAR2(100) := NVL(SYS_CONTEXT('APEX$SESSION','APP_USER'), SYS_CONTEXT('USERENV','SESSION_USER'));
BEGIN
    SELECT MIN(company_id) INTO v_company_id FROM HR_COMPANIES;
    IF v_company_id IS NOT NULL THEN
        MERGE INTO HR_ONBOARDING_STEP_CONFIG c
        USING (
            SELECT v_company_id company_id, 'DOC_COLLECTION' step_code, 'Document Collection' step_name, 'NID' doc_type, 1 seq_no, 'Y' enforce_seq FROM dual UNION ALL
            SELECT v_company_id, 'BACKGROUND_CHECK', 'Background Check', 'BG_CHECK', 2, 'Y' FROM dual UNION ALL
            SELECT v_company_id, 'SYSTEM_ACCESS', 'System Access Provisioning', 'IT_ACCESS', 3, 'N' FROM dual UNION ALL
            SELECT v_company_id, 'ORIENTATION', 'Employee Orientation', 'ONBOARDING', 4, 'N' FROM dual
        ) s
        ON (c.company_id = s.company_id AND c.step_code = s.step_code)
        WHEN MATCHED THEN UPDATE SET
            c.step_name = s.step_name,
            c.document_type = s.doc_type,
            c.sequence_no = s.seq_no,
            c.enforce_sequence = s.enforce_seq,
            c.updated_date = SYSDATE,
            c.updated_by = v_user
        WHEN NOT MATCHED THEN INSERT (
            step_cfg_id, company_id, step_code, step_name, document_type,
            sequence_no, enforce_sequence, allow_manual_override, is_active, created_by
        ) VALUES (
            HR_ONBOARDING_STEP_CFG_SEQ.NEXTVAL, s.company_id, s.step_code, s.step_name, s.doc_type,
            s.seq_no, s.enforce_seq, 'Y', 'Y', v_user
        );
    END IF;
END;
/

COMMIT;
