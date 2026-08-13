# Day 3: Validation Rules, Flows, and Declarative Automation

## Concepts Covered Today

These are the topics you should know after completing Day 3.

| Concept | What it means |
|---------|---------------|
| Validation Rules | Prevent invalid data from being saved |
| Formula Functions | TODAY(), ISBLANK(), AND(), OR() |
| Record-Triggered Flow | Automatically run logic when a record is created or updated |
| Declarative Automation | Business automation without Apex code |
| Decision Element | Conditional logic inside Flow |
| Update Records Element | Modify Salesforce records in Flow |
| Create Records Element | Create new records automatically |
| Email Alerts / Notifications | Communicate business events |

---

## Prerequisites

You should already know:

- ✅ Custom Objects
- ✅ Custom Fields
- ✅ Lookup Relationships
- ✅ SOQL
- ✅ Apex Classes
- ✅ Triggers
- ✅ Trigger Handler Pattern
- ✅ Service Layer

You already completed all of these in Day 1 and Day 2, so you're ready.

---

## What We Are Building Today

Today we will add business automation to the Placement Management System.

### Current System:
```
Student
   │
   ▼
Application
   │
   ▼
Trigger
   │
   ▼
ApplicationService
```

### After Day 3:
```
Student
   │
   ▼
Application
   │
   ├── Validation Rules
   ├── Trigger
   └── Flow
       │
       ├── Set Application Date
       ├── Create Offer Letter
       └── Send Notification
```

**Important:** We are not replacing Apex. We are using Flows for business automation and Validation Rules for data integrity.

---

## Salesforce Website Tasks

Everything in this section is done in the Salesforce UI.

### Task 1: Create the Offer_Letter__c Object

#### Create Object

Go to:
```
Setup → Object Manager → Create → Custom Object
```

Use:

| Property | Value |
|----------|-------|
| Label | Offer Letter |
| Plural Label | Offer Letters |
| Object Name | Offer_Letter |
| Record Name | Offer Letter Number |
| Data Type | Auto Number |

#### Create Fields

Create these fields:

**1. Student**
- Type: Lookup Relationship
- Related To: Student

**2. Job**
- Type: Lookup Relationship
- Related To: Job

**3. Offer Date**
- Type: Date

**4. Status**
- Type: Picklist
- Values:
  - Issued
  - Accepted
  - Declined

When finished, the object should contain:
- Offer Letter Number
- Student
- Job
- Offer Date
- Status

---

### Task 2: Create Validation Rule — Application After Closing Date

Go to:
```
Setup → Object Manager → Application → Validation Rules
```

Click **New**.

| Property | Value |
|----------|-------|
| Rule Name | Prevent_Application_After_Closing_Date |
| Formula | `Job__r.Closing_Date__c < TODAY()` |
| Error Message | Applications cannot be submitted after the job closing date. |
| Error Location | Field: Job |

**Save.**

#### Test

1. Temporarily edit a Job record and set **Closing Date = Yesterday**
2. Try creating an Application

**Expected:**
Salesforce should block the save.

---

### Task 3: Create Validation Rule — Student Must Be Selected

We should not allow an Application without a Student.

Create another validation rule.

| Property | Value |
|----------|-------|
| Rule Name | Student_Required |
| Formula | `ISBLANK(Student__c)` |
| Error Message | Student is required before creating an application. |
| Error Location | Field: Student |

**Save.**

#### Test

Try creating an Application without selecting a Student.

**Expected:**
Validation error appears immediately.

---

### Task 4: Create Record-Triggered Flow

This is the main Day 3 task.

Go to:
```
Setup → Flows → New Flow
```

Choose:
```
Record-Triggered Flow
```

Configure:

| Setting | Value |
|---------|-------|
| Object | Application |
| Trigger | When a record is created |
| Run | After the record is saved |

Click **Done**.

---

#### Build the Flow

We will build this:

```
Application Created
       │
       ▼
Update Application Date
       │
       ▼
Check Status
       │
       ▼
Is Status = Selected?
       │
      Yes
       │
       ▼
Create Offer Letter
```

#### Element 1: Update Application Date

Click **+ → Update Records**

| Property | Value |
|----------|-------|
| Label | Set Application Date |
| Update | The triggering Application record |
| Set | Application_Date__c = TODAY() |

**Save.**

---

#### Element 2: Decision

Click **+ → Decision**

| Property | Value |
|----------|-------|
| Label | Is Student Selected? |
| Outcome | Selected |
| Condition | $Record.Status__c Equals Selected |

**Save.**

---

#### Element 3: Create Offer Letter

From the **Selected** outcome, click **+ → Create Records**

| Property | Value |
|----------|-------|
| Label | Create Offer Letter |
| Create | One Record |
| Object | Offer Letter |

Map fields:

| Offer Letter Field | Value |
|-------------------|-------|
| Student | $Record.Student__c |
| Job | $Record.Job__c |
| Offer Date | TODAY() |
| Status | Issued |

**Save.**

---

#### Activate the Flow

Click:
1. **Save**
   - Flow Name: `Application Automation`
2. Then click: **Activate**

⚠️ **This is important.** Flows do not run until activated.

---

#### Test the Flow

**Test 1: Normal application**

Create an Application with:
- Rahul
- Microsoft
- Status = Applied

**Expected:**
Application Date should automatically become today.

**Test 2: Selected application**

Create another Application:
- Rahul
- KSquare
- Status = Selected

**Expected:**
- Application is created
- Offer Letter record is automatically created

**Verify:**
```
App Launcher → Offer Letters
```
You should see a new Offer Letter.

---

## VS Code Tasks

Today VS Code work is minimal because we are focusing on declarative automation.

### Retrieve Metadata

Run:

```bash
sf project retrieve start
```

This will pull:
- Validation Rules
- Flow metadata
- Offer Letter object

### Verify Project Structure

You should now see something like:

```
force-app/
└── main/
    └── default/
        ├── objects/
        │   ├── Application__c/
        │   │   └── validationRules/
        │   ├── Job__c/
        │   ├── Student__c/
        │   └── Offer_Letter__c/
        ├── flows/
        │   └── Application_Automation.flow-meta.xml
        ├── classes/
        └── triggers/
```

---

## Git / GitHub

Commit Day 3.

```bash
git add .
git commit -m "Day 3: Validation rules and record-triggered automation"
git push
```

---

## What You Learned Today

Keep these interview-ready.

| Concept | One-line interview answer |
|---------|---------------------------|
| Validation Rule | Prevents invalid data from being saved |
| Flow | Declarative automation tool in Salesforce |
| Record-Triggered Flow | Runs automatically when a record is created or updated |
| Decision Element | Performs conditional branching |
| Create Records | Automatically creates related records |
| Update Records | Modifies existing records |

---

## End of Day 3 Checklist

Complete before moving to Day 4:

- [ ] Offer_Letter__c object created
- [ ] Application after closing date validation rule created
- [ ] Student required validation rule created
- [ ] Record-triggered flow created and activated
- [ ] Application Date updates automatically
- [ ] Offer Letter creates automatically when Status = Selected
- [ ] Metadata retrieved into VS Code
- [ ] GitHub commit pushed

Once you finish these, we'll move to **Day 4: Lightning Web Components (LWC) Basics**, where we build the first UI for your Placement Management System directly inside Salesforce.

---

## Progress Tracker

### Completed:
- ✅ **Day 1:** Data Model, SOQL, Apex Basics, Trigger Basics
- ✅ **Day 2:** Collections, Bulkification, Trigger Handler Pattern, Service Layer
- ✅ **Day 3:** Validation Rules, Flows, Declarative Automation

### Upcoming:
- **Day 4:** Lightning Web Components (LWC) Basics
- **Day 5:** Service Architecture & Business Logic Organization
- **Day 6:** Enterprise Trigger Framework
- **Day 7:** Performance & Scale
- **Day 8:** Asynchronous Apex (Queueable, Batch, Scheduled)
- **Day 9:** Interactive Student Portal (LWC + Apex)
- **Day 10:** Component Communication & LDS
- **Day 11:** APIs, REST Integration, Named Credentials

---

**Status:** Day 3 Template Ready ✅  
**Next:** Complete Salesforce UI tasks, then retrieve and commit
