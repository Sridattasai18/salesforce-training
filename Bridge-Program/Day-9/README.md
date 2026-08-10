# Day 9 - LWC Sprint: Student Placement Portal

## Business Problem
The objective of this sprint is to build a modern, responsive portal for students to view and apply for jobs they are eligible for. The application process should ensure students meet strict criteria before allowing submission, preventing duplicate or invalid applications.

## Architecture
This project follows a clean separation of concerns using Salesforce best practices:
- **UI Layer (LWC)**: Composed of `eligibleJobs` (Parent) and `jobCard` (Child). Handles user interaction, state management, and display.
- **Controller Layer (Apex Controller)**: `ApplicationController.cls` serves as the bridge between LWC and backend logic. It exposes methods via `@AuraEnabled`.
- **Service Layer (Apex Service)**: `ApplicationService.cls` encapsulates all business logic, validation, and DML operations.

## Component Hierarchy
- `eligibleJobs` (Container/Parent)
  - Manages data retrieval (`@wire`).
  - Manages loading, success, empty, and error states.
  - Listens for events from child components and coordinates imperative Apex calls.
  - `jobCard` (Presentational/Child)
    - Displays details for a single job.
    - Dispatches standard custom events to notify the parent of user actions (e.g., clicking "Apply").

## Data Flow
1. **Load Data**: The parent component `eligibleJobs` uses the `@wire` service to call `ApplicationController.getEligibleJobs()` and load records proactively.
2. **User Interaction**: User clicks "Apply" on a `jobCard`.
3. **Event Bubbling**: The child component dispatches a CustomEvent (`apply`) containing the `jobId`.
4. **Processing**: The parent component catches the event, displays a loading spinner, and invokes imperative Apex (`submitApplication`).
5. **Business Logic**: The controller routes the call to `ApplicationService`, which validates rules and performs DML.
6. **Refresh**: Upon success, a toast is shown, and the UI is refreshed via `refreshApex`.

## Apply Workflow
`Student Clicks Apply` → `jobCard dispatches event` → `eligibleJobs receives event` → `Imperative Apex call` → `ApplicationController.submitApplication()` → `ApplicationService` → `Application__c created` → `Toast message shown` → `UI refreshed`

## Engineering Decisions
- **Thick Service, Thin Controller**: Moved business validation logic (duplicate checks, CGPA, backlogs, deadline) strictly into the `ApplicationService`. This promotes code reusability (e.g., if we ever build an API or Flow to do the same thing).
- **Graceful Error Handling**: Custom exceptions thrown by the service are caught by the controller and translated into `AuraHandledException` so they display user-friendly messages on the frontend, rather than ugly Apex stack traces.
- **Bulkification & SOQL**: Even though the current LWC flow is single-record based, standard patterns (no DML/SOQL in loops) are respected conceptually, setting up a solid foundation.
- **Encapsulated UI States**: Explicit state booleans (`isLoading`, `error`) are used to conditionally render parts of the HTML to guarantee a smooth UX.

## What I Learned
- Parent-child communication in LWC is robust when following standard DOM event patterns.
- Business logic is drastically easier to test and maintain when completely decoupled from the `@AuraEnabled` endpoints.
- Proper error bubbling and user notification via toasts are critical for modern single-page applications.
