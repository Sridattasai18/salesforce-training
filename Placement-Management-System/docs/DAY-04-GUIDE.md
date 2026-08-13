# Day 4: Lightning Web Components (LWC) Basics

## Concepts Covered Today

These are the topics you should know after completing Day 4.

| Concept | What it means |
|---------|---------------|
| Lightning Web Components (LWC) | Modern UI framework in Salesforce |
| Component Structure | HTML + JavaScript + XML |
| Data Binding | Display JavaScript values in HTML |
| @track | Reactive properties that update the UI |
| @api | Expose properties to other components or pages |
| Base Lightning Components | Ready-made UI elements like cards and buttons |
| Lightning App Builder | Place components on Salesforce pages |

---

## Prerequisites

You should already know:

- ✅ Objects and fields
- ✅ Relationships
- ✅ SOQL
- ✅ Apex classes
- ✅ Triggers
- ✅ Trigger handlers
- ✅ Flows
- ✅ Validation rules

You've completed all of these, so you're ready.

---

## Today's Goal

We are not building a full portal yet. We are building the **first UI component** for the Placement Management System.

By the end of today you will have a page like this:

```
┌────────────────────────────────────┐
│  Placement Dashboard               │
├────────────────────────────────────┤
│  Welcome, Student                  │
│                                    │
│  Students: 3                       │
│  Jobs: 2                           │
│  Applications: 6                   │
│  Offer Letters: 1                  │
└────────────────────────────────────┘
```

This will be our first LWC.

---

## Salesforce Website Tasks

### Task 1: Create a Lightning App Page

We need a page where the component will be placed.

**Steps:**

1. Click **Gear (⚙️) → Setup**
2. In Quick Find, search: **Lightning App Builder**
3. Open **Lightning App Builder**
4. Click **New**
5. Choose: **App Page**
6. Click **Next**
7. Label: `Placement Dashboard`
8. Click **Next**
9. Select: **One Region**
10. Click **Done**

**Leave this page open.** We'll add our LWC after creating it in VS Code.

---

## VS Code Tasks

This is the main Day 4 work.

### Task 2: Create the LWC

Open the terminal in VS Code.

Run:

```bash
sf lightning generate component --type lwc --name placementDashboard --output-dir force-app/main/default/lwc
```

This creates:

```
force-app/main/default/lwc/
└── placementDashboard/
    ├── placementDashboard.html
    ├── placementDashboard.js
    ├── placementDashboard.js-meta.xml
```

---

### Task 3: Build the HTML

Open: `placementDashboard.html`

Replace everything with:

```html
<template>
    <lightning-card title="Placement Dashboard">
        <div class="slds-p-around_medium">
            
            <h2 class="slds-text-heading_medium">
                Welcome, Student
            </h2>
            
            <div class="slds-m-top_medium">
                <p><strong>Students:</strong> {studentCount}</p>
                <p><strong>Jobs:</strong> {jobCount}</p>
                <p><strong>Applications:</strong> {applicationCount}</p>
                <p><strong>Offer Letters:</strong> {offerCount}</p>
            </div>
            
        </div>
    </lightning-card>
</template>
```

**What this does:**
- Creates a card with title "Placement Dashboard"
- Displays a welcome message
- Shows 4 statistics using data binding `{variableName}`

---

### Task 4: Build the JavaScript

Open: `placementDashboard.js`

Replace everything with:

```javascript
import { LightningElement } from 'lwc';

export default class PlacementDashboard extends LightningElement {
    
    studentCount = 3;
    jobCount = 2;
    applicationCount = 6;
    offerCount = 1;
}
```

**What this does:**
- Imports the base LightningElement class
- Creates a PlacementDashboard class that extends LightningElement
- Defines 4 properties with hardcoded values

**Note:** For Day 4 we are using hardcoded values. On Day 5 and Day 9 we'll connect this to Apex and real Salesforce data.

---

### Task 5: Expose the Component

Open: `placementDashboard.js-meta.xml`

Replace it with:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<LightningComponentBundle xmlns="http://soap.sforce.com/2006/04/metadata">
    <apiVersion>67.0</apiVersion>
    <isExposed>true</isExposed>
    <targets>
        <target>lightning__AppPage</target>
    </targets>
</LightningComponentBundle>
```

**What this does:**
- `isExposed>true` — Makes component visible in Lightning App Builder
- `target>lightning__AppPage` — Allows placement on App Pages

This allows the component to appear inside Lightning App Builder.

---

### Deploy to Salesforce

Run:

```bash
sf project deploy start
```

Wait for: **Deployment Succeeded**

---

### Add the Component to the Page

Go back to **Lightning App Builder**.

1. **Refresh the page**
2. In the left panel, search: `placementDashboard`
3. **Drag it** into the page
4. Click **Save**
5. Click **Activate**
6. **Activate for App Default**
7. Choose your main app
8. Click **Done**

---

### Open the Page

1. Use **App Launcher**
2. Search: `Placement Dashboard`
3. Open it

**You should see your first Salesforce UI component displaying the dashboard counts!**

---

## Small LWC Experiment

Let's see data binding in action.

Open: `placementDashboard.js`

Change:

```javascript
studentCount = 3;
```

to:

```javascript
studentCount = 10;
```

Deploy again:

```bash
sf project deploy start
```

Refresh the page.

**You'll see the UI update automatically.**

This is **data binding** in LWC.

---

## Testing

### Test 1: Component Displays

**Steps:**
1. Open Placement Dashboard page
2. Verify card title shows "Placement Dashboard"
3. Verify welcome message displays

**Expected:**
```
Welcome, Student
```

### Test 2: Data Binding Works

**Steps:**
1. Verify all 4 statistics display:
   - Students: 3
   - Jobs: 2
   - Applications: 6
   - Offer Letters: 1

**Expected:**
All values display correctly from JavaScript

### Test 3: Update Values

**Steps:**
1. Change `studentCount = 3` to `studentCount = 100` in JS
2. Deploy
3. Refresh page

**Expected:**
UI shows "Students: 100" automatically

---

## Git / GitHub

Commit Day 4.

```bash
git add .
git commit -m "Day 4: First Lightning Web Component dashboard"
git push
```

---

## What You Learned Today

Keep these interview-ready.

| Concept | One-line interview answer |
|---------|---------------------------|
| LWC | Modern UI framework for Salesforce |
| HTML file | Defines the component UI |
| JavaScript file | Stores component logic and data |
| Meta XML | Controls where the component can be used |
| Data Binding | Displays JavaScript values in HTML using curly brackets |
| Lightning App Builder | Places components on Salesforce pages |

---

## Understanding the LWC Structure

### The Three Files

Every LWC has exactly 3 files:

```
componentName.html       ← UI Layout
componentName.js         ← Logic & Data
componentName.js-meta.xml ← Configuration
```

### HTML File (Template)

```html
<template>
    <p>{variableName}</p>
</template>
```

- Uses `{variableName}` syntax to display JavaScript values
- Uses standard HTML tags
- Uses Salesforce Lightning Design System (SLDS) classes for styling

### JavaScript File (Controller)

```javascript
import { LightningElement } from 'lwc';

export default class ComponentName extends LightningElement {
    variableName = 'value';
}
```

- Imports base LightningElement class
- Exports a class that extends LightningElement
- Defines properties and methods

### Meta XML File (Metadata)

```xml
<isExposed>true</isExposed>
<targets>
    <target>lightning__AppPage</target>
</targets>
```

- Controls where component can be used
- Must set `isExposed>true` to see in App Builder
- Defines which page types support the component

---

## Data Binding Explained

**Data binding** connects JavaScript variables to HTML templates.

### Example:

**JavaScript:**
```javascript
studentCount = 3;
```

**HTML:**
```html
<p>Students: {studentCount}</p>
```

**Result:**
```
Students: 3
```

### How It Works:

1. Define property in JavaScript: `studentCount = 3`
2. Reference in HTML: `{studentCount}`
3. Framework automatically updates UI when value changes

**This is called reactive rendering.**

---

## Lightning Design System (SLDS)

The HTML uses SLDS utility classes for styling:

| Class | Purpose |
|-------|---------|
| `slds-p-around_medium` | Adds padding around element |
| `slds-m-top_medium` | Adds margin to top |
| `slds-text-heading_medium` | Styles text as medium heading |

These classes ensure your component looks consistent with Salesforce UI.

**Documentation:** https://www.lightningdesignsystem.com/

---

## Why Hardcoded Values?

Today we used hardcoded values:

```javascript
studentCount = 3;
jobCount = 2;
```

**Why?**

Day 4 focuses on **LWC basics**:
- Component structure
- Data binding
- Deployment
- Lightning App Builder

**Day 5 and beyond** will connect to real data:
- Call Apex methods
- Query Salesforce objects
- Display dynamic data

**Learning progression:**
```
Day 4: Static UI (hardcoded values)
   ↓
Day 5: Dynamic UI (Apex integration)
   ↓
Day 9: Interactive UI (full portal)
```

---

## Common Issues & Solutions

### Issue 1: Component Not Showing in App Builder

**Problem:** Can't find `placementDashboard` in component list

**Solution:**
1. Check `isExposed>true` in meta.xml
2. Check `target>lightning__AppPage` exists
3. Deploy again: `sf project deploy start`
4. Refresh Lightning App Builder page

### Issue 2: Values Not Displaying

**Problem:** Shows `{studentCount}` as text instead of "3"

**Solution:**
1. Check JavaScript property name matches HTML: `{studentCount}` = `studentCount = 3`
2. Check curly braces syntax: `{variableName}` not `{{variableName}}`
3. Deploy again

### Issue 3: Deployment Failed

**Problem:** Error during `sf project deploy start`

**Solution:**
1. Check all 3 files exist (html, js, js-meta.xml)
2. Check XML is valid (no syntax errors)
3. Check JavaScript syntax is correct
4. View full error: `sf project deploy report`

---

## End of Day 4 Checklist

Complete before moving to Day 5:

- [ ] Lightning App Page created
- [ ] `placementDashboard` LWC created (3 files)
- [ ] HTML implemented
- [ ] JavaScript implemented
- [ ] Meta XML updated
- [ ] Component deployed
- [ ] Component added to App Page
- [ ] Dashboard visible inside Salesforce
- [ ] Data binding tested (changed value, saw UI update)
- [ ] GitHub commit pushed

---

## Next Steps

**Day 5 Preview:**

Tomorrow we'll enhance this dashboard:
- Connect to Apex methods
- Query real Salesforce data
- Display actual Student, Job, Application counts from database
- Learn `@wire` decorator
- Understand lifecycle hooks

**From:**
```javascript
studentCount = 3;  // Hardcoded
```

**To:**
```javascript
@wire(getStudentCount)
studentCount;  // Dynamic from database
```

---

## Progress Tracker

### Completed:
- ✅ **Day 1:** Data Model, SOQL, Apex Basics, Trigger Basics
- ✅ **Day 2:** Collections, Bulkification, Trigger Handler Pattern, Service Layer
- ✅ **Day 3:** Validation Rules, Flows, Declarative Automation
- ✅ **Day 4:** Lightning Web Components (LWC) Basics

### Upcoming:
- **Day 5:** Service Architecture & Business Logic Organization
- **Day 6:** Enterprise Trigger Framework
- **Day 7:** Performance & Scale
- **Day 8:** Asynchronous Apex (Queueable, Batch, Scheduled)
- **Day 9:** Interactive Student Portal (LWC + Apex)
- **Day 10:** Component Communication & LDS
- **Day 11:** APIs, REST Integration, Named Credentials

---

**Status:** Day 4 Guide Ready ✅  
**Focus:** Single component, clear structure, data binding basics  
**Next:** Connect to real Salesforce data on Day 5

---

## Additional Resources

- [LWC Developer Guide](https://developer.salesforce.com/docs/component-library/documentation/en/lwc)
- [Lightning Design System](https://www.lightningdesignsystem.com/)
- [LWC Recipes](https://github.com/trailheadapps/lwc-recipes)
- [Component Library](https://developer.salesforce.com/docs/component-library/overview/components)

---

**This day is intentionally lighter than Day 3** because it introduces a completely new technology (LWC). Day 5 will connect this dashboard to real Salesforce data through Apex, so the hardcoded numbers become dynamic.
