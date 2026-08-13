# Salesforce Training - Bridge Program

This repository contains my 11-day Salesforce learning journey with daily training notes and a complete placement management project.

---

## 📁 What's Inside

### 📚 Bridge-Program/
**Daily training notes and tasks (Day 1-11)**

My day-by-day learning progression with code samples, notes, and screenshots for each day's topic.

- **Day 1**: Data model basics (Student, Job, Application objects), SOQL, first trigger
- **Day 2**: Collections, bulkification, handler pattern, service layer
- **Day 3**: Validation rules, flows, declarative automation
- **Day 4**: Lightning Web Components - placement dashboard
- **Day 5**: Service architecture and Apex-LWC integration
- **Day 6**: Enterprise trigger framework
- **Day 7**: Performance optimization, analytics, bulk processing
- **Day 8**: Asynchronous Apex (Queueable, Batch, Scheduled)
- **Day 9**: Interactive student portal with job filtering
- **Day 10**: Multi-component communication and Lightning Data Service
- **Day 11**: REST API integration

---

### 🚀 Placement-Management-System/
**Combined project folder - All Days 1-11 integrated**

Complete Salesforce placement management system combining everything learned across all 11 days into a single production-ready project.

**Components:**
- 19 Apex classes
- 3 triggers
- 9 LWC components
- 5 custom objects
- REST API endpoints
- Complete documentation

**Deploy:**
```bash
cd Placement-Management-System
sf org login web --alias MyOrg
sf project deploy start
```

See [QUICK-START.md](Placement-Management-System/QUICK-START.md) for setup guide.

---

## 🚀 Quick Clone & Deploy

```bash
git clone https://github.com/Sridattasai18/salesforce-training.git
cd salesforce-training/Placement-Management-System
sf org login web --alias MyOrg
sf project deploy start
```

---

## 📚 Documentation

**Placement-Management-System:**
- [README.md](Placement-Management-System/README.md) - Complete project overview
- [QUICK-START.md](Placement-Management-System/QUICK-START.md) - 5-minute setup
- [API-REFERENCE.md](Placement-Management-System/API-REFERENCE.md) - REST API documentation

**Bridge-Program:**  
Each day folder contains notes, code samples, and screenshots for that day's learning.
