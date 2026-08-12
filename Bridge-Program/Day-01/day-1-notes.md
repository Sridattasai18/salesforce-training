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

## What's Next?

Next step in Day 1 is creating an **ApplicationTrigger** that automatically validates applications. For example: students with CGPA < job minimum shouldn't be able to apply.

That's where triggers come in - code that runs automatically when records are inserted/updated/deleted.

---

**Status**: ✅ PlacementService completed and tested!  
**Test Results**: 1/1 tests passed (100%)  
**Code Coverage**: Service class methods covered  
