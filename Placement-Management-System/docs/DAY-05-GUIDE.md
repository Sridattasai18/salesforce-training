# Day 5: Business Logic Architecture (Service Classes)

## Concepts Covered Today

| Concept | What it means |
|---------|---------------|
| Service Layer | Keep business logic in dedicated Apex classes |
| Separation of Concerns | UI, triggers, and business logic should be separate |
| Reusable Methods | One method can be used by LWC, triggers, and controllers |
| Thin Triggers | Triggers should only delegate work |
| Apex Controllers | Expose methods to Lightning Web Components |
| @AuraEnabled | Allows LWC to call Apex methods |

---

## Prerequisites

- ✅ Objects and relationships
- ✅ SOQL
- ✅ Apex classes
- ✅ Triggers + Trigger handlers
- ✅ Flows + Validation rules
- ✅ LWC basics

---

## What We Are Building Today

### Before Day 5:
```
LWC
 └── Hardcoded numbers (studentCount = 3)
```

### After Day 5:
```
placementDashboard (LWC)
        ↓
PlacementDashboardController
        ↓
StudentService  JobService  ApplicationService  OfferService
        ↓
Salesforce Database
```

The dashboard now shows **real counts** from your org.

---

## Salesforce Website Tasks

Almost nothing to do in the UI today. The only task is refreshing the dashboard after deployment to verify real data appears.

---

## VS Code Tasks

### Task 1: StudentService.cls

```apex
public with sharing class StudentService {

    public static Integer getStudentCount() {
        return [SELECT COUNT() FROM Student__c];
    }

    public static List<Student__c> getAllStudents() {
        return [
            SELECT Id, Name, Department__c, CGPA__c
            FROM Student__c
            ORDER BY Name
        ];
    }
}
```

---

### Task 2: JobService.cls

```apex
public with sharing class JobService {

    public static Integer getJobCount() {
        return [SELECT COUNT() FROM Job__c];
    }

    public static List<Job__c> getOpenJobs() {
        return [
            SELECT Id, Name, Company__c, Minimum_CGPA__c
            FROM Job__c
            WHERE Status__c = 'Open'
            ORDER BY Name
        ];
    }
}
```

---

### Task 3: ApplicationService.cls — New Methods Added

Added to the existing class (existing validation logic untouched):

```apex
public static Integer getApplicationCount() {
    return [SELECT COUNT() FROM Application__c];
}

public static List<Application__c> getApplicationsForStudent(Id studentId) {
    return [
        SELECT Id, Name, Status__c,
               Job__r.Name,
               Job__r.Company__c
        FROM Application__c
        WHERE Student__c = :studentId
        ORDER BY CreatedDate DESC
    ];
}
```

---

### Task 4: OfferService.cls

```apex
public with sharing class OfferService {

    public static Integer getOfferCount() {
        return [SELECT COUNT() FROM Offer_Letter__c];
    }

    public static List<Offer_Letter__c> getIssuedOffers() {
        return [
            SELECT Id, Name,
                   Student__r.Name,
                   Job__r.Name,
                   Offer_Date__c,
                   Status__c
            FROM Offer_Letter__c
            ORDER BY Offer_Date__c DESC
        ];
    }
}
```

---

### Task 5: PlacementDashboardController.cls

```apex
public with sharing class PlacementDashboardController {

    public class DashboardData {
        @AuraEnabled public Integer studentCount;
        @AuraEnabled public Integer jobCount;
        @AuraEnabled public Integer applicationCount;
        @AuraEnabled public Integer offerCount;
    }

    @AuraEnabled(cacheable=true)
    public static DashboardData getDashboardData() {

        DashboardData data = new DashboardData();

        data.studentCount     = StudentService.getStudentCount();
        data.jobCount         = JobService.getJobCount();
        data.applicationCount = ApplicationService.getApplicationCount();
        data.offerCount       = OfferService.getOfferCount();

        return data;
    }
}
```

---

### Task 6: placementDashboard.js — Connected to Apex

```javascript
import { LightningElement, wire } from 'lwc';
import getDashboardData from '@salesforce/apex/PlacementDashboardController.getDashboardData';

export default class PlacementDashboard extends LightningElement {

    studentCount = 0;
    jobCount = 0;
    applicationCount = 0;
    offerCount = 0;

    @wire(getDashboardData)
    wiredDashboard({ error, data }) {
        if (data) {
            this.studentCount     = data.studentCount;
            this.jobCount         = data.jobCount;
            this.applicationCount = data.applicationCount;
            this.offerCount       = data.offerCount;
        } else if (error) {
            console.error('Dashboard load error:', error);
        }
    }
}
```

The HTML doesn't change — `{studentCount}`, `{jobCount}` etc. still work exactly the same.

---

## Deploy

```bash
sf project deploy start
```

---

## Testing

### Test 1: Dashboard shows real numbers
- Open Placement Dashboard page
- Counts should match actual records in your org

### Test 2: Dynamic update
1. Create a new Student record in Salesforce
2. Refresh the dashboard page
3. Student count increases automatically

**This confirms LWC is wired to Apex successfully.**

---

## Git / GitHub

```bash
git add .
git commit -m "Day 5: Service layer architecture and Apex-powered dashboard"
git push
```

---

## What You Learned Today

| Concept | One-line interview answer |
|---------|---------------------------|
| Service Layer | Centralizes business logic for reuse and maintainability |
| Controller | Exposes Apex methods to the UI layer |
| @AuraEnabled | Makes Apex accessible to Lightning components |
| @wire | Calls Apex reactively from LWC |
| cacheable=true | Allows client-side caching for read operations |
| Separation of Concerns | Keeps UI, triggers, and business logic independent |

---

## Architecture After Day 5

```
placementDashboard (LWC)
        ↓
PlacementDashboardController
        ↓
StudentService    — getStudentCount(), getAllStudents()
JobService        — getJobCount(), getOpenJobs()
ApplicationService — getApplicationCount(), getApplicationsForStudent()
OfferService      — getOfferCount(), getIssuedOffers()
        ↓
Salesforce Database
```

---

## End of Day 5 Checklist

- [ ] StudentService created
- [ ] JobService created
- [ ] ApplicationService updated with count + query methods
- [ ] OfferService created
- [ ] PlacementDashboardController created
- [ ] LWC connected to Apex using @wire
- [ ] Dashboard shows real Salesforce data
- [ ] Dynamic update test passed (new record → count increases)
- [ ] GitHub commit pushed

---

## Progress Tracker

- ✅ Day 1: Data Model, SOQL, Apex Basics, Trigger Basics
- ✅ Day 2: Collections, Bulkification, Handler Pattern, Service Layer
- ✅ Day 3: Validation Rules, Flows, Declarative Automation
- ✅ Day 4: LWC Basics
- ✅ Day 5: Business Logic Architecture (Service Classes)
- **Day 6:** Enterprise Trigger Framework — up next
