# Day 6 – Clean Trigger Architecture

## 1. Overview

Today I learned how Apex Triggers make Salesforce applications respond automatically to business events. Instead of putting business logic inside the Trigger, I implemented a clean Trigger → Service architecture that keeps the code scalable and maintainable. This approach separates event detection from business rules, which is critical for building enterprise-grade Salesforce applications.

---

## 2. What I Learned

* **Event-driven programming:** How Salesforce responds to DML operations.
* **Before vs After Triggers:** When to run logic before a record saves versus after it saves.
* **Trigger Context Variables:** Using `Trigger.new` and `Trigger.oldMap` to process records.
* **Trigger responsibilities:** Triggers should only route events.
* **Service class responsibilities:** Service classes should contain all the business logic.
* **Business timing:** Ensuring validations happen at the right point in the transaction.
* **Clean Trigger architecture:** Keeping the trigger logic small and delegating to handler/service classes.

---

## 3. Concepts Learned

### Business Event
* **Definition:** A meaningful change in data that requires a system response.
* **Example:** A student applying for a job, or an application status changing to "Selected".
* **Real-world analogy:** A smoke detector (Trigger) sensing smoke (Event) and calling the fire department (Service).
* **Interview note:** Always discuss triggers in terms of business events rather than just database changes.

### Before Trigger
* **When to use:** Used to validate or modify a record *before* it is saved to the database.
* **Example:** Validating that a student's CGPA meets the job requirement before saving the application.

### After Trigger
* **When to use:** Used to access field values that are set by the system (like Id) or to affect other records *after* the record is saved.
* **Example:** Updating placement statistics or sending notifications after an application status is updated to "Selected".

### Trigger vs Service
* **Why separate them?** Triggers are difficult to test and maintain if they contain complex logic. Service classes are modular, testable, and reusable.
* **Benefits:** Cleaner code, easier debugging, and the ability to reuse the same business logic from other places (like a Batch Apex class or an LWC). This separation is one of the main engineering principles in Salesforce development.

---

## 4. Architecture

Instead of having the Trigger do everything, I implemented a delegated architecture:

```text
Student Creates Application
        │
        ▼
Application Trigger (Before Insert & After Update)
        │
        ├── Validate CGPA (ApplicationService)
        ├── Check Deadline (ApplicationService)
        ├── Update Statistics (StatisticsService)
        ├── Send Notifications (NotificationService)
        └── Notify Alumni (AlumniService)
```

---

## 5. Hands-on Tasks Completed

* ✅ Built a **before insert** Trigger for validation.
* ✅ Delegated validation logic to `ApplicationService`.
* ✅ Created `StatisticsService` to track placement metrics.
* ✅ Created `NotificationService` for status changes.
* ✅ Implemented `AlumniService` for specific business rules.
* ✅ Tested with sample data to ensure accurate outcomes.

---

## 6. Key Engineering Principles

The core engineering idea is that **the Trigger only observes events and delegates work to service classes**.

**Trigger observes:**

NOT:
```text
Trigger
↓
Everything (Business Logic inside Trigger)
```

YES:
```text
Trigger
↓
Service
↓
Business Logic
```

Exactly as the sprint teaches.

---

## 7. Sample Test Cases

| Student | CGPA | Job                  | Result     |
| ------- | ---- | -------------------- | ---------- |
| Datta   | 8.6  | Salesforce Developer | ✅ Accepted |
| Krishna | 6.4  | Salesforce Developer | ❌ Rejected |
| Gopi    | 7.8  | Backend Developer    | ✅ Accepted |
| Vithal  | 8.1  | Salesforce Developer | ✅ Accepted |

---

## 8. Folder Structure

```text
Day-6/
 ├── codes/
 │      ApplicationTrigger.trigger
 │      ApplicationService.cls
 │      StatisticsService.cls
 │      NotificationService.cls
 │      AlumniService.cls
 ├── screenshots/
 └── day6-notes.md
```

---

## 9. Interview Questions

* **Why should Triggers remain small?** To make the codebase maintainable, readable, and easier to troubleshoot. Complex logic in triggers leads to spaghetti code.
* **Before vs After Trigger?** Use 'Before' to validate or change fields on the record being saved. Use 'After' to interact with other records or when you need the record's Id.
* **Why use Service classes?** Service classes encapsulate business logic, making it reusable across Triggers, Visualforce/Lightning controllers, and APIs.
* **Why shouldn't business logic be inside Triggers?** Triggers cannot be called explicitly from other code. If logic is in a trigger, it can only run during DML operations, limiting reusability and making testing harder.

---

## 10. Best Practices

* One Trigger per object.
* One responsibility per Service class.
* No business logic directly in the Trigger.
* The Trigger only coordinates and delegates.
* Use a *before* Trigger for validation and default field values.
* Use an *after* Trigger for related record updates and notifications.

---

## 11. Outcome

At the end of this sprint, my Placement Management System automatically validates applications, updates placement statistics, sends notifications, and remains easy to extend through a clean Trigger → Service architecture. I am now confident in designing systems that separate event routing from core business logic.
