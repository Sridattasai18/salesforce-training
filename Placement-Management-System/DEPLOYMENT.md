# Deployment Guide — Placement Management System

## Prerequisites

Before deploying, ensure you have:

- ✅ Salesforce CLI installed (`sf --version`)
- ✅ Authenticated Salesforce org (`sf org list`)
- ✅ Git installed (optional, for version control)
- ✅ VS Code with Salesforce extensions (recommended)

---

## Quick Start

### 1. Deploy to Salesforce

```bash
# Navigate to placement-system folder
cd placement-system

# Deploy all metadata
sf project deploy start

# Wait for deployment to complete
# Expected output: "Status: Succeeded"
```

### 2. Verify Deployment

```bash
# Check deployment status
sf project deploy report

# Open your org
sf org open
```

### 3. Create Test Data

Navigate to your org and create sample records:

**Students:**
1. Rahul Kumar — CGPA 9.0, CS
2. Priya Sharma — CGPA 8.5, IT
3. Kiran Patel — CGPA 7.0, CS

**Jobs:**
1. Microsoft — Software Engineer, Min CGPA 8.0
2. Amazon — SDE, Min CGPA 8.5
3. TCS — Developer, Min CGPA 7.0

**Applications:**
- Try creating valid and invalid applications to test validations

---

## Detailed Deployment Steps

### Step 1: Authenticate Your Org

If not already authenticated:

```bash
# For sandbox
sf org login web --set-default

# For production (use carefully!)
sf org login web --set-default --instance-url https://login.salesforce.com
```

### Step 2: Deploy Custom Objects

Objects are deployed automatically with `sf project deploy start`, but you can deploy them separately:

```bash
# Deploy only objects
sf project deploy start --source-dir force-app/main/default/objects
```

**Objects deployed:**
- Student__c
- Job__c  
- Application__c

### Step 3: Deploy Apex Code

```bash
# Deploy all Apex classes and triggers
sf project deploy start --source-dir force-app/main/default/classes,force-app/main/default/triggers
```

**Classes deployed:**
- ApplicationService.cls
- ApplicationTriggerHandler.cls
- PlacementService.cls

**Triggers deployed:**
- ApplicationTrigger.trigger

### Step 4: Verify Objects

In your org:
1. Setup → Object Manager
2. Find: Student__c, Job__c, Application__c
3. Verify all fields are present

### Step 5: Test the System

#### Test 1: Valid Application ✅

```apex
// Execute in Developer Console → Execute Anonymous
Student__c s = new Student__c(
    Name = 'Test Student',
    Roll_Number__c = 'TEST001',
    Email__c = 'test@example.com',
    CGPA__c = 9.0,
    Department__c = 'Computer Science',
    Active_Backlogs__c = 0,
    Placement_Status__c = 'Not Placed'
);
insert s;

Job__c j = new Job__c(
    Name = 'Test Job',
    Company__c = 'Test Company',
    Minimum_CGPA__c = 8.0,
    Status__c = 'Open'
);
insert j;

Application__c app = new Application__c(
    Student__c = s.Id,
    Job__c = j.Id,
    Status__c = 'Applied',
    Application_Date__c = Date.today()
);
insert app; // Should succeed

System.debug('Application created: ' + app.Id);
```

**Expected:** Application created successfully ✅

#### Test 2: Low CGPA Validation ❌

```apex
// Create student with CGPA 7.0
Student__c s2 = new Student__c(
    Name = 'Low CGPA Student',
    Roll_Number__c = 'TEST002',
    CGPA__c = 7.0,
    Department__c = 'Computer Science'
);
insert s2;

// Try to apply for job requiring 8.0
Application__c app2 = new Application__c(
    Student__c = s2.Id,
    Job__c = j.Id,
    Status__c = 'Applied',
    Application_Date__c = Date.today()
);

try {
    insert app2;
    System.debug('ERROR: Should have failed!');
} catch (DmlException e) {
    System.debug('Correct: ' + e.getMessage());
    // Should see: "Student does not meet the minimum CGPA requirement."
}
```

**Expected:** Error message displayed ❌

#### Test 3: Duplicate Prevention ❌

```apex
// Try to apply again with same student and job
Application__c app3 = new Application__c(
    Student__c = s.Id,
    Job__c = j.Id,
    Status__c = 'Applied',
    Application_Date__c = Date.today()
);

try {
    insert app3;
    System.debug('ERROR: Should have failed!');
} catch (DmlException e) {
    System.debug('Correct: ' + e.getMessage());
    // Should see: "This student has already applied for this job."
}
```

**Expected:** Duplicate error ❌

---

## Verification Queries

Run these in Developer Console → Query Editor:

### 1. Check All Applications

```sql
SELECT Id, Name,
       Student__r.Name,
       Student__r.CGPA__c,
       Job__r.Name,
       Job__r.Company__c,
       Job__r.Minimum_CGPA__c,
       Status__c,
       Application_Date__c
FROM Application__c
ORDER BY CreatedDate DESC
```

### 2. Check for Duplicates (should return 0 rows)

```sql
SELECT Student__c, Job__c, COUNT(Id) duplicateCount
FROM Application__c
GROUP BY Student__c, Job__c
HAVING COUNT(Id) > 1
```

### 3. View Students

```sql
SELECT Name, CGPA__c, Department__c, Placement_Status__c
FROM Student__c
ORDER BY CGPA__c DESC
```

### 4. View Jobs

```sql
SELECT Name, Company__c, Minimum_CGPA__c, Status__c
FROM Job__c
ORDER BY Name
```

---

## Post-Deployment Configuration

### 1. Create Permission Sets (Optional)

If you need custom access controls:

1. Setup → Permission Sets → New
2. Name: "Placement Manager"
3. Add CRUD access to all three objects
4. Assign to placement office users

### 2. Create Record Types (Optional)

For different types of jobs (Full-time, Internship, etc.):

1. Setup → Object Manager → Job__c
2. Record Types → New
3. Add picklist values specific to type

### 3. Create Validation Rules (Optional)

Additional UI-level validations:

**Example: Closing Date must be future**
```
Closing_Date__c < TODAY()
Error: "Closing date must be in the future"
```

### 4. Create Workflows/Flows (Optional)

Automate additional processes:
- Send email when application status changes
- Update student placement status when selected
- Close job automatically after closing date

---

## Troubleshooting

### Issue 1: Deployment Failed

**Error:** "Component failures [X]"

**Solution:**
1. Read the error message carefully
2. Common issues:
   - Missing metadata files (.cls-meta.xml)
   - API version mismatch
   - Org has existing custom fields with same name

**Fix:**
```bash
# Check specific error
sf project deploy report --job-id <deployment-id>

# Deploy incrementally
sf project deploy start --source-dir force-app/main/default/objects
sf project deploy start --source-dir force-app/main/default/classes
```

### Issue 2: "No org found"

**Error:** "No default org found"

**Solution:**
```bash
# List orgs
sf org list

# Set default
sf config set target-org your-username@example.com

# Or login again
sf org login web
```

### Issue 3: Validation Still Not Working

**Problem:** Applications are created even when CGPA is low

**Solution:**
1. Check if trigger is active:
   - Setup → Apex Triggers → ApplicationTrigger
   - Status should be "Active"

2. Check debug logs:
   - Setup → Debug Logs
   - Add your user
   - Try creating application
   - View log to see if validation ran

3. Verify code deployed:
   ```bash
   sf project retrieve start --metadata ApexClass:ApplicationService
   ```

### Issue 4: Custom Objects Not Visible

**Problem:** Can't see Student__c, Job__c, or Application__c

**Solution:**
1. Check deployment status:
   ```bash
   sf project deploy report
   ```

2. Verify in Setup:
   - Setup → Object Manager
   - Search for custom objects

3. Check user permissions:
   - Profile must have CRUD access to custom objects

---

## Deployment Checklist

Before considering deployment complete:

- [ ] All objects deployed (Student__c, Job__c, Application__c)
- [ ] All fields visible in object manager
- [ ] All Apex classes deployed (ApplicationService, PlacementService, ApplicationTriggerHandler)
- [ ] Trigger deployed and active (ApplicationTrigger)
- [ ] Test data created (at least 2 students, 2 jobs)
- [ ] Valid application test passed ✅
- [ ] CGPA validation test passed ❌
- [ ] Duplicate prevention test passed ❌
- [ ] No duplicate applications in org (query returned 0 rows)
- [ ] Debug logs checked for errors
- [ ] Users have appropriate permissions

---

## Rollback Plan

If something goes wrong:

### Option 1: Remove Specific Components

```bash
# Delete Apex class
sf project delete source --metadata ApexClass:ApplicationService --target-org your-org

# Delete trigger
sf project delete source --metadata ApexTrigger:ApplicationTrigger --target-org your-org
```

### Option 2: Full Rollback

1. Deactivate trigger:
   - Setup → Apex Triggers → ApplicationTrigger
   - Change Status to "Inactive"

2. Delete test data:
   ```sql
   DELETE [SELECT Id FROM Application__c];
   DELETE [SELECT Id FROM Job__c];
   DELETE [SELECT Id FROM Student__c];
   ```

3. Remove custom objects (if needed):
   - Setup → Object Manager
   - Find object → Delete

---

## Production Deployment

For deploying to production org:

### 1. Test in Sandbox First

```bash
# Deploy to sandbox
sf org login web --alias my-sandbox --instance-url https://test.salesforce.com
sf project deploy start --target-org my-sandbox
```

### 2. Run All Tests

```bash
# Deploy with tests
sf project deploy start --test-level RunLocalTests --target-org production
```

### 3. Schedule Downtime (Optional)

For major deployments:
- Notify users
- Schedule maintenance window
- Have rollback plan ready

### 4. Deploy to Production

```bash
# Authenticate production
sf org login web --alias production --instance-url https://login.salesforce.com

# Deploy
sf project deploy start --target-org production --test-level RunLocalTests

# Monitor deployment
sf project deploy report --target-org production
```

### 5. Post-Production Verification

- Verify all components deployed
- Test critical workflows
- Check debug logs for errors
- Monitor user feedback

---

## Support

If you encounter issues:

1. Check debug logs (Setup → Debug Logs)
2. Review deployment report (`sf project deploy report`)
3. Verify all files present in `force-app/`
4. Check API version compatibility
5. Review ARCHITECTURE.md and FEATURES.md docs

---

## Next Steps

After successful deployment:

1. **Create sample data** — Populate with realistic test records
2. **Train users** — Demonstrate application submission flow
3. **Set up reports** — Create reports for placement analytics
4. **Add monitoring** — Enable field history tracking
5. **Plan enhancements** — Review FEATURES.md "Future Enhancements"

---

**Deployment Version:** 1.0  
**Last Updated:** 2024  
**Status:** Deployment Ready ✅
