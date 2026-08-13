# Placement Management System

A comprehensive Salesforce application for managing campus placement activities, including student profiles, job postings, and application tracking.

## Overview

The Placement Management System streamlines the entire campus recruitment process by:
- Managing student profiles with academic performance tracking
- Handling job postings from companies
- Automating application validation based on eligibility criteria
- Preventing duplicate applications
- Providing real-time application status tracking

## Features

### ✅ Student Management
- Complete student profiles with academic details
- CGPA tracking
- Department-wise organization
- Backlog management
- Placement status tracking

### ✅ Job Management
- Job posting creation with detailed requirements
- Company information
- Location and salary details
- Minimum CGPA requirements
- Allowed backlogs specification
- Opening and closing dates

### ✅ Application Management
- Automated eligibility validation
- Duplicate application prevention
- Application status workflow (Applied → Reviewed → Selected/Rejected)
- Application date tracking
- Bulk-safe processing

### ✅ Business Logic Layer
- Service-oriented architecture
- Reusable business logic
- Trigger handler pattern
- Exception handling
- Governor limit optimized

## Architecture

```
ApplicationTrigger (Entry Point)
    ↓
ApplicationTriggerHandler (Event Router)
    ↓
ApplicationService (Business Logic)
    ├── validateApplications()
    └── submitApplication()

PlacementService (Utility Methods)
    ├── getEligibleStudents()
    ├── getStudentsByDepartment()
    └── createApplication()
```

### Design Patterns Used

1. **Trigger Handler Pattern** — Clean separation between trigger and logic
2. **Service Layer Pattern** — Reusable business logic components
3. **Bulk Processing** — All operations handle multiple records efficiently
4. **Exception Handling** — Custom exceptions for validation errors

## Data Model

### Custom Objects

#### Student__c
| Field | Type | Description |
|-------|------|-------------|
| Name | Text | Student name |
| Roll_Number__c | Text | Unique roll number |
| Email__c | Email | Contact email |
| CGPA__c | Number(2,2) | Current CGPA |
| Department__c | Picklist | Academic department |
| Active_Backlogs__c | Number | Count of active backlogs |
| Placement_Status__c | Picklist | Placed/Not Placed |

#### Job__c
| Field | Type | Description |
|-------|------|-------------|
| Name | Text | Job title |
| Company__c | Text | Hiring company |
| Location__c | Text | Job location |
| Minimum_CGPA__c | Number(2,2) | Minimum CGPA required |
| Allowed_Backlogs__c | Number | Maximum backlogs allowed |
| Salary__c | Currency | Salary package |
| Closing_Date__c | Date | Application deadline |
| Status__c | Picklist | Open/Closed |

#### Application__c
| Field | Type | Description |
|-------|------|-------------|
| Student__c | Lookup(Student__c) | Applicant student |
| Job__c | Lookup(Job__c) | Applied job |
| Status__c | Picklist | Applied/Reviewed/Selected/Rejected |
| Application_Date__c | Date | Date of application |

### Relationships

```
Student__c ──< Application__c >── Job__c
   (1:N)                            (N:1)
```

## Business Rules

### Validation Rules

1. **CGPA Eligibility**
   - Student's CGPA must meet or exceed job's minimum CGPA requirement
   - Error: "Student does not meet the minimum CGPA requirement."

2. **Duplicate Prevention**
   - A student cannot apply to the same job twice
   - Error: "This student has already applied for this job."

### Trigger Events

- **before insert** — Validates applications before saving

## Installation

### Prerequisites
- Salesforce CLI installed
- Authenticated Salesforce org
- Git (optional, for version control)

### Deployment Steps

```bash
# 1. Clone or navigate to the project
cd placement-system

# 2. Deploy to your org
sf project deploy start

# 3. Verify deployment
sf project deploy report

# 4. Open the org
sf org open
```

### Post-Deployment Setup

1. **Create Sample Data**
   - Add students with varying CGPA values
   - Create job postings with different requirements
   - Test application creation

2. **Assign Permissions**
   - Ensure users have CRUD access to all custom objects
   - Grant execute permission on Apex classes

3. **Test Validations**
   - Try creating a valid application (should succeed)
   - Try applying with low CGPA (should fail)
   - Try duplicate application (should fail)

## Usage

### Creating Students

```apex
Student__c student = new Student__c(
    Name = 'Rahul Kumar',
    Roll_Number__c = 'CS2021001',
    Email__c = 'rahul@example.com',
    CGPA__c = 8.5,
    Department__c = 'Computer Science',
    Active_Backlogs__c = 0,
    Placement_Status__c = 'Not Placed'
);
insert student;
```

### Creating Jobs

```apex
Job__c job = new Job__c(
    Name = 'Software Engineer',
    Company__c = 'Microsoft',
    Location__c = 'Hyderabad',
    Minimum_CGPA__c = 8.0,
    Allowed_Backlogs__c = 0,
    Salary__c = 1200000,
    Closing_Date__c = Date.today().addDays(30),
    Status__c = 'Open'
);
insert job;
```

### Submitting Applications

```apex
// Option 1: Direct insert (trigger validates)
Application__c app = new Application__c(
    Student__c = studentId,
    Job__c = jobId,
    Status__c = 'Applied',
    Application_Date__c = Date.today()
);
insert app; // Validation happens automatically

// Option 2: Using service method
Id applicationId = ApplicationService.submitApplication(jobId);
```

### Querying Data

```sql
-- Get all applications for a student
SELECT Job__r.Name, Job__r.Company__c, Status__c
FROM Application__c
WHERE Student__c = :studentId
ORDER BY Application_Date__c DESC

-- Get eligible students for a job
SELECT Name, CGPA__c, Department__c
FROM Student__c
WHERE CGPA__c >= 8.0 AND Active_Backlogs__c = 0

-- Check application status
SELECT Student__r.Name, Job__r.Name, Status__c
FROM Application__c
WHERE Status__c = 'Applied'
```

## API Reference

### ApplicationService

#### `validateApplications(List<Application__c> applications)`
- **Type:** Static void method
- **Purpose:** Validates CGPA eligibility and prevents duplicates
- **Called by:** ApplicationTriggerHandler
- **Governor Limits:** 3 SOQL queries (bulk-safe)

#### `submitApplication(Id jobId)`
- **Type:** Static method
- **Returns:** Id (Application record ID)
- **Purpose:** Creates an application for the first student (demo)
- **Throws:** ApplicationException on validation failure

### PlacementService

#### `getEligibleStudents(Decimal minimumCGPA)`
- **Type:** Static method
- **Returns:** List<Student__c>
- **Purpose:** Retrieves students meeting CGPA criteria

#### `getStudentsByDepartment(String department)`
- **Type:** Static method
- **Returns:** List<Student__c>
- **Purpose:** Retrieves students from a specific department

#### `createApplication(Id studentId, Id jobId)`
- **Type:** Static method
- **Returns:** Application__c
- **Purpose:** Creates an application record

## Testing

### Manual Testing Scenarios

1. **Valid Application**
   - Student CGPA: 9.0, Job Minimum: 8.0
   - Expected: Application created ✅

2. **CGPA Validation**
   - Student CGPA: 7.0, Job Minimum: 8.0
   - Expected: Error message ❌

3. **Duplicate Prevention**
   - Create same application twice
   - Expected: Second attempt fails ❌

### Verification Queries

```sql
-- Check for duplicates (should return 0 rows)
SELECT Student__c, Job__c, COUNT(Id)
FROM Application__c
GROUP BY Student__c, Job__c
HAVING COUNT(Id) > 1

-- View all applications
SELECT Name, Student__r.Name, Job__r.Name, Status__c
FROM Application__c
ORDER BY CreatedDate DESC
```

## Governor Limits Compliance

| Operation | Queries Used | Limit | % Used |
|-----------|--------------|-------|--------|
| validateApplications() | 3 | 100 | 3% |
| submitApplication() | 3 | 100 | 3% |

All methods are **bulk-safe** and handle up to 10,000 records per transaction.

## Security

- All classes use `with sharing` keyword for enforcing record-level security
- Field-level security respected through SOQL queries
- Custom exceptions prevent information leakage

## Troubleshooting

### Common Issues

**Issue:** "Student does not meet the minimum CGPA requirement"
- **Solution:** Verify student CGPA vs. job minimum CGPA requirement

**Issue:** "This student has already applied for this job"
- **Solution:** Check existing applications; delete if duplicate test data

**Issue:** Deployment fails with "Invalid field" error
- **Solution:** Ensure all custom objects and fields are deployed before classes

## Roadmap

### Planned Features
- Lightning Web Components for student portal
- Email notifications on application status change
- Batch processing for expired jobs
- Integration with external recruitment systems
- Advanced reporting and analytics

## Contributing

When extending this system:
1. Follow the existing architecture patterns
2. Keep all code bulk-safe
3. Add validation in ApplicationService, not in triggers
4. Update documentation for new features
5. Test with both single and bulk records

## Support

For issues or questions:
- Check the `docs/` folder for detailed guides
- Review `ARCHITECTURE.md` for design decisions
- See `FEATURES.md` for feature specifications

## License

Internal use only — Campus Placement Management System

---

**Version:** 1.0 (Day 1 + Day 2 Combined)  
**Last Updated:** 2024  
**Status:** Production Ready ✅
