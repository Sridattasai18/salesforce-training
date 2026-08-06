# Day 5 - SOQL, DML & Business Logic

## 📌 Objective

The goal of Day 5 was to understand how Salesforce applications interact with data using **SOQL** and **DML**. I learned how to retrieve records, validate business rules, and perform database operations as part of a complete business transaction.

---

## 🚀 What I Built

### 1. Student Data Retrieval
- Retrieved student records using SOQL.
- Fetched only the fields required for validation.

### 2. Job Data Retrieval
- Retrieved job eligibility details using SOQL.
- Used the job information for application validation.

### 3. Duplicate Application Check
- Queried existing application records.
- Prevented students from applying for the same job more than once.

### 4. Create Application
- Created new `Application__c` records using DML `insert`.
- Set the default application status to **Applied**.

### 5. Update Application Status
- Updated application records using DML `update`.
- Changed the status from **Applied** to **Selected**.

### 6. ApplicationService Class
Built an `ApplicationService` class that performs the complete application workflow:
- Retrieve Student
- Retrieve Job
- Check Duplicate Application
- Validate Eligibility
- Create Application
- Return Success/Error Message

---

## 📂 Project Structure

```
Day-5/
│
├── classes/
│   └── ApplicationService.cls
│
├── soql/
│   ├── 01_GetStudent.soql
│   ├── 02_GetJob.soql
│   └── 03_CheckDuplicate.soql
│
├── apex/
│   ├── 04_CreateApplication.apex
│   ├── 05_UpdateApplication.apex
│   └── 06_TestApplicationService.apex
│
└── README.md
```

---

## 🗄️ Sample Data Used

### Students

| Name | CGPA | Branch | Backlogs |
|------|------|----------|-----------|
| Datta | 8.9 | CSE-AI | 0 |
| Koushik | 8.2 | CSE | 1 |
| Krishna | 7.4 | CSE-AI | 0 |
| Vithal | 9.1 | AIML | 0 |
| Gopi | 6.8 | ECE | 2 |

### Jobs

- Frontend Developer
- Backend Developer
- Salesforce Developer
- UI/UX Designer

---

## 📖 What I Learned

### SOQL
- Retrieve Salesforce records.
- Use `SELECT`, `FROM`, `WHERE`, and `LIMIT`.
- Fetch only the required fields.
- Use SOQL to answer business questions before making decisions.

### DML
- `insert` → Create records.
- `update` → Modify existing records.
- Understand when to use each DML operation.

### Business Logic
- Software should validate business rules before saving data.
- Prevent duplicate applications.
- Validate CGPA and backlog requirements.
- Check application deadlines before creating records.

### Business Transaction Flow

```
Student Clicks Apply
        │
        ▼
Retrieve Student
        │
        ▼
Retrieve Job
        │
        ▼
Check Duplicate
        │
        ▼
Validate Eligibility
        │
        ▼
Create Application
        │
        ▼
Insert Record
        │
        ▼
Return Success Message
```

---

## 🧪 Test Scenarios

✅ Eligible Student → Application Created

❌ Low CGPA → Application Rejected

❌ Maximum Backlogs Exceeded → Application Rejected

❌ Duplicate Application → Application Rejected

❌ Application Deadline Expired → Application Rejected

---

## 💡 Key Takeaways

- SOQL is used to retrieve data from Salesforce.
- DML is used to create and update records.
- Business validation should always happen before DML.
- Every SOQL query should answer a specific business question.
- Service classes help organize business logic and keep code clean.
- A complete business transaction combines Apex, SOQL, and DML to solve a real business problem.

---

## 🛠️ Technologies Used

- Salesforce DX
- Apex
- SOQL
- DML
- Salesforce Developer Console

---

## 🎯 Next Step

Day 6 focuses on **Apex Triggers**, where the application process becomes automatic. Instead of manually calling methods, Salesforce will execute business logic whenever records are created or updated.

---

**Status:** ✅ Day 5 Completed
