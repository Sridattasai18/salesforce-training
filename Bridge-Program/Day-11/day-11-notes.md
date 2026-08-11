# Day 11 Notes – REST APIs, Callouts, and External Integration

## Core Concepts

### 1. REST API Fundamentals

**What is REST?**
- REpresentational State Transfer
- Architectural style for web services
- Uses HTTP methods (GET, POST, PUT, DELETE)
- Stateless communication
- Resource-based (URLs represent resources)

**HTTP Methods:**
- **GET** - Retrieve data
- **POST** - Create new resource
- **PUT** - Update existing resource
- **DELETE** - Remove resource
- **PATCH** - Partial update

**HTTP Status Codes:**
- **2xx** - Success (200 OK, 201 Created)
- **3xx** - Redirection
- **4xx** - Client Error (400 Bad Request, 404 Not Found)
- **5xx** - Server Error (500 Internal Server Error)

### 2. Salesforce HTTP Callouts

**HttpRequest Class**
```apex
HttpRequest req = new HttpRequest();
req.setEndpoint('https://api.example.com/resource');
req.setMethod('POST');
req.setHeader('Content-Type', 'application/json');
req.setBody('{"key": "value"}');
```

**HttpResponse Class**
```apex
Http http = new Http();
HttpResponse res = http.send(req);

Integer statusCode = res.getStatusCode();
String body = res.getBody();
```

**Governor Limits:**
- 100 HTTP callouts per transaction
- 120 seconds total timeout
- 12MB max request size
- 12MB max response size

### 3. Named Credentials

**Benefits:**
- Centralized credential storage
- No hardcoded URLs or API keys
- Environment-independent code
- Automatic credential injection
- Easy sandbox → production migration

**Usage:**
```apex
// Instead of:
req.setEndpoint('https://api.example.com/posts');

// Use:
req.setEndpoint('callout:Named_Credential/posts');
```

**Authentication Types:**
- OAuth 2.0
- Basic Authentication
- JWT
- AWS Signature v4
- Custom (via Apex)

### 4. Queueable Apex

**Purpose:**
- Run long-running operations asynchronously
- Make HTTP callouts outside user transaction
- Process large data volumes
- Avoid blocking UI

**Implementation:**
```apex
public class MyJob implements Queueable, Database.AllowsCallouts {
    public void execute(QueueableContext context) {
        // Your async logic + callouts
    }
}

// Enqueue:
System.enqueueJob(new MyJob());
```

**Key Features:**
- Monitoring via Apex Jobs
- Can chain other queueable jobs (50 max)
- Passes complex data types (objects, lists)
- Better than @future methods

**Governor Limits:**
- 50 queueable jobs per transaction
- Same Apex limits as synchronous (but separate context)
- Can make callouts (unlike regular Apex)

### 5. Trigger Handler Pattern

**Bad Practice:**
```apex
trigger ApplicationTrigger on Application__c (after update) {
    // Business logic directly in trigger
    for (Application__c app : Trigger.new) {
        // 50 lines of code...
    }
}
```

**Good Practice:**
```apex
trigger ApplicationTrigger on Application__c (after update) {
    ApplicationTriggerHandler.handleAfterUpdate(Trigger.new, Trigger.oldMap);
}
```

**Benefits:**
- Testable (pure Apex class)
- Reusable logic
- Easier debugging
- Cleaner code organization
- Avoids "logic-ful triggers"

### 6. Integration Patterns

**Fire and Forget:**
- Send request, don't wait for response
- Use for non-critical updates
- Logged for auditing

**Request-Response:**
- Send request, process response
- Validate data returned
- Handle errors immediately

**Batch Integration:**
- Collect multiple records
- Send in single API call
- More efficient than record-by-record

**Event-Driven:**
- External system calls Salesforce
- Platform Events for real-time sync
- Webhook endpoints

### 7. Error Handling Strategies

**Try-Catch Pattern:**
```apex
try {
    HttpResponse res = http.send(req);
    // Process response
} catch (CalloutException e) {
    // Log error
    System.debug('Callout failed: ' + e.getMessage());
}
```

**Logging:**
- Store request/response for debugging
- Track success/failure rates
- Enable support team to investigate

**Retry Logic:**
- Exponential backoff
- Maximum retry attempts
- Dead letter queue for permanent failures

**Circuit Breaker:**
- Stop calling failing API
- Return cached data or error
- Periodically test if API recovered

## Day 11 Architecture Breakdown

### Flow Diagram
```
User updates Application Status to "Selected"
  ↓
[Trigger Layer] ApplicationTrigger fires
  ↓
[Handler Layer] ApplicationTriggerHandler detects change
  ↓
[Async Layer] CandidateSyncJob enqueued
  ↓
[Service Layer] ExternalPlacementService queries data
  ↓
[Integration Layer] HTTP POST to Named Credential
  ↓
[External API] JSONPlaceholder receives data
  ↓
[Logging Layer] Integration_Log__c created
```

### Separation of Concerns

**Trigger** - Entry point only
**Handler** - Orchestration, no logic
**Queueable** - Enable async + callouts
**Service** - Business logic + HTTP calls
**Logger** - Persistence layer

### Why This Architecture?

1. **Testability** - Each layer tested independently
2. **Maintainability** - Clear responsibilities
3. **Scalability** - Async processing avoids timeouts
4. **Reliability** - Logging enables debugging
5. **Security** - Named Credentials protect secrets

## JSON in Apex

### Serialization
```apex
Map<String, Object> data = new Map<String, Object>();
data.put('name', 'John Doe');
data.put('email', 'john@example.com');

String jsonString = JSON.serialize(data);
// Result: {"name":"John Doe","email":"john@example.com"}
```

### Deserialization
```apex
String jsonString = '{"id":1,"status":"success"}';
Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(jsonString);

Integer id = (Integer) result.get('id');
```

### Typed Deserialization
```apex
public class ApiResponse {
    public Integer id;
    public String status;
}

ApiResponse response = (ApiResponse) JSON.deserialize(jsonString, ApiResponse.class);
```

## Integration_Log__c Design

**Purpose:**
- Audit trail of all integrations
- Debugging failed callouts
- Performance monitoring
- Compliance requirements

**Fields:**
- **Related_Record_Id__c** - Links back to Application
- **Integration_Type__c** - Categorize integrations
- **Request_Body__c** - What we sent
- **Response_Body__c** - What we received
- **Status_Code__c** - HTTP status
- **Success__c** - Quick filter
- **Error_Message__c** - Exception details
- **Timestamp__c** - When it occurred

**Usage:**
```apex
Integration_Log__c log = new Integration_Log__c();
log.Related_Record_Id__c = applicationId;
log.Success__c = true;
log.Status_Code__c = 200;
log.Request_Body__c = jsonRequest;
log.Response_Body__c = jsonResponse;
insert log;
```

## Platform Objects Used (From Previous Days)

### Application__c (Created in Day 5-6)
**Purpose:** Junction object between Student and Job  
**Key Fields:**
- Student__c (Lookup to Student__c)
- Job__c (Lookup to Job__c)
- Status__c (Picklist: Applied, Interview Scheduled, Selected, Rejected)
- Applied_Date__c (Date)

**Used in Day 11:**
- Trigger fires on Status__c change to "Selected"
- Queried with Student__r and Job__r relationships
- Linked to Integration_Log__c via Related_Record_Id__c

### Student__c (Created in Day 5)
**Purpose:** Student records for placement system  
**Key Fields:**
- Name (Text)
- Email__c (Email)
- Department__c (Text)
- CGPA__c (Number)

**Used in Day 11:**
- Student name and email sent to external API
- Accessed via Application__c.Student__r relationship

### Job__c (Created in Day 5)
**Purpose:** Job posting records  
**Key Fields:**
- Name (Text) - Job title
- Company__c (Text)
- Minimum_CGPA__c (Number)
- Salary__c (Currency)

**Used in Day 11:**
- Job title and company sent to external API
- Accessed via Application__c.Job__r relationship

## Object Relationship Diagram

```
Student__c
    ↓ (Lookup)
Application__c ←→ Integration_Log__c (via Related_Record_Id__c)
    ↓ (Lookup)
Job__c
```

**Query Pattern:**
```apex
SELECT Id, Name, Status__c,
       Student__c, Student__r.Name, Student__r.Email__c,
       Job__c, Job__r.Name, Job__r.Company__c
FROM Application__c
WHERE Id IN :applicationIds
```

**Note:** Company_Integration__c mentioned in the original requirements is NOT used in this implementation. The current design uses Integration_Log__c to track all integration attempts, which serves the same purpose without requiring per-company configuration. In a real enterprise scenario, Company_Integration__c could be used to store API endpoints per recruiting company, but for this learning project, we use a single Named Credential (Recruitment_API) instead.

## Governor Limits (Callouts)

| Limit | Value |
|-------|-------|
| HTTP callouts per transaction | 100 |
| Total timeout per transaction | 120 seconds |
| Individual callout timeout | 120 seconds (default 10s) |
| Max request size | 12 MB |
| Max response size | 12 MB |
| Max long-running request time | 120 seconds |

**Avoiding Limits:**
- Use Queueable/Batch for bulk operations
- Combine multiple operations in single callout
- Use Platform Events for high-volume scenarios
- Implement async patterns

## Security Best Practices

### 1. Never Hardcode Credentials
```apex
// ❌ BAD
req.setEndpoint('https://api.example.com');
req.setHeader('Authorization', 'Bearer abc123token');

// ✅ GOOD
req.setEndpoint('callout:API_Credential');
// Salesforce injects auth automatically
```

### 2. Use HTTPS Only
- Always use encrypted connections
- Verify SSL certificates
- Never send sensitive data over HTTP

### 3. Validate Response Data
```apex
if (res.getStatusCode() == 200) {
    // Parse and validate JSON
    // Don't trust external data
}
```

### 4. Field-Level Security
- Restrict access to Integration_Log__c
- Sensitive data in Request/Response bodies
- Use profiles/permission sets

### 5. Rate Limiting
- Respect API quotas
- Implement throttling
- Cache responses when possible

## Common Callout Patterns

### 1. Simple POST
```apex
HttpRequest req = new HttpRequest();
req.setEndpoint('callout:My_API/resource');
req.setMethod('POST');
req.setHeader('Content-Type', 'application/json');
req.setBody(JSON.serialize(data));

Http http = new Http();
HttpResponse res = http.send(req);
```

### 2. GET with Query Parameters
```apex
String endpoint = 'callout:My_API/search?q=' + EncodingUtil.urlEncode(searchTerm, 'UTF-8');
req.setEndpoint(endpoint);
req.setMethod('GET');
```

### 3. With Bearer Token (via Named Credential)
```apex
// Named Credential handles OAuth automatically
req.setEndpoint('callout:OAuth_API/data');
req.setMethod('GET');
```

### 4. Form-Encoded POST
```apex
String body = 'param1=value1&param2=value2';
req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
req.setBody(body);
```

## Debugging Callouts

### Enable Debug Logs
1. Setup → Debug Logs
2. Add user
3. Set Callout level to FINEST

### Check Logs For:
```
20:13:45.123 CALLOUT_REQUEST
External endpoint: https://jsonplaceholder.typicode.com/posts
Method: POST
Headers: Content-Type=application/json
Body: {"candidateName":"John Doe"...}

20:13:45.789 CALLOUT_RESPONSE
Status: 201
Body: {"id":101,"candidateName":"John Doe"...}
```

### Query Integration Logs
```apex
List<Integration_Log__c> failed = [
    SELECT Id, Related_Record_Id__c, Error_Message__c, Timestamp__c
    FROM Integration_Log__c
    WHERE Success__c = false
    ORDER BY Timestamp__c DESC
];
```

## Testing Callouts

### Mock HTTP Responses
```apex
@isTest
public class ExternalPlacementServiceTest {
    
    @isTest
    static void testSuccessfulSync() {
        // Setup test data
        Application__c app = TestDataFactory.createApplication();
        
        // Set mock
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        // Execute
        Test.startTest();
        ExternalPlacementService.syncSelectedCandidates(new List<Id>{app.Id});
        Test.stopTest();
        
        // Verify log created
        Integration_Log__c log = [SELECT Success__c, Status_Code__c FROM Integration_Log__c LIMIT 1];
        System.assertEquals(true, log.Success__c);
        System.assertEquals(200, log.Status_Code__c);
    }
}
```

### Mock Class
```apex
public class MockHttpResponseGenerator implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setBody('{"id":1,"status":"success"}');
        return res;
    }
}
```

## Real-World Applications

1. **Payment Processing** - Send payment to Stripe/PayPal
2. **SMS Notifications** - Twilio integration
3. **Email Services** - SendGrid/Mailchimp
4. **ERP Integration** - Sync with SAP/Oracle
5. **HR Systems** - Workday/BambooHR sync
6. **Marketing Automation** - HubSpot/Marketo
7. **Data Warehouses** - Snowflake/BigQuery

## Interview Questions & Answers

**Q: What's the difference between @future and Queueable?**
A: Queueable allows complex types, chaining, better monitoring, and explicit context.

**Q: How do you handle API authentication in Salesforce?**
A: Use Named Credentials with OAuth 2.0, Basic Auth, or JWT depending on the API requirements.

**Q: What happens if an HTTP callout times out?**
A: A CalloutException is thrown. We catch it, log the error, and optionally retry.

**Q: How do you test Apex that makes callouts?**
A: Use Test.setMock() with HttpCalloutMock interface to simulate responses.

**Q: Why log integration attempts?**
A: For debugging, compliance, auditing, performance monitoring, and error analysis.

**Q: What's a Named Credential?**
A: A Salesforce feature that stores endpoint URLs and authentication credentials securely, referenced in code via `callout:` syntax.

**Q: How do you make Apex calls asynchronous?**
A: Use @future, Queueable Apex, Batch Apex, or Scheduled Apex depending on requirements.

**Q: What's the trigger handler pattern?**
A: Separating trigger logic into a handler class for testability, maintainability, and avoiding "logic-ful triggers".

## Real-World Integration Examples

### 1. Payment Processing (Stripe)
```apex
// Create a payment
Map<String, Object> payload = new Map<String, Object>{
    'amount' => 5000,  // $50.00
    'currency' => 'usd',
    'source' => cardToken,
    'description' => 'Student placement fee'
};

HttpRequest req = new HttpRequest();
req.setEndpoint('callout:Stripe_API/v1/charges');
req.setMethod('POST');
req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
req.setBody(buildFormEncodedBody(payload));

HttpResponse res = http.send(req);
```

### 2. SMS Notifications (Twilio)
```apex
// Send SMS
Map<String, String> params = new Map<String, String>{
    'To' => studentPhone,
    'From' => twilioPhone,
    'Body' => 'Congratulations! You have been selected for ' + jobTitle
};

HttpRequest req = new HttpRequest();
req.setEndpoint('callout:Twilio_API/2010-04-01/Accounts/{AccountSid}/Messages.json');
req.setMethod('POST');
req.setBody(buildFormEncodedBody(params));
```

### 3. Document Generation (DocuSign)
```apex
// Send document for signature
Map<String, Object> envelope = new Map<String, Object>{
    'emailSubject' => 'Please sign your offer letter',
    'documents' => new List<Object>{ documentData },
    'recipients' => new Map<String, Object>{ 'signers' => signerList },
    'status' => 'sent'
};

HttpRequest req = new HttpRequest();
req.setEndpoint('callout:DocuSign_API/v2/accounts/{accountId}/envelopes');
req.setMethod('POST');
req.setHeader('Content-Type', 'application/json');
req.setBody(JSON.serialize(envelope));
```

### 4. Data Warehouse Sync (Snowflake)
```apex
// Bulk load data to warehouse
List<Map<String, Object>> records = new List<Map<String, Object>>();
for (Application__c app : applications) {
    records.add(new Map<String, Object>{
        'student_id' => app.Student__c,
        'job_id' => app.Job__c,
        'status' => app.Status__c,
        'applied_date' => app.CreatedDate
    });
}

HttpRequest req = new HttpRequest();
req.setEndpoint('callout:Snowflake_API/api/v2/statements');
req.setMethod('POST');
req.setBody(JSON.serialize(new Map<String, Object>{
    'statement' => 'INSERT INTO applications VALUES (?)',
    'bindings' => records
}));
```

## Advanced Error Handling

### Retry with Exponential Backoff
```apex
public class RetryableCallout {
    private static final Integer MAX_RETRIES = 3;
    private static final Integer BASE_DELAY = 1000; // 1 second
    
    public static HttpResponse makeCalloutWithRetry(HttpRequest req) {
        Integer attempt = 0;
        
        while (attempt < MAX_RETRIES) {
            try {
                Http http = new Http();
                HttpResponse res = http.send(req);
                
                // Success - return response
                if (res.getStatusCode() >= 200 && res.getStatusCode() < 300) {
                    return res;
                }
                
                // Server error - retry
                if (res.getStatusCode() >= 500) {
                    attempt++;
                    if (attempt < MAX_RETRIES) {
                        // Exponential backoff: 1s, 2s, 4s
                        Integer delay = BASE_DELAY * (Integer)Math.pow(2, attempt - 1);
                        // Note: Apex doesn't have Thread.sleep(), 
                        // In production, use Queueable chaining with delay
                    }
                    continue;
                }
                
                // Client error - don't retry
                return res;
                
            } catch (Exception e) {
                attempt++;
                if (attempt >= MAX_RETRIES) {
                    throw e;
                }
            }
        }
        
        return null;
    }
}
```

### Circuit Breaker Pattern
```apex
public class CircuitBreaker {
    private static Integer failureCount = 0;
    private static final Integer FAILURE_THRESHOLD = 5;
    private static DateTime lastFailureTime;
    private static final Integer COOLDOWN_MINUTES = 5;
    
    public static Boolean isOpen() {
        // If threshold exceeded recently, circuit is open
        if (failureCount >= FAILURE_THRESHOLD) {
            if (lastFailureTime != null && 
                lastFailureTime.addMinutes(COOLDOWN_MINUTES) > System.now()) {
                return true; // Circuit open - don't make call
            } else {
                // Cooldown period passed - reset
                failureCount = 0;
                return false;
            }
        }
        return false;
    }
    
    public static void recordSuccess() {
        failureCount = 0;
    }
    
    public static void recordFailure() {
        failureCount++;
        lastFailureTime = System.now();
    }
}

// Usage:
if (CircuitBreaker.isOpen()) {
    System.debug('Circuit breaker open - skipping API call');
    return;
}

try {
    HttpResponse res = http.send(req);
    if (res.getStatusCode() >= 200 && res.getStatusCode() < 300) {
        CircuitBreaker.recordSuccess();
    } else {
        CircuitBreaker.recordFailure();
    }
} catch (Exception e) {
    CircuitBreaker.recordFailure();
}
```

## Performance Optimization

### 1. Batch Multiple Records in Single Callout
```apex
// Instead of one callout per application
for (Application__c app : applications) {
    makeCallout(app); // BAD - uses all 100 callout limit quickly
}

// Batch them
List<Map<String, Object>> batch = new List<Map<String, Object>>();
for (Application__c app : applications) {
    batch.add(buildPayload(app));
    
    // Send in batches of 50
    if (batch.size() == 50) {
        sendBatch(batch);
        batch.clear();
    }
}
if (!batch.isEmpty()) {
    sendBatch(batch); // Send remaining
}
```

### 2. Caching Responses
```apex
public class ApiCache {
    private static Map<String, String> cache = new Map<String, String>();
    private static Map<String, DateTime> cacheExpiry = new Map<String, DateTime>();
    
    public static String get(String key) {
        if (cache.containsKey(key)) {
            DateTime expiry = cacheExpiry.get(key);
            if (expiry > System.now()) {
                return cache.get(key); // Return cached value
            } else {
                cache.remove(key); // Expired
                cacheExpiry.remove(key);
            }
        }
        return null;
    }
    
    public static void put(String key, String value, Integer ttlMinutes) {
        cache.put(key, value);
        cacheExpiry.put(key, System.now().addMinutes(ttlMinutes));
    }
}

// Usage:
String cacheKey = 'job_details_' + jobId;
String cachedResponse = ApiCache.get(cacheKey);

if (cachedResponse != null) {
    return cachedResponse; // Use cached data
}

// Make API call
HttpResponse res = http.send(req);
ApiCache.put(cacheKey, res.getBody(), 60); // Cache for 60 minutes
```

### 3. Parallel Processing with Platform Events
```apex
// Publisher (in trigger handler)
List<Candidate_Sync_Event__e> events = new List<Candidate_Sync_Event__e>();
for (Id appId : selectedAppIds) {
    events.add(new Candidate_Sync_Event__e(
        Application_Id__c = appId
    ));
}
EventBus.publish(events);

// Subscriber (separate trigger)
trigger CandidateSyncEventTrigger on Candidate_Sync_Event__e (after insert) {
    List<Id> appIds = new List<Id>();
    for (Candidate_Sync_Event__e event : Trigger.new) {
        appIds.add((Id)event.Application_Id__c);
    }
    System.enqueueJob(new CandidateSyncJob(appIds));
}
```

## Security Deep Dive

### 1. Field-Level Security
```apex
// Check FLS before querying
if (!Schema.sObjectType.Student__c.fields.Email__c.isAccessible()) {
    throw new SecurityException('No access to Email field');
}

// Use WITH SECURITY_ENFORCED
List<Application__c> apps = [
    SELECT Id, Student__r.Email__c 
    FROM Application__c 
    WITH SECURITY_ENFORCED
];
```

### 2. Named Credential with OAuth 2.0
```
Setup → Named Credentials → New
- Label: Production API
- URL: https://api.production.com
- Identity Type: Named Principal
- Authentication Protocol: OAuth 2.0
- Token Endpoint: https://api.production.com/oauth/token
- Client ID: [from API provider]
- Client Secret: [from API provider]
- Scope: read write
- Start Authentication Flow → Authorize
```

### 3. IP Whitelisting
```
Setup → Remote Site Settings → New
- Remote Site Name: ProductionAPI
- Remote Site URL: https://api.production.com
- Disable Protocol Security: Unchecked (always use HTTPS)

Setup → Network Access → New
- IP Address: [API provider's IP range]
```

### 4. Protecting Sensitive Data in Logs
```apex
private static void logIntegration(String request, String response) {
    // Mask sensitive fields
    request = maskSensitiveData(request);
    response = maskSensitiveData(response);
    
    Integration_Log__c log = new Integration_Log__c();
    log.Request_Body__c = request;
    log.Response_Body__c = response;
    insert log;
}

private static String maskSensitiveData(String data) {
    // Mask credit card numbers
    data = data.replaceAll('\\d{4}[\\s-]?\\d{4}[\\s-]?\\d{4}[\\s-]?\\d{4}', '****-****-****-####');
    
    // Mask email addresses
    data = data.replaceAll('[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}', '***@***.***');
    
    // Mask SSN
    data = data.replaceAll('\\d{3}-\\d{2}-\\d{4}', '***-**-####');
    
    return data;
}
```

## Production Monitoring Dashboard

### Custom Metadata for Integration Endpoints
```apex
// Define Integration_Endpoint__mdt
Integration_Endpoint__mdt endpoint = [
    SELECT Endpoint_URL__c, Timeout__c, Retry_Count__c, Active__c
    FROM Integration_Endpoint__mdt
    WHERE DeveloperName = 'Recruitment_API'
];

if (!endpoint.Active__c) {
    System.debug('Endpoint is disabled');
    return;
}

req.setEndpoint(endpoint.Endpoint_URL__c);
req.setTimeout((Integer)endpoint.Timeout__c);
```

### Health Check Scheduled Job
```apex
global class IntegrationHealthCheck implements Schedulable {
    global void execute(SchedulableContext sc) {
        // Check last 24 hours
        AggregateResult[] stats = [
            SELECT COUNT(Id) total,
                   SUM(CASE WHEN Success__c = true THEN 1 ELSE 0 END) successful
            FROM Integration_Log__c
            WHERE CreatedDate = LAST_N_DAYS:1
        ];
        
        Integer total = (Integer)stats[0].get('total');
        Integer successful = (Integer)stats[0].get('successful');
        Decimal successRate = total > 0 ? (successful * 100.0 / total) : 100;
        
        // Alert if success rate drops below 95%
        if (successRate < 95) {
            // Send alert email
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[]{'admin@company.com'});
            mail.setSubject('Integration Health Alert: Success Rate ' + successRate + '%');
            mail.setPlainTextBody('Integration success rate dropped to ' + successRate + '%');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
        }
    }
}

// Schedule hourly
System.schedule('Integration Health Check', '0 0 * * * ?', new IntegrationHealthCheck());
```

## What I Learned Today

✅ REST API integration from Salesforce  
✅ Named Credentials for secure authentication  
✅ Queueable Apex for async callouts  
✅ Trigger Handler pattern for clean code  
✅ Integration logging for debugging  
✅ Error handling in distributed systems  
✅ JSON serialization/deserialization  
✅ Governor limits for callouts  
✅ Testing strategies for external integrations  
✅ Production-grade patterns: retry logic, circuit breaker, caching  
✅ Security best practices for external integrations  
✅ Monitoring and alerting for integration health  

## Key Takeaways

1. **Never hardcode** - Use Named Credentials
2. **Always log** - Integration_Log__c is critical
3. **Go async** - Queueable for callouts
4. **Separate concerns** - Trigger → Handler → Service
5. **Handle errors** - Try-catch + logging + retry logic
6. **Test with mocks** - HttpCalloutMock interface
7. **Think production** - Retry logic, monitoring, alerts, circuit breakers
8. **Secure everything** - OAuth, FLS, HTTPS only, mask sensitive data
9. **Optimize performance** - Batch records, cache responses, use Platform Events
10. **Monitor proactively** - Health checks, success rate tracking, alerting

