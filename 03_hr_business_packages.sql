-- =============================================================================
-- FILE: 03_hr_business_packages.sql
-- PURPOSE: Compliance logic, configurable data generation, integration stubs,
--          audit export, and unified compliance query access
-- =============================================================================

BEGIN EXECUTE IMMEDIATE 'DROP PACKAGE HR_INTEGRATION_PKG'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP PACKAGE HR_DATA_GEN_PKG'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP PACKAGE HR_COMPLIANCE_PKG'; EXCEPTION WHEN OTHERS THEN NULL; END;
/

CREATE OR REPLACE PACKAGE HR_COMPLIANCE_PKG AS
    FUNCTION calc_annual_tax (
        p_company_id            IN NUMBER,
        p_tax_year              IN NUMBER,
        p_annual_taxable_income IN NUMBER
    ) RETURN NUMBER;

    FUNCTION calc_pf_amount (
        p_basic_salary IN NUMBER,
        p_rate_pct     IN NUMBER DEFAULT 10
    ) RETURN NUMBER;

    FUNCTION gratuity_eligible (
        p_hire_date        IN DATE,
        p_termination_date IN DATE DEFAULT NULL
    ) RETURN CHAR;

    PROCEDURE run_probation_flagging (
        p_company_id    IN NUMBER DEFAULT NULL,
        p_flagged_count OUT NUMBER
    );

    PROCEDURE export_audit_trail (
        p_from_date      IN DATE,
        p_to_date        IN DATE,
        p_table_name     IN VARCHAR2 DEFAULT NULL,
        p_json_output    OUT CLOB,
        p_summary_output OUT CLOB
    );

    FUNCTION get_compliance_refcursor (
        p_query_code   IN VARCHAR2,
        p_from_date    IN DATE DEFAULT NULL,
        p_to_date      IN DATE DEFAULT NULL,
        p_dept_id      IN NUMBER DEFAULT NULL,
        p_grade_id     IN NUMBER DEFAULT NULL
    ) RETURN SYS_REFCURSOR;
END HR_COMPLIANCE_PKG;
/

CREATE OR REPLACE PACKAGE BODY HR_COMPLIANCE_PKG AS
    FUNCTION calc_annual_tax (
        p_company_id            IN NUMBER,
        p_tax_year              IN NUMBER,
        p_annual_taxable_income IN NUMBER
    ) RETURN NUMBER IS
        v_income NUMBER := NVL(p_annual_taxable_income, 0);
        v_tax    NUMBER := 0;
        v_span   NUMBER;
    BEGIN
        FOR r IN (
            SELECT min_income, max_income, tax_rate
              FROM HR_TAX_BRACKETS
             WHERE company_id = p_company_id
               AND tax_year = p_tax_year
               AND is_active = 'Y'
             ORDER BY min_income
        ) LOOP
            EXIT WHEN v_income <= 0;
            IF r.max_income IS NULL THEN
                v_span := v_income;
            ELSE
                v_span := LEAST(v_income, r.max_income - r.min_income);
            END IF;
            IF v_span > 0 THEN
                v_tax := v_tax + (v_span * r.tax_rate / 100);
                v_income := v_income - v_span;
            END IF;
        END LOOP;
        RETURN ROUND(v_tax, 2);
    END calc_annual_tax;

    FUNCTION calc_pf_amount (
        p_basic_salary IN NUMBER,
        p_rate_pct     IN NUMBER DEFAULT 10
    ) RETURN NUMBER IS
    BEGIN
        RETURN ROUND(NVL(p_basic_salary,0) * NVL(p_rate_pct,10) / 100, 2);
    END calc_pf_amount;

    FUNCTION gratuity_eligible (
        p_hire_date        IN DATE,
        p_termination_date IN DATE DEFAULT NULL
    ) RETURN CHAR IS
    BEGIN
        IF p_hire_date IS NULL THEN
            RETURN 'N';
        END IF;
        RETURN CASE
            WHEN MONTHS_BETWEEN(NVL(p_termination_date, TRUNC(SYSDATE)), p_hire_date) >= 60 THEN 'Y'
            ELSE 'N'
        END;
    END gratuity_eligible;

    PROCEDURE run_probation_flagging (
        p_company_id    IN NUMBER DEFAULT NULL,
        p_flagged_count OUT NUMBER
    ) IS
    BEGIN
        p_flagged_count := 0;
        FOR e IN (
            SELECT emp_id
              FROM HR_EMPLOYEES
             WHERE (p_company_id IS NULL OR company_id = p_company_id)
               AND probation_end_date IS NOT NULL
               AND probation_end_date <= TRUNC(SYSDATE)
               AND employment_status IN ('ACTIVE','ON_LEAVE')
        ) LOOP
            INSERT INTO HR_NOTIFICATIONS (
                notification_id, emp_id, notification_type, title, message,
                reference_id, reference_table, is_read, sent_via, created_date
            ) VALUES (
                HR_NOTIFICATIONS_SEQ.NEXTVAL,
                e.emp_id,
                'PROBATION_REVIEW',
                'Probation Expired',
                'Probation period ended. HR confirmation required to transition employee.',
                e.emp_id,
                'HR_EMPLOYEES',
                'N',
                'IN_APP',
                SYSDATE
            );
            p_flagged_count := p_flagged_count + 1;
        END LOOP;
    END run_probation_flagging;

    PROCEDURE export_audit_trail (
        p_from_date      IN DATE,
        p_to_date        IN DATE,
        p_table_name     IN VARCHAR2 DEFAULT NULL,
        p_json_output    OUT CLOB,
        p_summary_output OUT CLOB
    ) IS
        v_first BOOLEAN := TRUE;
    BEGIN
        DBMS_LOB.CREATETEMPORARY(p_json_output, TRUE);
        DBMS_LOB.CREATETEMPORARY(p_summary_output, TRUE);
        DBMS_LOB.APPEND(p_json_output, '[');

        FOR r IN (
            SELECT log_id, table_name, record_id, operation, old_values, new_values, changed_by, changed_date
              FROM HR_AUDIT_LOG
             WHERE changed_date >= CAST(TRUNC(NVL(p_from_date, DATE '1900-01-01')) AS TIMESTAMP)
               AND changed_date <  CAST(TRUNC(NVL(p_to_date, DATE '2999-12-31')) + 1 AS TIMESTAMP)
               AND (p_table_name IS NULL OR table_name = UPPER(p_table_name))
             ORDER BY changed_date, log_id
        ) LOOP
            IF NOT v_first THEN
                DBMS_LOB.APPEND(p_json_output, ',');
            END IF;
            v_first := FALSE;

            DBMS_LOB.APPEND(
                p_json_output,
                JSON_OBJECT(
                    'logId' VALUE r.log_id,
                    'tableName' VALUE r.table_name,
                    'recordId' VALUE r.record_id,
                    'operation' VALUE r.operation,
                    'oldValues' VALUE r.old_values,
                    'newValues' VALUE r.new_values,
                    'changedBy' VALUE r.changed_by,
                    'changedDate' VALUE TO_CHAR(r.changed_date, 'YYYY-MM-DD"T"HH24:MI:SS')
                )
            );

            DBMS_LOB.APPEND(
                p_summary_output,
                r.table_name || ' record ' || r.record_id || ': ' || r.operation ||
                ' by ' || r.changed_by || ' on ' || TO_CHAR(r.changed_date, 'YYYY-MM-DD HH24:MI:SS') || CHR(10)
            );
        END LOOP;
        DBMS_LOB.APPEND(p_json_output, ']');
    END export_audit_trail;

    FUNCTION get_compliance_refcursor (
        p_query_code   IN VARCHAR2,
        p_from_date    IN DATE DEFAULT NULL,
        p_to_date      IN DATE DEFAULT NULL,
        p_dept_id      IN NUMBER DEFAULT NULL,
        p_grade_id     IN NUMBER DEFAULT NULL
    ) RETURN SYS_REFCURSOR IS
        rc SYS_REFCURSOR;
    BEGIN
        IF UPPER(p_query_code) = 'GRATUITY' THEN
            OPEN rc FOR
                SELECT * FROM HR_QRY_GRATUITY_ELIGIBILITY q
                 WHERE (p_dept_id IS NULL OR q.dept_id = p_dept_id)
                   AND (p_grade_id IS NULL OR q.grade_id = p_grade_id)
                   AND (p_from_date IS NULL OR q.hire_date >= p_from_date)
                   AND (p_to_date IS NULL OR q.hire_date <= p_to_date);
        ELSIF UPPER(p_query_code) = 'NBR_TAX' THEN
            OPEN rc FOR
                SELECT * FROM HR_QRY_NBR_TAX_VALIDATION q
                 WHERE (p_dept_id IS NULL OR q.dept_id = p_dept_id)
                   AND (p_grade_id IS NULL OR q.grade_id = p_grade_id);
        ELSIF UPPER(p_query_code) = 'TURNOVER' THEN
            OPEN rc FOR
                SELECT * FROM HR_QRY_TURNOVER_ANALYSIS q
                 WHERE (p_dept_id IS NULL OR q.dept_id = p_dept_id)
                   AND (p_grade_id IS NULL OR q.grade_id = p_grade_id);
        ELSE
            OPEN rc FOR
                SELECT * FROM HR_QRY_SALARY_AUDIT q
                 WHERE (p_dept_id IS NULL OR q.dept_id = p_dept_id)
                   AND (p_grade_id IS NULL OR q.grade_id = p_grade_id)
                   AND (p_from_date IS NULL OR q.effective_date >= p_from_date)
                   AND (p_to_date IS NULL OR q.effective_date <= p_to_date);
        END IF;
        RETURN rc;
    END get_compliance_refcursor;
END HR_COMPLIANCE_PKG;
/

CREATE OR REPLACE PACKAGE HR_DATA_GEN_PKG AS
    PROCEDURE init_defaults;
    PROCEDURE generate_employees_batch (p_batch_size IN NUMBER DEFAULT NULL);
    PROCEDURE generate_employees_bulk;
    PROCEDURE generate_recruitment_data (p_job_postings IN NUMBER DEFAULT 80, p_candidates IN NUMBER DEFAULT 500);
    PROCEDURE reset_transactions (
        p_reset_leave IN CHAR DEFAULT 'N',
        p_reset_payroll IN CHAR DEFAULT 'N',
        p_reset_attendance IN CHAR DEFAULT 'N',
        p_reset_appraisals IN CHAR DEFAULT 'N',
        p_reset_recruitment IN CHAR DEFAULT 'N'
    );
    PROCEDURE regenerate_employees (
        p_confirmation_text IN VARCHAR2,
        p_batch_mode IN VARCHAR2 DEFAULT 'BULK',
        p_batch_size IN NUMBER DEFAULT 1000
    );
END HR_DATA_GEN_PKG;
/

CREATE OR REPLACE PACKAGE BODY HR_DATA_GEN_PKG AS
    c_nid_base             CONSTANT NUMBER := 700000000000000;
    c_tin_base             CONSTANT NUMBER := 100000000;
    c_hire_spread_months   CONSTANT NUMBER := 96;

    FUNCTION app_user RETURN VARCHAR2 IS
    BEGIN
        RETURN NVL(SYS_CONTEXT('APEX$SESSION','APP_USER'), SYS_CONTEXT('USERENV','SESSION_USER'));
    END;

    FUNCTION fake_nid (p_seed IN NUMBER) RETURN VARCHAR2 IS
        v_base VARCHAR2(16);
        v_sum  NUMBER := 0;
        v_chk  NUMBER;
    BEGIN
        v_base := LPAD(TO_CHAR(c_nid_base + p_seed), 16, '0');
        FOR i IN 1 .. LENGTH(v_base) LOOP
            v_sum := v_sum + TO_NUMBER(SUBSTR(v_base, i, 1)) * CASE WHEN MOD(i,2)=0 THEN 3 ELSE 1 END;
        END LOOP;
        v_chk := MOD(10 - MOD(v_sum,10), 10);
        RETURN v_base || TO_CHAR(v_chk);
    END;

    FUNCTION fake_tin (p_seed IN NUMBER) RETURN VARCHAR2 IS
    BEGIN
        RETURN 'TIN' || LPAD(TO_CHAR(c_tin_base + p_seed), 9, '0');
    END;

    PROCEDURE create_leave_balances (
        p_emp_id      IN NUMBER,
        p_leave_mode  IN VARCHAR2,
        p_emp_status  IN VARCHAR2,
        p_is_prob     IN CHAR
    ) IS
        v_mult NUMBER;
        v_open NUMBER;
    BEGIN
        IF p_emp_status = 'TERMINATED' THEN
            v_mult := 0;
        ELSIF p_is_prob = 'Y' THEN
            v_mult := 0.5;
        ELSE
            v_mult := 1;
        END IF;

        FOR lt IN (SELECT leave_type_id, days_per_year FROM HR_LEAVE_TYPES WHERE is_active = 'Y') LOOP
            IF UPPER(p_leave_mode) = 'FULL' THEN
                v_open := lt.days_per_year;
            ELSE
                v_open := ROUND(lt.days_per_year * DBMS_RANDOM.VALUE(0.35, 1), 2);
            END IF;

            INSERT INTO HR_LEAVE_BALANCES (
                balance_id, emp_id, leave_type_id, fiscal_year, opening_balance,
                accrued, taken, pending, last_updated, created_by
            ) VALUES (
                HR_LEAVE_BALANCES_SEQ.NEXTVAL, p_emp_id, lt.leave_type_id,
                EXTRACT(YEAR FROM SYSDATE), ROUND(v_open * v_mult, 2),
                0, 0,
                CASE WHEN UPPER(p_leave_mode) = 'REALISTIC' THEN ROUND(DBMS_RANDOM.VALUE(0,2),2) ELSE 0 END,
                SYSDATE, app_user
            );
        END LOOP;
    END;

    PROCEDURE log_run (p_progress_id IN NUMBER, p_action IN VARCHAR2, p_summary IN VARCHAR2, p_count IN NUMBER, p_status IN VARCHAR2) IS
    BEGIN
        INSERT INTO HR_DATA_GEN_RUN_AUDIT (
            run_audit_id, progress_id, action_type, summary_text, generated_count, run_status, executed_by
        ) VALUES (
            HR_DATA_GEN_RUN_AUDIT_SEQ.NEXTVAL, p_progress_id, p_action, p_summary, p_count, p_status, app_user
        );
    END;

    PROCEDURE init_defaults IS
        v_company_id NUMBER;
        v_count NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_count FROM HR_COMPANIES;
        IF v_count = 0 THEN
            INSERT INTO HR_COMPANIES (
                company_id, company_code, company_name, registration_no, tax_id, city, country, currency_code, is_active, created_by
            ) VALUES (
                HR_COMPANIES_SEQ.NEXTVAL, 'BDHR01', 'Bangladesh Enterprise HR Ltd', 'REG-BD-0001', 'TIN-ORG-00001', 'Dhaka', 'Bangladesh', 'BDT', 'Y', app_user
            );
        END IF;

        SELECT MIN(company_id) INTO v_company_id FROM HR_COMPANIES;

        SELECT COUNT(*) INTO v_count FROM HR_DEPARTMENTS WHERE company_id = v_company_id;
        IF v_count = 0 THEN
            INSERT INTO HR_DEPARTMENTS (dept_id, company_id, dept_code, dept_name, is_active, created_by) VALUES (HR_DEPARTMENTS_SEQ.NEXTVAL, v_company_id, 'HR', 'Human Resources', 'Y', app_user);
            INSERT INTO HR_DEPARTMENTS (dept_id, company_id, dept_code, dept_name, is_active, created_by) VALUES (HR_DEPARTMENTS_SEQ.NEXTVAL, v_company_id, 'FIN', 'Finance', 'Y', app_user);
            INSERT INTO HR_DEPARTMENTS (dept_id, company_id, dept_code, dept_name, is_active, created_by) VALUES (HR_DEPARTMENTS_SEQ.NEXTVAL, v_company_id, 'OPS', 'Operations', 'Y', app_user);
            INSERT INTO HR_DEPARTMENTS (dept_id, company_id, dept_code, dept_name, is_active, created_by) VALUES (HR_DEPARTMENTS_SEQ.NEXTVAL, v_company_id, 'IT', 'Information Technology', 'Y', app_user);
            INSERT INTO HR_DEPARTMENTS (dept_id, company_id, dept_code, dept_name, is_active, created_by) VALUES (HR_DEPARTMENTS_SEQ.NEXTVAL, v_company_id, 'SAL', 'Sales', 'Y', app_user);
        END IF;

        SELECT COUNT(*) INTO v_count FROM HR_GRADES WHERE company_id = v_company_id;
        IF v_count = 0 THEN
            FOR i IN 1 .. 10 LOOP
                INSERT INTO HR_GRADES (
                    grade_id, company_id, grade_code, grade_name, min_salary, max_salary, is_active, created_by
                ) VALUES (
                    HR_GRADES_SEQ.NEXTVAL, v_company_id, 'G' || i, 'Grade ' || i,
                    CASE WHEN i = 1 THEN 15000 ELSE 15000 + (i - 1) * 25000 END,
                    CASE WHEN i = 10 THEN 600000 ELSE 40000 + i * 55000 END,
                    'Y', app_user
                );
            END LOOP;
        END IF;

        SELECT COUNT(*) INTO v_count FROM HR_POSITIONS WHERE company_id = v_company_id;
        IF v_count = 0 THEN
            FOR d IN (SELECT dept_id, dept_code FROM HR_DEPARTMENTS WHERE company_id = v_company_id) LOOP
                FOR lv IN 1 .. 10 LOOP
                    INSERT INTO HR_POSITIONS (
                        position_id, company_id, dept_id, position_code, position_title, position_level, min_salary, max_salary, is_active, created_by
                    ) VALUES (
                        HR_POSITIONS_SEQ.NEXTVAL, v_company_id, d.dept_id,
                        d.dept_code || '_P' || LPAD(lv,2,'0'),
                        CASE WHEN lv <= 2 THEN 'Associate ' WHEN lv <=5 THEN 'Officer ' WHEN lv <=8 THEN 'Manager ' ELSE 'Director ' END || d.dept_code,
                        lv, 15000 + (lv-1)*20000, 55000 + lv*55000, 'Y', app_user
                    );
                END LOOP;
            END LOOP;
        END IF;

        MERGE INTO HR_DATA_GEN_CONFIG c
        USING (SELECT 1 config_id FROM dual) d
        ON (c.config_id = d.config_id)
        WHEN NOT MATCHED THEN
            INSERT (
                config_id, config_name, target_employee_count, default_batch_size, min_salary_bdt, max_salary_bdt,
                pct_active, pct_on_leave, pct_probation, pct_terminated, contract_date_mode, fixed_hire_date,
                leave_balance_mode, department_dist_json, salary_by_grade_json, is_active, created_by
            )
            VALUES (
                1, 'DEFAULT_50K_CONFIG', 50000, 1000, 15000, 550000, 95, 2, 2, 1, 'VARIED', DATE '2024-01-01',
                'REALISTIC', '{"HR":8,"FINANCE":7,"IT":12,"OPERATIONS":53,"SALES":20}',
                '{"G1":15000,"G2":22000,"G3":30000,"G4":45000,"G5":70000,"G6":110000,"G7":170000,"G8":260000,"G9":380000,"G10":550000}',
                'Y', app_user
            );

        MERGE INTO HR_DATA_GEN_PROGRESS p
        USING (SELECT 1 config_id FROM dual) d
        ON (p.config_id = d.config_id)
        WHEN NOT MATCHED THEN
            INSERT (progress_id, config_id, target_employee_count, generated_employee_count, status, created_by)
            VALUES (HR_DATA_GEN_PROGRESS_SEQ.NEXTVAL, 1, 50000, 0, 'NOT_STARTED', app_user);

        MERGE INTO HR_LEAVE_TYPES t
        USING (
            SELECT v_company_id company_id, 'CASUAL' leave_type_code, 'Casual Leave' leave_type_name, 'CASUAL' leave_category, 10 days_per_year, 0 max_cf, 'ANNUAL' accrual_method FROM dual UNION ALL
            SELECT v_company_id, 'EARNED', 'Earned Leave', 'EARNED', 20, 10, 'DAILY' FROM dual UNION ALL
            SELECT v_company_id, 'SICK', 'Sick Leave', 'SICK', 14, 0, 'ANNUAL' FROM dual UNION ALL
            SELECT v_company_id, 'MATERNITY', 'Maternity Leave', 'MATERNITY', 112, 0, 'ANNUAL' FROM dual
        ) s
        ON (t.company_id = s.company_id AND t.leave_type_code = s.leave_type_code)
        WHEN NOT MATCHED THEN
            INSERT (
                leave_type_id, company_id, leave_type_code, leave_type_name, leave_category,
                days_per_year, max_carry_forward, is_paid, requires_approval, min_notice_days,
                accrual_method, is_active, created_by
            ) VALUES (
                HR_LEAVE_TYPES_SEQ.NEXTVAL, s.company_id, s.leave_type_code, s.leave_type_name, s.leave_category,
                s.days_per_year, s.max_cf, 'Y', 'Y', 0, s.accrual_method, 'Y', app_user
            );

        MERGE INTO HR_TAX_BRACKETS b
        USING (
            SELECT v_company_id company_id, EXTRACT(YEAR FROM SYSDATE) tax_year, 0 min_income, 350000 max_income, 0 tax_rate FROM dual UNION ALL
            SELECT v_company_id, EXTRACT(YEAR FROM SYSDATE), 350000, 450000, 5 FROM dual UNION ALL
            SELECT v_company_id, EXTRACT(YEAR FROM SYSDATE), 450000, 750000, 10 FROM dual UNION ALL
            SELECT v_company_id, EXTRACT(YEAR FROM SYSDATE), 750000, 1150000, 15 FROM dual UNION ALL
            SELECT v_company_id, EXTRACT(YEAR FROM SYSDATE), 1150000, 1600000, 20 FROM dual UNION ALL
            SELECT v_company_id, EXTRACT(YEAR FROM SYSDATE), 1600000, NULL, 25 FROM dual
        ) s
        ON (
            b.company_id = s.company_id
            AND b.tax_year = s.tax_year
            AND b.min_income = s.min_income
            AND NVL(b.max_income,-1) = NVL(s.max_income,-1)
        )
        WHEN NOT MATCHED THEN
            INSERT (
                bracket_id, company_id, tax_year, min_income, max_income, tax_rate, surcharge_rate, is_active, created_by
            ) VALUES (
                HR_TAX_BRACKETS_SEQ.NEXTVAL, s.company_id, s.tax_year, s.min_income, s.max_income, s.tax_rate, 0, 'Y', app_user
            );

        MERGE INTO HR_DATA_GEN_GRADE_SALARY gs
        USING (
            SELECT grade_id,
                   CASE grade_code
                       WHEN 'G1' THEN 15000
                       WHEN 'G2' THEN 22000
                       WHEN 'G3' THEN 30000
                       WHEN 'G4' THEN 45000
                       WHEN 'G5' THEN 70000
                       WHEN 'G6' THEN 110000
                       WHEN 'G7' THEN 170000
                       WHEN 'G8' THEN 260000
                       WHEN 'G9' THEN 380000
                       ELSE 550000
                   END base_salary_bdt
              FROM HR_GRADES
             WHERE company_id = v_company_id
        ) x
        ON (gs.grade_id = x.grade_id)
        WHEN MATCHED THEN UPDATE SET
            gs.base_salary_bdt = x.base_salary_bdt,
            gs.updated_date = SYSDATE,
            gs.updated_by = app_user
        WHEN NOT MATCHED THEN
            INSERT (grade_id, base_salary_bdt, created_by)
            VALUES (x.grade_id, x.base_salary_bdt, app_user);

        log_run((SELECT MIN(progress_id) FROM HR_DATA_GEN_PROGRESS WHERE config_id = 1), 'INIT_DEFAULTS', 'Initialized default data generation config', 0, 'SUCCESS');
    END;

    PROCEDURE generate_employees_batch (p_batch_size IN NUMBER DEFAULT NULL) IS
        v_batch NUMBER;
        v_cfg HR_DATA_GEN_CONFIG%ROWTYPE;
        v_prg HR_DATA_GEN_PROGRESS%ROWTYPE;
        v_company_id NUMBER;
        v_to_create NUMBER;
        v_emp_id NUMBER;
        v_grade_id NUMBER;
        v_dept_id NUMBER;
        v_position_id NUMBER;
        v_salary NUMBER;
        v_status VARCHAR2(20);
        v_prob CHAR(1);
        v_hire_date DATE;
        v_rand NUMBER;
    BEGIN
        SELECT * INTO v_cfg FROM HR_DATA_GEN_CONFIG WHERE config_id = 1;
        SELECT * INTO v_prg FROM HR_DATA_GEN_PROGRESS WHERE config_id = 1 FOR UPDATE;
        SELECT MIN(company_id) INTO v_company_id FROM HR_COMPANIES;
        v_batch := NVL(p_batch_size, v_cfg.default_batch_size);
        v_to_create := LEAST(v_batch, v_cfg.target_employee_count - v_prg.generated_employee_count);
        IF v_to_create <= 0 THEN RETURN; END IF;

        FOR i IN 1 .. v_to_create LOOP
            v_emp_id := HR_EMPLOYEES_SEQ.NEXTVAL;
            SELECT grade_id INTO v_grade_id FROM (SELECT grade_id FROM HR_GRADES ORDER BY DBMS_RANDOM.VALUE) WHERE ROWNUM = 1;
            SELECT dept_id INTO v_dept_id FROM (SELECT dept_id FROM HR_DEPARTMENTS ORDER BY DBMS_RANDOM.VALUE) WHERE ROWNUM = 1;
            SELECT position_id INTO v_position_id FROM (SELECT position_id FROM HR_POSITIONS WHERE dept_id = v_dept_id ORDER BY DBMS_RANDOM.VALUE) WHERE ROWNUM = 1;
            SELECT NVL(base_salary_bdt, 15000) INTO v_salary FROM HR_DATA_GEN_GRADE_SALARY WHERE grade_id = v_grade_id;
            v_rand := DBMS_RANDOM.VALUE(0,100);
            v_status := CASE
                WHEN v_rand <= v_cfg.pct_terminated THEN 'TERMINATED'
                WHEN v_rand <= v_cfg.pct_terminated + v_cfg.pct_on_leave THEN 'ON_LEAVE'
                ELSE 'ACTIVE'
            END;
            v_prob := CASE
                WHEN v_status = 'TERMINATED' THEN 'N'
                WHEN v_rand > (v_cfg.pct_terminated + v_cfg.pct_on_leave)
                 AND v_rand <= (v_cfg.pct_terminated + v_cfg.pct_on_leave + v_cfg.pct_probation) THEN 'Y'
                ELSE 'N'
            END;
            v_hire_date := CASE WHEN v_cfg.contract_date_mode = 'FIXED' THEN v_cfg.fixed_hire_date ELSE ADD_MONTHS(TRUNC(SYSDATE), -TRUNC(DBMS_RANDOM.VALUE(0, c_hire_spread_months))) END;

            INSERT INTO HR_EMPLOYEES (
                emp_id, company_id, emp_code, first_name, last_name, gender, national_id,
                email_personal, email_official, dept_id, position_id, grade_id, hire_date,
                employment_type, employment_status, work_arrangement, tin_number,
                provident_fund_eligible, gratuity_eligible, probation_end_date, notice_period_days, created_by
            ) VALUES (
                v_emp_id, v_company_id, 'BD-' || LPAD(v_emp_id,6,'0'),
                'Emp' || v_emp_id, 'User', CASE MOD(v_emp_id,2) WHEN 0 THEN 'MALE' ELSE 'FEMALE' END,
                fake_nid(v_emp_id), LOWER('p' || v_emp_id || '@example.test'), LOWER('o' || v_emp_id || '@company.bd'),
                v_dept_id, v_position_id, v_grade_id, v_hire_date,
                CASE WHEN v_prob='Y' THEN 'PROBATIONARY' ELSE 'PERMANENT' END,
                v_status, 'OFFICE', fake_tin(v_emp_id), 'Y',
                HR_COMPLIANCE_PKG.gratuity_eligible(v_hire_date, NULL),
                CASE WHEN v_prob='Y' THEN ADD_MONTHS(v_hire_date, 6) END,
                60, app_user
            );

            INSERT INTO HR_EMPLOYEE_COMPENSATION (
                comp_id, emp_id, effective_date, basic_salary, house_rent_allowance, medical_allowance,
                transport_allowance, gross_salary, is_active, created_by
            ) VALUES (
                HR_EMPLOYEE_COMPENSATION_SEQ.NEXTVAL, v_emp_id, v_hire_date, v_salary,
                ROUND(v_salary*0.40,2), ROUND(v_salary*0.10,2), ROUND(v_salary*0.05,2),
                ROUND(v_salary*1.55,2), 'Y', app_user
            );

            create_leave_balances(v_emp_id, v_cfg.leave_balance_mode, v_status, v_prob);
        END LOOP;

        UPDATE HR_DATA_GEN_PROGRESS
           SET generated_employee_count = generated_employee_count + v_to_create,
               last_batch_size = v_to_create,
               last_run_at = SYSTIMESTAMP,
               status = CASE WHEN generated_employee_count + v_to_create >= target_employee_count THEN 'COMPLETED' ELSE 'IN_PROGRESS' END,
               updated_date = SYSDATE,
               updated_by = app_user
         WHERE progress_id = v_prg.progress_id;

        log_run(v_prg.progress_id, 'GENERATE_BATCH', 'Generated batch employees', v_to_create, 'SUCCESS');
    END;

    PROCEDURE generate_employees_bulk IS
        v_remaining NUMBER;
        v_batch NUMBER;
    BEGIN
        SELECT target_employee_count - generated_employee_count, default_batch_size
          INTO v_remaining, v_batch
          FROM HR_DATA_GEN_PROGRESS p
          JOIN HR_DATA_GEN_CONFIG c ON c.config_id = p.config_id
         WHERE p.config_id = 1;

        WHILE v_remaining > 0 LOOP
            generate_employees_batch(v_batch);
            SELECT target_employee_count - generated_employee_count INTO v_remaining FROM HR_DATA_GEN_PROGRESS WHERE config_id = 1;
        END LOOP;
        log_run((SELECT MIN(progress_id) FROM HR_DATA_GEN_PROGRESS WHERE config_id = 1), 'GENERATE_BULK', 'Bulk generation completed', 0, 'SUCCESS');
    END;

    PROCEDURE generate_recruitment_data (p_job_postings IN NUMBER DEFAULT 80, p_candidates IN NUMBER DEFAULT 500) IS
        v_company_id NUMBER;
        v_candidate_id NUMBER;
    BEGIN
        SELECT MIN(company_id) INTO v_company_id FROM HR_COMPANIES;
        FOR i IN 1 .. p_job_postings LOOP
            INSERT INTO HR_JOB_POSTINGS (
                posting_id, company_id, dept_id, position_id, posting_title, posting_description,
                min_salary, max_salary, posting_date, closing_date, status, no_of_positions, created_by
            ) VALUES (
                HR_JOB_POSTINGS_SEQ.NEXTVAL, v_company_id,
                (SELECT dept_id FROM (SELECT dept_id FROM HR_DEPARTMENTS ORDER BY DBMS_RANDOM.VALUE) WHERE ROWNUM=1),
                (SELECT position_id FROM (SELECT position_id FROM HR_POSITIONS ORDER BY DBMS_RANDOM.VALUE) WHERE ROWNUM=1),
                'Job Posting #' || i, 'Synthetic posting', TRUNC(DBMS_RANDOM.VALUE(15000,150000)),
                TRUNC(DBMS_RANDOM.VALUE(160000,500000)), TRUNC(SYSDATE)-TRUNC(DBMS_RANDOM.VALUE(0,30)),
                TRUNC(SYSDATE)+TRUNC(DBMS_RANDOM.VALUE(7,60)), 'OPEN', TRUNC(DBMS_RANDOM.VALUE(1,6)), app_user
            );
        END LOOP;
        FOR i IN 1 .. p_candidates LOOP
            v_candidate_id := HR_CANDIDATES_SEQ.NEXTVAL;
            INSERT INTO HR_CANDIDATES (
                candidate_id, first_name, last_name, email, phone, expected_salary, source, status, created_by
            ) VALUES (
                v_candidate_id, 'Candidate' || i, 'BD',
                LOWER('candidate' || v_candidate_id || '@mail.test'), '01' || LPAD(TRUNC(DBMS_RANDOM.VALUE(300000000,999999999)),9,'0'),
                TRUNC(DBMS_RANDOM.VALUE(15000,500000)), 'JOB_PORTAL', 'ACTIVE', app_user
            );
        END LOOP;
        log_run((SELECT MIN(progress_id) FROM HR_DATA_GEN_PROGRESS WHERE config_id = 1), 'SEED_RECRUITMENT', 'Generated recruitment data', p_candidates, 'SUCCESS');
    END;

    PROCEDURE reset_transactions (
        p_reset_leave IN CHAR DEFAULT 'N',
        p_reset_payroll IN CHAR DEFAULT 'N',
        p_reset_attendance IN CHAR DEFAULT 'N',
        p_reset_appraisals IN CHAR DEFAULT 'N',
        p_reset_recruitment IN CHAR DEFAULT 'N'
    ) IS
    BEGIN
        IF p_reset_leave = 'Y' THEN DELETE FROM HR_LEAVE_REQUESTS; END IF;
        IF p_reset_payroll = 'Y' THEN DELETE FROM HR_PROVIDENT_FUND; DELETE FROM HR_PAYSLIPS; DELETE FROM HR_PAYROLL_RUNS; DELETE FROM HR_PAYROLL_PERIODS; END IF;
        IF p_reset_attendance = 'Y' THEN DELETE FROM HR_ATTENDANCE; END IF;
        IF p_reset_appraisals = 'Y' THEN DELETE FROM HR_GOALS; DELETE FROM HR_APPRAISALS; DELETE FROM HR_APPRAISAL_CYCLES; END IF;
        IF p_reset_recruitment = 'Y' THEN DELETE FROM HR_APPLICATIONS; DELETE FROM HR_CANDIDATES; DELETE FROM HR_JOB_POSTINGS; END IF;
        log_run((SELECT MIN(progress_id) FROM HR_DATA_GEN_PROGRESS WHERE config_id = 1), 'RESET_TRANSACTIONS', 'Selective reset done', 0, 'SUCCESS');
    END;

    PROCEDURE regenerate_employees (
        p_confirmation_text IN VARCHAR2,
        p_batch_mode IN VARCHAR2 DEFAULT 'BULK',
        p_batch_size IN NUMBER DEFAULT 1000
    ) IS
        v_dep NUMBER;
    BEGIN
        IF UPPER(NVL(p_confirmation_text,'X')) <> 'CONFIRM_REGENERATE' THEN
            RAISE_APPLICATION_ERROR(-20011, 'Pass CONFIRM_REGENERATE to continue.');
        END IF;
        SELECT SUM(cnt)
          INTO v_dep
          FROM (
                SELECT COUNT(*) cnt FROM HR_PAYSLIPS
                UNION ALL
                SELECT COUNT(*) FROM HR_LEAVE_REQUESTS
                UNION ALL
                SELECT COUNT(*) FROM HR_ATTENDANCE
               );
        IF v_dep > 0 THEN
            RAISE_APPLICATION_ERROR(-20012, 'Reset payroll/leave/attendance transactions before regeneration.');
        END IF;
        -- Delete in dependency-safe order: child transactional tables first, then employee master.
        DELETE FROM HR_CONTRACTS;
        DELETE FROM HR_EMPLOYEE_COMPENSATION;
        DELETE FROM HR_EMPLOYEES;
        UPDATE HR_DATA_GEN_PROGRESS SET generated_employee_count = 0, status = 'RESET', updated_date = SYSDATE, updated_by = app_user WHERE config_id = 1;
        IF UPPER(p_batch_mode) = 'BATCH' THEN
            generate_employees_batch(p_batch_size);
        ELSE
            generate_employees_bulk;
        END IF;
        log_run((SELECT MIN(progress_id) FROM HR_DATA_GEN_PROGRESS WHERE config_id = 1), 'REGENERATE_EMPLOYEES', 'Regeneration completed', 0, 'SUCCESS');
    END;
END HR_DATA_GEN_PKG;
/

CREATE OR REPLACE PACKAGE HR_INTEGRATION_PKG AS
    PROCEDURE payroll_sync_reference (
        p_run_id       IN NUMBER,
        p_period_id    IN NUMBER,
        p_endpoint_url IN VARCHAR2 DEFAULT 'https://mock-payroll.example.local/api/v1/payroll/sync'
    );

    PROCEDURE biometric_attendance_stub (
        p_from_date   IN DATE,
        p_to_date     IN DATE,
        p_result_json OUT CLOB
    );

    PROCEDURE nbr_tax_filing_stub (
        p_tax_year    IN NUMBER,
        p_payload_out OUT CLOB
    );
END HR_INTEGRATION_PKG;
/

CREATE OR REPLACE PACKAGE BODY HR_INTEGRATION_PKG AS
    PROCEDURE log_intg (p_type IN VARCHAR2, p_direction IN VARCHAR2, p_status IN VARCHAR2, p_req IN CLOB, p_resp IN CLOB, p_err IN VARCHAR2) IS
    BEGIN
        INSERT INTO HR_INTEGRATION_LOG (
            log_id, integration_type, direction, status, request_payload, response_payload,
            error_message, retry_count, max_retries, created_date, completed_date
        ) VALUES (
            HR_INTEGRATION_LOG_SEQ.NEXTVAL, p_type, p_direction, p_status, p_req, p_resp,
            p_err, 0, 3, SYSTIMESTAMP, SYSTIMESTAMP
        );
    END;

    PROCEDURE payroll_sync_reference (
        p_run_id       IN NUMBER,
        p_period_id    IN NUMBER,
        p_endpoint_url IN VARCHAR2 DEFAULT 'https://mock-payroll.example.local/api/v1/payroll/sync'
    ) IS
        v_req CLOB;
        v_res CLOB;
    BEGIN
        v_req := JSON_OBJECT(
            'runId' VALUE p_run_id,
            'periodId' VALUE p_period_id,
            'currency' VALUE 'BDT',
            'endpoint' VALUE p_endpoint_url
        );
        v_res := JSON_OBJECT(
            'status' VALUE 'ACCEPTED',
            'reference' VALUE 'MOCK-' || TO_CHAR(SYSTIMESTAMP, 'YYYYMMDDHH24MISSFF3')
        );
        log_intg('PAYROLL_SYNC', 'OUTBOUND', 'SUCCESS', v_req, v_res, NULL);
    EXCEPTION
        WHEN OTHERS THEN
            log_intg('PAYROLL_SYNC', 'OUTBOUND', 'FAILED', v_req, NULL, SQLERRM);
            RAISE;
    END;

    PROCEDURE biometric_attendance_stub (
        p_from_date   IN DATE,
        p_to_date     IN DATE,
        p_result_json OUT CLOB
    ) IS
    BEGIN
        p_result_json := JSON_OBJECT(
            'integration' VALUE 'BIOMETRIC',
            'fromDate' VALUE TO_CHAR(p_from_date, 'YYYY-MM-DD'),
            'toDate' VALUE TO_CHAR(p_to_date, 'YYYY-MM-DD'),
            'records' VALUE JSON_ARRAY(
                JSON_OBJECT('employeeCode' VALUE 'BD-001001', 'checkIn' VALUE '09:01', 'checkOut' VALUE '18:01'),
                JSON_OBJECT('employeeCode' VALUE 'BD-001002', 'checkIn' VALUE '09:09', 'checkOut' VALUE '18:14')
            )
        );
        log_intg('BIOMETRIC', 'INBOUND', 'SUCCESS', NULL, p_result_json, NULL);
    END;

    PROCEDURE nbr_tax_filing_stub (
        p_tax_year    IN NUMBER,
        p_payload_out OUT CLOB
    ) IS
    BEGIN
        p_payload_out := JSON_OBJECT(
            'integration' VALUE 'NBR_TAX',
            'taxYear' VALUE p_tax_year,
            'currency' VALUE 'BDT',
            'totalWithheld' VALUE (SELECT NVL(SUM(income_tax),0) FROM HR_PAYSLIPS WHERE tax_year = p_tax_year)
        );
        log_intg('NBR_TAX', 'OUTBOUND', 'SUCCESS', p_payload_out, JSON_OBJECT('status' VALUE 'QUEUED'), NULL);
    END;
END HR_INTEGRATION_PKG;
/

COMMIT;
