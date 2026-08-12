# Salesforce Developer Bridge Program — Day 4 Summary

# Lightning Web Components (LWC)

## Today's Goal

Today was all about learning the **frontend** part of Salesforce using **Lightning Web Components (LWC)**.

Until Day 3, we worked mainly on backend concepts:
- Data Model
- SOQL
- Apex
- Triggers

Today we started building the **User Interface (UI)** that users interact with.

---

## Learning Objectives

By the end of today I learned how to:

- Understand what Lightning Web Components are.
- Create and deploy an LWC.
- Understand the three files inside every LWC.
- Use JavaScript variables.
- Perform Data Binding.
- Handle Button Click Events.
- Update UI using JavaScript.
- Build a small Placement Portal dashboard.

---

## Part 1 — Think Before Coding

### 1. Why do users need a graphical interface?

Users should not interact directly with databases or code. A UI makes the application simple, secure and user-friendly.

### 2. Why can't users execute SOQL?

SOQL can expose business data and logic. Apex controls what data can be accessed.

### 3. Why is JavaScript required?

JavaScript handles:
- Variables
- Button clicks
- Logic
- Dynamic UI updates

### 4. UI Responsibilities

- Display information
- Buttons
- Forms
- User interaction

### 5. Apex Responsibilities

- Business Logic
- Database Operations
- SOQL
- Validation

---

## Understanding LWC

Every LWC contains three files:

```text
componentName.html
componentName.js
componentName.js-meta.xml
```

| File        | Purpose                                           |
|-------------|---------------------------------------------------|
| HTML        | UI Layout                                         |
| JavaScript  | Logic & Variables                                 |
| Meta XML    | Makes component available in Lightning App Builder |

---

## Project Structure

```text
force-app/
└── main/
    └── default/
        └── lwc/
            ├── placementHome
            ├── studentInfo
            ├── welcomeMessage
            ├── applicationStatus
            └── placementDashboard
```

---

## Task 1 — placementHome

### Objective

Create a component named **placementHome**.

Display:

```
Welcome to Vishnu Placement Portal
```

### placementHome.html

```html
<template>
    <lightning-card title="Placement Portal" icon-name="standard:education">
        <div class="container">
            <h1>Welcome to Vishnu Placement Portal</h1>

            <p class="subtitle">
                Your gateway to placement opportunities. Explore jobs,
                apply for companies, and track your applications.
            </p>

            <lightning-button
                label="Get Started"
                variant="brand">
            </lightning-button>
        </div>
    </lightning-card>
</template>
```

### placementHome.js

```javascript
import { LightningElement } from 'lwc';

export default class PlacementHome extends LightningElement {}
```

### Deployment

```bash
sf project deploy start --source-dir force-app/main/default/lwc/placementHome
```

📸 **Screenshot Here**

---

## Task 2 — Data Binding (studentInfo)

### Objective

Display:
- Student Name
- Roll Number
- Department

using JavaScript variables.

### studentInfo.js

```javascript
import { LightningElement } from 'lwc';

export default class StudentInfo extends LightningElement {
    studentName = 'Datta';
    rollNumber = '22B81A0505';
    department = 'AI & Data Science';
}
```

### studentInfo.html

```html
<template>
    <lightning-card title="Student Information">
        <div class="slds-p-around_medium">
            <p><strong>Student Name:</strong> {studentName}</p>
            <p><strong>Roll Number:</strong> {rollNumber}</p>
            <p><strong>Department:</strong> {department}</p>
        </div>
    </lightning-card>
</template>
```

### What I Learned

Data Binding means connecting JavaScript variables with HTML using:

```html
{studentName}
```

Whenever the JavaScript value changes, the UI updates automatically.

### Deployment

```bash
sf project deploy start --source-dir force-app/main/default/lwc/studentInfo
```

📸 **Screenshot Here**

---

## Task 3 — Button Click (welcomeMessage)

### Objective

Create a button that displays a welcome message when clicked.

### welcomeMessage.js

```javascript
import { LightningElement } from 'lwc';

export default class WelcomeMessage extends LightningElement {
    message = '';
    isVisible = false;

    showMessage() {
        this.message = 'Welcome to Vishnu Placement Portal!';
        this.isVisible = true;
    }
}
```

### welcomeMessage.html

```html
<template>
    <lightning-card title="Welcome Message">
        <div class="slds-p-around_medium">
            <lightning-button
                label="Show Welcome"
                variant="brand"
                onclick={showMessage}>
            </lightning-button>

            <template lwc:if={isVisible}>
                <p class="slds-m-top_medium">{message}</p>
            </template>
        </div>
    </lightning-card>
</template>
```

### Deployment

```bash
sf project deploy start --source-dir force-app/main/default/lwc/welcomeMessage
```

📸 **Screenshot Here**

---

## Task 4 — Application Status (applicationStatus)

### Objective

Initially show:

```
Status: Not Applied
```

After clicking Apply:

```
Status: Applied
```

### applicationStatus.js

```javascript
import { LightningElement } from 'lwc';

export default class ApplicationStatus extends LightningElement {
    status = 'Not Applied';

    updateStatus() {
        this.status = 'Applied';
    }
}
```

### applicationStatus.html

```html
<template>
    <lightning-card title="Application Status">
        <div class="slds-p-around_medium">
            <p class="slds-m-bottom_medium">
                <strong>Status:</strong> {status}
            </p>

            <lightning-button
                label="Apply"
                variant="success"
                onclick={updateStatus}>
            </lightning-button>
        </div>
    </lightning-card>
</template>
```

### Deployment

```bash
sf project deploy start --source-dir force-app/main/default/lwc/applicationStatus
```

📸 **Screenshot Here**

---

## Task 5 — Placement Dashboard (placementDashboard)

### Objective

Display:
- Today's Date
- Welcome Student
- Number of Companies
- Number of Jobs
- Applications Submitted

### placementDashboard.js

```javascript
import { LightningElement } from 'lwc';

export default class PlacementDashboard extends LightningElement {
    today = '31 July 2026';
    student = 'Datta';
    companies = 25;
    jobs = 63;
    applications = 5;
}
```

### placementDashboard.html

```html
<template>
    <lightning-card title="Placement Dashboard">
        <div class="slds-p-around_medium">
            <p><strong>Today's Date:</strong> {today}</p>
            <p><strong>Welcome Student:</strong> {student}</p>

            <div class="slds-m-top_medium">
                <p><strong>Number of Companies:</strong> {companies}</p>
                <p><strong>Number of Jobs:</strong> {jobs}</p>
                <p><strong>Applications Submitted:</strong> {applications}</p>
            </div>
        </div>
    </lightning-card>
</template>
```

### Deployment

```bash
sf project deploy start --source-dir force-app/main/default/lwc/placementDashboard
```

📸 **Screenshot Here**

---

## Testing

### Task 1

- Component loads with Placement Portal card and icon.

### Task 2

Change:

```javascript
studentName = 'Rahul';
```

to:

```javascript
studentName = 'Datta';
```

Result: UI changed automatically.

✅ Data Binding verified.

### Task 3

Click **Show Welcome**

Expected:

```
Welcome to Vishnu Placement Portal!
```

### Task 4

Click **Apply**

Expected:

```
Status: Applied
```

### Task 5

Verify dashboard values are displayed correctly.

---

## Issue We Found

The Student Information card displayed **Datta** while the Dashboard student field also displays **Datta**.

> **Note:** Even though both show the same name today, they are completely independent variables in two separate JavaScript files. Changing one does NOT automatically update the other.

### Why?

Each Lightning Web Component has its own JavaScript file and its own variables.

Changing:

```javascript
studentName = 'Datta';
```

inside **studentInfo** does NOT automatically update:

```javascript
student = 'Datta';
```

inside **placementDashboard**.

### Real-world Solution

Later in Salesforce we can solve this using:

- Parent → Child communication
- Lightning Message Service
- Apex + Database

---

## Deployment Commands (All at Once)

```bash
sf project deploy start --source-dir force-app/main/default/lwc/placementHome
```

```bash
sf project deploy start --source-dir force-app/main/default/lwc/studentInfo
```

```bash
sf project deploy start --source-dir force-app/main/default/lwc/welcomeMessage
```

```bash
sf project deploy start --source-dir force-app/main/default/lwc/applicationStatus
```

```bash
sf project deploy start --source-dir force-app/main/default/lwc/placementDashboard
```

Or deploy all LWC at once:

```bash
sf project deploy start --source-dir force-app/main/default/lwc
```

---

## Interview Questions

### What is LWC?

Lightning Web Components is Salesforce's modern UI framework built using HTML, JavaScript and CSS.

### Why JavaScript?

To write logic, variables and events.

### What are the three files in every LWC?

- HTML — UI Layout
- JavaScript — Logic & Variables
- Meta XML — Makes component available in Lightning App Builder

### What is Data Binding?

Connecting JavaScript variables with HTML using `{variableName}`. When the JS value changes, the UI updates automatically.

### Can LWC execute SOQL directly?

No. LWC calls Apex, and Apex executes SOQL.

### What is `lwc:if`?

A directive that conditionally renders HTML based on a JavaScript boolean value.

---

## What I Learned Today

- Built my first Lightning Web Components.
- Learned the LWC folder structure.
- Understood Data Binding.
- Learned Button Click Events using `onclick`.
- Used `lwc:if` for conditional rendering.
- Built five different LWCs for the Placement Portal.
- Created a Placement Dashboard with hardcoded data.

---

## Screenshot Checklist

- 📸 Task 1 — placementHome
- 📸 Task 2 — studentInfo (Data Binding)
- 📸 Task 3 — welcomeMessage (Button Click)
- 📸 Task 4 — applicationStatus (Status Update)
- 📸 Task 5 — placementDashboard

---

## Submission Checklist

- Source Code
- GitHub Repository
- Screenshots
- README
- Successful Deployment

---

## Topics to Revise

- LWC Architecture
- HTML templates in LWC
- JavaScript in LWC
- Meta XML configuration
- Data Binding (`{}`)
- Event Handling (`onclick`)
- Conditional Rendering (`lwc:if`)
- Lightning App Builder

---

## Next Day Preview

Tomorrow these hardcoded values will gradually be connected to Apex so that data comes directly from Salesforce instead of JavaScript variables.
