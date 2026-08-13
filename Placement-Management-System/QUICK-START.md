# Quick Start Guide

Get the Placement Management System up and running in 5 minutes.

## Prerequisites

✅ Salesforce CLI installed (`sf --version`)  
✅ VS Code with Salesforce extensions  
✅ Salesforce Developer Org or Sandbox access

---

## Install in 4 Steps

### 1. Authorize Your Org
```bash
sf org login web --alias MyOrg --set-default
```

### 2. Deploy Everything
```bash
sf project deploy start
```

Wait for: `Deployment Succeeded`

### 3. Create Sample Data

Open Developer Console (Setup → Developer Console → Execute Anonymous):

```apex
// Create 5 students
List<Student__c> students = new List<Student__c>{
    new Student__c(Name='Alice Kumar', Department__c='CSE', CGPA__c=8.5, Active_Backlogs__c=0),
    new Student__c(Name='Bob Singh', Department__c='ECE', CGPA__c=7.2, Active_Backlogs__c=1),
    new Student__c(Name='Carol Patel', Department__c='CSE', CGPA__c=9.1, Active_Backlogs__c=0),
    new Student__c(Name='David Sharma', Department__c='MECH', CGPA__c=6.8, Active_Backlogs__c=2),
    new Student__c(Name='Eve Reddy', Department__c='CSE', CGPA__c=8.9, Active_Backlogs__c=0)
};
insert students;

// Create 3 jobs
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

System.debug('✅ Created ' + students.size() + ' students and ' + jobs.size() + ' jobs');
```

### 4. Open Your Org
```bash
sf org open
```

---

## Test the System

### Test 1: View Students & Jobs
1. Click **App Launcher** (9 dots icon)
2. Search for **Students** → View records
3. Search for **Jobs** → View records

### Test 2: Create Application
1. Go to **Applications** tab → New
2. Select a **Student**
3. Select a **Job**
4. Click **Save**
5. ✅ Application created (if CGPA meets requirement)
6. ❌ Error shown (if CGPA too low or duplicate)

### Test 3: Test REST API

In Developer Console → Execute Anonymous:

```apex
RestRequest req = new RestRequest();
RestResponse res = new RestResponse();

req.requestURI = '/services/apexrest/placement/jobs';
req.httpMethod = 'GET';

RestContext.request = req;
RestContext.response = res;

System.debug(PlacementApi.doGet());
```

Expected: JSON array of jobs

---

## What You Just Installed

### Objects
- **Student__c** - Student profiles with CGPA
- **Job__c** - Job postings with requirements
- **Application__c** - Job applications
- **Offer_Letter__c** - Offer letters (auto-created)
- **Integration_Log__c** - API call logs

### Automation
- **Triggers** - Validate CGPA, prevent duplicates, auto-close expired jobs
- **Flows** - Auto-set dates, auto-create offer letters
- **Queueable Jobs** - Background processing after application
- **Batch Jobs** - Analytics refresh
- **Scheduled Jobs** - Daily job expiration check

### User Interface
- **Placement Dashboard** - Statistics overview
- **Student Portal** - Students can view eligible jobs and apply

### API
- `GET /placement/jobs` - List all jobs
- `GET /placement/students` - List all students
- `POST /placement/apply` - Submit application

---

## Common Tasks

### Add a Lightning Component to a Page
1. Setup → Lightning App Builder → New Lightning Page
2. Choose "App Page"
3. Name: "Placement Dashboard"
4. Drag **placementDashboard** component onto page
5. Save → Activate → Assign to app

### Schedule Job Expiration Check
```apex
JobExpirationScheduler scheduler = new JobExpirationScheduler();
String cronExp = '0 0 2 * * ?'; // 2 AM daily
System.schedule('Daily Job Expiration Check', cronExp, scheduler);
```

### Run Tests
```bash
sf apex run test --test-level RunLocalTests --result-format human
```

### View Integration Logs
1. Go to **Integration Logs** tab
2. View API call history
3. Check request/response bodies

---

## Next Steps

📖 Read [README.md](README.md) for full system overview  
🔧 See [SETUP.md](SETUP.md) for detailed configuration  
📚 Check [API-REFERENCE.md](API-REFERENCE.md) for API documentation  
🚀 Review [DEPLOYMENT.md](DEPLOYMENT.md) for deployment strategies

---

## Need Help?

**Deployment Issues?** → See [SETUP.md](SETUP.md#troubleshooting)  
**API Questions?** → See [API-REFERENCE.md](API-REFERENCE.md)  
**Contributing?** → See [CONTRIBUTING.md](CONTRIBUTING.md)

---

## System Architecture (Quick Reference)

```
Student Portal (LWC)
    ↓
Controller (Apex)
    ↓
Service Layer
    ↓
Trigger Handler
    ↓
Database
    ↓
Async Jobs → External API
```

**Validation Flow:**
```
Create Application
  → Trigger fires
  → Handler validates
  → Service checks CGPA/duplicates
  → Success or Error
```

---

**⏱️ Total Setup Time:** ~5 minutes  
**📦 Components Deployed:** 19 classes, 3 triggers, 9 LWC, 5 objects  
**✅ Ready to Use!**
