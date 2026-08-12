# Day 1 Notes - Salesforce Foundations

## What We Built Today

Today was all about laying the foundation. We created the core data model for our Placement Management System and wrote our first real Apex code.

## Step 1-6: Custom Objects & Data Model

We created three custom objects that work together:

### Student__c
The students looking for jobs.

**Fields:**
- Name (Text) - Student name
- Email__c (Email) - Contact email
- Roll_Number__c (Number) - Unique ID
- Department__c (Picklist) - CSE, ECE, MECH, etc.
- CGPA__c (Number) - Grade point average (0-10)
- Active_Backlogs__c (Number) - How many subjects they failed
- Placement_Status__c (Picklist) - Placed, Not Placed, Offer Received

### Job__c
Job postings from companies.

**Fields:**
- Name (Text) - Job title (e.g., "Software Engineer")
- Company__c (Text) - Company name
- Location__c (Text) - Where the job is
- Salary__c (Currency) - Package offered
- Minimum_CGPA__c (Number) - Eligibility criteria
- Posted_Date__c (Date) - When it was posted
- Closing_Date__c (Date) - Application deadline
- Status__c (Picklist) - Open, Closed, On Hold

### Application__c
Connects students to jobs (junction object).

**Fields:**
- Student__c (Lookup to Student__c)
- Job__c (Lookup to Job__c)
- Application_Date__c (Date)
- Status__c (Picklist) - Applied, Interview Scheduled, Selected, Rejected

**Relationship:**
```
Student__c
    ↓ (can have many applications)
Application__c
    ↓ (for one job)
Job__c
```

## Step 7: PlacementService Class

This is our first real Apex service class. Think of it as a toolbox of reusable methods.

### Why Service Classes?

Instead of writing the same query in multiple places, we write it once in a service class. Then anyone who needs it can call the service method.

**Bad approach:**
```apex
// Controller 1
List<Student__c> students = [SELECT Id FROM Student__c WHERE CGPA__c >= 8];

// Controller 2
List<Student__c> students = [SELECT Id FROM Student__c WHERE CGPA__c >= 8];

// LWC Controller
List<Student__c> students = [SELECT Id FROM Student__c WHERE CGPA__c >= 8];
```

**Good approach (Service Class):**
```apex
// PlacementService.cls
public static List<Student__c> getEligibleStudents(Decimal minimumCGPA) {
    return [SELECT Id FROM Student__c WHERE CGPA__c >= :minimumCGPA];
}

// Anyone who needs it:
List<Student__c> students = PlacementService.getEligibleStudents(8);
```

Now if the logic changes, we update ONE place, not ten.

### What PlacementService Does

**1. getEligibleStudents(minimumCGPA)**
- Returns students with CGPA >= the minimum
- Used for filtering eligible candidates

**2. getStudentsByDepartment(department)**
- Returns all students from a specific department
- Used for department-wise filtering

**3. createApplication(studentId, jobId)**
- Creates a new application linking a student to a job
- Sets status to "Applied" automatically
- Sets application date to today

### Key Apex Concepts You Learned

**public with sharing class**
- `public` = other classes can use it
- `with sharing` = respects user permissions (security)

**Static Methods**
- Called directly without creating an instance
- `PlacementService.getEligibleStudents(8)` ← no need for `new PlacementService()`

**SOQL (Salesforce Object Query Language)**
```apex
[SELECT Id, Name FROM Student__c WHERE CGPA__c >= :minimumCGPA]
```
- Like SQL but for Salesforce
- `:variable` binds a variable safely (prevents injection)

**DML (Data Manipulation Language)**
```apex
insert app;  // Saves the record to database
```

**Method Parameters & Return Types**
```apex
public static List<Student__c> getEligibleStudents(Decimal minimumCGPA)
              ↑ returns a list          ↑ method name    ↑ accepts a decimal parameter
```

## Testing Our Code

Every Apex class needs a test class. Why? Salesforce requires 75% code coverage to deploy to production.

### PlacementServiceTest

**Test Method Structure:**
```apex
@IsTest                           // Marks this as a test class
static void testGetEligibleStudents() {
    
    // 1. Setup: Create test data
    Student__c s = new Student__c(...);
    insert s;
    
    // 2. Execute: Run the code being tested
    Test.startTest();
    List<Student__c> result = PlacementService.getEligibleStudents(8);
    Test.stopTest();
    
    // 3. Verify: Check the results
    System.assertEquals(1, result.size());
}
```

**Why Test.startTest() and Test.stopTest()?**
- Resets governor limits (like SOQL query limits)
- Isolates the code you're testing
- Forces async code to complete

**Assertions**
```apex
System.assertEquals(expected, actual);  // Checks if two values match
```
If they don't match, the test fails.

## What Makes This Code Production-Ready?

✅ **Separation of Concerns** - Business logic lives in service classes  
✅ **Security** - `with sharing` respects user permissions  
✅ **Reusable** - Methods can be called from anywhere  
✅ **Tested** - Has test coverage  
✅ **Parameterized** - Methods accept parameters (flexible)  
✅ **Clear Purpose** - Each method does one thing well  

## Common Patterns You'll Use Daily

### Pattern 1: Query with Parameters
```apex
public static List<Student__c> getEligibleStudents(Decimal minimumCGPA) {
    return [SELECT Id, Name FROM Student__c WHERE CGPA__c >= :minimumCGPA];
}
```
The `:minimumCGPA` safely binds the parameter.

### Pattern 2: Insert with Return
```apex
public static Application__c createApplication(Id studentId, Id jobId) {
    Application__c app = new Application__c(...);
    insert app;
    return app;  // Caller gets the inserted record (now with an Id!)
}
```

### Pattern 3: Test Data Creation
```apex
Student__c s = new Student__c(
    Name = 'Test Student',
    CGPA__c = 9
);
insert s;
```

## Deployment & Testing Commands

**Deploy a class:**
```bash
sf project deploy start --source-dir force-app/main/default/classes/PlacementService.cls
```

**Run tests:**
```bash
sf apex run test --tests PlacementServiceTest --synchronous
```

**Check code coverage:**
```bash
sf apex get test --code-coverage
```

## What You Actually Learned

1. **Data Modeling** - How to design objects and relationships
2. **SOQL** - Querying data from Salesforce
3. **DML** - Inserting/updating/deleting records
4. **Service Classes** - Where business logic lives
5. **Testing** - How to write and run Apex tests
6. **Deployment** - Using Salesforce CLI to push code

## Common Mistakes to Avoid

❌ **Putting queries in loops**
```apex
for (Student__c s : students) {
    Job__c j = [SELECT Id FROM Job__c WHERE Id = :s.Job__c];  // BAD!
}
```

✅ **Query once, use many times**
```apex
List<Job__c> jobs = [SELECT Id FROM Job__c WHERE Id IN :jobIds];
```

❌ **No test class**
```apex
public class MyService {
    // code but no tests = can't deploy!
}
```

✅ **Always write tests**
```apex
@IsTest
private class MyServiceTest {
    // tests here
}
```

## Key Takeaways

1. **Service classes are your friends** - Keep logic reusable
2. **Always test your code** - Required for deployment
3. **Use parameters** - Makes methods flexible
4. **SOQL is powerful** - Learn it well
5. **Security matters** - Use `with sharing`

## Step 8: ApplicationTrigger – CGPA Validation

This is where the project becomes a real business application. Instead of manually checking if a student is eligible, Salesforce now does it automatically every time someone tries to apply.

### What it does

When someone creates a new Application__c record, the trigger:
1. Grabs the student's CGPA
2. Grabs the job's minimum CGPA requirement
3. Compares them
4. Blocks the save with an error message if the student doesn't qualify

**Real examples:**
- Rahul (CGPA 9) → Microsoft (min 8) → ✅ Allowed
- Ananya (CGPA 8) → Microsoft (min 8) → ✅ Allowed
- Kiran (CGPA 7) → Microsoft (min 8) → ❌ Blocked

### The Trigger Code

```apex
trigger ApplicationTrigger on Application__c (before insert, after update) {

    // Day 1: Validate CGPA eligibility before a new application is saved
    if (Trigger.isBefore && Trigger.isInsert) {
        ApplicationTriggerHandler.handleBeforeInsert(Trigger.new);
    }

    // Day 11: Sync selected candidates to external system (added later)
    if (Trigger.isAfter && Trigger.isUpdate) {
        ApplicationTriggerHandler.handleAfterUpdate(Trigger.new, Trigger.oldMap);
    }
}
```

Notice the trigger is tiny — just routing to a handler. The actual logic lives in the handler class.

### The Handler Logic

```apex
public static void handleBeforeInsert(List<Application__c> newList) {

    // Step 1: Collect all IDs first
    Set<Id> studentIds = new Set<Id>();
    Set<Id> jobIds = new Set<Id>();

    for (Application__c app : newList) {
        if (app.Student__c != null) studentIds.add(app.Student__c);
        if (app.Job__c != null)     jobIds.add(app.Job__c);
    }

    // Step 2: Query once for all students, once for all jobs
    Map<Id, Student__c> studentMap = new Map<Id, Student__c>(
        [SELECT Id, Name, CGPA__c FROM Student__c WHERE Id IN :studentIds]
    );
    Map<Id, Job__c> jobMap = new Map<Id, Job__c>(
        [SELECT Id, Name, Minimum_CGPA__c FROM Job__c WHERE Id IN :jobIds]
    );

    // Step 3: Validate each application
    for (Application__c app : newList) {
        Student__c student = studentMap.get(app.Student__c);
        Job__c     job     = jobMap.get(app.Job__c);

        if (student != null && job != null) {
            if (student.CGPA__c < job.Minimum_CGPA__c) {
                app.addError('Student is not eligible for this job because the CGPA requirement is not met.');
            }
        }
    }
}
```

### Why This Is Already Production-Ready

**Bulkification** — This is the most important concept in Salesforce development.

If someone imports 200 applications at once using Data Loader, this trigger handles all 200 in one shot. Here's why:

❌ **Naive approach (broken at scale):**
```apex
for (Application__c app : Trigger.new) {
    Student__c s = [SELECT CGPA__c FROM Student__c WHERE Id = :app.Student__c]; // SOQL in loop!
    Job__c j = [SELECT Minimum_CGPA__c FROM Job__c WHERE Id = :app.Job__c];      // SOQL in loop!
}
```
For 200 records → 400 SOQL queries. Salesforce allows 100 max. 💥 Crashes.

✅ **Bulkified approach (what we built):**
```apex
// Collect all IDs first
for (Application__c app : Trigger.new) {
    studentIds.add(app.Student__c);
    jobIds.add(app.Job__c);
}

// Query once for everything
Map<Id, Student__c> studentMap = new Map<Id, Student__c>([...WHERE Id IN :studentIds]);
Map<Id, Job__c> jobMap = new Map<Id, Job__c>([...WHERE Id IN :jobIds]);

// Then loop and use the Map (no SOQL here)
for (Application__c app : Trigger.new) {
    Student__c s = studentMap.get(app.Student__c);  // instant Map lookup, not a query
}
```
For 200 records → 2 SOQL queries. Always. ✅

### Key Concepts from This Trigger

| Concept | Where it's used |
|---|---|
| `before insert` | Runs before the record saves (can block it) |
| `Trigger.new` | List of records being inserted |
| `Set<Id>` | Collecting unique IDs without duplicates |
| `Map<Id, SObject>` | Fast lookup by record ID |
| `addError()` | Blocks the save and shows user-facing message |
| Bulkification | No SOQL inside loops — ever |

### Testing the Trigger

**Test 1 - Should pass:**
1. App Launcher → Applications → New
2. Student: Rahul (CGPA 9), Job: Microsoft (min 8)
3. Click Save → Record created ✅

**Test 2 - Should be blocked:**
1. App Launcher → Applications → New
2. Student: Kiran (CGPA 7), Job: Microsoft (min 8)
3. Click Save → Error message appears ❌

**Verify with SOQL:**
```sql
SELECT Name, Student__r.Name, Job__r.Name, Status__c
FROM Application__c
```
Only the valid application should appear.

### What `before insert` vs `after insert` means

- **before insert** — Record exists in memory but NOT yet saved to the database.
  - Can modify field values
  - Can call `addError()` to block the save
  - Cannot use the record's Id (it doesn't have one yet)

- **after insert** — Record is now saved. Has an Id.
  - Cannot block the save
  - Good for creating related records or sending notifications

For validation, always use `before insert`.

---

**Status**: ✅ PlacementService + ApplicationTrigger completed!
**Tests**: 1/1 passing
**Deployment**: Succeeded
**Trigger tested**: CGPA validation working correctly
