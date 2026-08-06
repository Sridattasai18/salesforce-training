[[Day-1 – Salesforce Developer Bridge Program]]
# Salesforce Developer Bridge Program – Day 1 Summary

## Block 1 – Data Model (Task 1)

### What I Learned

- Understood the purpose of a Salesforce data model and how custom objects, fields, and relationships organize business data.
    
- Learned the difference between **Lookup Relationship** and **Master-Detail Relationship**.
    
- Designed a Hospital OPD Management System using four custom objects:
    
    - Patient
        
    - Doctor
        
    - Appointment
        
    - Prescription
        

### Relationships Used

- Patient → Appointment (Lookup)
    
- Doctor → Appointment (Lookup)
    
- Appointment → Prescription (Master-Detail)
    

### Outcome

Successfully created the Hospital OPD data model and verified the relationships using Schema Builder.

---

# Block 2 – Apex Basics (Task 2)

### What I Learned

- Learned Apex classes, methods, variables, and DML operations.
    
- Created an Apex class to insert Patient records.
    
- Practiced different Apex data types.
    
- Executed Apex code using Execute Anonymous.
    

### Sample Apex Code

```apex
public class PatientService {
    public static void addPatient() {
        Patient__c p = new Patient__c(
            Name='Datta',
            Age__c=17,
            Gender__c='Male'
        );
        insert p;
    }
}
```

### Outcome

Successfully created and executed an Apex class for inserting sample records into Salesforce.

---

# Task 3 – SOQL Practice

### What I Learned

Using the Hospital OPD data model, I inserted sample Patient, Doctor, Appointment, and Prescription records and practiced different types of SOQL queries.

## Query 1 – WHERE Clause

```sql
SELECT Name, Status__c
FROM Appointment__c
WHERE Status__c='Scheduled'
```

**Purpose:** Retrieves only Scheduled appointments.

---

## Query 2 – ORDER BY + LIMIT

```sql
SELECT Name, Appointment_Date__c
FROM Appointment__c
ORDER BY Appointment_Date__c DESC
LIMIT 2
```

**Purpose:** Displays the latest two appointments.

---

## Query 3 – Relationship Query

```sql
SELECT Name,
       Patient__r.Name,
       Doctor__r.Name
FROM Appointment__c
```

**Purpose:** Retrieves Appointment, Patient, and Doctor details using a child-to-parent relationship.

---

## Query 4 – Aggregate Query

```sql
SELECT COUNT()
FROM Appointment__c
```

**Purpose:** Counts the total number of Appointment records.

---

## Query 5 – Comparison Operator

```sql
SELECT Name, Appointment_Date__c
FROM Appointment__c
WHERE Appointment_Date__c >= TODAY
```

**Purpose:** Retrieves appointments scheduled today or later.

### Outcome

All five SOQL queries executed successfully without syntax errors and the results were saved for submission.

---

# Block 3 – Apex Triggers (Task 4)

### What I Learned

- Learned how Apex Triggers automate business processes.
    
- Used the Trigger–Handler design pattern.
    
- Created a trigger on the Appointment object.
    

## Trigger Code

```apex
trigger AppointmentTrigger on Appointment__c (
    before insert,
    after update
) {

    if (Trigger.isBefore && Trigger.isInsert) {
        AppointmentTriggerHandler.preventDuplicateAppointments(Trigger.new);
    }

    if (Trigger.isAfter && Trigger.isUpdate) {
        AppointmentTriggerHandler.updatePatientLastVisit(Trigger.new);
    }

}
```

## Handler Class

```apex
public class AppointmentTriggerHandler {

    public static void preventDuplicateAppointments(List<Appointment__c> newAppointments) {
        // Checks existing appointments and blocks duplicates
    }

    public static void updatePatientLastVisit(List<Appointment__c> updatedAppointments) {
        // Updates Last Visit Date when appointment is completed
    }

}
```

### Business Requirements

- Before Insert → Prevent duplicate appointments for the same patient on the same date.
    
- After Update → Update the Patient's Last Visit Date when the appointment status becomes **Completed**.
    

### Outcome

Successfully implemented the Trigger–Handler pattern and tested both automation scenarios.

---

# Block 4 – Lightning Web Components (Task 5)

### Component

**Component Name:** `patientList`

### Purpose

Displays Patient records from the custom `Patient__c` object using Apex and the `@wire` service.

### Concepts Used

- Lightning Web Components (LWC)
    
- Apex Controller
    
- SOQL
    
- @wire
    
- cacheable=true
    
- for:each
    
- if:true
    
- SLDS
    

### Files Included

- patientList.html
    
- patientList.js
    
- patientList.js-meta.xml
    
- PatientController.cls
    

### LWC ZIP / Drive Link

**ZIP File:** _(Attach your patientList.zip here in the submission.)_

**Google Drive Link:**

```
https://drive.google.com/file/d/1iVK4VuAMfrX0F6SREa5WXuFYuWkS5wwh/view?usp=drive_link
```

### Outcome

Successfully deployed the LWC, displayed Patient records, and handled Loading, Success, Error, and Empty states using Apex and the `@wire` service.

---

# Overall Learning Outcome

By the end of Day 1, I was able to:

- Design a complete Salesforce data model using custom objects and relationships.
    
- Write Apex classes and perform DML operations.
    
- Insert sample records into Salesforce.
    
- Write and execute various SOQL queries, including filtering, sorting, relationship, aggregate, and comparison queries.
    
- Build Apex Triggers using the Trigger–Handler pattern.
    
- Understand trigger best practices such as bulkification and governor limits.
    
- Develop and deploy a Lightning Web Component integrated with Apex and SOQL using the `@wire` service.
---
