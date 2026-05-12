# HR-Application (Oracle APEX 24.2 / Bangladesh Labor Act 2006)

This repository now provides a production-oriented Oracle schema + PL/SQL backend foundation for a full Oracle APEX HR system.

## Deliverables in this repository

- `01_schema.sql`  
  Core 38-table Bangladesh-compliant HR schema with indexes and audit triggers.
- `02_hr_support_objects.sql`  
  APEX support objects:
  - data generation config/progress/audit tables
  - onboarding workflow configuration and tracking tables
  - compliance query catalog (static + parameterized query definitions)
  - unified compliance report source views
  - manager department visibility view
  - integration type extension for BIOMETRIC and NBR_TAX logging
- `03_hr_business_packages.sql`  
  PL/SQL packages:
  - `HR_COMPLIANCE_PKG` (tax/PF/gratuity/probation/audit export/compliance cursor)
  - `HR_DATA_GEN_PKG` (50k batch/bulk generation, regeneration safeguards, selective resets, recruitment seed)
  - `HR_INTEGRATION_PKG` (payroll integration reference flow + biometric/NBR stubs)

---

## Module structure and navigation (APEX)

Create one top-level navigation menu with these groups:

1. **Organization**
   - Companies, Departments, Positions, Grades
2. **People**
   - Employees, Contracts, Employment History, Documents, Onboarding
3. **Attendance & Leave**
   - Attendance, Leave Balances, Leave Requests, Leave Approval
4. **Performance**
   - Appraisal Cycles, Appraisals, Goals
5. **Recruitment**
   - Job Postings, Candidates, Applications
6. **Payroll & Compliance**
   - Payroll Periods/Runs/Payslips, Provident Fund, Tax Brackets, Compliance Reports
7. **Training**
   - Programs, Sessions, Enrollments
8. **Admin**
   - Data Generator, Transaction Reset, Integration Logs, Audit Trail Export, RBAC Users

---

## Role-based access control (fixed 5 roles)

Use `HR_APP_USERS.ROLE_CODE` and APEX authorization schemes:

- `HR_ADMIN`: full CRUD + admin pages
- `MANAGER`: department-level visibility (`HR_MANAGER_DEPT_EMP_V`) + leave approvals
- `FINANCE_OFFICER`: payroll, tax, PF, compliance reporting
- `RECRUITER`: job posting/candidate/application/onboarding intake
- `EMPLOYEE`: self-service (profile, leave, attendance, payslips)

No custom role extensibility is required.

---

## Data generation tool usage

### Initialize baseline
Run:
```sql
BEGIN
  HR_DATA_GEN_PKG.INIT_DEFAULTS;
END;
/
```

### Generate employees
- Batch mode (incremental, cross-session):
```sql
BEGIN
  HR_DATA_GEN_PKG.GENERATE_EMPLOYEES_BATCH(1000);
END;
/
```
- Bulk mode (to configured target):
```sql
BEGIN
  HR_DATA_GEN_PKG.GENERATE_EMPLOYEES_BULK;
END;
/
```

Progress is tracked in `HR_DATA_GEN_PROGRESS`; each run is logged in `HR_DATA_GEN_RUN_AUDIT`.

### Recruitment seed
```sql
BEGIN
  HR_DATA_GEN_PKG.GENERATE_RECRUITMENT_DATA(80, 500);
END;
/
```

### Leave balance behavior
Config supports:
- `FULL` mode (healthy balances)
- `REALISTIC` mode (mid-year variability)

Status-based balance behavior in generator:
- probation: 50%
- active/on-leave: 100%
- terminated: 0%

### Contract start mode
Configured via `HR_DATA_GEN_CONFIG.CONTRACT_DATE_MODE`:
- `FIXED` (single configured date)
- `VARIED` (multi-year spread)

### Regeneration safety
Regeneration requires explicit confirmation and dependency reset:
```sql
BEGIN
  HR_DATA_GEN_PKG.REGENERATE_EMPLOYEES(
    p_confirmation_text => 'CONFIRM_REGENERATE',
    p_batch_mode        => 'BULK'
  );
END;
/
```

If payroll/leave/attendance transactional rows exist, regeneration is blocked.

### Independent transaction resets
```sql
BEGIN
  HR_DATA_GEN_PKG.RESET_TRANSACTIONS(
    p_reset_leave       => 'Y',
    p_reset_payroll     => 'N',
    p_reset_attendance  => 'Y',
    p_reset_appraisals  => 'N',
    p_reset_recruitment => 'N'
  );
END;
/
```

Use any combination for granular preserve/reset behavior.

---

## Probation management workflow

- `HR_COMPLIANCE_PKG.RUN_PROBATION_FLAGGING` raises notifications when probation end has passed.
- HR reviews notified employees and confirms transition to permanent/active status in APEX employee lifecycle pages.

---

## Manager access and approvals

- Manager department visibility is provided by `HR_MANAGER_DEPT_EMP_V`.
- Leave approval pages should use this view + `HR_LEAVE_REQUESTS` to allow manager actions for all department employees, regardless of status.
- Build dashboard cards/charts with drill-down links into source interactive reports.

---

## Compliance reporting (saved queries + unified report)

Static report source views:
- `HR_QRY_GRATUITY_ELIGIBILITY`
- `HR_QRY_NBR_TAX_VALIDATION`
- `HR_QRY_TURNOVER_ANALYSIS`
- `HR_QRY_SALARY_AUDIT`

Saved query metadata:
- `HR_COMPLIANCE_QUERY_CATALOG` includes both static and parameterized entries.

Unified tabbed/segmented page:
- active tab values: GRATUITY / NBR_TAX / TURNOVER / SALARY_AUDIT
- common filters: date range, department, grade
- report source: `HR_COMPLIANCE_PKG.GET_COMPLIANCE_REFCURSOR(...)`
- persist filters in APEX session state (default behavior for page items)

---

## Audit trail export (JSON + formatted summary together)

```sql
DECLARE
  l_json CLOB;
  l_summary CLOB;
BEGIN
  HR_COMPLIANCE_PKG.EXPORT_AUDIT_TRAIL(
    p_from_date      => DATE '2024-01-01',
    p_to_date        => DATE '2024-12-31',
    p_table_name     => NULL,
    p_json_output    => l_json,
    p_summary_output => l_summary
  );
  -- write l_json and l_summary to files/BLOBs via APEX process
END;
/
```

Use two parallel downloads in APEX:
- raw JSON file
- formatted summary text/PDF

---

## Integration architecture

### Payroll processor (reference implementation)
`HR_INTEGRATION_PKG.PAYROLL_SYNC_REFERENCE`:
- builds outbound JSON payload from payroll run context
- writes integration transaction into `HR_INTEGRATION_LOG`
- mock response allows validation without external connectivity

### Biometric attendance (stub)
`HR_INTEGRATION_PKG.BIOMETRIC_ATTENDANCE_STUB` returns realistic sample records and logs inbound integration.

### NBR filing (stub)
`HR_INTEGRATION_PKG.NBR_TAX_FILING_STUB` returns mock filing payload and logs outbound integration.

APEX plugin templates:
- create REST Data Source + Web Source modules per connector
- map plugin process to package calls above
- keep connector-specific logic outside core HR business tables/packages

---

## Post-import setup steps

1. Run scripts in order:
   1) `01_schema.sql`  
   2) `02_hr_support_objects.sql`  
   3) `03_hr_business_packages.sql`
2. Create APEX application pages mapped to modules listed above.
3. Define authorization schemes for the 5 fixed roles.
4. Create LOVs from lookup/reference tables and role codes.
5. Create dashboard pages and drill-down links.
6. Build Data Generator admin page with calls to package procedures.
7. Build Compliance unified report page with tab selector + shared filters.

---

## Test data strategy and verification

- Fully synthetic names/emails/IDs only.
- NID/TIN are generated fake formatted values; not real government identifiers.
- Salary model is grade-based and consistent per grade baseline (`HR_DATA_GEN_GRADE_SALARY`).
- Intended status distribution defaults to:
  - ~95% active
  - ~2% on leave
  - ~2% probationary
  - ~1% terminated
- Supports both fixed and varied hire date modes.
- Supports mixed org complexity by department/position hierarchy.

Verification checklist:
- `SELECT COUNT(*) FROM HR_EMPLOYEES;` approaches configured target.
- `SELECT status, COUNT(*) FROM HR_DATA_GEN_PROGRESS GROUP BY status;`
- Validate compliance views return rows.
- Validate integration log receives entries for payroll/biometric/NBR stubs.
- Validate audit export returns both JSON and summary payloads.
