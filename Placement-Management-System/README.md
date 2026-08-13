# Placement Management System

A Salesforce application built during the Bridge Program to manage campus placements — students, jobs, applications, and offer letters — all in one place.

---

## What This Is

This is a clean, production-ready version of the project built day by day through the Bridge Program. Each day added something new — from the data model all the way to the UI.

---

## What's Built So Far

### Full-Stack Salesforce Application

A complete placement management system with:

**Core Architecture (Days 1-3):**
- Custom objects with relationships (Student, Job, Application, Offer Letter)
- Enterprise trigger framework (Trigger → Handler → Service pattern)
- Declarative automation (validation rules, flows)
- SOQL queries with aggregate functions

**Service Layer (Days 5-7):**
- ApplicationService — business logic for applications
- StudentService — student operations
- JobService — job management
- OfferService — offer letter handling
- AnalyticsService — aggregate queries for reporting
- PlacementService — shared utilities

**Asynchronous Processing (Day 8):**
- Queueable: ApplicationPostProcessingJob (notifications after apply)
- Batch: PlacementStatisticsBatch (analytics refresh)
- Scheduled: JobExpirationScheduler (auto-close expired jobs)
- External sync: CandidateSyncJob (integrate with external systems)

**User Interface (Days 4, 9, 10):**
- placementDashboard — live statistics dashboard
- studentPortal — parent component orchestrating student view
- eligibleJobs — shows jobs student can apply for with Apply button
- myApplications — shows student's application history
- jobCard, applicationCard — reusable card components
- studentSummary, studentProfileForm — student profile management
- Parent-child communication with custom events
- Lightning Data Service for automatic refresh

**Integration (Day 11):**
- REST API endpoints:
  - GET `/services/apexrest/placement/jobs` — list all jobs
  - GET `/services/apexrest/placement/students` — list all students
  - POST `/services/apexrest/placement/apply` — submit application
- JSON serialization for external system communication

---

## Project Structure

```
Placement-Management-System/
├── force-app/
│   └── main/default/
│       ├── classes/
│       │   ├── ApplicationService.cls              ← Core business logic
│       │   ├── ApplicationTriggerHandler.cls       ← Routes trigger events
│       │   ├── ApplicationController.cls           ← LWC controller for myApplications
│       │   ├── ApplicationPostProcessingJob.cls    ← Queueable (Day 8)
│       │   ├── StudentService.cls                  ← Student operations
│       │   ├── StudentTriggerHandler.cls           ← Student validation
│       │   ├── StudentPortalController.cls         ← Portal controller (Day 9)
│       │   ├── JobService.cls                      ← Job operations
│       │   ├── JobTriggerHandler.cls               ← Job validation
│       │   ├── JobExpirationScheduler.cls          ← Scheduled Apex (Day 8)
│       │   ├── OfferService.cls                    ← Offer letter handling
│       │   ├── PlacementService.cls                ← Utility queries
│       │   ├── PlacementServiceTest.cls            ← Test coverage
│       │   ├── PlacementDashboardController.cls    ← Dashboard controller
│       │   ├── PlacementStatisticsBatch.cls        ← Batch Apex (Day 8)
│       │   ├── PlacementApi.cls                    ← REST API (Day 11)
│       │   ├── AnalyticsService.cls                ← Analytics queries (Day 7)
│       │   ├── CandidateSyncJob.cls                ← External sync (Day 8)
│       │   └── ExternalPlacementService.cls        ← External callouts
│       ├── triggers/
│       │   ├── ApplicationTrigger.trigger          ← Before insert/update
│       │   ├── StudentTrigger.trigger              ← Before insert/update
│       │   └── JobTrigger.trigger                  ← Before insert/update
│       ├── objects/
│       │   ├── Student__c/                         ← Student profiles
│       │   ├── Job__c/                             ← Job postings
│       │   ├── Application__c/                     ← Application records
│       │   ├── Offer_Letter__c/                    ← Offer letters
│       │   └── Integration_Log__c/                 ← Integration tracking
│       └── lwc/
│           ├── placementDashboard/                 ← Dashboard (Day 4)
│           ├── studentPortal/                      ← Portal parent (Day 10)
│           ├── eligibleJobs/                       ← Job listing (Day 9)
│           ├── myApplications/                     ← Application history (Day 10)
│           ├── jobCard/                            ← Job card component
│           ├── applicationCard/                    ← Application card component
│           ├── studentSummary/                     ← Student summary
│           ├── studentProfileForm/                 ← Profile editor (Day 10)
│           └── profileForm/                        ← Profile form
├── docs/
│   ├── ARCHITECTURE.md                             ← Design decisions
│   ├── FEATURES.md                                 ← Feature details
│   ├── DAY-04-GUIDE.md                             ← Day 4 guide
│   └── DAY-05-GUIDE.md                             ← Day 5 guide
├── README.md
├── DEPLOYMENT.md
└── .forceignore
```

---

## Data Model

```
Student__c ──────< Application__c >────── Job__c
   │                                         │
   └── CGPA__c                    Minimum_CGPA__c ┘
   └── Active_Backlogs__c      Allowed_Backlogs__c ┘

Application__c ──── Offer_Letter__c
   └── Status = Selected → Offer Letter auto-created (Flow)
```

---

## Business Rules

| Rule | Type | Where |
|------|------|--------|
| CGPA must meet job minimum | Apex | ApplicationService |
| No duplicate applications | Apex | ApplicationService |
| Can't apply after closing date | Validation Rule | Salesforce UI |
| Student field is required | Validation Rule | Salesforce UI |
| Application Date auto-set | Flow | Salesforce UI |
| Offer Letter auto-created on Selected | Flow | Salesforce UI |

---

## Deploy

```bash
# Deploy everything
sf project deploy start

# Deploy only classes
sf project deploy start --source-dir force-app/main/default/classes

# Deploy only LWC
sf project deploy start --source-dir force-app/main/default/lwc
```

---

## Progress

| Day | Topic | Status |
|-----|-------|--------|
| Day 1 | Data Model, SOQL, Apex Basics, Triggers | ✅ Done |
| Day 2 | Collections, Bulkification, Handler Pattern, Service Layer | ✅ Done |
| Day 3 | Validation Rules, Flows, Declarative Automation | ✅ Done |
| Day 4 | Lightning Web Components Basics | ✅ Done |
| Day 5 | Service Architecture & Apex Integration | ✅ Done |
| Day 6 | Enterprise Trigger Framework | ✅ Done |
| Day 7 | Performance & Scale (Analytics, Bulk Processing) | ✅ Done |
| Day 8 | Async Apex (Queueable, Batch, Scheduled) | ✅ Done |
| Day 9 | Interactive Student Portal with Eligible Jobs | ✅ Done |
| Day 10 | Component Communication & Lightning Data Service | ✅ Done |
| Day 11 | REST API Integration | ✅ Done |

---

## Complete Features

### Day 5-11 Additions

**Day 5:** Connected UI to real Apex controllers
- PlacementDashboardController with live counts
- Service architecture for job eligibility filtering

**Day 6:** Enterprise trigger framework
- StudentTriggerHandler (CGPA validation)
- JobTriggerHandler (auto-close expired jobs)
- Proper separation: Trigger → Handler → Service

**Day 7:** Performance optimization
- AnalyticsService with aggregate queries
- Bulk-safe operations using Maps and Sets
- PlacementStatisticsBatch for background analytics

**Day 8:** Asynchronous processing
- ApplicationPostProcessingJob (Queueable)
- PlacementStatisticsBatch (Batch Apex)
- JobExpirationScheduler (Scheduled Apex)
- CandidateSyncJob for external integration

**Day 9:** Interactive student portal
- StudentPortalController with eligibility filtering
- eligibleJobs LWC with Apply button
- Real-time job applications from UI

**Day 10:** Multi-component architecture
- Parent-child communication (studentPortal → eligibleJobs → myApplications)
- Custom events for data refresh
- Lightning Data Service integration
- applicationCard and studentProfileForm components

**Day 11:** REST API
- PlacementApi with GET/POST endpoints
- External systems can fetch jobs/students
- API endpoint to submit applications
- JSON serialization/deserialization
