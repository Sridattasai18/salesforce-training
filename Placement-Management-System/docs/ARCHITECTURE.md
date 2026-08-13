# Placement Management System — Architecture

## Overview

The Placement Management System follows enterprise-grade Salesforce development patterns with clear separation of concerns, bulk-safe processing, and maintainable code structure.

## Architectural Principles

### 1. Separation of Concerns
Each layer has a single responsibility:
- **Triggers** — Entry points only (3 lines max)
- **Handlers** — Route events to appropriate service methods
- **Services** — Contain all business logic
- **Models** — Custom objects define data structure

### 2. Bulkification
All code handles multiple records efficiently:
- No SOQL/DML in loops
- Collections used for batch processing
- Governor limit conscious

### 3. Reusability
Service methods can be called from:
- Triggers
- Controllers (Apex)
- Lightning Web Components
- Batch/Scheduled jobs
- REST APIs

### 4. Testability
Business logic isolated in service classes:
- Easy to unit test
- Mock data support
- Independent of trigger context

## Layers

### Layer 1: Data Model (Custom Objects)

```
┌─────────────┐       ┌──────────────┐       ┌─────────┐
│  Student__c │       │ Application  │       │ Job__c  │
│             │◄──────│     __c      │──────►│         │
│ - Name      │  1:N  │              │  N:1  │ - Name  │
│ - CGPA__c   │       │ - Student__c │       │ - Min   │
│ - Email__c  │       │ - Job__c     │       │   CGPA  │
└─────────────┘       │ - Status__c  │       └─────────┘
                      └──────────────┘
```

**Design Decisions:**
- Lookup relationships for flexibility (not Master-Detail)
- Picklist fields for controlled values
- Indexed fields for common queries

### Layer 2: Trigger Layer

```apex
trigger ApplicationTrigger on Application__c (before insert) {
    ApplicationTriggerHandler.beforeInsert(Trigger.new);
}
```

**Responsibilities:**
- Define trigger events (before insert, after update, etc.)
- Pass control to handler immediately
- No business logic

**Why thin triggers?**
- Easier to test
- Prevents recursion issues
- Clear execution flow
- Easy to disable/enable logic

### Layer 3: Handler Layer

```apex
public with sharing class ApplicationTriggerHandler {
    
    public static void beforeInsert(List<Application__c> applications) {
        ApplicationService.validateApplications(applications);
    }
    
    // Future methods for other events:
    // public static void afterUpdate(List<Application__c> newList, Map<Id, Application__c> oldMap) {
    //     ApplicationService.sendNotifications(newList, oldMap);
    // }
}
```

**Responsibilities:**
- Route trigger events to service methods
- Conditional logic for when to call services
- Context variables management (Trigger.new, Trigger.old, etc.)

**Pattern Benefits:**
- One handler per object
- Easy to add new trigger events
- Clear method naming (matches trigger events)
- Static methods for easy invocation

### Layer 4: Service Layer

```apex
public with sharing class ApplicationService {
    
    // Main validation logic
    public static void validateApplications(List<Application__c> applications) {
        // 1. Collect IDs
        Set<Id> studentIds = new Set<Id>();
        Set<Id> jobIds = new Set<Id>();
        
        // 2. Query once
        Map<Id, Student__c> students = new Map<Id, Student__c>([...]);
        Map<Id, Job__c> jobs = new Map<Id, Job__c>([...]);
        
        // 3. Check existing records
        Set<String> existingPairs = new Set<String>();
        
        // 4. Validate in loop (no queries)
        for (Application__c app : applications) {
            // Validation logic
        }
    }
}
```

**Responsibilities:**
- All business logic
- SOQL queries (bulkified)
- DML operations (bulkified)
- Complex calculations
- Integration callouts

**Bulkification Strategy:**

```
Input: List<Application__c> applications (could be 1 or 10,000)

Step 1: Collect IDs
┌─────────────────────────┐
│ Set<Id> studentIds      │ ← Unique student IDs
│ Set<Id> jobIds          │ ← Unique job IDs
└─────────────────────────┘

Step 2: Query Once Per Object
┌─────────────────────────┐
│ Map<Id, Student__c>     │ ← Query 1: All students
│ Map<Id, Job__c>         │ ← Query 2: All jobs
│ Set<String> existing    │ ← Query 3: Existing apps
└─────────────────────────┘

Step 3: Process in Loop (No SOQL)
┌─────────────────────────┐
│ for (app : applications)│
│   student = map.get()   │ ← Instant lookup
│   job = map.get()       │ ← Instant lookup
│   validate()            │ ← Pure logic, no queries
└─────────────────────────┘

Result: 3 SOQL queries total (not 3 × N)
```

### Layer 5: Utility Services

```apex
public with sharing class PlacementService {
    
    // Reusable query methods
    public static List<Student__c> getEligibleStudents(Decimal minimumCGPA) {
        return [SELECT Id, Name, CGPA__c FROM Student__c WHERE CGPA__c >= :minimumCGPA];
    }
    
    // Helper methods
    public static Application__c createApplication(Id studentId, Id jobId) {
        // Factory method for creating applications
    }
}
```

**Responsibilities:**
- Reusable query methods
- Common utility functions
- Factory methods for object creation

## Data Flow

### Scenario: Student Submits Application

```
┌──────────────┐
│ UI (LWC/VF)  │ User clicks "Apply"
└──────┬───────┘
       │
       ▼
┌──────────────────────────┐
│ Controller (Apex)        │ Calls ApplicationService.submitApplication()
└──────┬───────────────────┘
       │
       ▼
┌──────────────────────────┐
│ ApplicationService       │ Creates Application__c record
└──────┬───────────────────┘
       │ DML insert
       ▼
┌──────────────────────────┐
│ ApplicationTrigger       │ before insert event fires
└──────┬───────────────────┘
       │
       ▼
┌──────────────────────────┐
│ ApplicationTriggerHandler│ Routes to beforeInsert()
└──────┬───────────────────┘
       │
       ▼
┌──────────────────────────┐
│ ApplicationService       │ validateApplications()
│ - Check CGPA             │ - Query student & job
│ - Check duplicate        │ - Validate eligibility
│ - addError() if fails    │ - Throw exception if needed
└──────┬───────────────────┘
       │
       ▼
┌──────────────┐
│ Result       │ Success or Error
└──────────────┘
```

## Design Patterns Used

### 1. Trigger Handler Pattern

**Problem:** Triggers with all logic become unmaintainable

**Solution:** Separate trigger from logic
```
Trigger → Handler → Service
```

**Benefits:**
- Easy to test
- Reusable logic
- Clear structure
- Easy to extend

### 2. Service Layer Pattern

**Problem:** Business logic scattered across codebase

**Solution:** Centralize in service classes
```
ApplicationService - Application-specific logic
PlacementService   - General placement utilities
```

**Benefits:**
- Single source of truth
- Reusable from anywhere
- Easy to maintain
- Clear API

### 3. Bulkification Pattern

**Problem:** Code breaks with multiple records

**Solution:** Process collections, not single records
```apex
// Bad
for (Application__c app : applications) {
    Student__c s = [SELECT CGPA__c FROM Student__c WHERE Id = :app.Student__c]; // Query in loop!
}

// Good
Set<Id> studentIds = new Set<Id>();
for (Application__c app : applications) {
    studentIds.add(app.Student__c);
}
Map<Id, Student__c> students = new Map<Id, Student__c>(
    [SELECT Id, CGPA__c FROM Student__c WHERE Id IN :studentIds]
); // One query
```

**Benefits:**
- Governor limit compliant
- Handles bulk operations
- Production-ready

### 4. Exception Handling Pattern

**Problem:** Generic error messages, hard to debug

**Solution:** Custom exceptions with clear messages
```apex
public class ApplicationException extends Exception {}

throw new ApplicationException('Student does not meet the minimum CGPA requirement.');
```

**Benefits:**
- User-friendly errors
- Catchable in controllers
- Clear error tracking

## Governor Limits Strategy

### SOQL Queries (Limit: 100 per transaction)

| Method | Queries | Strategy |
|--------|---------|----------|
| validateApplications() | 3 | Bulkified - queries once per object type |
| submitApplication() | 3 | Single record, acceptable |
| getEligibleStudents() | 1 | Direct query with filter |

**Total for typical transaction:** 3-6 queries (well under limit)

### DML Statements (Limit: 150 per transaction)

| Method | DML Ops | Strategy |
|--------|---------|----------|
| validateApplications() | 0 | Validation only, no DML |
| submitApplication() | 1 | Single insert |
| createApplication() | 1 | Single insert |

**Batch DML:** When creating multiple applications, use `insert applications;` (one DML for all records)

### Heap Size (Limit: 6 MB)

**Strategy:**
- Use Maps for lookups (memory efficient)
- Avoid loading unnecessary fields in SOQL
- Process in batches if needed

## Security Model

### Sharing Rules

All classes use `with sharing`:
```apex
public with sharing class ApplicationService {
    // Respects record-level security
}
```

**Why?**
- Enforces user's access rights
- Prevents unauthorized data access
- Complies with security requirements

### Field-Level Security

SOQL queries respect FLS automatically:
```apex
// Returns only fields user can see
SELECT Id, Name, CGPA__c FROM Student__c WITH SECURITY_ENFORCED
```

## Testing Strategy

### Unit Tests

**Service Layer Tests:**
```apex
@isTest
private class ApplicationServiceTest {
    
    @isTest
    static void testValidateApplications_ValidCGPA() {
        // Setup: Student with CGPA 9.0, Job requires 8.0
        // Act: Create application
        // Assert: No errors
    }
    
    @isTest
    static void testValidateApplications_InvalidCGPA() {
        // Setup: Student with CGPA 7.0, Job requires 8.0
        // Act: Try to create application
        // Assert: Error thrown
    }
    
    @isTest
    static void testValidateApplications_Duplicate() {
        // Setup: Application already exists
        // Act: Try to create duplicate
        // Assert: Error thrown
    }
    
    @isTest
    static void testBulkProcessing() {
        // Setup: 200 applications
        // Act: Insert all
        // Assert: All validated correctly
    }
}
```

### Integration Tests

Test complete flow:
1. Create student
2. Create job
3. Submit application via controller
4. Verify trigger + service + validation

## Scalability Considerations

### Current Capacity

- **Records per transaction:** 10,000 (Salesforce limit)
- **SOQL queries:** 3 (3% of limit)
- **DML operations:** 1-2 (1% of limit)

### Future Enhancements

For large-scale operations:
1. **Batch Apex** — Process millions of records overnight
2. **Queueable Apex** — Chain multiple operations
3. **Platform Events** — Asynchronous processing
4. **@future methods** — Offload heavy operations

## Extension Points

### Adding New Validations

Add to `ApplicationService.validateApplications()`:
```apex
// New validation: Check backlog count
if (student.Active_Backlogs__c > job.Allowed_Backlogs__c) {
    app.addError('Student has too many active backlogs.');
}
```

### Adding New Trigger Events

Add method to handler:
```apex
public static void afterUpdate(List<Application__c> newList, Map<Id, Application__c> oldMap) {
    ApplicationService.sendStatusChangeNotification(newList, oldMap);
}
```

Update trigger:
```apex
trigger ApplicationTrigger on Application__c (before insert, after update) {
    if (Trigger.isBefore && Trigger.isInsert) {
        ApplicationTriggerHandler.beforeInsert(Trigger.new);
    }
    if (Trigger.isAfter && Trigger.isUpdate) {
        ApplicationTriggerHandler.afterUpdate(Trigger.new, Trigger.oldMap);
    }
}
```

### Adding New Services

Create new service class:
```apex
public with sharing class NotificationService {
    public static void sendEmail(List<Application__c> applications) {
        // Email logic
    }
}
```

Call from handler or another service.

## Best Practices Followed

✅ One trigger per object  
✅ Thin triggers (3 lines max)  
✅ Handler pattern for routing  
✅ Service layer for business logic  
✅ Bulkified code (no SOQL in loops)  
✅ `with sharing` for security  
✅ Custom exceptions for errors  
✅ Clear naming conventions  
✅ Documentation in code  
✅ Governor limit conscious  

## Anti-Patterns Avoided

❌ Fat triggers with all logic  
❌ SOQL/DML in loops  
❌ Hard-coded IDs  
❌ Mixing concerns in one class  
❌ Ignoring bulk operations  
❌ `without sharing` unless necessary  
❌ Generic exceptions  
❌ Magic numbers  

---

**Version:** 1.0  
**Last Updated:** 2024  
**Status:** Production Architecture ✅
