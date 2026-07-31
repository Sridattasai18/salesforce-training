# Salesforce Developer Bridge Program — Day 4

## Lightning Web Components (LWC)

This folder contains all Day 4 work for documentation and GitHub submission purposes.

> The original Salesforce project source code remains untouched inside `force-app/`.

---

## Folder Structure

```
salesforce-day4/
│
├── README.md
│
├── code/
│   ├── placementHome/         — Task 1: First LWC
│   ├── studentInfo/           — Task 2: Data Binding
│   ├── welcomeMessage/        — Task 3: Button Click Event
│   ├── applicationStatus/     — Task 4: Application Status
│   └── placementDashboard/    — Task 5: Placement Dashboard
│
└── screenshots/
    ├── header.png
    ├── Student_information.png
    ├── Welcome message.png
    ├── Application_status.png
    ├── Placement dashboard.png
    └── Dashboard.png
```

---

## Components

| Component           | Description                          |
|---------------------|--------------------------------------|
| placementHome       | Landing page for Vishnu Placement Portal |
| studentInfo         | Displays student details via Data Binding |
| welcomeMessage      | Shows a message on button click       |
| applicationStatus   | Tracks and updates application status |
| placementDashboard  | Dashboard showing placement statistics |

---

## Deployment Commands

```bash
sf project deploy start --source-dir force-app/main/default/lwc/placementHome
sf project deploy start --source-dir force-app/main/default/lwc/studentInfo
sf project deploy start --source-dir force-app/main/default/lwc/welcomeMessage
sf project deploy start --source-dir force-app/main/default/lwc/applicationStatus
sf project deploy start --source-dir force-app/main/default/lwc/placementDashboard
```

Or deploy all at once:

```bash
sf project deploy start --source-dir force-app/main/default/lwc
```

---

## Key Concepts Covered

- LWC folder structure (`.html`, `.js`, `.js-meta.xml`)
- Data Binding using `{variable}`
- Button Click Events using `onclick`
- Conditional Rendering using `lwc:if`
- Deploying components using Salesforce CLI
