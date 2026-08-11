# Day 11 - Crossing the Salesforce Boundary (REST API Integration)

## Overview
Day 11 extends the Placement Management System by integrating with external recruitment systems. When an application status changes to "Selected", the system automatically syncs candidate data to an external API using enterprise-grade integration patterns.

## Business Flow
```
Application Status = 'Selected'
  ↓
ApplicationTrigger fires (after update)
  ↓
ApplicationTriggerHandler detects status change
  ↓
CandidateSyncJob enqueued (Queueable Apex)
  ↓
ExternalPlacementService makes HTTP callout
  ↓
Named Credential: Recruitment_API
  ↓
External REST API (JSONPlaceholder)
  ↓
Integration_Log__c record created
```

## Architecture

### Trigger Layer
**ApplicationTrigger.trigger**
- Fires on `after update` of Application__c
- Delegates all logic to handler
- Clean, minimal trigger pattern

### Handler Layer
**ApplicationTriggerHandler.cls**
- Detects Status__c change from any value → 'Selected'
- Collects affected Application IDs
- Enqueues asynchronous job (respects governor limits)
- No business logic - pure orchestration

### Queueable Layer
**CandidateSyncJob.cls**
- Implements `Queueable` interface
- Implements `Database.AllowsCallouts` for HTTP requests
- Executes asynchronously in separate context
- Calls service layer for actual integration

### Service Layer
**ExternalPlacementService.cls**
- Core integration logic
- Queries Application__c with Student__r and Job__r relationships
- Builds JSON payload for external API
- Makes HTTP POST callout via Named Credential
- Logs all integration attempts (success or failure)
- Handles errors gracefully

## Components

### 1. Custom Objects

**Integration_Log__c**
- Related_Record_Id__c (Text, 18) - Application ID
- Integration_Type__c (Text, 255) - "Candidate Sync"
- Request_Body__c (Long Text, 131072) - JSON sent to API
- Response_Body__c (Long Text, 131072) - JSON received from API
- Status_Code__c (Number) - HTTP status code
- Success__c (Checkbox) - Integration success flag
- Error_Message__c (Long Text, 131072) - Error details if failed
- Timestamp__c (DateTime) - When integration occurred

### 2. Named Credential

**Recruitment_API**
- Endpoint: https://jsonplaceholder.typicode.com
- Authentication: Anonymous (for demo)
- Protocol: NoAuthentication
- Used in callout: `callout:Recruitment_API/posts`

### 3. Apex Classes

**ApplicationTrigger** (4 lines)
```apex
trigger ApplicationTrigger on Application__c (after update) {
    if (Trigger.isAfter && Trigger.isUpdate) {
        ApplicationTriggerHandler.handleAfterUpdate(Trigger.new, Trigger.oldMap);
    }
}
```

**ApplicationTriggerHandler** (17 lines)
- Single public method: `handleAfterUpdate()`
- Loops through records once
- Compares old vs new Status__c value
- Enqueues job only if selectedAppIds is not empty

**CandidateSyncJob** (10 lines)
- Constructor accepts List<Id>
- Execute method calls service
- Simple pass-through to enable async + callouts

**ExternalPlacementService** (60 lines)
- `syncSelectedCandidates()` - public entry point
- Queries Application__c with relationships
- Loops through applications (bulk-safe)
- Builds payload per application
- Makes HTTP POST request
- Calls `logIntegration()` for each attempt
- `logIntegration()` - private helper method
- Truncates long text to avoid field length errors
- Inserts Integration_Log__c record

## Key Design Patterns

### 1. Trigger Handler Pattern
- Trigger contains no logic
- Handler is a pure Apex class (testable)
- Separation of concerns

### 2. Asynchronous Processing
- Queueable Apex for long-running operations
- Avoids blocking user transactions
- Respects governor limits

### 3. Named Credentials
- No hardcoded URLs in code
- Centralized credential management
- Easy environment switching (sandbox → production)

### 4. Integration Logging
- Every API call logged
- Request/response bodies stored
- Enables debugging and auditing
- Track success/failure rates

### 5. Error Handling
- Try-catch around each integration
- Failed integrations logged
- System continues even if one fails
- No data loss

## Testing the Integration

### Manual Test Steps
1. Query an existing Application__c record
2. Update Status__c to 'Selected'
3. Check Debug Logs for:
   - Trigger execution
   - Handler logic
   - Queueable job enqueued
4. Query Integration_Log__c records
5. Verify external API received request

### Anonymous Apex Test
```apex
// Get an application
Application__c app = [SELECT Id, Status__c FROM Application__c LIMIT 1];

// Update status to Selected
app.Status__c = 'Selected';
update app;

// Wait a moment for async processing
// Then query logs
List<Integration_Log__c> logs = [
    SELECT Id, Related_Record_Id__c, Success__c, Status_Code__c, 
           Request_Body__c, Response_Body__c, Timestamp__c
    FROM Integration_Log__c
    ORDER BY CreatedDate DESC
    LIMIT 5
];

for (Integration_Log__c log : logs) {
    System.debug('Log: ' + log);
    System.debug('Success: ' + log.Success__c);
    System.debug('Status: ' + log.Status_Code__c);
}
```

## Deployment

All components deployed to: `kaligotlasridattasai18@brave-unicorn-tpzhyl.com`

**Deployed Components:**
- ApplicationTrigger.trigger ✓
- ApplicationTriggerHandler.cls ✓
- CandidateSyncJob.cls ✓
- ExternalPlacementService.cls ✓
- Integration_Log__c (object + 8 fields) ✓
- Recruitment_API (Named Credential) ✓

## Integration with Days 1-10

**Reuses:**
- Application__c object (Day 5+)
- Student__c object (Day 5+)
- Job__c object (Day 5+)
- Existing Application records (Day 9-10)

**Extends:**
- Adds trigger to Application__c
- Adds external system integration
- Adds integration logging
- No changes to existing LWC components

## Production Considerations

### Security
- Use OAuth 2.0 for real APIs (not Anonymous)
- Store API keys in Named Credentials
- Never hardcode credentials in code
- Review field-level security on Integration_Log__c

### Scalability
- Current design is bulk-safe
- Consider Platform Events for higher volumes
- Implement retry logic for failed integrations
- Add rate limiting if API has quotas

### Monitoring
- Create reports on Integration_Log__c
- Set up email alerts for failed integrations
- Track success rate metrics
- Monitor API response times

### Error Recovery
- Implement exponential backoff retry
- Dead letter queue for permanently failed records
- Admin dashboard for manual retry
- Scheduled batch job to retry failed integrations

## Interview Questions

**Q: Why use Queueable instead of @future?**
A: Queueable provides:
- Better monitoring via Apex Jobs
- Chaining capability
- Can pass complex data types (not just primitives)
- More flexible than @future methods

**Q: Why create Integration_Log__c?**
A: 
- Auditing and compliance
- Debugging failed integrations
- Performance analytics
- Proof of data transmission
- Error analysis and pattern detection

**Q: What if the external API is down?**
A: Current implementation logs the error. Production solution:
- Retry logic (exponential backoff)
- Circuit breaker pattern
- Alert administrators
- Queue failed requests for later retry

**Q: How do you secure the Named Credential?**
A: 
- Use OAuth 2.0 authentication
- Rotate credentials regularly
- Limit permissions to specific users/profiles
- Use separate credentials per environment
- Enable callout restrictions

**Q: What's the governor limit on HTTP callouts?**
A: 
- 100 callouts per transaction
- 120 seconds total timeout per transaction
- 12MB max request/response size
- Design for batch processing if exceeding limits

## What I Learned (Day 11)

1. **REST API Integration** - Making HTTP callouts from Apex
2. **Named Credentials** - Secure credential management
3. **Queueable Apex** - Asynchronous processing with callouts
4. **Trigger Handler Pattern** - Separation of trigger logic
5. **Integration Logging** - Auditing external system interactions
6. **Error Handling** - Graceful failure in distributed systems
7. **Enterprise Patterns** - Production-grade integration architecture

## Next Steps (Day 12+)

- Implement retry logic for failed integrations
- Add Platform Events for real-time updates
- Build admin UI to view Integration_Log__c records
- Implement bidirectional sync (inbound webhooks)
- Add monitoring dashboards
- Implement circuit breaker pattern

