# APEX Page Planning Blueprint (No Export SQL)

This document implements the page-planning scope for the HR APEX application without generating APEX export SQL.

## 1) App Foundation

| Page ID | Page Name | Type | Primary Source | Authorization |
|---|---|---|---|---|
| 1 | Login | Built-in Login | APEX Auth + `HR_APP_USERS` | Public |
| 10 | Home Dashboard | Dashboard | KPI cards/charts from HR tables/views | Authenticated (role-aware regions) |
| 11 | Global Search | Report + Filters | Employees, departments, candidates, applications | `HR_ADMIN`, `MANAGER`, `RECRUITER` |
| 12 | Shared Components Setup | Admin Utility | LOVs, lists, breadcrumbs, nav menu | `HR_ADMIN` |

### Shared Components / LOV Plan
- Role LOV: `HR_APP_USERS.ROLE_CODE`
- Department LOV: `HR_DEPARTMENTS`
- Position LOV: `HR_POSITIONS`
- Grade LOV: `HR_GRADES`
- Leave type/status LOVs: `HR_LEAVE_TYPES` + lookup values
- Employee status and workflow status LOVs from lookup tables

---

## 2) Organization Pages

| Page ID | Page Name | Type | Primary Table | Authorization |
|---|---|---|---|---|
| 100 | Companies | Interactive Report | `HR_COMPANIES` | `HR_ADMIN` |
| 101 | Company Form | Form (modal) | `HR_COMPANIES` | `HR_ADMIN` |
| 110 | Departments | Interactive Report | `HR_DEPARTMENTS` | `HR_ADMIN`, `MANAGER` (read) |
| 111 | Department Form | Form (modal) | `HR_DEPARTMENTS` | `HR_ADMIN` |
| 120 | Positions | Interactive Report | `HR_POSITIONS` | `HR_ADMIN`, `MANAGER` (read) |
| 121 | Position Form | Form (modal) | `HR_POSITIONS` | `HR_ADMIN` |
| 130 | Grades | Interactive Report | `HR_GRADES` | `HR_ADMIN`, `FINANCE_OFFICER` (read) |
| 131 | Grade Form | Form (modal) | `HR_GRADES` | `HR_ADMIN` |

---

## 3) People Pages

| Page ID | Page Name | Type | Primary Source | Authorization |
|---|---|---|---|---|
| 200 | Employees | Interactive Report | `HR_EMPLOYEES` | `HR_ADMIN`, `MANAGER`, `RECRUITER` |
| 201 | Employee Form | Form (modal) | `HR_EMPLOYEES` | `HR_ADMIN`, `RECRUITER` |
| 210 | Employee Profile | Tabbed detail | Employee + related child datasets | Self/manager/admin scoped |
| 211 | Contracts | Report + Form | `HR_CONTRACTS` | `HR_ADMIN`, `RECRUITER` |
| 212 | Employment History | Report + Form | `HR_EMPLOYMENT_HISTORY` | `HR_ADMIN`, `MANAGER` (read) |
| 213 | Employee Documents | Report + Upload | `HR_EMPLOYEE_DOCUMENTS` | Self + HR/admin scoped |
| 214 | Onboarding Tracker | Workflow Board | `HR_ONBOARDING_CASES`, `HR_ONBOARDING_CASE_STEPS` | `HR_ADMIN`, `RECRUITER`, `MANAGER` |

---

## 4) Attendance & Leave Pages

| Page ID | Page Name | Type | Primary Source | Authorization |
|---|---|---|---|---|
| 300 | Attendance Log | Interactive Report | `HR_ATTENDANCE` | `HR_ADMIN`, `MANAGER`, `EMPLOYEE` (self) |
| 301 | Leave Balances | Report + Drilldown | `HR_LEAVE_BALANCES` | `HR_ADMIN`, `MANAGER`, `EMPLOYEE` (self) |
| 302 | Leave Requests | Report + Form | `HR_LEAVE_REQUESTS` | `HR_ADMIN`, `MANAGER`, `EMPLOYEE` |
| 303 | Leave Approval Workbench | Queue + Actions | `HR_LEAVE_REQUESTS` + `HR_MANAGER_DEPT_EMP_V` | `MANAGER`, `HR_ADMIN` |

---

## 5) Performance Pages

| Page ID | Page Name | Type | Primary Table | Authorization |
|---|---|---|---|---|
| 400 | Appraisal Cycles | Interactive Report | `HR_APPRAISAL_CYCLES` | `HR_ADMIN`, `MANAGER` |
| 401 | Appraisals | Interactive Report + Form | `HR_APPRAISALS` | `HR_ADMIN`, `MANAGER` |
| 402 | Goals | Report + Form | `HR_GOALS` | `HR_ADMIN`, `MANAGER`, `EMPLOYEE` (self) |

---

## 6) Recruitment Pages

| Page ID | Page Name | Type | Primary Table | Authorization |
|---|---|---|---|---|
| 500 | Job Postings | Interactive Report + Form | `HR_JOB_POSTINGS` | `HR_ADMIN`, `RECRUITER` |
| 501 | Candidates | Interactive Report + Form | `HR_CANDIDATES` | `HR_ADMIN`, `RECRUITER` |
| 502 | Applications Pipeline | Status Board / Report | `HR_APPLICATIONS` | `HR_ADMIN`, `RECRUITER`, `MANAGER` (read) |

---

## 7) Payroll & Compliance Pages

| Page ID | Page Name | Type | Primary Source | Authorization |
|---|---|---|---|---|
| 600 | Payroll Periods | Interactive Report + Form | `HR_PAYROLL_PERIODS` | `HR_ADMIN`, `FINANCE_OFFICER` |
| 601 | Payroll Runs | Report + Run Action | `HR_PAYROLL_RUNS` | `HR_ADMIN`, `FINANCE_OFFICER` |
| 602 | Payslips | Report + Detail | `HR_PAYSLIPS` | `HR_ADMIN`, `FINANCE_OFFICER`, `EMPLOYEE` (self) |
| 603 | Provident Fund | Interactive Report | `HR_PROVIDENT_FUND` | `HR_ADMIN`, `FINANCE_OFFICER` |
| 604 | Tax Brackets | Interactive Report + Form | `HR_TAX_BRACKETS` | `HR_ADMIN`, `FINANCE_OFFICER` |
| 605 | Compliance Report Hub | Tabbed report page | `HR_COMPLIANCE_PKG.GET_COMPLIANCE_REFCURSOR` | `HR_ADMIN`, `FINANCE_OFFICER`, `MANAGER` (read) |

### Compliance Page Filters
- Active tab: `GRATUITY`, `NBR_TAX`, `TURNOVER`, `SALARY_AUDIT`
- Shared filters: Date range, Department, Grade
- Session state retained for all filter items

---

## 8) Training Pages

| Page ID | Page Name | Type | Primary Table | Authorization |
|---|---|---|---|---|
| 700 | Training Programs | Interactive Report + Form | `HR_TRAINING_PROGRAMS` | `HR_ADMIN`, `MANAGER` |
| 701 | Training Sessions | Interactive Report + Form | `HR_TRAINING_SESSIONS` | `HR_ADMIN`, `MANAGER` |
| 702 | Training Enrollments | Interactive Report + Form | `HR_TRAINING_ENROLLMENTS` | `HR_ADMIN`, `MANAGER`, `EMPLOYEE` (self read) |

---

## 9) Admin Pages

| Page ID | Page Name | Type | Primary Source | Authorization |
|---|---|---|---|---|
| 800 | Data Generator Console | Control + Logs | `HR_DATA_GEN_PKG` + `HR_DATA_GEN_*` tables | `HR_ADMIN` |
| 801 | Transaction Reset Utility | Form + Action | `HR_DATA_GEN_PKG.RESET_TRANSACTIONS` | `HR_ADMIN` |
| 802 | Integration Logs | Interactive Report | `HR_INTEGRATION_LOG` | `HR_ADMIN`, `FINANCE_OFFICER` |
| 803 | Audit Trail Export | Parameter form + Downloads | `HR_COMPLIANCE_PKG.EXPORT_AUDIT_TRAIL` | `HR_ADMIN`, `FINANCE_OFFICER` |
| 804 | RBAC Users | Interactive Report + Form | `HR_APP_USERS` | `HR_ADMIN` |

---

## 10) Role Access Mapping

| Role | Access Scope |
|---|---|
| `HR_ADMIN` | Full access to all pages and admin utilities |
| `MANAGER` | Dashboard, team employees, leave approvals, dept-level reports, selected performance/recruitment read access |
| `FINANCE_OFFICER` | Payroll, payslips, tax brackets, PF, compliance reporting, audit/integration visibility as needed |
| `RECRUITER` | Job postings, candidates, applications, onboarding-related intake and employee create/edit intake flows |
| `EMPLOYEE` | Self-service profile, leave requests/history, attendance self-view, payslips self-view, training self-view |

---

## 11) Delivery Order (Implementation Sequence)

### Phase 1
- Foundation pages
- Shared components and LOVs
- Organization pages
- Core employee pages

### Phase 2
- Attendance & Leave
- Recruitment and onboarding tracking

### Phase 3
- Payroll & Compliance pages
- Training pages

### Phase 4
- Admin utilities
- Role-hardening and authorization checks
- Dashboard drill-down refinements

---

## 12) Implementation Notes
- Keep page processes package-centric (`HR_COMPLIANCE_PKG`, `HR_DATA_GEN_PKG`, `HR_INTEGRATION_PKG`).
- Use `HR_MANAGER_DEPT_EMP_V` for manager-scoped employee visibility.
- Keep all module pages in one top-level navigation menu grouped by module.
- No APEX application export SQL is included in this planning deliverable.
