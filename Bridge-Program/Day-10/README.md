# Day 10 - Multi-Component Student Placement Portal

## Connection from Day 9 → Day 10

### What Day 9 Built
Day 9 implemented **one isolated business capability**:
- View eligible jobs based on student criteria
- Apply for a job with validation
- Two-component architecture: `eligibleJobs` (parent) + `jobCard` (child)

### What Day 10 Builds
Day 10 transforms the isolated feature into a **complete integrated dashboard** by:
- Creating a parent coordinator (`StudentPortal`)
- Adding student profile management
- Displaying application history
- Coordinating refresh behavior across all components
- Maintaining component reusability

**Key Principle:** Day 10 **reuses** the existing Day 9 components (`eligibleJobs`, `jobCard`) without modification. It wraps them in a larger context and adds complementary features.

---

## Architecture Overview

### Component Hierarchy
```
StudentPortal (new coordinator/container)
├── StudentSummary (displays current student info)
├── StudentProfileForm (edits student record)
├── EligibleJobs (reused from Day 9)
│   └── JobCard (reused from Day 9)
├── MyApplications (shows submitted applications)
│   └── ApplicationCard (displays single application)
```

### Data Flow

**Parent → Child (Props via @api)**
```
StudentPortal
  ↓ studentId
StudentSummary, StudentProfileForm, EligibleJobs, MyApplications
  ↓ job
JobCard
```

**Child → Parent (Custom Events)**
```
StudentProfileForm fires 'profileupdated'
  ↓
StudentPortal catches event
  ↓
Refreshes StudentSummary and EligibleJobs

EligibleJobs fires 'applicationcreated'
  ↓
StudentPortal catches event
  ↓
Refreshes MyApplications
```

---

## Components

### 1. StudentPortal (Container/Coordinator)
**Purpose:** Top-level container that coordinates all student-facing features

**Responsibilities:**
- Host all child components
- Pass shared state (studentId) to children
- Listen for custom events from children
- Coordinate refresh actions across components
- Maintain consistent UI state

**Does NOT:**
- Contain business logic
- Make Apex calls directly (delegates to children)
- Manipulate child component internals

---

### 2. StudentSummary (Read-Only Display)
**Purpose:** Display current student information

**Data Source:** Lightning Data Service (LDS) via `lightning-record-view-form`

**Displays:**
- Student Name
- Department
- CGPA
- Email

**Refresh Trigger:** Receives refresh signal from parent after profile update

---

### 3. StudentProfileForm (Editable Form)
**Purpose:** Allow student to edit their profile

**Data Source:** Lightning Data Service (LDS) via `lightning-record-edit-form`

**Fields:**
- Name
- Email__c
- Department__c
- CGPA__c

**Features:**
- Required field validation
- CGPA range validation
- Save button
- Cancel button
- Success/Error toast messages

**Custom Event:** Fires `profileupdated` event to parent on successful save

**Advantages of LDS:**
- No custom Apex needed
- Automatic field-level security
- Built-in validation
- Optimistic UI updates

---

### 4. EligibleJobs (Reused from Day 9)
**Purpose:** Display eligible jobs and handle application submission

**No Changes Required** - Component works as-is in Day 10 context

**Enhancement for Day 10:**
- Fires `applicationcreated` event to parent after successful application
- Parent can coordinate refresh of MyApplications component

**Existing Features:**
- @wire getEligibleJobs
- 4 UI states (loading, success, empty, error)
- Handles apply event from JobCard
- Imperative Apex for submitApplication
- Toast notifications
- refreshApex after application

---

### 5. JobCard (Reused from Day 9)
**Purpose:** Display single job information with Apply button

**No Changes Required** - Component works as-is in Day 10 context

**Existing Features:**
- Receives @api job from parent
- Displays: Company, Location, Salary, Deadline
- Apply button with disabled state
- Dispatches CustomEvent('apply')

---

### 6. MyApplications (New Component)
**Purpose:** Display current student's submitted applications

**Data Source:** 
- Option A: @wire Apex method `getMyApplications(studentId)`
- Option B: LDS with filtered view

**Displays:**
- List of Application__c records
- Each application rendered by ApplicationCard child component

**Refresh Trigger:** Receives refresh signal from parent after new application submitted

---

### 7. ApplicationCard (New Component)
**Purpose:** Display single application record

**Displays:**
- Job Name
- Company
- Status__c
- Application_Date__c

**Optional Actions:**
- View Details button
- Withdraw button (future enhancement)

---

## Communication Patterns

### Pattern 1: Parent → Child (Data Down)
```javascript
// Parent passes data via @api
<c-student-summary student-id={currentStudentId}></c-student-summary>
<c-eligible-jobs student-id={currentStudentId}></c-eligible-jobs>
```

### Pattern 2: Child → Parent (Events Up)
```javascript
// Child fires event
const event = new CustomEvent('profileupdated', {
    detail: { studentId: this.studentId }
});
this.dispatchEvent(event);

// Parent listens
<c-student-profile-form onprofileupdated={handleProfileUpdate}>
```

### Pattern 3: Sibling Communication (via Parent)
```
Child A fires event → Parent catches → Parent triggers refresh on Child B
```

---

## Refresh Coordination Strategy

### Scenario 1: Profile Updated
```
StudentProfileForm saves record
  ↓
Fires 'profileupdated' event
  ↓
StudentPortal catches event
  ↓
Triggers refresh on:
  - StudentSummary (shows new data)
  - EligibleJobs (filters may change based on new CGPA)
```

### Scenario 2: Application Submitted
```
EligibleJobs submits application
  ↓
Fires 'applicationcreated' event
  ↓
StudentPortal catches event
  ↓
Triggers refresh on:
  - MyApplications (shows new application)
  - EligibleJobs (already refreshes itself via refreshApex)
```

### Implementation Options

**Option A: RefreshApex (for @wire components)**
```javascript
handleProfileUpdate() {
    refreshApex(this.wiredStudentResult);
    refreshApex(this.wiredJobsResult);
}
```

**Option B: Custom Refresh Method (via @api)**
```javascript
// In parent
handleProfileUpdate() {
    this.template.querySelector('c-eligible-jobs').refreshJobs();
    this.template.querySelector('c-my-applications').refreshApplications();
}

// In child
@api
refreshJobs() {
    return refreshApex(this.wiredJobsResult);
}
```

**Option C: Refresh Signal (via property change)**
```javascript
// In parent
@track refreshSignal = 0;

handleProfileUpdate() {
    this.refreshSignal++; // trigger child watchers
}

// Pass to child
<c-eligible-jobs refresh-signal={refreshSignal}></c-eligible-jobs>

// In child
@api refreshSignal;

@wire(getEligibleJobs)
wiredJobs({ data, error }) {
    // Automatically re-fires when refreshSignal changes
}
```

---

## Apex Controller Extensions (if needed)

### ApplicationController.cls (Potential Additions)

```apex
@AuraEnabled(cacheable=true)
public static Student__c getCurrentStudent() {
    // Return first student for demo
    // In production: use User lookup
}

@AuraEnabled(cacheable=true)
public static List<Application__c> getMyApplications(Id studentId) {
    return [
        SELECT Id, Name, Job__c, Job__r.Name, Job__r.Company__c,
               Status__c, Application_Date__c
        FROM Application__c
        WHERE Student__c = :studentId
        WITH SECURITY_ENFORCED
        ORDER BY Application_Date__c DESC
    ];
}
```

**Note:** Profile editing uses LDS, so no Apex needed for that functionality.

---

## Engineering Decisions

### Why Reuse Day 9 Components?
- **Production Reality:** Don't rebuild working code
- **Component Reusability:** Same component works in different contexts
- **Maintainability:** Single source of truth for job display and application logic
- **Learning Outcome:** Understanding component composition over component creation

### Why Use LDS for Profile Management?
- **Less Code:** No custom Apex for CRUD operations
- **Automatic Security:** Field-level security enforced by platform
- **Standard UX:** Consistent with Salesforce editing patterns
- **Optimistic UI:** Instant feedback, background save

### Why Introduce StudentPortal Container?
- **Separation of Concerns:** Coordinator vs Worker components
- **Scalability:** Easy to add new features without refactoring children
- **State Management:** Single point of control for shared state
- **Event Orchestration:** Centralized event handling

---

## What I Learned (Day 10)

### Component Communication
- **Props (@api)** for passing data down the component tree
- **Custom Events** for notifying parents of state changes
- **Event bubbling** to traverse component hierarchy
- **Refresh coordination** to keep sibling components in sync

### Component Architecture Patterns
- **Container/Presentational** pattern (Smart vs Dumb components)
- **Component composition** over component sprawl
- **Reusability** through clear component contracts (@api properties, named events)

### Lightning Data Service
- When to use LDS vs custom Apex
- Benefits of declarative data loading
- How LDS handles caching and refresh
- Field-level security and validation

### Real-World LWC Development
- Building feature families, not isolated components
- Coordinating multiple data sources
- Managing refresh behavior across components
- Balancing declarative vs programmatic approaches

---

## Testing Checklist

### StudentSummary
- [ ] Displays current student information correctly
- [ ] Refreshes when profile is updated
- [ ] Handles missing student gracefully

### StudentProfileForm
- [ ] Pre-populates with current student data
- [ ] Validates required fields
- [ ] Validates CGPA range (0-10)
- [ ] Shows success toast on save
- [ ] Shows error toast on failure
- [ ] Fires profileupdated event
- [ ] Cancel button discards changes

### EligibleJobs (Existing)
- [ ] Shows eligible jobs based on CGPA
- [ ] Apply button creates Application__c
- [ ] Refreshes job list after application
- [ ] Shows empty state when no eligible jobs
- [ ] Fires applicationcreated event (new)

### MyApplications
- [ ] Shows student's submitted applications
- [ ] Displays correct job and status information
- [ ] Refreshes when new application submitted
- [ ] Shows empty state when no applications

### StudentPortal Integration
- [ ] All child components render correctly
- [ ] Profile update triggers refresh of StudentSummary and EligibleJobs
- [ ] Application submission triggers refresh of MyApplications
- [ ] No console errors
- [ ] Proper loading states

---

## Deployment Instructions

1. **Copy Day 9 Components** (if not already in force-app):
   ```
   force-app/main/default/lwc/eligibleJobs/
   force-app/main/default/lwc/jobCard/
   ```

2. **Add Day 10 Components**:
   ```
   force-app/main/default/lwc/studentPortal/
   force-app/main/default/lwc/studentSummary/
   force-app/main/default/lwc/studentProfileForm/
   force-app/main/default/lwc/myApplications/
   force-app/main/default/lwc/applicationCard/
   ```

3. **Update ApplicationController.cls** (if adding getMyApplications):
   ```
   force-app/main/default/classes/ApplicationController.cls
   ```

4. **Deploy to Org**:
   ```bash
   sf project deploy start --source-dir force-app
   ```

5. **Add to Lightning Page**:
   - Create new Lightning Page or edit existing
   - Add `studentPortal` component to page
   - Activate and assign to Student Profile

6. **Test the Flow**:
   - View student summary
   - Edit profile → verify summary and eligible jobs refresh
   - Apply for job → verify application appears in MyApplications
   - Check all 4 sections display correctly

---

## Future Enhancements (Beyond Day 10)

- User authentication (connect to actual logged-in user)
- Application withdrawal functionality
- Job search and filtering
- Application status tracking
- Email notifications
- Mobile-responsive layout improvements
- Accessibility enhancements
- Error logging and monitoring

  