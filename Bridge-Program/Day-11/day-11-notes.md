# Day 11 Notes – Talking to the Outside World

## What We're Building Today

Remember how all our code so far has stayed inside Salesforce? Today we're breaking out! We're going to teach Salesforce how to talk to external systems. When a student gets selected for a job, we'll automatically notify an external recruitment system.

Think of it like this: your Salesforce is making a phone call to another system. 📞

## REST APIs - The Basics

REST is just a fancy way of saying "websites talking to each other". You've actually used REST APIs before without knowing it - every time you use a mobile app that fetches data from a server, that's a REST API in action.

**The Main Actions (HTTP Methods):**
- **GET** - "Hey, give me some data" (like viewing a webpage)
- **POST** - "Here's new data, save it" (like submitting a form)
- **PUT** - "Update this existing data"
- **DELETE** - "Remove this data"

**Response Codes (What the server tells you back):**
- **200 OK** - "Got it, everything worked!"
- **201 Created** - "Done! I created the new thing you asked for"
- **400 Bad Request** - "Umm, your request doesn't make sense"
- **404 Not Found** - "Can't find what you're looking for"
- **500 Server Error** - "Oops, something broke on my end"

## Making HTTP Calls from Salesforce

Salesforce has built-in classes to make HTTP requests. It's actually pretty straightforward:

```apex
// Step 1: Create a request
HttpRequest req = new HttpRequest();
req.setEndpoint('https://api.example.com/resource');
req.setMethod('POST');
req.setHeader('Content-Type', 'application/json');
req.setBody('{"name": "John Doe"}');

// Step 2: Send it
Http http = new Http();
HttpResponse res = http.send(req);

// Step 3: Check what came back
Integer statusCode = res.getStatusCode();  // 200, 404, etc.
String body = res.getBody();  // The actual response data
```

**Important Limits to Know:**
- You can make 100 HTTP calls per transaction (that's actually a lot!)
- Each call can take up to 120 seconds max
- Request/response size limit: 12 MB (huge!)

Don't worry about hitting these limits - they're pretty generous for most use cases.

## Named Credentials - Your Secret Weapon

Here's the deal: you should NEVER hardcode API URLs or passwords in your code. Ever. That's like writing your bank password on a sticky note.

Instead, Salesforce has Named Credentials - a secure place to store all that sensitive stuff.

**Without Named Credentials (BAD):**
```apex
req.setEndpoint('https://api.example.com');
req.setHeader('Authorization', 'Bearer abc123secrettoken');  // 😱 NO!
```

**With Named Credentials (GOOD):**
```apex
req.setEndpoint('callout:My_API/resource');  // 👍 Salesforce handles auth automatically
```

**Why this is awesome:**
1. No secrets in your code
2. Easy to change URLs without touching code
3. Different credentials for sandbox vs production (no code changes!)
4. Salesforce handles authentication for you
5. Works with OAuth, JWT, Basic Auth, whatever you need

## Queueable Apex - Why We Need It

Here's a problem: triggers can't make HTTP calls directly. Why? Because HTTP calls take time, and we don't want to make users wait while staring at a loading screen.

Solution: **Queueable Apex** - it's like saying "hey Salesforce, run this later in the background".

```apex
public class MyBackgroundJob implements Queueable, Database.AllowsCallouts {
    public void execute(QueueableContext context) {
        // Do your HTTP callout here
        // User isn't waiting - this runs in the background
    }
}

// Start the background job
System.enqueueJob(new MyBackgroundJob());
```

**Why Queueable instead of @future?**
- Can pass actual objects (not just primitive types)
- Better monitoring - you can see it in Setup → Apex Jobs
- Can chain jobs together if needed
- More flexible overall

I used @future before and honestly, Queueable is just... better. Trust me.

## The Trigger Handler Pattern

You know how putting business logic directly in triggers is messy? Yeah, we learned that lesson. Here's the clean way:

**The Messy Way (Don't do this):**
```apex
trigger ApplicationTrigger on Application__c (after update) {
    // 100 lines of business logic here... 😢
}
```

**The Clean Way (Do this):**
```apex
trigger ApplicationTrigger on Application__c (after update) {
    ApplicationTriggerHandler.handleAfterUpdate(Trigger.new, Trigger.oldMap);
}
```

Now all your logic lives in a regular Apex class that you can test, debug, and maintain easily. The trigger is just a tiny entry point.

## How Everything Fits Together Today

Here's the flow we built:

```
1. User changes Application Status to "Selected"
   ↓
2. Trigger fires (ApplicationTrigger)
   ↓
3. Handler checks what changed (ApplicationTriggerHandler)
   ↓
4. Starts background job (CandidateSyncJob)
   ↓
5. Makes the actual API call (ExternalPlacementService)
   ↓
6. Logs what happened (Integration_Log__c)
```

**Why this many layers?**
Each piece has ONE job:
- **Trigger** → Just fires, no logic
- **Handler** → Figures out what changed
- **Queueable** → Enables background + HTTP calls
- **Service** → Does the actual work
- **Logger** → Saves everything for debugging

It seems like overkill, but trust me - when something breaks at 2 AM, you'll be glad everything is separated and logged.

## Working with JSON in Apex

JSON is just a way to structure data that both systems can understand. Think of it like a common language.

**Turning Apex into JSON (Serialization):**
```apex
Map<String, Object> data = new Map<String, Object>();
data.put('name', 'John Doe');
data.put('email', 'john@example.com');

String jsonString = JSON.serialize(data);
// Result: {"name":"John Doe","email":"john@example.com"}
```

**Turning JSON into Apex (Deserialization):**
```apex
String jsonString = '{"id":1,"status":"success"}';
Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(jsonString);

Integer id = (Integer) result.get('id');  // Gets 1
```

Pro tip: For complex JSON, create a matching Apex class and use typed deserialization. Way cleaner!

## Integration_Log__c - Our Safety Net

This is arguably the most important part. Every single time we talk to an external system, we log it. Why?

1. **Debugging** - When something breaks, you need to see what happened
2. **Proof** - "Did we send that data?" → Check the logs
3. **Monitoring** - How many calls succeeded today? Failed?
4. **Compliance** - Some industries require audit trails

**Fields we track:**
- **Related_Record_Id__c** - Which Application triggered this?
- **Integration_Type__c** - What kind of integration? ("Candidate Sync")
- **Request_Body__c** - Exactly what we sent
- **Response_Body__c** - Exactly what they sent back
- **Status_Code__c** - 200, 404, 500, etc.
- **Success__c** - Did it work? (checkbox for quick filtering)
- **Error_Message__c** - If it failed, why?
- **Timestamp__c** - When did this happen?

**Quick queries you'll use:**
```apex
// Show me all failed integrations from today
SELECT Id, Error_Message__c, Timestamp__c
FROM Integration_Log__c
WHERE Success__c = false AND CreatedDate = TODAY

// Show me everything for this application
SELECT Id, Status_Code__c, Success__c, Timestamp__c
FROM Integration_Log__c
WHERE Related_Record_Id__c = 'a00xxxxxxx'
ORDER BY Timestamp__c DESC
```

## The Objects We're Using (From Previous Days)

We're not creating new objects - we're reusing what we built earlier:

**Application__c** (from Day 5-6)
- Links a Student to a Job they applied for
- Has a Status__c field: Applied, Interview Scheduled, **Selected**, Rejected
- When Status changes to "Selected", our integration fires

**Student__c** (from Day 5)
- Student records with Name, Email, Department, CGPA
- We send the student's name and email to the external system

**Job__c** (from Day 5)
- Job postings with Title, Company, Minimum CGPA, Salary
- We send the job title and company to the external system

**How they connect:**
```
Application__c.Student__c → Student__c
Application__c.Job__c → Job__c
```

So we can query like this:
```apex
SELECT Id, Student__r.Name, Student__r.Email__c, Job__r.Name
FROM Application__c
WHERE Id = 'xxx'
```

The `__r` means "relationship" - we're jumping from Application to the related Student/Job records.

## Important Limits to Remember

Don't panic about these - they're pretty generous:

| What | Limit | Reality Check |
|------|-------|---------------|
| HTTP callouts per transaction | 100 | That's a LOT |
| Timeout per callout | 120 seconds | Most APIs respond in 1-2 seconds |
| Total timeout per transaction | 120 seconds | Just don't make 100 slow calls |
| Request/Response size | 12 MB each | Huge! You'd have to try to hit this |

**How to avoid problems:**
- Use Queueable/Batch for lots of callouts
- Bundle multiple records into one API call when possible
- Don't make callouts in loops (we designed around this)

## Security - Actually Important Stuff

**Rule #1: Never Hardcode Credentials**
```apex
// 🚫 NEVER DO THIS
req.setHeader('Authorization', 'Bearer secrettoken123');

// ✅ DO THIS
req.setEndpoint('callout:My_Named_Credential');
```

**Rule #2: Always Use HTTPS**
No exceptions. HTTP sends data in plain text. Would you email your password in plain text? Same thing.

**Rule #3: Respect Field-Level Security**
```apex
// Add this to your queries
SELECT Id, Name FROM Student__c WITH SECURITY_ENFORCED
```

**Rule #4: Be Careful What You Log**
Don't log sensitive stuff like credit cards or SSNs in Integration_Log__c. If you must, mask it first.

## Common Patterns You'll Use

### Simple POST Request
```apex
HttpRequest req = new HttpRequest();
req.setEndpoint('callout:My_API/resource');
req.setMethod('POST');
req.setHeader('Content-Type', 'application/json');
req.setBody(JSON.serialize(myData));

Http http = new Http();
HttpResponse res = http.send(req);
```

### GET with Query Parameters
```apex
String searchTerm = 'software engineer';
String encoded = EncodingUtil.urlEncode(searchTerm, 'UTF-8');
req.setEndpoint('callout:My_API/search?q=' + encoded);
req.setMethod('GET');
```

Always encode query parameters! Otherwise spaces and special characters will break your URL.

## Testing Your Integration

**The Quick Way (Anonymous Apex):**
```apex
// Get an application
Application__c app = [
    SELECT Id, Status__c 
    FROM Application__c 
    WHERE Status__c != 'Selected'
    LIMIT 1
];

// Update to Selected
app.Status__c = 'Selected';
update app;

// Wait a few seconds, then check the logs
List<Integration_Log__c> logs = [
    SELECT Success__c, Status_Code__c, Request_Body__c
    FROM Integration_Log__c
    WHERE Related_Record_Id__c = :app.Id
    ORDER BY CreatedDate DESC
    LIMIT 1
];

System.debug(logs);
```

**What to Check:**
1. **Debug Logs** - Setup → Debug Logs (set Callout level to FINEST)
2. **Apex Jobs** - Setup → Apex Jobs (see your queued job)
3. **Integration Logs** - Query Integration_Log__c records

## Debugging When Things Go Wrong

**"Unauthorized endpoint" error:**
- Your Named Credential isn't set up
- Go to Setup → Named Credentials and check it exists
- URL should be: https://jsonplaceholder.typicode.com

**"Read timed out" error:**
- The API is slow or down
- Add: `req.setTimeout(30000);` for a 30-second timeout

**Integration Log not created:**
- Check field-level security on Integration_Log__c
- Look for DML errors in debug logs
- Make sure request/response text isn't over 131,072 characters

**Job not running:**
- Check Setup → Apex Jobs
- Look for errors there
- You can only queue 50 jobs per transaction (you won't hit this)

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

## Real-World Examples (Where You'll Use This)

**Payment Processing (Stripe, PayPal)**
- Send payment details from Salesforce
- Create charges, refunds, subscriptions
- Log all transactions for accounting

**SMS/Email (Twilio, SendGrid)**
- Send notifications to students
- "You've been selected for an interview!"
- Track delivery status

**Document Generation (DocuSign)**
- Send offer letters for e-signature
- Track who signed what and when
- Store signed docs back in Salesforce

**ERP Systems (SAP, Oracle)**
- Sync employee data
- Update inventory levels
- Push order information

**Data Warehouses (Snowflake, BigQuery)**
- Send reporting data
- Nightly bulk exports
- Analytics and BI integration

The pattern is always the same - it's what we built today, just with different APIs.

## Interview Questions (What They'll Ask)

**Q: Why use Queueable instead of @future?**
A: Queueable lets you pass complex objects (not just primitives), has better monitoring in Apex Jobs, and you can chain jobs if needed. Plus it's just more modern.

**Q: What's a Named Credential?**
A: It's where you store API URLs and credentials securely. Instead of hardcoding "https://api.example.com" and tokens in your code, you reference it as "callout:My_API". Salesforce handles authentication for you.

**Q: Why log every integration?**
A: Debugging, compliance, proving data was sent, tracking success rates, and finding patterns in failures. When something breaks in production, logs save your life.

**Q: What if the API is down?**
A: Current code logs the error. In production, add retry logic (try 3 times with increasing delays), then alert someone. Maybe queue it for manual retry later.

**Q: How do you test Apex that makes callouts?**
A: Use Test.setMock() with HttpCalloutMock to fake responses. You can't make real HTTP calls in test methods (Salesforce blocks it).

## What I Actually Learned Today

- How to make HTTP calls from Salesforce (it's easier than I thought!)
- Named Credentials are brilliant (no more hardcoded secrets!)
- Queueable Apex for background processing
- Why we separate trigger → handler → service (it seems excessive until something breaks)
- Integration logging is non-negotiable (you'll thank yourself later)
- JSON serialization/deserialization in Apex
- How to debug callouts (debug logs are your friend)

## Key Takeaways (The Important Bits)

1. **Never hardcode credentials** - Use Named Credentials
2. **Always log integrations** - Future you will thank current you
3. **Use Queueable for callouts** - Triggers can't make HTTP calls directly
4. **Separate your concerns** - Trigger stays tiny, business logic goes in services
5. **Handle errors gracefully** - Try-catch + logging
6. **Think async** - Don't make users wait for external APIs

## What's Next?

In a real project, you'd add:
- **Retry logic** - Auto-retry failed calls
- **Monitoring dashboards** - Charts showing success rates
- **Platform Events** - For high-volume real-time scenarios
- **Bidirectional sync** - External system calling back into Salesforce
- **OAuth** - Replace anonymous auth with real security

But what we built today is solid. It's production-ready for many scenarios, logs everything, and follows best practices. Not bad for Day 11!

