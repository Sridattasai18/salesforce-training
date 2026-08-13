# Placement Management System

A Salesforce application built during the Bridge Program to manage campus placements — students, jobs, applications, and offer letters — all in one place.

---

## What This Is

This is a clean, production-ready version of the project built day by day through the Bridge Program. Each day added something new — from the data model all the way to the UI.

---

## What's Built So Far

### Day 1 — Data Model & Trigger Basics

Set up the foundation. Three custom objects, relationships between them, and a trigger that validates CGPA before an application is saved.

**Objects:**
- `Student__c` — Student profiles with CGPA, department, backlogs
- `Job__c` — Job postings with minimum CGPA, salary, closing date
- `Application__c` — Links students to jobs with status tracking

**Code:**
- `PlacementService.cls` — Utility methods for querying students and jobs
- `ApplicationTrigger.trigger` — Fires before insert on Application__c

---

### Day 2 — Trigger Handler Pattern & Service Layer

Refactored the trigger into a proper architecture. Business logic moved out of the trigger and into a service class.

```
ApplicationTrigger (3 lines)
    ↓
ApplicationTriggerHandler
    ↓
ApplicationService
    ├── validateApplications()   ← CGPA check + duplicate check
    └── submitApplication()      ← Used by LWC components
```

**What the validation does:**
- Blocks application if student CGPA is below job minimum
- Blocks duplicate applications (same student, same job)
- Processes any number of records safely (bulk-safe)

---

### Day 3 — Validation Rules & Flows *(Done in Salesforce UI)*

Added declarative automation on top of the Apex layer.

- **Validation Rule:** Can't apply after job closing date
- **Validation Rule:** Student field is required
- **Flow:** Auto-sets Application Date on create
- **Flow:** Auto-creates Offer Letter when status changes to Selected
- **New Object:** `Offer_Letter__c` — tracks issued offer letters

---

### Day 4 — First LWC Component

Built the first UI component: a Placement Dashboard that shows a summary of the system.

```
┌─────────────────────────────────────┐
│  Placement Dashboard          🎓    │
│  Welcome, Student 👋                │
│  Here's a quick look at your        │
│  placement activity.                │
│                                     │
│  ┌──────────┐  ┌──────────┐        │
│  │    3     │  │    2     │        │
│  │ Students │  │   Jobs   │        │
│  └──────────┘  └──────────┘        │
│  ┌──────────┐  ┌──────────┐        │
│  │    6     │  │    1     │        │
│  │  Apps    │  │  Offers  │        │
│  └──────────┘  └──────────┘        │
└─────────────────────────────────────┘
```

Values are hardcoded for now. Day 5 will connect them to real data via Apex.

---

## Project Structure

```
Placement-Management-System/
├── force-app/
│   └── main/default/
│       ├── classes/
│       │   ├── ApplicationService.cls          ← Core business logic
│       │   ├── ApplicationTriggerHandler.cls   ← Routes trigger events
│       │   └── PlacementService.cls            ← Utility queries
│       ├── triggers/
│       │   └── ApplicationTrigger.trigger      ← Before insert
│       ├── objects/
│       │   ├── Student__c/                     ← Student profiles
│       │   ├── Job__c/                         ← Job postings
│       │   └── Application__c/                 ← Application records
│       └── lwc/
│           └── placementDashboard/             ← Day 4 dashboard
├── docs/
│   ├── ARCHITECTURE.md                         ← Design decisions
│   ├── FEATURES.md                             ← Feature details
│   ├── DAY-04-GUIDE.md                         ← Day 4 guide
│   └── DEPLOYMENT.md                           ← How to deploy
├── README.md
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
| Day 5 | Service Architecture & Apex Integration | 🔜 Next |
| Day 6 | Enterprise Trigger Framework | ⬜ |
| Day 7 | Performance & Scale | ⬜ |
| Day 8 | Async Apex | ⬜ |
| Day 9 | Interactive Student Portal | ⬜ |
| Day 10 | Component Communication & LDS | ⬜ |
| Day 11 | APIs, REST Integration, Named Credentials | ⬜ |
