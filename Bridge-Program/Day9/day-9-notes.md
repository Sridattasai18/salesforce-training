# Day 9 Notes – Bringing Business Logic to Life & Engineering Sprint

## Core Concepts Covered

### Components represent user capabilities
Components should be built around what the user needs to achieve. In our case, the parent component fetches and manages the list of jobs, while the child component encapsulates the view and specific interaction (applying) for a single job.

### Data binding & Wire service
- **Reactive Properties**: LWC uses reactive data binding. Updating a tracked property immediately updates the DOM.
- **Wire Service**: `@wire` is used to read Salesforce data reactively. It's best used for retrieving data because it manages caching and component lifecycle automatically.

### Events & Parent-child communication
- **Child to Parent**: We use `CustomEvent` to communicate from child (`jobCard`) to parent (`eligibleJobs`).
- **Parent to Child**: Data is passed downward using public properties decorated with `@api`.

### Imperative Apex
While `@wire` is great for reading data, **Imperative Apex** is necessary for mutating data (inserts, updates, deletes) or taking actions where you need absolute control over when the call is made (e.g., exactly when the "Apply" button is clicked).

### UI states
A robust LWC component should explicitly handle different states of the application:
1. **Loading**: Show spinners while data is fetching or processing.
2. **Success**: Display the actual data.
3. **Empty**: Show a friendly message when no records are found.
4. **Error**: Display clear, non-technical error messages when things go wrong.

### Why business logic belongs in Apex (Service Layer)
- JavaScript should only handle UI state, formatting, and DOM manipulation.
- Placing business validation in an Apex Service class ensures that the rules are enforced regardless of where the action originates (LWC, API, Flow, Trigger). 
- It prevents logic duplication and makes testing the backend significantly easier.
