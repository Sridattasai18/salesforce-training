# Day 9 – Bulk-Safe Trigger Architecture

## Overview

Day 9 focuses on writing **enterprise-level Apex and Trigger architecture** that can safely process large volumes of data in Salesforce. The main objective is to move from **record-by-record coding** to **bulk-safe, scalable trigger design**.

In this project, I implemented a clean trigger architecture using the **Trigger → Trigger Handler → Service Layer** pattern. The trigger remains lightweight, the handler manages trigger events, and the service layer contains the actual business logic. This separation makes the application easier to maintain, test, and extend.

The project is based on the Placement Management System used throughout the bridge program and demonstrates how Salesforce developers build production-ready automation for student job applications.

---

## Objectives

* Understand why bulkification is necessary in Salesforce.
* Use **Trigger.new**, **Trigger.old**, **Trigger.newMap**, and **Trigger.oldMap** correctly.
* Collect record IDs using **Sets**.
* Reuse queried records using **Maps**.
* Perform **bulk SOQL** and **bulk DML** operations.
* Detect meaningful status changes during updates.
* Implement the **Trigger Handler Pattern**.
* Keep business logic inside reusable **Service classes**.
* Design automation that survives Salesforce Governor Limits.

---

## Business Problem

When students apply for jobs, the system must validate eligibility and update application records. If hundreds of applications are imported at once, poorly written triggers may exceed Salesforce Governor Limits.

This project solves that problem by processing all application records together using collections, Maps, and bulk queries.

---

## Architecture

```text
ApplicationTrigger
        ↓
ApplicationTriggerHandler
        ↓
ApplicationService
        ↓
PlacementStatusService
        ↓
SOQL / DML
        ↓
Salesforce Database
```

### Responsibility of Each Layer

| Layer                     | Responsibility                                             |
| ------------------------- | ---------------------------------------------------------- |
| ApplicationTrigger        | Receives Salesforce trigger events                         |
| ApplicationTriggerHandler | Routes before/after insert/update events                   |
| ApplicationService        | Validates applications and manages business rules          |
| PlacementStatusService    | Handles placement status updates and reusable status logic |
| Salesforce Database       | Stores Student, Job, and Application records               |

---

## Files Included

```text
Day9/
├── README.md
├── day-9-notes.md
├── ApplicationTrigger.trigger
├── ApplicationTriggerHandler.cls
├── ApplicationService.cls
├── PlacementStatusService.cls
├── sample-data.md
├── execute-anonymous.apex
└── expected-output.md
```

---

## What Was Implemented

### Trigger

* Before Insert
* Before Update
* After Update

### Business Logic

* Student eligibility validation
* CGPA validation
* Backlog validation
* Automatic application status assignment
* Status-change detection
* Bulk-safe processing using collections

### Bulkification Techniques

* **Set<Id>** for collecting unique Student and Job IDs.
* **Map<Id, Student__c>** and **Map<Id, Job__c>** for constant-time lookup.
* **One SOQL query per object**.
* **One DML operation outside loops**.

---

## Sample Business Flow

```text
Student Applies
        ↓
Trigger Fires
        ↓
Handler Executes
        ↓
Service Collects IDs
        ↓
Bulk SOQL Retrieves Students and Jobs
        ↓
Eligibility Validated
        ↓
Application Status Updated
        ↓
Records Saved
```

---

## Expected Output

### Successful Application

```text
Student: Rahul
CGPA: 8.2
Minimum Required: 7.5

Status = Applied

Result:
Application inserted successfully.
```

### Rejected Application

```text
Student: Ananya
CGPA: 7.1
Minimum Required: 7.5

Result:
Student CGPA is below the minimum requirement.
```

### Status Update

```text
Old Status:
Interview Scheduled

New Status:
Selected

Result:
Selection logic executed successfully.
```

---

## Key Learning Outcomes

* Triggers always receive **collections of records**.
* SOQL should never be written inside loops.
* DML should never be written inside loops.
* Sets help remove duplicate IDs automatically.
* Maps prevent repeated queries and improve performance.
* Trigger.oldMap is essential for detecting real business changes.
* Thin triggers and reusable service classes create maintainable Salesforce applications.
* Bulk-safe design is required for production Salesforce development.

---

## Interview Takeaways

### What is bulkification?

Bulkification is the process of designing Apex code so that it can process multiple records in a single transaction using collections, bulk SOQL, and bulk DML operations.

### Why use a Trigger Handler?

A Trigger Handler keeps triggers small and delegates business logic to separate classes, improving readability, testing, and maintainability.

### Why use Maps in Apex?

Maps provide fast lookup by record Id and allow previously queried records to be reused without executing additional SOQL queries.

### Difference between Trigger.new and Trigger.old

* **Trigger.new** contains the new version of records.
* **Trigger.old** contains the previous version of records.

---

## Day 9 Summary

Day 9 marks the transition from writing simple Apex to writing **production-quality Salesforce code**. The most important lesson is learning to think in **collections rather than individual records**. By combining Trigger architecture, service classes, Sets, Maps, and bulk-safe patterns, the Placement Management System can now process large numbers of applications efficiently while remaining maintainable and scalable.
