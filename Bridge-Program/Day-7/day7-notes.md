# Day 7 – Bulk-Safe Business Logic with Apex

## Overview

On Day 7, I learned how to write **bulk-safe Apex code** by following Salesforce best practices. The focus was on understanding how Salesforce processes multiple records in a single transaction and how to design Apex code that works efficiently at scale without exceeding Governor Limits.

I implemented bulkified business logic using **Lists, Sets, and Maps**, learned to use **Trigger Context Variables**, and followed the **Trigger → Handler → Service** architecture to keep the code clean, maintainable, and reusable.

---

# Learning Objectives

- Understand why Salesforce enforces Governor Limits.
- Learn the concept of Bulkification.
- Process records using collections instead of individual records.
- Use Trigger Context Variables effectively.
- Avoid SOQL and DML statements inside loops.
- Detect meaningful business changes using Trigger.oldMap.
- Organize Apex code using the Trigger Handler Pattern.

---

# Concepts Learned

## Governor Limits

Salesforce is a multi-tenant platform where multiple organizations share the same infrastructure. To prevent one transaction from consuming excessive resources, Salesforce enforces Governor Limits.

Some commonly used limits include:

| Resource       | Limit      |
| -------------- | ---------- |
| SOQL Queries   | 100        |
| DML Statements | 150        |
| Query Records  | 50,000     |
| DML Records    | 10,000     |
| CPU Time       | 10 Seconds |
| Heap Size      | 6 MB       |

---

## Bulkification

Bulkification means writing Apex code that works correctly whether Salesforce processes:

- 1 record
- 10 records
- 50 records
- 200 records

Instead of processing records one by one, Salesforce developers design code to process entire collections efficiently.

---

## Trigger Context Variables

### Trigger.new

Contains the new version of all records currently being processed.

### Trigger.old

Contains the previous version of records before the update.

### Trigger.oldMap

Stores previous records in a Map using their Id.

Used to detect meaningful field changes.

Example:

```apex
if(oldApp.Status__c != 'Selected'
&& app.Status__c == 'Selected'){
```

This ensures automation runs only when the status actually changes.

---

## Collections

### List

Stores multiple records.

```apex
List<Application__c> applications;
```

---

### Set

Stores unique values.

```apex
Set<Id> studentIds = new Set<Id>();
```

Useful for collecting unique Student IDs or Job IDs.

---

### Map

Stores key-value pairs for fast record lookup.

```apex
Map<Id, Student__c> studentMap;
```

Instead of querying repeatedly, records can be retrieved instantly using their Id.

---

# Hands-on Tasks Completed

## Task 1 – Bulk Eligibility Validation

Implemented validation logic to verify whether a student is eligible to apply for a job.

### Business Rules

- Student CGPA must satisfy Job Minimum CGPA.
- Validation should support bulk record processing.
- No SOQL inside loops.
- No DML inside loops.

### Implementation

- Collected Student IDs.
- Collected Job IDs.
- Queried Students using one SOQL query.
- Queried Jobs using one SOQL query.
- Stored records in Maps.
- Compared Student eligibility with Job requirements.
- Displayed errors using `addError()`.

---

### Bulk Pattern Used

```
Applications
      │
      ▼
Collect Student IDs
Collect Job IDs
      │
      ▼
One Student Query
One Job Query
      │
      ▼
Student Map
Job Map
      │
      ▼
Eligibility Validation
```

---

## Task 2 – Bulk Student Status Update

Implemented automation to update Student Placement Status whenever an Application status changes to **Selected**.

### Business Logic

Instead of checking only

```apex
app.Status__c == 'Selected'
```

the application compares both old and new values.

```apex
oldApp.Status__c != 'Selected'
&&
app.Status__c == 'Selected'
```

This ensures automation executes only once when the status changes.

---

### Bulk Processing Steps

- Receive updated Applications.
- Compare old and new status.
- Collect Student IDs.
- Query Students once.
- Update all Students together.

---

### Processing Flow

```
Updated Applications
        │
        ▼
Compare Old Status
        │
        ▼
Find Newly Selected Applications
        │
        ▼
Collect Student IDs
        │
        ▼
One Student Query
        │
        ▼
Update Student Records
        │
        ▼
One DML Update
```

---

# Trigger Architecture

Implemented the Trigger Handler Pattern.

```
ApplicationTrigger
        │
        ▼
ApplicationTriggerHandler
        │
        ▼
ApplicationService
```

---

## Responsibilities

### ApplicationTrigger

- Detects Trigger Events.
- Calls appropriate Handler methods.
- Contains no business logic.

Example:

```apex
if (Trigger.isAfter && Trigger.isUpdate) {

    ApplicationTriggerHandler.updateSelectedStudents(
        Trigger.new,
        Trigger.oldMap
    );

}
```

---

### ApplicationTriggerHandler

Acts as the routing layer.

Example:

```apex
public static void updateSelectedStudents(

    List<Application__c> applications,
    Map<Id,Application__c> oldMap

){

    ApplicationService.markStudentsSelected(
        applications,
        oldMap
    );

}
```

---

### ApplicationService

Contains the actual business logic.

Example:

```apex
public static void markStudentsSelected(

    List<Application__c> applications,
    Map<Id,Application__c> oldMap){

    Set<Id> studentIds = new Set<Id>();

    for(Application__c app : applications){

        Application__c oldApp = oldMap.get(app.Id);

        if(oldApp.Status__c != 'Selected'
        && app.Status__c == 'Selected'){

            studentIds.add(app.Student__c);

        }

    }

}
```

The remaining logic:

- Queries Student records.
- Updates Placement Status.
- Performs one bulk DML operation.

---

# Bulk Processing Best Practices

✅ Use Trigger.new as a collection.

✅ Use Trigger.oldMap to detect field changes.

✅ Collect IDs using Sets.

✅ Query related records only once.

✅ Store queried records inside Maps.

✅ Perform processing in memory.

✅ Perform one bulk DML operation.

❌ Never write SOQL inside loops.

❌ Never write DML inside loops.

---

# Engineering Mindset

During this sprint, I learned to stop thinking about processing one record at a time.

Instead of asking:

> Which record am I processing?

I learned to ask:

> Which records am I processing?

This shift from **record thinking** to **collection thinking** is one of the core principles of Salesforce development.

---

# Key Takeaways

- Learned Bulkification.
- Understood Governor Limits.
- Practiced Trigger Context Variables.
- Used Lists, Sets, and Maps effectively.
- Built bulk-safe Eligibility Validation.
- Implemented Student Status Update using Trigger.oldMap.
- Followed the Trigger → Handler → Service architecture.
- Eliminated SOQL and DML operations from loops.
- Designed Apex code that is scalable, maintainable, and production-ready.

---

# Folder Structure

```
day-7/
│
├── ApplicationTrigger.trigger
├── ApplicationTriggerHandler.cls
├── ApplicationService.cls
├── README.md
└── screenshots/
```

---

# Outcome

By the end of Day 7, I was able to design and implement enterprise-style Apex code that follows Salesforce best practices for bulk processing. The application now supports processing multiple records efficiently while remaining scalable, maintainable, and compliant with Governor Limits.
