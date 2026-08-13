# API Reference - Placement Management System

Complete reference for all REST API endpoints and Apex controllers.

## Table of Contents
1. [REST API Endpoints](#rest-api-endpoints)
2. [Apex Controllers](#apex-controllers)
3. [Service Classes](#service-classes)
4. [Error Handling](#error-handling)
5. [Examples](#examples)

---

## REST API Endpoints

Base URL: `/services/apexrest/placement`

### Authentication
- Requires valid Salesforce session or OAuth token
- Uses Salesforce's built-in security model

### GET /placement/jobs

Returns all available job postings.

**Request:**
```http
GET /services/apexrest/placement/jobs HTTP/1.1
Authorization: Bearer <access_token>
```

**Response:**
```json
[
  {
    "attributes": {
      "type": "Job__c",
      "url": "/services/data/v61.0/sobjects/Job__c/a01..."
    },
    "Id": "a01...",
    "Name": "Salesforce Developer",
    "Company__c": "TechCorp",
    "Location__c": "Hyderabad",
    "Salary__c": 800000,
    "Status__c": "Open"
  }
]
```

**Status Codes:**
- `200` - Success

---

### GET /placement/students

Returns all student records.

**Request:**
```http
GET /services/apexrest/placement/students HTTP/1.1
Authorization: Bearer <access_token>
```

**Response:**
```json
[
  {
    "attributes": {
      "type": "Student__c",
      "url": "/services/data/v61.0/sobjects/Student__c/a00..."
    },
    "Id": "a00...",
    "Name": "Alice Kumar",
    "Department__c": "CSE",
    "CGPA__c": 8.5
  }
]
```

**Status Codes:**
- `200` - Success

---

### POST /placement/apply

Submits a job application.

**Request:**
```http
POST /services/apexrest/placement/apply HTTP/1.1
Authorization: Bearer <access_token>
Content-Type: application/json

{
  "studentId": "a00...",
  "jobId": "a01..."
}
```

**Response (Success):**
```json
{
  "status": "success",
  "applicationId": "a02..."
}
```

**Response (Error):**
```json
{
  "error": "CGPA does not meet minimum requirement"
}
```

**Status Codes:**
- `200` - Application created successfully
- `400` - Validation error
- `404` - Student or Job not found
- `500` - Server error

**Validation Rules:**
- Student CGPA must meet job minimum
- No duplicate applications allowed
- Job must be open
- Application date must be before closing date

---

## Apex Controllers

### PlacementDashboardController

Used by the placementDashboard LWC component.

#### Methods

**`getStatistics()`**
```apex
@AuraEnabled(cacheable=true)
public static Map<String, Integer> getStatistics()
```

Returns count of students, jobs, applications, and offers.

**Returns:**
```json
{
  "students": 15,
  "jobs": 8,
  "applications": 42,
  "offers": 12
}
```

---

### StudentPortalController

Used by the student portal LWC components.

#### Methods

**`getEligibleJobs(Id studentId)`**
```apex
@AuraEnabled(cacheable=true)
public static List<Job__c> getEligibleJobs(Id studentId)
```

Returns jobs the student is eligible for based on CGPA and backlogs.

**Parameters:**
- `studentId` - The ID of the Student__c record

**Returns:**
```apex
List<Job__c> // Jobs matching criteria
```

**Eligibility Criteria:**
- `Minimum_CGPA__c <= Student.CGPA__c`
- `Allowed_Backlogs__c >= Student.Active_Backlogs__c`
- `Status__c = 'Open'`

**Example:**
```javascript
import getEligibleJobs from '@salesforce/apex/StudentPortalController.getEligibleJobs';

getEligibleJobs({ studentId: this.studentId })
  .then(jobs => {
    this.eligibleJobs = jobs;
  })
  .catch(error => {
    console.error(error);
  });
```

---

**`applyForJob(Id studentId, Id jobId)`**
```apex
@AuraEnabled
public static String applyForJob(Id studentId, Id jobId)
```

Creates an application record for the student and job.

**Parameters:**
- `studentId` - The ID of the Student__c record
- `jobId` - The ID of the Job__c record

**Returns:**
```apex
String // Success message
```

**Throws:**
- `AuraHandledException` - If validation fails

**Example:**
```javascript
import applyForJob from '@salesforce/apex/StudentPortalController.applyForJob';

applyForJob({ studentId: this.studentId, jobId: jobId })
  .then(result => {
    this.showSuccessToast();
  })
  .catch(error => {
    this.showErrorToast(error.body.message);
  });
```

---

### ApplicationController

Used by the myApplications LWC component.

#### Methods

**`getMyApplications(Id studentId)`**
```apex
@AuraEnabled(cacheable=true)
public static List<Application__c> getMyApplications(Id studentId)
```

Returns all applications for a specific student with related job details.

**Parameters:**
- `studentId` - The ID of the Student__c record

**Returns:**
```apex
List<Application__c> // Applications with Job__r fields
```

**Returned Fields:**
- `Id`, `Name`, `Status__c`, `Application_Date__c`
- `Job__r.Name`, `Job__r.Company__c`, `Job__r.Location__c`, `Job__r.Salary__c`

---

## Service Classes

### ApplicationService

Core business logic for application processing.

#### Methods

**`validateApplications(List<Application__c> applications)`**
```apex
public static void validateApplications(List<Application__c> applications)
```

Validates applications before insert/update.

**Validations:**
- CGPA check: Student CGPA >= Job Minimum CGPA
- Duplicate check: No existing application for same student/job
- Closing date check: Application date before job closing date

**Throws:**
- Adds error to record if validation fails

---

**`submitApplication(Id studentId, Id jobId)`**
```apex
public static Application__c submitApplication(Id studentId, Id jobId)
```

Creates and validates a new application.

**Parameters:**
- `studentId` - Student record ID
- `jobId` - Job record ID

**Returns:**
- `Application__c` - Created application record

**Throws:**
- `IllegalArgumentException` - If validation fails

---

### AnalyticsService

Provides aggregate analytics data.

#### Methods

**`applicationsPerJob()`**
```apex
public static Map<String, Integer> applicationsPerJob()
```

Returns count of applications grouped by job name.

**Returns:**
```apex
Map<String, Integer> // {"Job Name" => Count}
```

---

**`selectedApplications()`**
```apex
public static Integer selectedApplications()
```

Returns count of applications with status 'Selected'.

---

**`jobsPerCompany()`**
```apex
public static Map<String, Integer> jobsPerCompany()
```

Returns count of jobs grouped by company name.

---

### ExternalPlacementService

Handles external API integration.

#### Methods

**`syncSelectedCandidates(List<Id> applicationIds)`**
```apex
public static void syncSelectedCandidates(List<Id> applicationIds)
```

Sends candidate data to external recruitment API.

**Parameters:**
- `applicationIds` - List of Application__c IDs to sync

**Side Effects:**
- Makes HTTP POST request
- Creates Integration_Log__c records
- Handles errors gracefully (logs but doesn't throw)

**Named Credential:**
- Uses `Recruitment_API` named credential

---

## Error Handling

### REST API Errors

All REST endpoints follow consistent error handling:

**Success Response:**
```json
{
  "status": "success",
  "data": { ... }
}
```

**Error Response:**
```json
{
  "error": "Error message",
  "details": "Additional details if available"
}
```

### Apex Controller Errors

Lightning Web Components receive errors through `@wire` or Promise rejection:

```javascript
@wire(getEligibleJobs, { studentId: '$studentId' })
wiredJobs({ error, data }) {
  if (error) {
    console.error('Error loading jobs:', error);
    this.error = error;
  } else if (data) {
    this.jobs = data;
  }
}
```

### Common Error Messages

| Error | Meaning | Solution |
|-------|---------|----------|
| `CGPA does not meet minimum requirement` | Student CGPA too low | Apply to jobs with lower requirements |
| `Duplicate application detected` | Already applied to this job | View existing application |
| `Job closing date has passed` | Job no longer accepting applications | Apply to open jobs |
| `Insufficient privileges` | User lacks permission | Contact administrator |
| `FIELD_CUSTOM_VALIDATION_EXCEPTION` | Validation rule failed | Check validation error message |

---

## Examples

### Example 1: External API Integration

**Postman/cURL Request:**
```bash
curl -X GET \
  'https://yourinstance.salesforce.com/services/apexrest/placement/jobs' \
  -H 'Authorization: Bearer YOUR_ACCESS_TOKEN' \
  -H 'Content-Type: application/json'
```

**Response:**
```json
[
  {
    "Id": "a01...",
    "Name": "Salesforce Developer",
    "Company__c": "TechCorp",
    "Location__c": "Hyderabad",
    "Salary__c": 800000,
    "Status__c": "Open"
  }
]
```

---

### Example 2: Apply via API

**Request:**
```bash
curl -X POST \
  'https://yourinstance.salesforce.com/services/apexrest/placement/apply' \
  -H 'Authorization: Bearer YOUR_ACCESS_TOKEN' \
  -H 'Content-Type: application/json' \
  -d '{
    "studentId": "a00...",
    "jobId": "a01..."
  }'
```

**Response:**
```json
{
  "status": "success",
  "applicationId": "a02..."
}
```

---

### Example 3: LWC Integration

**Component JavaScript:**
```javascript
import { LightningElement, wire } from 'lwc';
import getEligibleJobs from '@salesforce/apex/StudentPortalController.getEligibleJobs';

export default class JobList extends LightningElement {
    studentId = 'a00...'; // Current student ID
    jobs;
    error;

    @wire(getEligibleJobs, { studentId: '$studentId' })
    wiredJobs({ error, data }) {
        if (data) {
            this.jobs = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.jobs = undefined;
        }
    }
}
```

---

### Example 4: Batch Analytics

**Anonymous Apex:**
```apex
// Run analytics batch
PlacementStatisticsBatch batch = new PlacementStatisticsBatch();
Database.executeBatch(batch, 200);

// Query results later
Map<String, Integer> stats = AnalyticsService.applicationsPerJob();
System.debug('Applications per job: ' + stats);
```

---

## Rate Limits & Governance

### Salesforce Governor Limits

All Apex code respects Salesforce governor limits:

- **SOQL Queries:** 100 per transaction
- **DML Statements:** 150 per transaction
- **Heap Size:** 6 MB (synchronous), 12 MB (asynchronous)
- **CPU Time:** 10,000 ms (synchronous), 60,000 ms (asynchronous)
- **HTTP Callouts:** 100 per transaction
- **Total Timeout:** 120 seconds per transaction

### Best Practices

- Use bulk operations (process 200 records at once)
- Cache @AuraEnabled(cacheable=true) methods
- Use asynchronous processing for long-running operations
- Implement pagination for large datasets

---

## Versioning

Current API Version: **v1.0**

All endpoints are versioned through the Salesforce API version in `sfdx-project.json`:
```json
"sourceApiVersion": "61.0"
```

Future versions will maintain backward compatibility or provide migration guides.

---

## Security

### Authentication
- All endpoints require Salesforce authentication
- Use OAuth 2.0 for external integrations
- Session tokens expire based on org settings

### Authorization
- Enforces Salesforce sharing rules
- Respects object-level security (CRUD)
- Respects field-level security (FLS)
- Uses `with sharing` keyword in all classes

### Data Protection
- No sensitive data in error messages
- Integration logs stored securely
- API credentials stored in Named Credentials

---

**Last Updated:** August 13, 2026
**API Version:** 1.0
**Salesforce API Version:** 61.0
