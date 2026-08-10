# Day 10 Notes – Multi-Component Communication & Coordination

## Core Concepts Covered

### Component Communication Patterns

**1. Parent → Child (Props via @api)**
- Parent components pass data down to children using `@api` decorated properties
- Children receive data reactively and re-render when values change
- Example: `studentId` passed from `StudentPortal` to all child components

```javascript
// Parent
<c-student-summary student-id={currentStudentId}></c-student-summary>

// Child
@api studentId;
```

**2. Child → Parent (Custom Events)**
- Children dispatch custom events to notify parents of actions
- Parents listen for events and coordinate responses
- Events use the `CustomEvent` API with detail payload

```javascript
// Child dispatches
const event = new CustomEvent('profileupdated', {
    detail: { studentId: this.studentId }
});
this.dispatchEvent(event);

// Parent listens
<c-student-profile-form onprofileupdated={handleProfileUpdate}>

// Parent handles
handleProfileUpdate(event) {
    const studentId = event.detail.studentId;
    // coordinate refresh
}
```

**3. Sibling Communication (via Parent Coordinator)**
- Siblings do not communicate directly
- Parent acts as message broker
- Pattern: Child A fires event → Parent catches → Parent triggers Child B refresh

```
ProfileForm saves
  ↓ fires 'profileupdated'
StudentPortal catches event
  ↓ calls refresh methods
StudentSummary + EligibleJobs refresh
```

### Lightning Data Service (LDS)

**Why Use LDS?**
- Automatic data caching and sharing across components
- No custom Apex needed for standard CRUD operations
- Built-in field-level security and sharing rules
- Optimistic UI updates for better UX
- Reduces server round trips

**When to Use LDS vs Custom Apex**
- **LDS:** Single record operations (view, edit, create)
- **Apex:** Filtered queries, aggregations, cross-object queries, business logic

**LDS Components Used:**
- `lightning-record-view-form` - Read-only display
- `lightning-record-edit-form` - Editable form with save/cancel
- `lightning-output-field` - Display single field
- `lightning-input-field` - Editable field with validation

### Refresh Coordination

**Challenge:** Multiple components display related data that can become stale

**Solution:** Coordinator pattern where parent orchestrates refreshes

**Techniques:**
1. **RefreshApex** - For @wire methods
2. **Public @api methods** - Child exposes refresh method
3. **Refresh signals** - Incrementing property triggers reactivity

**Refresh Flow Example:**
```
Student updates profile
  ↓
ProfileForm fires 'profileupdated' event
  ↓
StudentPortal catches event and:
  - Increments refreshSignal (triggers StudentSummary via LDS)
  - Calls eligibleJobs.refreshJobs() (triggers @wire refresh)
  ↓
All components show updated data
```

### Component Reusability

**Principles:**
- **Single Responsibility:** Each component has one clear purpose
- **Loose Coupling:** Components communicate through events, not direct references
- **No Assumptions:** Child components don't know about parent's structure
- **Public Contracts:** @api properties and events define component interface

**Day 10 Reusability Examples:**
- `eligibleJobs` and `jobCard` reused from Day 9 without modification
- `applicationCard` can be used in different contexts
- `studentSummary` can be placed anywhere needing student display
- Components work standalone or in portal

### Container/Presentational Pattern

**Container Components (Smart):**
- Manage state and data fetching
- Coordinate child component interactions
- Handle business logic and events
- Example: `StudentPortal`, `EligibleJobs`, `MyApplications`

**Presentational Components (Dumb):**
- Display data passed via props
- Dispatch events for user actions
- No direct data fetching or business logic
- Example: `JobCard`, `ApplicationCard`, `StudentSummary`

## Architecture Decisions

### Why StudentPortal as Coordinator?
- **Centralized Control:** Single point for managing portal state
- **Event Hub:** All child events flow through one handler
- **Scalability:** Easy to add new sections without modifying existing children
- **Testability:** Can test coordination logic independently

### Why Reuse Day 9 Components?
- **Real-world Pattern:** Production code extends existing features
- **Less Code:** No duplication, single source of truth
- **Compatibility:** Proves components are truly reusable
- **Maintainability:** Bug fixes apply everywhere

### Why Use Both LDS and Custom Apex?
- **LDS for Simple Operations:** Profile viewing/editing
- **Apex for Complex Queries:** Eligible jobs with business rules, applications list
- **Best Tool for Job:** Use platform features when possible, custom code when needed

## Component Breakdown

### StudentPortal
**Role:** Container/Coordinator
**Data Management:** Loads current student, passes to children
**Event Handling:** 
- `profileupdated` → refresh summary and jobs
- `applicationcreated` → refresh applications
**No UI Logic:** Just layout and coordination

### StudentSummary
**Role:** Presentational
**Data Source:** LDS via `lightning-record-view-form`
**Displays:** Name, Email, Department, CGPA
**Reactive:** Refreshes when studentId or refreshSignal changes

### StudentProfileForm
**Role:** Container (manages form state)
**Data Source:** LDS via `lightning-record-edit-form`
**Features:** Edit student fields, validation, save/cancel
**Event:** Fires `profileupdated` on successful save

### EligibleJobs (from Day 9)
**Role:** Container (manages jobs list and application)
**Data Source:** @wire Apex `getEligibleJobs()`
**Enhancement:** Now fires `applicationcreated` event
**Public Method:** `refreshJobs()` for parent-triggered refresh

### JobCard (from Day 9)
**Role:** Presentational
**Displays:** Single job information
**Event:** Fires `apply` event with jobId

### MyApplications
**Role:** Container
**Data Source:** @wire Apex `getMyApplications(studentId)`
**Displays:** List of ApplicationCard components
**Refresh:** Watches refreshSignal property

### ApplicationCard
**Role:** Presentational
**Displays:** Single application (job name, company, status, date)
**Formatting:** Friendly date, status badge with color

## Communication Flow Examples

### Flow 1: Profile Update
```
1. User edits CGPA in StudentProfileForm
2. User clicks "Save Profile"
3. LDS saves to Salesforce
4. StudentProfileForm.handleSuccess() fires
5. ShowToastEvent displays "Profile updated"
6. CustomEvent('profileupdated') dispatched
7. StudentPortal.handleProfileUpdate() catches event
8. StudentPortal increments refreshSignal
9. StudentSummary re-renders with new data (LDS auto-refresh)
10. StudentPortal calls eligibleJobs.refreshJobs()
11. EligibleJobs refreshApex re-queries eligible jobs
12. New eligible jobs appear (CGPA changed eligibility)
```

### Flow 2: Application Submission
```
1. User clicks "Apply" on JobCard
2. JobCard fires CustomEvent('apply') with jobId
3. EligibleJobs.handleApply() catches event
4. EligibleJobs calls submitApplication(jobId) - imperative Apex
5. ApplicationController → ApplicationService validates and creates Application__c
6. Success: EligibleJobs shows toast, calls refreshApex
7. EligibleJobs fires CustomEvent('applicationcreated')
8. StudentPortal.handleApplicationCreated() catches event
9. StudentPortal increments applicationRefreshSignal
10. MyApplications watches signal change, triggers refresh
11. New application appears in MyApplications list
```

## Key Learnings

### Component Architecture
- Components should be small, focused, and composable
- Communication patterns enable loose coupling
- Container/Presentational split clarifies responsibilities
- Public APIs (@api, events) define component contracts

### Data Management
- Use LDS for simple record operations
- Use @wire for reactive queries
- Use imperative Apex for mutations
- Coordinate refreshes at parent level

### Event-Driven Design
- Events flow up, data flows down
- Parents coordinate, children notify
- Custom events decouple components
- Event naming should describe business action

### Production Patterns
- Reuse existing code when possible
- Extend features, don't rebuild
- Keep business logic in Apex
- Use platform features (LDS) over custom code

## Common Pitfalls Avoided

### ❌ Don't: Tight Coupling
```javascript
// Bad: Child reaches into parent
this.template.querySelector('c-parent').doSomething();
```

### ✅ Do: Event-Based Communication
```javascript
// Good: Child fires event
this.dispatchEvent(new CustomEvent('action'));
```

### ❌ Don't: Duplicate Business Logic
```javascript
// Bad: Validation in both Apex and JS
if (cgpa < minCGPA) { // in JS
```

### ✅ Do: Single Source of Truth
```apex
// Good: Validation only in Apex Service
if (student.CGPA__c < job.Minimum_CGPA__c) {
```

### ❌ Don't: Direct Sibling Communication
```javascript
// Bad: Component A calls Component B directly
this.template.querySelector('c-sibling').refresh();
```

### ✅ Do: Parent-Coordinated Refresh
```javascript
// Good: A fires event, parent tells B to refresh
handleEvent() {
    this.template.querySelector('c-sibling').refresh();
}
```

## Testing Strategy

### Component-Level Testing
- Test each component in isolation with mock data
- Verify @api properties work correctly
- Verify events fire with correct detail
- Test all UI states (loading, success, error, empty)

### Integration Testing
- Test parent-child communication
- Verify refresh coordination works
- Test event bubbling through hierarchy
- Verify data consistency after mutations

### Manual Testing Checklist
- [ ] Profile displays correctly
- [ ] Profile edits save successfully
- [ ] Profile update refreshes summary
- [ ] Profile update refreshes eligible jobs
- [ ] Job application creates record
- [ ] Application appears in MyApplications
- [ ] All components show empty states correctly
- [ ] Error states display user-friendly messages
- [ ] Loading spinners appear during operations

## What Day 10 Taught Us

1. **Component Composition** - Building complex UIs from simple, reusable pieces
2. **Communication Patterns** - Props down, events up, parent coordinates
3. **State Management** - Who owns what data, and who can change it
4. **Refresh Strategies** - Keeping related data synchronized
5. **LDS Benefits** - When to use declarative vs programmatic approaches
6. **Production Thinking** - Extending existing code rather than rewriting

