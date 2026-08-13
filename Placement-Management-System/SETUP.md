# Setup Guide - Placement Management System

Complete setup instructions for deploying and configuring the Placement Management System.

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Quick Start](#quick-start)
3. [Detailed Setup](#detailed-setup)
4. [Post-Deployment Configuration](#post-deployment-configuration)
5. [Verification](#verification)
6. [Troubleshooting](#troubleshooting)

---

## Prerequisites

### Required Software
- **Salesforce CLI** (version 2.x or later)
  ```bash
  # Verify installation
  sf --version
  ```
  Install from: https://developer.salesforce.com/tools/sfdxcli

- **VS Code** with Salesforce Extension Pack
  - Install VS Code: https://code.visualstudio.com/
  - Install extension: Search for "Salesforce Extension Pack" in VS Code marketplace

- **Git** (for version control)
  ```bash
  # Verify installation
  git --version
  ```

### Salesforce Org Requirements
- Developer Edition, Production, or Sandbox org
- System Administrator access
- API access enabled

---

## Quick Start

For experienced Salesforce developers:

```bash
# 1. Clone and navigate
git clone <repository-url>
cd Placement-Management-System

# 2. Authorize org
sf org login web --alias MyOrg --set-default

# 3. Deploy everything
sf project deploy start

# 4. Open org
sf org open
```

Then follow [Post-Deployment Configuration](#post-deployment-configuration).

---

## Detailed Setup

### Step 1: Get the Code

**Option A: Clone from Git**
```bash
git clone <repository-url>
cd Placement-Management-System
```

**Option B: Download ZIP**
1. Download and extract the ZIP file
2. Open terminal/command prompt
3. Navigate to the extracted folder

### Step 2: Authorize Your Salesforce Org

**Using Web Login (Recommended):**
```bash
sf org login web --alias MyOrg --set-default
```
This opens a browser where you log in to your org.

**Using Username/Password:**
```bash
sf org login jwt --client-id <connected-app-client-id> \
  --jwt-key-file <path-to-jwt-key> \
  --username <your-username> \
  --alias MyOrg --set-default
```

**Verify connection:**
```bash
sf org display --target-org MyOrg
```

### Step 3: Deploy the Application

**Full Deployment (Recommended for first install):**
```bash
sf project deploy start --target-org MyOrg
```

**Validate Before Deploy (optional):**
```bash
# Check deployment without actually deploying
sf project deploy start --target-org MyOrg --dry-run
```

**Component-by-Component (if needed):**
```bash
# Deploy objects first
sf project deploy start --source-dir force-app/main/default/objects

# Deploy classes
sf project deploy start --source-dir force-app/main/default/classes

# Deploy triggers
sf project deploy start --source-dir force-app/main/default/triggers

# Deploy LWC
sf project deploy start --source-dir force-app/main/default/lwc

# Deploy named credentials
sf project deploy start --source-dir force-app/main/default/namedCredentials
```

### Step 4: Open Your Org
```bash
sf org open --target-org MyOrg
```

---

## Post-Deployment Configuration

### 1. Assign Permissions

**Option A: System Administrator**
- No additional setup needed (has all permissions)

**Option B: Create Permission Set**
1. Go to Setup → Permission Sets → New
2. Name: "Placement Management User"
3. Add object permissions:
   - Student__c: Read, Create, Edit, Delete
   - Job__c: Read, Create, Edit, Delete
   - Application__c: Read, Create, Edit, Delete
   - Offer_Letter__c: Read, Create, Edit, Delete
   - Integration_Log__c: Read, Create, Edit
4. Add Apex class access: Enable all Placement* classes
5. Save and assign to users

### 2. Configure Named Credentials (For API Integration)

1. Go to Setup → Named Credentials → Recruitment_API
2. Update endpoint if needed (default: jsonplaceholder.typicode.com)
3. Configure authentication:
   - For demo: NoAuthentication (already configured)
   - For production: Set up OAuth 2.0 or other auth

### 3. Create Sample Data

**Option A: Manual Entry**
1. Go to Students tab → New
2. Create 3-5 sample students with various CGPAs
3. Go to Jobs tab → New
4. Create 2-3 sample jobs with different requirements

**Option B: Anonymous Apex (Bulk)**
```apex
// Create students
List<Student__c> students = new List<Student__c>{
    new Student__c(Name='Alice Kumar', Department__c='CSE', CGPA__c=8.5, Active_Backlogs__c=0),
    new Student__c(Name='Bob Singh', Department__c='ECE', CGPA__c=7.2, Active_Backlogs__c=1),
    new Student__c(Name='Carol Patel', Department__c='CSE', CGPA__c=9.1, Active_Backlogs__c=0),
    new Student__c(Name='David Sharma', Department__c='MECH', CGPA__c=6.8, Active_Backlogs__c=2),
    new Student__c(Name='Eve Reddy', Department__c='CSE', CGPA__c=8.9, Active_Backlogs__c=0)
};
insert students;

// Create jobs
List<Job__c> jobs = new List<Job__c>{
    new Job__c(
        Name='Salesforce Developer',
        Company__c='TechCorp',
        Minimum_CGPA__c=8.0,
        Allowed_Backlogs__c=0,
        Location__c='Hyderabad',
        Salary__c=800000,
        Status__c='Open',
        Closing_Date__c=Date.today().addDays(30)
    ),
    new Job__c(
        Name='Java Developer',
        Company__c='SoftSolutions',
        Minimum_CGPA__c=7.0,
        Allowed_Backlogs__c=1,
        Location__c='Bangalore',
        Salary__c=600000,
        Status__c='Open',
        Closing_Date__c=Date.today().addDays(45)
    ),
    new Job__c(
        Name='Python Engineer',
        Company__c='DataTech',
        Minimum_CGPA__c=8.5,
        Allowed_Backlogs__c=0,
        Location__c='Pune',
        Salary__c=900000,
        Status__c='Open',
        Closing_Date__c=Date.today().addDays(20)
    )
};
insert jobs;

System.debug('Created ' + students.size() + ' students and ' + jobs.size() + ' jobs');
```

### 4. Add LWC Components to Pages

**Add Placement Dashboard:**
1. Go to App Launcher → Placement Dashboard (if app exists)
2. Or create a new Lightning App Page:
   - Setup → Lightning App Builder → New
   - Choose "App Page"
   - Name: "Placement Dashboard"
   - Drag "placementDashboard" component onto the page
   - Activate and assign to apps

**Add Student Portal:**
1. Create a new Lightning App Page
2. Name: "Student Portal"
3. Drag "studentPortal" component onto the page
4. Activate and assign to apps

### 5. Schedule Recurring Jobs (Optional)

**Schedule Job Expiration Check:**
```apex
// Run daily at 2 AM to close expired jobs
JobExpirationScheduler scheduler = new JobExpirationScheduler();
String cronExp = '0 0 2 * * ?'; // 2 AM daily
System.schedule('Daily Job Expiration Check', cronExp, scheduler);
```

**Schedule Statistics Batch:**
```apex
// Run weekly statistics refresh
PlacementStatisticsBatch batch = new PlacementStatisticsBatch();
String cronExp = '0 0 3 ? * SUN'; // 3 AM every Sunday
System.schedule('Weekly Statistics Refresh', cronExp, batch);
```

---

## Verification

### 1. Verify Deployment
```bash
# Check deployment status
sf project deploy report --target-org MyOrg

# List deployed components
sf org list metadata --metadata-type ApexClass
sf org list metadata --metadata-type ApexTrigger
sf org list metadata --metadata-type LightningComponentBundle
```

### 2. Run Tests
```bash
# Run all tests
sf apex run test --test-level RunLocalTests --result-format human --code-coverage

# Run specific test class
sf apex run test --tests PlacementServiceTest --result-format human
```

**Expected:** All tests should pass with 75%+ coverage.

### 3. Test Functionality

**Test Application Creation:**
1. Open Students tab
2. Select a student
3. Create a new Application
4. Link to a job
5. Verify validation runs (CGPA check, duplicate check)

**Test Student Portal:**
1. Open Student Portal page
2. Verify eligible jobs appear
3. Click Apply on a job
4. Check Applications tab for new record

**Test REST API:**
```apex
// In Developer Console → Execute Anonymous
RestRequest req = new RestRequest();
RestResponse res = new RestResponse();

req.requestURI = '/services/apexrest/placement/jobs';
req.httpMethod = 'GET';

RestContext.request = req;
RestContext.response = res;

System.debug(PlacementApi.doGet());
```

Expected: JSON array of jobs.

---

## Troubleshooting

### Deployment Errors

**Error: "Insufficient access on cross-reference id"**
- Solution: Deploy objects before classes/triggers
- Or: Deploy with System Administrator credentials

**Error: "Component is not available for this organization"**
- Solution: Check API version compatibility
- Update `sfdx-project.json` sourceApiVersion if needed

**Error: "Failed to compile Apex class"**
- Solution: Check for typos or syntax errors
- Review error message for specific line number

### Runtime Issues

**LWC Component Not Showing**
- Check component is added to page layout
- Verify component visibility settings
- Check browser console for JavaScript errors

**Trigger Not Firing**
- Verify trigger is active (not commented out)
- Check user has permission to trigger the object
- Review debug logs in Developer Console

**API Callout Fails**
- Verify Named Credential is configured
- Check Remote Site Settings (Setup → Remote Site Settings)
- Ensure org has API enabled

**Tests Failing**
- Review error messages carefully
- Check test data setup
- Verify CRUD/FLS permissions in test context

### Performance Issues

**Slow Page Load**
- Check SOQL queries in controllers (use LIMIT clause)
- Review Lightning component JavaScript efficiency
- Enable caching where appropriate (@AuraEnabled(cacheable=true))

**Governor Limit Exceptions**
- Review bulk operations in triggers
- Use aggregate queries instead of loops where possible
- Consider batch Apex for large data volumes

---

## Additional Resources

- [Salesforce Developer Documentation](https://developer.salesforce.com/docs)
- [Salesforce CLI Command Reference](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/)
- [LWC Developer Guide](https://developer.salesforce.com/docs/component-library/documentation/en/lwc)
- [Apex Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/)

---

## Getting Help

If you encounter issues not covered here:
1. Check the [README.md](README.md) for architecture overview
2. Review [DEPLOYMENT.md](DEPLOYMENT.md) for deployment specifics
3. See [CONTRIBUTING.md](CONTRIBUTING.md) for development guidelines
4. Open an issue in the repository with:
   - Detailed error message
   - Steps to reproduce
   - Your environment (org type, Salesforce CLI version)

---

**Next Steps:** After successful setup, review [README.md](README.md) to understand the system architecture and features.
