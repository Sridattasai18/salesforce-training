# Day 8 – Asynchronous Apex

## Overview

On Day 8, I learned how to design Salesforce applications that perform long-running operations in the background instead of making users wait. The core engineering lesson was understanding **when** a task should happen immediately versus when it can safely happen after the main transaction completes. I implemented all four asynchronous mechanisms: Future Methods, Queueable Apex, Queueable Chaining, Batch Apex, and Scheduled Apex, all built around our Placement Management System.

---

# Learning Objectives

- Understand the difference between synchronous and asynchronous processing.
- Decide which operations should happen immediately and which can run in the background.
- Create Future Methods for simple background work.
- Build Queueable Apex jobs for structured, stateful background processing.
- Use Queueable Chaining to guarantee execution order across multiple jobs.
- Process large datasets safely using Batch Apex.
- Schedule recurring business tasks using Scheduled Apex.
- Understand Governor Limits in async context.

---

# Concepts Learned

## Synchronous vs Asynchronous Processing

**Synchronous:** Every step happens in one transaction. The user waits for everything to complete.

**Asynchronous:** Critical work happens immediately. Secondary work moves to the background.

```text
Student Accepts Offer
        │
        ▼
Validate + Update  ← Happens Now (User gets response)

        Background ↓

Send Email         ← Happens Later
External Sync      ← Happens Later
Create Audit Log   ← Happens Later
```

---

## Future Method

The simplest async option. Annotated with `@future`, runs in the background after the transaction commits.

- Must be `static`.
- Parameters must be primitive types only (Id, String, Integer).
- Cannot pass SObjects directly.
- No chaining supported.

**When to use:** Simple, one-step background operations.

**Business example:** After a student applies, update their Placement Status in the background.

---

## Queueable Apex

The modern, preferred replacement for Future Methods. Implements the `Queueable` interface.

- Accepts SObjects and complex types as parameters.
- Supports Queueable Chaining.
- Full job monitoring via Apex Jobs.
- Enqueued using `System.enqueueJob()`.

**When to use:** Structured background workflows with state and chaining.

**Business example:** After an offer is accepted, update student status, create audit record, and initiate external sync.

---

## Queueable Chaining

One Queueable job enqueues another inside its `execute()` method. This creates a guaranteed, ordered sequence of background steps.

```text
Job A (External Sync) runs first
        │
        ▼
Job A enqueues Job B
        │
        ▼
Job B (Notification) runs second
```

**Why chaining?** To guarantee that Step 2 never runs before Step 1 completes.

---

## Batch Apex

Designed for large volumes of records that would hit Governor Limits in a single transaction.
Breaks data into chunks (default 200), each chunk processed in its own transaction with its own Governor Limits.

Three required methods:

| Method      | When It Runs               | Purpose                          |
| ----------- | -------------------------- | -------------------------------- |
| `start()`   | Once at the beginning      | Returns QueryLocator for records |
| `execute()` | Once per chunk             | Processes each batch of records  |
| `finish()`  | Once after all chunks done | Cleanup, confirmation            |

**When to use:** Processing thousands or millions of records.

**Business example:** Calculate Placement Category (Dream/Regular) for 120,000 applications.

---

## Scheduled Apex

Runs jobs automatically at a time defined by a CRON expression. Commonly used to start Batch jobs on a schedule.

```apex
String cron = '0 0 6 * * ?';  // Every day at 6 AM
System.schedule('Job Name', cron, new MyScheduler());
```

**When to use:** Recurring automated business tasks.

**Business example:** Every morning at 6 AM, start the PlacementCategoryBatch automatically.

---

## Governor Limits in Async Apex

Async Apex does **not** remove Governor Limits. It provides a **new transaction** with its own fresh set of limits.

| Resource      | Sync Limit | Async Limit |
| ------------- | ---------- | ----------- |
| SOQL Queries  | 100        | 200         |
| CPU Time      | 10 seconds | 60 seconds  |
| Heap Size     | 6 MB       | 12 MB       |

Batch Apex is special: each `execute()` chunk gets its own limits. That is why it safely handles millions of records.

---

# Hands-on Tasks Completed

## Task 1 – Future Method

Updated student Placement Status from `Not Placed` to `Application Submitted` in the background after they applied for a job.

**Flow:**
- Student applies → Application created → Transaction commits.
- `@future` method fires → Status updated in background.
- Student already received their confirmation — they didn't wait for the update.

---

## Task 2 – Queueable Apex (Offer Post Processing)

After Gopi's offer was accepted, a Queueable job handled all secondary work.

**Flow:**
- Offer accepted → Main transaction commits.
- Queueable job fires.
- Student Placement Status → Placed.
- Notification logged.
- Audit record created.
- External system sync initiated.

---

## Task 3 – Queueable Chaining

Designed a two-step chain where External Sync always runs before Notification.

**Flow:**

```text
ExternalPlacementSyncJob runs
        │
        ▼
External data synced
        │
        ▼
PlacementNotificationJob enqueued
        │
        ▼
Congratulations email sent
```

---

## Task 4 – Batch Apex

Processed all Application records in the org to assign Placement Category.

- Package >= 12 LPA → **Dream**
- Package < 12 LPA → **Regular**

Batch size: 200 records per chunk. Each chunk runs in its own transaction.

**Expected output:**

| Student | Package | Category |
| ------- | ------- | -------- |
| Vithal  | 18 LPA  | Dream    |
| Krishna | 14 LPA  | Dream    |
| Koushik | 12 LPA  | Dream    |
| Datta   | 8 LPA   | Regular  |
| Gopi    | 8 LPA   | Regular  |

---

## Task 5 – Scheduled Apex

Registered a daily job that fires every morning at 6 AM.

- Scheduler fires → Starts `PlacementCategoryBatch`.
- Batch processes all applications.
- Categories updated automatically, no manual step needed.

---

# Architecture

```text
Student Accepts Offer
        │
        ▼
Validate + Update Offer     ← Synchronous (user gets response)
        │
        ▼
OfferPostProcessingJob      ← Queueable Apex (background)
        │
        ▼
ExternalPlacementSyncJob    ← Queueable Chain – Job A
        │
        ▼
PlacementNotificationJob    ← Queueable Chain – Job B
```

```text
6:00 AM every day
        │
        ▼
ExpiredJobScheduler         ← Scheduled Apex
        │
        ▼
PlacementCategoryBatch      ← Batch Apex
        │
        ▼
Applications Categorized
```

---

# Choosing the Right Async Mechanism

| Requirement                      | Mechanism        |
| -------------------------------- | ---------------- |
| Simple one-step background task  | Future Method    |
| Structured background workflow   | Queueable Apex   |
| Guaranteed execution order       | Queueable Chain  |
| 1,000+ records                   | Batch Apex       |
| Recurring automated job          | Scheduled Apex   |

---

# Key Engineering Principle

> Not every business task should happen in the same transaction.
>
> Good architecture separates what must happen immediately from what can happen in the background.

---

# Key Takeaways

- Learned all four async mechanisms and when each one applies.
- Understood why Queueable is preferred over Future Methods for new work.
- Implemented Queueable Chaining to guarantee step ordering.
- Processed large datasets safely with Batch Apex.
- Automated recurring tasks with Scheduled Apex.
- Confirmed that async Apex gives a new transaction, not a Governor Limit bypass.
- Designed systems where the user experience and background processing are cleanly separated.

---

# Folder Structure

```text
Day-8/
├── codes/
│       FutureMethod.cls
│       OfferPostProcessingJob.cls
│       ExternalPlacementSyncJob.cls
│       PlacementNotificationJob.cls
│       PlacementCategoryBatch.cls
│       ExpiredJobScheduler.cls
│       ExecuteAnonymous.apex
├── screenshots/
└── day8-notes.md
```

---

# Outcome

By the end of Day 8, I can design and implement all four types of Asynchronous Apex. The Placement Management System now handles background processing properly — students get immediate responses, and secondary work runs safely in the background. I can explain async Apex in interviews at both a business and technical level.
