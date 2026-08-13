# Placement Management System – Day 1

## What Is This?

A Salesforce-based system that lets students apply for jobs and automatically checks whether they're eligible based on CGPA. Built from scratch using custom objects, Apex, and triggers.

---

## Objects

### Student__c
Stores student information.

| Field | API Name | Type |
|---|---|---|
| Student Name | Name | Text |
| Roll Number | Roll_Number__c | Number |
| Department | Department__c | Picklist |
| CGPA | CGPA__c | Number (decimal) |
| Active Backlogs | Active_Backlogs__c | Number |
| Placement Status | Placement_Status__c | Picklist |
| Email | Email__c | Email |

### Job__c
Stores job postings from companies.

| Field | API Name | Type |
|---|---|---|
| Job Name | Name | Text |
| Company | Company__c | Text |
| Minimum CGPA | Minimum_CGPA__c | Number (decimal) |
| Allowed Backlogs | Allowed_Backlogs__c | Number |
| Location | Location__c | Text |
| Salary | Salary__c | Currency |
| Closing Date | Closing_Date__c | Date |
| Status | Status__c | Picklist |

### Application__c
Links a student to a job (junction object).

| Field | API Name | Type |
|---|---|---|
| Student | Student__c | Lookup → Student__c |
| Job | Job__c | Lookup → Job__c |
| Status | Status__c | Picklist |
| Application Date | Application_Date__c | Date |

---

## Object Relationships

```
Student__c ──────┐
                 ├──► Application__c
Job__c ──────────┘
```

Both are Lookup relationships — deleting a student or job does not cascade delete the application.

---

## Features Built

- Custom data model with 3 objects and lookup relationships
- SOQL queries across all 3 objects including cross-object joins
- Apex service class with reusable methods
- Before Insert trigger with automatic CGPA eligibility check
- Bulkified trigger (safe for bulk data loads)

---

## Apex Components

### PlacementService.cls

```apex
public with sharing class PlacementService {

    // Returns students with CGPA >= minimumCGPA
    public static List<Student__c> getEligibleStudents(Decimal minimumCGPA)

    // Returns students from a specific department
    public static List<Student__c> getStudentsByDepartment(String department)

    // Creates a new application linking student and job
    public static Application__c createApplication(Id studentId, Id jobId)
}
```

### ApplicationTrigger.trigger + ApplicationTriggerHandler.cls

Fires on `before insert` of Application__c.

**Logic:**
1. Collect all Student IDs and Job IDs from the batch
2. Query students and jobs in two SOQL calls
3. Build Maps for fast lookup
4. Compare each student's CGPA against their target job's minimum
5. Block the save with `addError()` if CGPA is too low

**Examples:**
- Rahul (9.0 CGPA) → Microsoft (min 8.0) → ✅ Saved
- Kiran (7.0 CGPA) → Microsoft (min 8.0) → ❌ Blocked

**Error message shown to user:**
> Student is not eligible for this job because the CGPA requirement is not met.

---

## SOQL Queries Used

```sql
-- Get all eligible students
SELECT Id, Name, CGPA__c
FROM Student__c
WHERE CGPA__c >= 8.0

-- Get applications with student and job names
SELECT Name,
       Student__r.Name,
       Job__r.Name,
       Job__r.Company__c,
       Status__c
FROM Application__c

-- Count applications per student
SELECT Student__r.Name, COUNT(Id) total
FROM Application__c
GROUP BY Student__r.Name
```

---

## Project Structure

```
force-app/main/default/
├── objects/
│   ├── Student__c/
│   ├── Job__c/
│   └── Application__c/
├── classes/
│   ├── PlacementService.cls
│   ├── PlacementService.cls-meta.xml
│   ├── PlacementServiceTest.cls
│   └── PlacementServiceTest.cls-meta.xml
└── triggers/
    ├── ApplicationTrigger.trigger
    └── ApplicationTrigger.trigger-meta.xml

Bridge-Program/Day-01/
├── code/
│   ├── PlacementService.cls
│   ├── PlacementServiceTest.cls
│   ├── ApplicationTriggerHandler.cls
│   └── triggers/
│       └── ApplicationTrigger.trigger
├── day-1-notes.md
└── README.md  ← this file
```

---

## Test Results

```
Test Class:   PlacementServiceTest
Tests Run:    1
Passed:       1
Failed:       0
Pass Rate:    100%
```

---

## Day 1 Learning Outcomes

| Topic | Where it appears |
|---|---|
| Custom Objects & Fields | Student__c, Job__c, Application__c |
| Lookup Relationships | Application__c → Student/Job |
| SOQL | All queries, cross-object joins |
| Apex Class | PlacementService.cls |
| DML | `insert app` in createApplication() |
| Trigger | ApplicationTrigger — before insert |
| Bulkification | No SOQL in loops, Map-based lookup |
| Test Class | PlacementServiceTest.cls |
| addError() | Blocking ineligible applications |

---

## What Day 2 Adds

Day 1 built a working system. Day 2 turns it into production-quality code:
- Trigger Handler Pattern (refactor the trigger)
- Duplicate application prevention
- StudentService, JobService, ApplicationService
- Collections deep dive (List, Set, Map)
- Governor limits in practice
