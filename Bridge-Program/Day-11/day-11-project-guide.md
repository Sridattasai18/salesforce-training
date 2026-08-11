# Day 11 Project Guide – Real-Time External System Integration

## 🎯 Goal
Build a production-grade Salesforce integration that automatically syncs selected candidates to an external recruitment system when their Application status changes to "Selected".

## 🏗️ Architecture Overview

### End-to-End Flow
```
Application Status Updated to "Selected"
    ↓
[Trigger Layer] ApplicationTrigger.trigger
    ↓
[Handler Layer] ApplicationTriggerHandler.cls
    ↓
[Async Layer] CandidateSyncJob.cls (Queueable)
    ↓
[Service Layer] ExternalPlacementService.cls
    ↓
[Named Credential] Recruitment_API
    ↓
[External API] JSONPlaceholder REST API
    ↓
[Logging Layer] Integration_Log__c record
```

## 📦 Components Built

### 1. ApplicationTrigger.trigger
**Purpose:** Entry point for Application__c record updates  
**Responsibility:** Detect after update events and delegate to handler  
**Lines of Code:** 5

```apex
trigger ApplicationTrigger on Application__c (after update) {
    if (Trigger.isAfter && Trigger.isUpdate) {
        ApplicationTriggerHandler.handleAfterUpdate(Trigger.new, Trigger.oldMap);
    }
}
```

**Why After Update?**
- We need the record to be fully saved before syncing
- Need access to both old and new values to detect changes
- Avoids recursion issues from before update logic

### 2. ApplicationTriggerHandler.cls
**Purpose:** Orchestrate trigger logic without business logic  
**Responsibility:** Detect status changes and enqueue async job  
**Pattern:** Trigger Handler Pattern  
**Lines of Code:** 19

**Key Logic:**
```apex
// Compare old vs new Status__c value
if (oldApp.Status__c != 'Selected' && app.Status__c == 'Selected') {
    selectedAppIds.add(app.Id);
}

// Only enqueue if there are selected applications
if (!selectedAppIds.isEmpty()) {
    System.enqueueJob(new CandidateSyncJob(selectedAppIds));
}
```

**Why This Pattern?**
- ✅ Testable (pure Apex class)
- ✅ No business logic in trigger
- ✅ Reusable across multiple triggers if needed
- ✅ Easier debugging with debug logs
- ✅ Follows Salesforce best practices

### 3. CandidateSyncJob.cls
**Purpose:** Enable asynchronous processing with HTTP callouts  
**Implements:** `Queueable, Database.AllowsCallouts`  
**Responsibility:** Bridge between trigger context and callout context  
**Lines of Code:** 12

```apex
public class CandidateSyncJob implements Queueable, Database.AllowsCallouts {
    private List<Id> applicationIds;
    
    public CandidateSyncJob(List<Id> applicationIds) {
        this.applicationIds = applicationIds;
    }
    
    public void execute(QueueableContext context) {
        ExternalPlacementService.syncSelectedCandidates(applicationIds);
    }
}
```

**Why Queueable?**
- ✅ Can make HTTP callouts (triggers cannot directly)
- ✅ Can pass complex data types (List<Id>)
- ✅ Better monitoring via Apex Jobs
- ✅ Can chain other queueable jobs
- ✅ Doesn't block user transaction

**Why Not @future?**
- ❌ @future only accepts primitives (would need to serialize/deserialize)
- ❌ No chaining capability
- ❌ Harder to monitor
- ❌ Less flexible

### 4. ExternalPlacementService.cls
**Purpose:** Core integration logic with external API  
**Responsibility:** Query data, build payload, make callout, log results  
**Pattern:** Service Layer Pattern  
**Lines of Code:** 72

**Key Features:**
1. **Query with Relationships**
```apex
List<Application__c> applications = [
    SELECT Id, Name, Status__c, 
           Student__c, Student__r.Name, Student__r.Email__c,
           Job__c, Job__r.Name, Job__r.Company__c
    FROM Application__c
    WHERE Id IN :applicationIds
    WITH SECURITY_ENFORCED
];
```

2. **Build JSON Payload**
```apex
Map<String, Object> payload = new Map<String, Object>();
payload.put('candidateName', app.Student__r.Name);
payload.put('email', app.Student__r.Email__c);
payload.put('jobTitle', app.Job__r.Name);
payload.put('company', app.Job__r.Company__c);
payload.put('applicationId', app.Id);
payload.put('status', app.Status__c);

String requestBody = JSON.serialize(payload);
```

3. **Make HTTP Callout**
```apex
HttpRequest req = new HttpRequest();
req.setEndpoint('callout:Recruitment_API/posts');
req.setMethod('POST');
req.setHeader('Content-Type', 'application/json');
req.setBody(requestBody);

Http http = new Http();
HttpResponse res = http.send(req);
```

4. **Log Every Integration**
```apex
logIntegration(
    app.Id, 
    requestBody, 
    res.getBody(), 
    res.getStatusCode(), 
    res.getStatusCode() >= 200 && res.getStatusCode() < 300, 
    null
);
```

5. **Error Handling**
```apex
try {
    // Make callout
} catch (Exception e) {
    // Log failure
    logIntegration(app.Id, null, null, 500, false, e.getMessage());
}
```

**Why Service Layer?**
- ✅ All business logic in one testable class
- ✅ Reusable from multiple entry points (trigger, batch, manual)
- ✅ Clear separation of concerns
- ✅ Easy to mock for testing

### 5. Integration_Log__c Custom Object
**Purpose:** Audit trail and debugging support  
**Fields:** 8 custom fields

| Field | Type | Purpose |
|-------|------|---------|
| Related_Record_Id__c | Text(18) | Link back to Application__c |
| Integration_Type__c | Text(255) | Categorize integrations (e.g., "Candidate Sync") |
| Request_Body__c | Long Text Area(131,072) | Complete JSON sent to API |
| Response_Body__c | Long Text Area(131,072) | Complete JSON received from API |
| Status_Code__c | Number(3,0) | HTTP status code (200, 404, 500, etc.) |
| Success__c | Checkbox | Quick filter for success/failure |
| Error_Message__c | Long Text Area(131,072) | Exception details if failed |
| Timestamp__c | Date/Time | When integration occurred |

**Query Examples:**
```apex
// All failed integrations today
SELECT Id, Related_Record_Id__c, Error_Message__c, Timestamp__c
FROM Integration_Log__c
WHERE Success__c = false 
  AND Timestamp__c = TODAY

// Last 10 integrations for an application
SELECT Id, Status_Code__c, Success__c, Timestamp__c
FROM Integration_Log__c
WHERE Related_Record_Id__c = :applicationId
ORDER BY Timestamp__c DESC
LIMIT 10

// Success rate calculation
SELECT COUNT(Id) total, 
       SUM(CASE WHEN Success__c THEN 1 ELSE 0 END) successful
FROM Integration_Log__c
WHERE CreatedDate = LAST_N_DAYS:7
```

### 6. Named Credential: Recruitment_API
**Purpose:** Centralized credential management  
**Configuration:**
- Label: Recruitment API
- Name: Recruitment_API
- URL: https://jsonplaceholder.typicode.com
- Authentication: Anonymous (for demo)

**Benefits:**
- ✅ No hardcoded URLs in code
- ✅ Easy environment switching (Sandbox → Production)
- ✅ Centralized credential management
- ✅ Salesforce handles authentication automatically
- ✅ Supports OAuth, JWT, Basic Auth, etc.

**Usage in Code:**
```apex
// Instead of hardcoding:
req.setEndpoint('https://jsonplaceholder.typicode.com/posts');

// Use Named Credential:
req.setEndpoint('callout:Recruitment_API/posts');
```

**Production Setup:**
For real APIs, configure:
1. Authentication Protocol (OAuth 2.0, JWT, etc.)
2. Client ID/Secret
3. Token Endpoint
4. Scopes
5. Identity Type

## 🧠 Design Decisions

### 1. Why Trigger → Handler → Queueable → Service?
**Trigger** - Entry point only, no logic  
**Handler** - Detect changes, orchestrate  
**Queueable** - Enable async + callouts  
**Service** - Business logic + HTTP calls

**Alternative Considered:** Put everything in trigger  
**Why Rejected:** Not testable, violates separation of concerns, hard to debug

### 2. Why Log Every Integration?
**Benefits:**
- Debugging failed callouts
- Compliance and audit requirements
- Performance monitoring
- Error pattern analysis
- Proof of data transmission

**Cost:** Additional DML operation  
**Decision:** Worth it for production visibility

### 3. Why Individual Callouts (Not Bulk)?
**Current Implementation:** One HTTP callout per application

**Alternative:** Batch multiple applications in single callout  
**Trade-off:**
- Current: Simple, failure isolated to one record
- Batch: More efficient, but complex error handling

**Decision:** Start simple, optimize later if needed

### 4. Why JSONPlaceholder for Demo?
- Free public API
- No authentication required
- Accepts POST requests
- Returns realistic responses
- Perfect for learning/testing

**Production:** Replace with real recruitment API

## 🔄 Data Flow (Step-by-Step)

### Scenario: User Updates Application Status

**Step 1: User Action**
```
User navigates to Application record
Changes Status__c from "Interview Scheduled" to "Selected"
Clicks Save
```

**Step 2: Trigger Fires**
```
ApplicationTrigger (after update) executes
Calls ApplicationTriggerHandler.handleAfterUpdate()
Passes: Trigger.new (List<Application__c>)
Passes: Trigger.oldMap (Map<Id, Application__c>)
```

**Step 3: Handler Detects Change**
```apex
for (Application__c app : newList) {
    Application__c oldApp = oldMap.get(app.Id);
    
    // OLD: "Interview Scheduled" → NEW: "Selected"
    if (oldApp.Status__c != 'Selected' && app.Status__c == 'Selected') {
        selectedAppIds.add(app.Id);  // Add to list
    }
}
```

**Step 4: Queueable Job Enqueued**
```apex
if (!selectedAppIds.isEmpty()) {
    System.enqueueJob(new CandidateSyncJob(selectedAppIds));
}
```

User sees success message, page refreshes  
Job ID: 707xx000000XXXX (visible in Apex Jobs)

**Step 5: Queueable Executes (Async)**
```apex
public void execute(QueueableContext context) {
    ExternalPlacementService.syncSelectedCandidates(applicationIds);
}
```

**Step 6: Service Queries Data**
```sql
SELECT Id, Name, Status__c, 
       Student__r.Name, Student__r.Email__c,
       Job__r.Name, Job__r.Company__c
FROM Application__c
WHERE Id IN ('a00xx000001XXXX')
```

**Step 7: Build JSON Payload**
```json
{
    "candidateName": "John Doe",
    "email": "john.doe@example.com",
    "jobTitle": "Software Engineer",
    "company": "Tech Corp",
    "applicationId": "a00xx000001XXXX",
    "status": "Selected"
}
```

**Step 8: Make HTTP Callout**
```http
POST https://jsonplaceholder.typicode.com/posts
Content-Type: application/json

{JSON payload from step 7}
```

**Step 9: Receive Response**
```json
{
    "id": 101,
    "candidateName": "John Doe",
    "email": "john.doe@example.com",
    ...
}
```

HTTP Status: 201 Created

**Step 10: Log Integration**
```apex
Integration_Log__c log = new Integration_Log__c();
log.Related_Record_Id__c = 'a00xx000001XXXX';
log.Integration_Type__c = 'Candidate Sync';
log.Request_Body__c = '{JSON sent}';
log.Response_Body__c = '{JSON received}';
log.Status_Code__c = 201;
log.Success__c = true;
log.Timestamp__c = 2024-08-11 15:30:45;
insert log;
```

**Step 11: Complete**
Job status changes to "Completed" in Apex Jobs  
Integration_Log__c record available for review

## 🧪 Testing Strategy

### 1. Manual Testing (Anonymous Apex)
```apex
// Step 1: Query an application
Application__c app = [
    SELECT Id, Status__c 
    FROM Application__c 
    WHERE Status__c != 'Selected'
    LIMIT 1
];

System.debug('Application ID: ' + app.Id);
System.debug('Current Status: ' + app.Status__c);

// Step 2: Update to Selected
app.Status__c = 'Selected';
update app;

System.debug('Status updated to Selected');

// Step 3: Wait 5-10 seconds for async processing

// Step 4: Check Apex Jobs
// Setup → Apex Jobs → Sort by Time

// Step 5: Query Integration Logs
List<Integration_Log__c> logs = [
    SELECT Id, Related_Record_Id__c, Integration_Type__c,
           Status_Code__c, Success__c, Timestamp__c,
           Request_Body__c, Response_Body__c, Error_Message__c
    FROM Integration_Log__c
    WHERE Related_Record_Id__c = :app.Id
    ORDER BY Timestamp__c DESC
    LIMIT 1
];

if (!logs.isEmpty()) {
    Integration_Log__c log = logs[0];
    System.debug('=== INTEGRATION LOG ===');
    System.debug('Success: ' + log.Success__c);
    System.debug('Status Code: ' + log.Status_Code__c);
    System.debug('Request: ' + log.Request_Body__c);
    System.debug('Response: ' + log.Response_Body__c);
    if (!log.Success__c) {
        System.debug('Error: ' + log.Error_Message__c);
    }
} else {
    System.debug('No integration log found yet. Wait a bit longer.');
}
```

### 2. Debug Log Review
**Enable Debug Logs:**
1. Setup → Debug Logs
2. Click "New"
3. Select your user
4. Set "Callout" level to "FINEST"
5. Save

**Look for:**
```
CALLOUT_REQUEST
External endpoint: https://jsonplaceholder.typicode.com/posts
Method: POST
Headers: Content-Type=application/json
Body: {"candidateName":"John Doe",...}

CALLOUT_RESPONSE
Status: 201
Body: {"id":101,"candidateName":"John Doe",...}
```

### 3. Apex Test Class (Future Enhancement)
```apex
@isTest
public class ExternalPlacementServiceTest {
    
    // Mock HTTP callout
    private class MockHttpResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(201);
            res.setBody('{"id":101,"status":"success"}');
            return res;
        }
    }
    
    @isTest
    static void testSuccessfulSync() {
        // Create test data
        Student__c student = new Student__c(Name='Test Student', Email__c='test@example.com');
        insert student;
        
        Job__c job = new Job__c(Name='Test Job', Company__c='Test Co');
        insert job;
        
        Application__c app = new Application__c(
            Student__c = student.Id,
            Job__c = job.Id,
            Status__c = 'Applied'
        );
        insert app;
        
        // Set mock callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        
        // Update to Selected
        Test.startTest();
        app.Status__c = 'Selected';
        update app;
        Test.stopTest();
        
        // Verify log created
        Integration_Log__c log = [
            SELECT Id, Success__c, Status_Code__c 
            FROM Integration_Log__c 
            WHERE Related_Record_Id__c = :app.Id
            LIMIT 1
        ];
        
        System.assertEquals(true, log.Success__c);
        System.assertEquals(201, log.Status_Code__c);
    }
}
```

## 🚀 Deployment Guide

### Prerequisites
- Salesforce CLI installed
- Authenticated to target org
- Application__c, Student__c, Job__c objects exist (from Days 5-10)

### Deployment Steps

**1. Deploy Custom Object**
```cmd
sf project deploy start --metadata CustomObject:Integration_Log__c
```

**2. Deploy Named Credential**
```cmd
sf project deploy start --metadata NamedCredential:Recruitment_API
```

**3. Deploy Apex Classes**
```cmd
sf project deploy start --metadata ApexClass:ApplicationTriggerHandler
sf project deploy start --metadata ApexClass:CandidateSyncJob
sf project deploy start --metadata ApexClass:ExternalPlacementService
```

**4. Deploy Trigger**
```cmd
sf project deploy start --metadata ApexTrigger:ApplicationTrigger
```

**5. Verify Deployment**
```cmd
sf project deploy report --target-org [alias]
```

**6. Run Tests (if test classes exist)**
```cmd
sf apex run test --test-level RunLocalTests --result-format human
```

### Deployment Verification
- [ ] Integration_Log__c appears in Object Manager
- [ ] All 8 fields exist on Integration_Log__c
- [ ] Recruitment_API appears in Named Credentials
- [ ] All 4 Apex classes appear in Setup → Apex Classes
- [ ] ApplicationTrigger appears in Setup → Apex Triggers
- [ ] No deployment errors in logs

## 🐛 Debugging Common Issues

### Issue 1: "ENTITY_IS_DELETED: entity is deleted"
**Cause:** Application__c, Student__c, or Job__c record was deleted  
**Solution:**
```apex
// Add null checks
if (app.Student__c == null || app.Job__c == null) {
    continue; // Skip this application
}
```

### Issue 2: "Unauthorized endpoint, please check Setup->Security->Remote site settings"
**Cause:** Named Credential not set up correctly  
**Solution:**
1. Setup → Named Credentials
2. Verify "Recruitment_API" exists
3. Check URL: https://jsonplaceholder.typicode.com
4. No trailing slash in URL

### Issue 3: "System.CalloutException: Read timed out"
**Cause:** External API took too long to respond  
**Solution:**
```apex
req.setTimeout(30000); // 30 seconds (default is 10)
```

### Issue 4: Integration Log not created
**Cause:** Exception in logIntegration() method  
**Debug:**
1. Check Debug Logs for DML errors
2. Verify field lengths (request/response < 131,072 chars)
3. Check field-level security permissions

### Issue 5: Queueable job not executing
**Cause:** Too many jobs in queue or governor limits hit  
**Check:**
1. Setup → Apex Jobs → Look for job status
2. System → Limits → Queueable Apex
3. Debug logs for "ENQUEUE" events

## 📊 Monitoring Production Integration

### 1. Create Report: Integration Success Rate
```
Object: Integration_Log__c
Fields: 
- Created Date (group by day)
- Record Count
- Success__c = TRUE (count)
- Success__c = FALSE (count)
Chart: Line chart showing success vs failure over time
```

### 2. Create Dashboard: Integration Health
Widgets:
- Total integrations today
- Success rate (%)
- Failed integrations list
- Average response time (parse Response_Body__c)

### 3. Set Up Email Alerts
```
Process Builder or Flow:
WHEN: Integration_Log__c created
CONDITION: Success__c = FALSE
ACTION: Send email to admin with Error_Message__c
```

### 4. Scheduled Apex: Retry Failed Integrations
```apex
global class RetryFailedIntegrationsScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        List<Integration_Log__c> failed = [
            SELECT Related_Record_Id__c
            FROM Integration_Log__c
            WHERE Success__c = false
              AND CreatedDate = LAST_N_DAYS:1
            LIMIT 100
        ];
        
        Set<Id> appIds = new Set<Id>();
        for (Integration_Log__c log : failed) {
            appIds.add((Id)log.Related_Record_Id__c);
        }
        
        if (!appIds.isEmpty()) {
            System.enqueueJob(new CandidateSyncJob(new List<Id>(appIds)));
        }
    }
}

// Schedule to run every hour
System.schedule('Retry Failed Integrations', '0 0 * * * ?', new RetryFailedIntegrationsScheduler());
```

## 🏆 Production Best Practices

### 1. Security
- ✅ Use OAuth 2.0 for real APIs (not Anonymous)
- ✅ Store credentials in Named Credentials only
- ✅ Never hardcode API keys in code
- ✅ Use field-level security on Integration_Log__c
- ✅ Limit who can see request/response bodies

### 2. Scalability
- ✅ Current design is bulk-safe (processes multiple records)
- ✅ Consider Platform Events for high-volume scenarios
- ✅ Implement batch processing if > 100 records/transaction
- ✅ Use caching for repetitive API calls

### 3. Reliability
- ✅ Log every integration attempt
- ✅ Implement retry logic with exponential backoff
- ✅ Set up monitoring and alerting
- ✅ Have a manual retry mechanism

### 4. Performance
- ✅ Use @ReadOnly annotation for read-heavy operations
- ✅ Minimize SOQL queries (one query for all applications)
- ✅ Avoid callouts in loops (current design is good)
- ✅ Monitor API response times

### 5. Maintainability
- ✅ Clear separation of concerns (Trigger → Handler → Service)
- ✅ Comprehensive comments in code
- ✅ Detailed logging for debugging
- ✅ Version control (Git)
- ✅ Documentation (this guide!)

## 📚 Key Takeaways

1. **Asynchronous is Essential** - HTTP callouts must be async (Queueable, Future, or Batch)
2. **Named Credentials are Non-Negotiable** - Never hardcode URLs or credentials
3. **Logging is Critical** - Integration_Log__c enables debugging and auditing
4. **Trigger Handler Pattern** - Separates concerns, improves testability
5. **Error Handling Matters** - Try-catch + logging ensures no silent failures
6. **Production Thinking** - Design for monitoring, retry, and failure recovery

## 🔗 Related Documentation

- Day 5: Apex fundamentals
- Day 6: Trigger Handler pattern
- Day 8: Queueable Apex
- Day 9-10: LWC components that create Application__c records
- Salesforce Docs: [HTTP Callouts](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_classes_restful_http.htm)
- Salesforce Docs: [Named Credentials](https://help.salesforce.com/s/articleView?id=sf.named_credentials_about.htm)

## ✅ Completion Checklist

- [x] ApplicationTrigger created and deployed
- [x] ApplicationTriggerHandler created and deployed
- [x] CandidateSyncJob created and deployed
- [x] ExternalPlacementService created and deployed
- [x] Integration_Log__c object with 8 fields created
- [x] Recruitment_API Named Credential configured
- [x] Manual testing completed successfully
- [x] Debug logs reviewed
- [x] Integration logs verified
- [x] Documentation complete (day-11-notes.md, README.md, this guide)
- [x] Code committed to Git
- [x] Code pushed to remote repository

## 🚀 Next Steps (Day 12 Ideas)

1. **Bidirectional Sync** - External API calls Salesforce via webhook
2. **Platform Events** - Real-time event-driven architecture
3. **Retry Logic** - Exponential backoff for failed integrations
4. **Circuit Breaker** - Stop calling failing APIs
5. **Admin UI** - LWC component to view/retry integrations
6. **Batch Sync** - Nightly batch job to sync all selected candidates
7. **Middleware Simulation** - Mulesoft/Boomi integration patterns
8. **OAuth Implementation** - Replace Anonymous auth with OAuth 2.0

---

**Congratulations! You've built a production-grade external system integration! 🎉**
