### Insert Operation

Rahul → Salesforce

```text
CGPA: 8.2
Required: 7.5
Backlogs: 0
Allowed: 0

Status: Applied

Result:
Application inserted successfully.
```

Ananya → Salesforce

```text
CGPA: 7.1
Required: 7.5

Result:
Student CGPA is below the minimum requirement.
```

Kiran → TCS

```text
CGPA: 6.4
Required: 6.5

Result:
Student CGPA is below the minimum requirement.
```

### Bulk Insert Result

| Student | Job        | Status  |
| ------- | ---------- | ------- |
| Rahul   | Salesforce | Applied |
| Ananya  | Salesforce | Error   |
| Kiran   | TCS        | Error   |

### Update Operation

When an application changes from Interview Scheduled → Selected:

```text
Old Status:
Interview Scheduled

New Status:
Selected

Result:
Student Placement_Status__c updated to 'Placed'
Last_Status_Change__c updated with today’s date
After-update processing completed successfully.
```
