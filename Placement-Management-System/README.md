# 🎓 Placement Management System

A full-stack Salesforce application for managing campus placements with student profiles, job postings, eligibility filtering, application tracking, and external recruitment system integration.

[![Salesforce](https://img.shields.io/badge/Salesforce-00A1E0?style=flat&logo=salesforce&logoColor=white)](https://www.salesforce.com/)
[![Apex](https://img.shields.io/badge/Apex-00A1E0?style=flat&logo=salesforce&logoColor=white)](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/)
[![Lightning Web Components](https://img.shields.io/badge/LWC-00A1E0?style=flat&logo=salesforce&logoColor=white)](https://developer.salesforce.com/docs/component-library/documentation/en/lwc)

---

## ✨ Key Features

- **🎯 Student Management** — Profile management with CGPA, department, and placement status
- **💼 Job Management** — Job postings with eligibility criteria and auto-close on deadline
- **📝 Smart Applications** — Eligibility filtering, duplicate prevention, and validation
- **📄 Offer Letter Automation** — Auto-generation via Salesforce Flow
- **📊 Live Dashboard** — Real-time placement statistics
- **🌐 Student Portal** — Interactive LWC portal with job browsing and application submission
- **🔗 External Integration** — REST API and outbound callouts to recruitment systems
- **📝 Integration Logging** — Complete audit trail of all external API calls

---

## 🏗️ Architecture

```
Lightning Web Components (UI)
        ↓
Apex Controllers
        ↓
Service Layer
        ↓
Trigger → Handler Framework
        ↓
Salesforce Data (Student__c, Job__c, Application__c, Integration_Log__c)
```

**Clean separation of concerns** with enterprise trigger patterns, asynchronous processing (Queueable, Batch, Scheduled), and external integration via Named Credentials.

---

## 🚀 Quick Start

### Prerequisites
- [Salesforce CLI](https://developer.salesforce.com/tools/salesforcecli) (`sf` command)
- Salesforce Developer Edition or Sandbox org
- Git

### Setup

```bash
# 1. Clone the repository
git clone https://github.com/Sridattasai18/Placement-Management-System.git
cd Placement-Management-System

# 2. Authenticate your Salesforce org
sf org login web --alias placement-dev --set-default

# 3. Deploy all metadata
sf project deploy start

# 4. Run tests
sf apex run test --test-level RunLocalTests --result-format human

# 5. Open your org
sf org open
```

### Post-Deployment
1. **Configure Named Credential:** Setup → Named Credentials → `Recruitment_API` → Set endpoint URL
2. **Add to App:** Use Lightning App Builder to add `studentPortal` and `placementDashboard` components
3. **Create Sample Data:** Use Developer Console to create test students and jobs

---

## 📦 What's Inside

| Component | Count | Description |
|-----------|-------|-------------|
| **Apex Classes** | 20 | Controllers, services, trigger handlers, async jobs, REST API |
| **Apex Triggers** | 3 | Application, Student, Job triggers |
| **LWC Components** | 9 | Student Portal, Dashboard, reusable cards |
| **Custom Objects** | 5 | Student, Job, Application, Offer Letter, Integration Log |
| **Test Classes** | 2 | 7 tests, 100% pass rate |
| **Named Credentials** | 1 | External recruitment API integration |

---

## 🧪 Testing

All tests pass with 100% success rate:

```bash
sf apex run test --test-level RunLocalTests --result-format human
```

**Test Coverage:**
- ✅ 6 integration tests (ExternalPlacementServiceTest)
- ✅ 1 service layer test (PlacementServiceTest)
- ✅ End-to-end trigger → callout → logging verified

---

## 📚 Documentation

| Document | Description |
|----------|-------------|
| **[DETAILED-README.md](docs/DETAILED-README.md)** | Complete technical documentation with data model, API reference, and architecture details |
| **[DEPLOYMENT-WORKFLOW.md](docs/DEPLOYMENT-WORKFLOW.md)** | Source-driven deployment guide with Git workflow and best practices |
| **[ARCHITECTURE.md](docs/ARCHITECTURE.md)** | System architecture and design patterns |
| **[FEATURES.md](docs/FEATURES.md)** | Complete feature documentation |

---

## 🔗 Integration

The system integrates with external recruitment platforms via:
- **Outbound Callouts:** Named Credential → HTTP POST when candidate selected
- **REST API Endpoints:** 
  - `GET /placement/jobs` — List all jobs
  - `GET /placement/students` — List all students  
  - `POST /placement/apply` — Submit application
- **Integration Logging:** Every API call logged to `Integration_Log__c`

---

## 🛠️ Tech Stack

- **Platform:** Salesforce (API 67.0)
- **Backend:** Apex (Classes, Triggers, Queueable, Batch, Scheduled)
- **Frontend:** Lightning Web Components (LWC)
- **Automation:** Flows, Process Builder
- **Integration:** REST API, Named Credentials, HTTP Callouts
- **Version Control:** Git + GitHub
- **Deployment:** Salesforce CLI (source-driven)

---

## 🤝 Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

---

## 📄 License

MIT License — see [LICENSE](LICENSE) for details.

---

## 🌟 Acknowledgments

Built as part of the Salesforce Bridge Program - A comprehensive training covering Apex, LWC, integration, and enterprise development patterns.

---

**📧 Contact:** [kaligotlasridattasai18@gmail.com](mailto:kaligotlasridattasai18@gmail.com)  
**🔗 Repository:** [github.com/Sridattasai18/Placement-Management-System](https://github.com/Sridattasai18/Placement-Management-System)
