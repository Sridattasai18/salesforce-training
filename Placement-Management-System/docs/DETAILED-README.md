# Placement Management System

A full-stack Salesforce application for managing campus placements — students, jobs, applications, offer letters, and external recruitment integration.

---

## Overview

The Placement Management System automates the end-to-end campus placement process on the Salesforce platform. It handles student profiles, job postings, eligibility-based job filtering, application submission with validation, offer letter generation, and synchronisation with an external recruitment system when a candidate is selected.

The application enforces business rules at the Apex layer (not only in the UI), uses an enterprise trigger framework with clean separation of concerns, and exposes a REST API for external system integration.

---

## Key Features

### Student Management
- Student profiles with CGPA, department, backlog count, and placement status
- Profile editing via Lightning Web Component form
- Student summary display with live data

### Job Management
- Job postings with company, location, salary, minimum CGPA requirement, backlog limit, and closing date
- Automatic status change to `Closed` when closing date passes (trigger + scheduled job)

### Application Management
- Students apply for jobs directly from the Student Portal
- Eligibility filtering: only jobs the student qualifies for are shown
- CGPA validation enforced in Apex trigger (not just UI)
- Backlog count validation enforced in Apex trigger
- Duplicate application prevention enforced in Apex trigger
- Closing date check before application is accepted
- Application status workflow: `Applied → Reviewed → Selected / Rejected`

### Offer Letter Automation
- Offer letter record auto-created when Application status is set to `Selected` (Salesforce Flow)

### Placement Dashboard
- Live statistics: student count, job count, application count, offer letter count
- Error state display when data cannot be loaded

### Student Placement Portal
- Parent–child LWC architecture: `studentPortal` orchestrates `studentSummary`, `eligibleJobs`, and `profileForm`
- Student selection dropdown — dynamically switches context across all child components
- Apply button with real-time feedback toast (success and specific failure messages)
- My Applications history panel

### External Recruitment Integration
- When an Application status changes to `Selected`, a Queueable Apex job fires asynchronously
- Candidate data is posted to an external recruitment API via Named Credential
- Every integration attempt (success or failure) is logged to `Integration_Log__c`

### REST API
- `GET /services/apexrest/placement/jobs` — returns all job records as JSON
- `GET /services/apexrest/placement/students` — returns all student records as JSON
- `POST /services/apexrest/placement/apply` — submits a new application from an external system

---

## Architecture

```
Lightning Web Components (UI)
        │
        ▼
Apex Controllers
(StudentPortalController, ApplicationController, PlacementDashboardController)
        │
        ▼
Service Layer
(ApplicationService, StudentService, JobService, OfferService, AnalyticsService)
        │
        ▼
Trigger → Handler Layer
(ApplicationTrigger → ApplicationTriggerHandler)
(StudentTrigger  → StudentTriggerHandler)
(JobTrigger      → JobTriggerHandler)
        │
        ▼
Salesforce Data
(Student__c, Job__c, Application__c, Offer_Letter__c, Integration_Log__c)
```

### External Integration Path

```
Application status → 'Selected'
        │
        ▼
ApplicationTrigger (after update)
        │
        ▼
ApplicationTriggerHandler.handleAfterUpdate()
        │
        ▼
CandidateSyncJob  (Queueable, Database.AllowsCallouts)
        │
        ▼
ExternalPlacementService.syncSelectedCandidates()
        │
        ▼
HTTP POST via Named Credential: Recruitment_API
        │
        ▼
Integration_Log__c  (success or failure logged)
```

---

## Data Model

### `Student__c`
| Field | Type | Description |
|---|---|---|
| Name | Text | Student full name |
| Roll_Number__c | Text (Unique) | Student ID |
| Email__c | Email | Contact email |
| CGPA__c | Number(2,2) | GPA on 0–10 scale |
| Department__c | Picklist | Academic department |
| Active_Backlogs__c | Number | Pending backlogs |
| Placement_Status__c | Picklist | `Not Placed` / `Placed` |

### `Job__c`
| Field | Type | Description |
|---|---|---|
| Name | Text | Job title |
| Company__c | Text | Hiring company |
| Location__c | Text | Job location |
| Minimum_CGPA__c | Number(2,2) | CGPA cutoff |
| Allowed_Backlogs__c | Number | Max backlogs allowed |
| Salary__c | Currency | Annual package |
| Closing_Date__c | Date | Application deadline |
| Status__c | Picklist | `Open` / `Closed` |

### `Application__c`
| Field | Type | Description |
|---|---|---|
| Student__c | Lookup(Student__c) | Applicant |
| Job__c | Lookup(Job__c) | Job applied for |
| Status__c | Picklist | `Applied` / `Reviewed` / `Selected` / `Rejected` |
| Application_Date__c | Date | Date of application |

### `Offer_Letter__c`
Auto-created by Flow when Application status changes to `Selected`.

### `Integration_Log__c`
| Field | Type | Description |
|---|---|---|
| Related_Record_Id__c | Text | Application ID that triggered the sync |
| Integration_Type__c | Text | e.g. `Candidate Sync` |
| Request_Body__c | Long Text | JSON payload sent |
| Response_Body__c | Long Text | API response |
| Status_Code__c | Number | HTTP status code |
| Success__c | Checkbox | Whether the call succeeded |
| Error_Message__c | Long Text | Error detail if failed |
| Timestamp__c | DateTime | When the call was made |

---

## Apex Architecture

### Controllers
| Class | Purpose |
|---|---|
| `StudentPortalController` | Fetches students, eligible jobs; handles `applyForJob()` with full validation |
| `ApplicationController` | Fetches application history for a student |
| `PlacementDashboardController` | Returns aggregate counts for the dashboard |
| `PlacementApi` | `@RestResource` — exposes REST endpoints for external systems |

### Services
| Class | Purpose |
|---|---|
| `ApplicationService` | Core application business logic, bulk validation |
| `StudentService` | Student queries and counts |
| `JobService` | Job queries and counts |
| `OfferService` | Offer letter queries and counts |
| `AnalyticsService` | Aggregate queries for reporting |
| `PlacementService` | Shared utility queries |
| `ExternalPlacementService` | HTTP callout to external recruitment API |

### Trigger Handlers
| Class | Handles |
|---|---|
| `ApplicationTriggerHandler` | `beforeInsert` validation, `afterInsert` post-processing, `afterUpdate` external sync |
| `StudentTriggerHandler` | `beforeSave` CGPA range validation |
| `JobTriggerHandler` | `beforeSave` CGPA cap validation, auto-close on past closing date |

### Asynchronous Apex
| Class | Type | Purpose |
|---|---|---|
| `CandidateSyncJob` | Queueable + AllowsCallouts | Syncs selected candidates to external API |
| `ApplicationPostProcessingJob` | Queueable | Post-insert processing after application created |
| `PlacementStatisticsBatch` | Batch | Analytics refresh across all applications |
| `JobExpirationScheduler` | Scheduled | Daily job to close expired job postings |

### Tests
| Class | Coverage |
|---|---|
| `PlacementServiceTest` | Core service layer |
| `ExternalPlacementServiceTest` | 6 tests — success callout, API failure, empty list, Queueable execution, trigger fires on `Selected`, trigger does not fire on other status changes |

---

## Lightning Web Components

| Component | Role |
|---|---|
| `studentPortal` | Parent orchestrator — student dropdown, passes `studentId` to all children |
| `studentSummary` | Displays selected student's name, department, CGPA, backlogs |
| `eligibleJobs` | Fetches and displays jobs the student qualifies for; handles Apply |
| `jobCard` | Reusable card for a single job listing |
| `myApplications` | Displays the selected student's application history |
| `applicationCard` | Reusable card for a single application record |
| `studentProfileForm` | `lightning-record-edit-form` for editing student profile |
| `profileForm` | Lightweight profile display form |
| `placementDashboard` | Statistics dashboard with live counts |

### Student Portal Component Tree

```
studentPortal  (parent, manages selectedStudentId)
  ├── studentSummary      (@api student)
  ├── eligibleJobs        (@api studentId)
  │     └── jobCard       (@api job)
  ├── myApplications      (@api studentId)
  │     └── applicationCard  (@api application)
  └── studentProfileForm  (@api studentId) / profileForm
```

---

## Automation

### Flows
- **Set Application Date** — Auto-sets `Application_Date__c` to today on new Application record
- **Create Offer Letter** — Auto-creates an `Offer_Letter__c` record when Application status changes to `Selected`

### Trigger-Driven Rules
- CGPA must be ≥ job minimum (Apex trigger — `ApplicationTriggerHandler.beforeInsert`)
- Backlogs must be ≤ job limit (Apex trigger — `ApplicationTriggerHandler.beforeInsert`)
- No duplicate applications (Apex trigger — `ApplicationTriggerHandler.beforeInsert`)
- Student CGPA must be between 0 and 10 (Apex trigger — `StudentTriggerHandler.beforeSave`)
- Job minimum CGPA cannot exceed 10 (Apex trigger — `JobTriggerHandler.beforeSave`)
- Jobs past closing date are auto-closed (Apex trigger — `JobTriggerHandler.beforeSave`)

---

## Integration

### Named Credential
The external API callout uses a Salesforce Named Credential (`Recruitment_API`), so no credentials or URLs are hardcoded in Apex. The credential is configured in Setup → Named Credentials.

The current configuration points to `https://jsonplaceholder.typicode.com` as a demo endpoint. Replace with your actual recruitment API endpoint when deploying to a real environment.

### Callout Flow
1. Application status changes to `Selected`
2. Trigger enqueues `CandidateSyncJob`
3. Job calls `ExternalPlacementService.syncSelectedCandidates()`
4. For each application: builds JSON payload, fires HTTP POST via Named Credential
5. Logs result to `Integration_Log__c` regardless of success or failure

### Payload sent to external API
```json
{
  "candidateName": "Student Name",
  "email": "student@example.com",
  "jobTitle": "Software Engineer",
  "company": "TechCorp",
  "applicationId": "a00xxxx",
  "status": "Selected"
}
```

### Error Handling
- API errors (4xx, 5xx) are logged with status code and response body
- Callout exceptions are caught and logged with error message
- Failures are isolated per application — one failure does not block others

---

## Testing

### Running Tests
```bash
sf apex run test --test-level RunLocalTests --result-format human
```

### Day 11 Integration Tests (`ExternalPlacementServiceTest`)
| Test | Verifies |
|---|---|
| `testSyncSelectedCandidates_Success` | Successful callout logs `Success__c = true`, `Status_Code = 201` |
| `testSyncSelectedCandidates_ApiFailure` | API 500 response logs `Success__c = false` |
| `testSyncSelectedCandidates_EmptyList` | Empty input creates no log |
| `testCandidateSyncJob_Execute` | Queueable job fires integration correctly |
| `testTrigger_StatusChangeToSelected_EnqueuesJob` | Trigger → Queueable → callout → log verified end-to-end |
| `testTrigger_StatusChangeToRejected_DoesNotSync` | Status change to `Rejected` does NOT trigger sync |

All 6 tests pass against a Salesforce Developer Edition org.

---

## Setup

### Prerequisites
- [Salesforce CLI](https://developer.salesforce.com/tools/salesforcecli) installed
- A Salesforce Developer Edition or Sandbox org
- Git (to clone the repository)

### Steps

**1. Clone the repository**
```bash
git clone https://github.com/Sridattasai18/Placement-Management-System.git
cd Placement-Management-System
```

**2. Authenticate your org**
```bash
sf org login web --alias placement-dev --set-default
```

**3. Deploy all metadata**
```bash
sf project deploy start
```

**4. Configure the Named Credential**

After deployment, configure the `Recruitment_API` Named Credential in your org:
- Setup → Named Credentials → `Recruitment API`
- Update the endpoint URL to your actual external API
- Set authentication as required by your API

> The metadata file deploys the Named Credential structure. The endpoint URL and any authentication secrets must be set or confirmed in the org UI — they are not stored in source code.

**5. Open your org**
```bash
sf org open
```

**6. Add components to Lightning App Pages**

Use Setup → Lightning App Builder to add `placementDashboard` or `studentPortal` to an App Page.

**7. Create sample data**

Open Developer Console → Execute Anonymous and run the data script in [QUICK-START.md](QUICK-START.md).

---

## Deployment

### Full deployment
```bash
sf project deploy start
```

### Deploy specific layers
```bash
# Objects and fields only
sf project deploy start --source-dir force-app/main/default/objects

# Apex classes and triggers only
sf project deploy start --source-dir force-app/main/default/classes
sf project deploy start --source-dir force-app/main/default/triggers

# LWC components only
sf project deploy start --source-dir force-app/main/default/lwc
```

### Run tests during deployment
```bash
sf project deploy start --test-level RunLocalTests
```

---

## Project Structure

```
Placement-Management-System/
├── force-app/
│   └── main/default/
│       ├── classes/          (20 Apex classes + test classes)
│       ├── triggers/         (3 Apex triggers)
│       ├── lwc/              (9 Lightning Web Components)
│       ├── objects/          (Student__c, Job__c, Application__c,
│       │                      Integration_Log__c + fields)
│       └── namedCredentials/ (Recruitment_API)
├── docs/
│   ├── ARCHITECTURE.md
│   └── FEATURES.md
├── README.md
├── QUICK-START.md
├── SETUP.md
├── API-REFERENCE.md
├── DEPLOYMENT.md
├── CHANGELOG.md
├── CONTRIBUTING.md
├── LICENSE
├── sfdx-project.json
└── .forceignore
```

---

## Future Improvements

- **Integration retry logic** — Failed callouts are logged but not automatically retried. A retry queue or scheduled re-sync would make the integration more resilient.
- **Idempotency protection** — If an Application is set to `Selected` more than once, the external API is called again. An `Integration_Sent__c` flag on the Application record would prevent duplicate syncs.
- **Expanded test coverage** — Additional unit tests for controller error paths and LWC component behaviour.

---

## License

MIT License — see [LICENSE](LICENSE) for details.
