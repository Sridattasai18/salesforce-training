# Salesforce Training - Bridge Program

This repository contains both the daily learning materials and a complete production-ready Salesforce project built over 11 days.

---

## 📁 Repository Structure

### 📚 Bridge-Program/
**Daily learning materials and tasks (Day 1-11)**

Contains day-by-day progression of learning with code samples, notes, and screenshots. Each day builds upon the previous, teaching a specific Salesforce development concept.

- **Day 1**: Introduction to Salesforce, data model basics (Student, Job, Application objects), SOQL queries, and first trigger
- **Day 2**: Collections, bulkification, trigger handler pattern, and service layer architecture
- **Day 3**: Validation rules, flows, and declarative automation
- **Day 4**: Lightning Web Components basics - building a placement dashboard
- **Day 5**: Service architecture and Apex integration with LWC
- **Day 6**: Enterprise trigger framework (Student + Job triggers and handlers)
- **Day 7**: Performance optimization, analytics service, and bulk-safe operations
- **Day 8**: Asynchronous Apex (Queueable, Batch, Scheduled jobs)
- **Day 9**: Interactive student portal with eligible jobs filtering and apply functionality
- **Day 10**: Multi-component communication, Lightning Data Service, parent-child patterns
- **Day 11**: REST API integration - exposing placement system via REST endpoints

**Use this folder to:** Review learning progression, understand concepts step-by-step, reference daily notes and code samples.

---

### 🚀 Placement-Management-System/
**Complete production-ready project combining all Days 1-11**

A standalone, exportable Salesforce application that integrates everything learned across all 11 days into a professional placement management system.

**What's included:**
- ✅ 19 Apex classes (services, handlers, controllers, async jobs, API)
- ✅ 3 Apex triggers (Application, Student, Job)
- ✅ 9 Lightning Web Components (dashboard, portal, cards, forms)
- ✅ 5 Custom objects (Student, Job, Application, Offer Letter, Integration Log)
- ✅ REST API endpoints (GET jobs, GET students, POST apply)
- ✅ Complete documentation (README, setup guide, API reference, etc.)
- ✅ Configuration files (sfdx-project.json, .gitignore, .forceignore)
- ✅ MIT License

**Use this folder to:** Deploy to Salesforce org, export for portfolio, share as standalone project, or use as reference architecture.

**Quick Start:**
```bash
cd Placement-Management-System
sf org login web --alias MyOrg
sf project deploy start
sf org open
```

See [Placement-Management-System/QUICK-START.md](Placement-Management-System/QUICK-START.md) for detailed setup.

---

### 🔧 force-app/
**Active development and deployment directory**

Working directory synchronized with Salesforce org. Contains the same components as Placement-Management-System and is used for live development and deployment.

---

### 📝 Documentation Files
**Project organization and reference guides**

- `WORKFLOW-GUIDE.md` - Development workflow and best practices
- `SYSTEM-VERIFICATION.md` - Component verification checklist
- `FILE-ORGANIZATION-REPORT.md` - Detailed file inventory
- `PROJECT-ORGANIZATION-SUMMARY.md` - Organization overview
- `EXPORT-CHECKLIST.md` - Export preparation and verification
- `DEPLOYMENT-SUMMARY.md` - GitHub deployment record

---

## 🎯 How to Use This Repository

### For Learning
1. Start with `Bridge-Program/Day-01/`
2. Read the README and notes for each day
3. Review code samples and screenshots
4. Progress through Days 1-11 sequentially

### For Deployment
1. Navigate to `Placement-Management-System/`
2. Follow `QUICK-START.md` or `SETUP.md`
3. Deploy to your Salesforce org
4. Test the complete system

### For Portfolio
1. Clone or export `Placement-Management-System/` folder
2. Deploy to a demo org
3. Share the GitHub repository link
4. Use as interview talking points

---

## 🏗️ Project Architecture

The Placement Management System follows enterprise Salesforce patterns:

```
Student Portal (LWC)
    ↓
Controllers (Apex)
    ↓
Service Layer (Business Logic)
    ↓
Trigger Handlers (Validation)
    ↓
Database (Custom Objects)
    ↓
Async Jobs (Background Processing)
    ↓
External APIs (REST Integration)
```

---

## 🌟 Key Features

- **Data Model**: Student, Job, Application, Offer Letter objects with relationships
- **Validation**: CGPA checks, duplicate prevention, closing date validation
- **Automation**: Flows for auto-creating offer letters, validation rules
- **UI Components**: Dashboard, student portal, job cards, application history
- **API Integration**: REST endpoints for external system integration
- **Async Processing**: Queueable, Batch, and Scheduled Apex for background tasks
- **Analytics**: Aggregate queries for placement statistics
- **Enterprise Patterns**: Trigger → Handler → Service architecture

---

## 📊 Project Statistics

| Metric | Count |
|--------|-------|
| Apex Classes | 19 |
| Apex Triggers | 3 |
| LWC Components | 9 |
| Custom Objects | 5 |
| Days Completed | 11 |
| Lines of Code | 4,000+ |
| Documentation Files | 18 |

---

## 🚀 Quick Deploy

```bash
# Clone repository
git clone https://github.com/Sridattasai18/salesforce-training.git
cd salesforce-training

# Option 1: Deploy complete system
cd Placement-Management-System
sf org login web --alias MyOrg
sf project deploy start

# Option 2: Deploy from force-app (active dev)
sf org login web --alias MyOrg
sf project deploy start --source-dir force-app
```

---

## 📚 Documentation

### Placement-Management-System Documentation
- [README.md](Placement-Management-System/README.md) - Project overview
- [QUICK-START.md](Placement-Management-System/QUICK-START.md) - 5-minute setup
- [SETUP.md](Placement-Management-System/SETUP.md) - Detailed installation
- [API-REFERENCE.md](Placement-Management-System/API-REFERENCE.md) - REST API docs
- [DEPLOYMENT.md](Placement-Management-System/DEPLOYMENT.md) - Deployment guide
- [CONTRIBUTING.md](Placement-Management-System/CONTRIBUTING.md) - Development guidelines

### Bridge-Program Documentation
Each day folder contains:
- `README.md` - Day overview and objectives
- `day-X-notes.md` - Detailed learning notes
- `code/` - Code samples for that day
- `screenshots/` - Visual documentation

---

## 🔗 Links

**Repository**: https://github.com/Sridattasai18/salesforce-training  
**Clone (HTTPS)**: `git clone https://github.com/Sridattasai18/salesforce-training.git`  
**Clone (SSH)**: `git clone git@github.com:Sridattasai18/salesforce-training.git`

---

## 📄 License

This project is licensed under the MIT License - see [Placement-Management-System/LICENSE](Placement-Management-System/LICENSE) file for details.

---

## 🤝 Contributing

Contributions are welcome! Please read [Placement-Management-System/CONTRIBUTING.md](Placement-Management-System/CONTRIBUTING.md) for guidelines.

---

## 📞 Contact

**GitHub**: [@Sridattasai18](https://github.com/Sridattasai18)  
**Repository**: [salesforce-training](https://github.com/Sridattasai18/salesforce-training)

For questions or issues, please create a GitHub issue or refer to the documentation files.

---

**Status**: ✅ Complete (Days 1-11)  
**Last Updated**: August 13, 2026  
**Version**: 1.0.0
