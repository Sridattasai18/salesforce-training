# Expected Output

When deploying and adding the `eligibleJobs` component to a Lightning Page (e.g., App Page or Home Page), you should see the following behavior based on the configured org data:

1. **On Initial Load**:
   - A loading spinner will appear while jobs are fetched from Salesforce.

2. **When Eligible Jobs Exist**:
   - The UI will display a grid of Job Cards.
   - Each card will display the Company, Role, Package, Location, and Deadline.
   - Each card will have a "View Details" button and an "Apply" button.

3. **When Applying**:
   - Clicking "Apply" on a job will immediately show a loading spinner over the component.
   - The "Apply" button will temporarily disable.
   - If successful: A green success toast reading "Application submitted successfully!" will appear. The job list will refresh.
   - If validation fails (e.g., deadline passed, too many backlogs, duplicate app): A red error toast will appear displaying the business-friendly error message, e.g., "You have already applied for this job."

4. **Empty State**:
   - If the student does not qualify for any jobs, or if no jobs exist, the UI will display: "No eligible jobs available at the moment." with an info icon.

5. **Error State**:
   - If the Apex controller completely fails to execute (e.g., due to a permissions issue), the component body will display a red error message icon and text.
