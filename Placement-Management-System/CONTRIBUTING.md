# Contributing to Placement Management System

Thank you for your interest in contributing! This document provides guidelines for contributing to this project.

## Development Setup

### Prerequisites
- Salesforce CLI installed
- VS Code with Salesforce Extension Pack
- Access to a Salesforce Developer Org
- Git installed

### Initial Setup
```bash
# Clone the repository
git clone <repository-url>
cd Placement-Management-System

# Authorize your Salesforce org
sf org login web --set-default-dev-hub --alias MyDevHub

# Create a scratch org (optional)
sf org create scratch --definition-file config/project-scratch-def.json --alias PMS --set-default

# Deploy the code
sf project deploy start
```

## Project Structure

```
Placement-Management-System/
├── force-app/main/default/
│   ├── classes/          # Apex classes
│   ├── triggers/         # Apex triggers
│   ├── lwc/             # Lightning Web Components
│   ├── objects/         # Custom object metadata
│   └── namedCredentials/ # Integration credentials
├── docs/                # Architecture documentation
├── README.md            # Project overview
├── DEPLOYMENT.md        # Deployment instructions
└── CHANGELOG.md         # Version history
```

## Coding Standards

### Apex
- Follow [Salesforce Apex Style Guide](https://developer.salesforce.com/wiki/apex_code_best_practices)
- Use meaningful variable and method names
- Add inline comments for complex logic
- Keep methods focused (single responsibility)
- Always write bulk-safe code
- Use proper exception handling

**Example:**
```apex
public with sharing class MyService {
    
    // Good: Bulk-safe with clear naming
    public static void updateStudentRecords(List<Student__c> students) {
        Map<Id, Decimal> cgpaMap = new Map<Id, Decimal>();
        
        for (Student__c student : students) {
            if (student.CGPA__c != null) {
                cgpaMap.put(student.Id, student.CGPA__c);
            }
        }
        
        // Process using map...
    }
}
```

### Lightning Web Components
- Follow [LWC Developer Guide](https://developer.salesforce.com/docs/component-library/documentation/en/lwc)
- Use semantic HTML
- Keep component files small and focused
- Use proper naming conventions (camelCase for JS, kebab-case for HTML)
- Add JSDoc comments for public methods
- Handle errors gracefully with try-catch

**Example:**
```javascript
import { LightningElement, api } from 'lwc';

export default class MyComponent extends LightningElement {
    @api recordId;
    
    /**
     * Handles the click event
     * @param {Event} event - The click event
     */
    handleClick(event) {
        try {
            // Component logic
        } catch (error) {
            this.handleError(error);
        }
    }
}
```

### Triggers
- Keep triggers minimal (delegate to handlers)
- One trigger per object
- Use trigger handler pattern
- Always handle bulk operations

**Example:**
```apex
trigger MyObjectTrigger on MyObject__c (before insert, before update) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert || Trigger.isUpdate) {
            MyObjectTriggerHandler.beforeSave(Trigger.new);
        }
    }
}
```

## Testing Requirements

### Minimum Requirements
- All Apex classes must have test coverage
- Minimum 75% code coverage (aim for 85%+)
- Test both positive and negative scenarios
- Test bulk operations (200+ records)
- Use Test.startTest() and Test.stopTest()

**Example:**
```apex
@isTest
private class MyServiceTest {
    
    @testSetup
    static void setup() {
        // Create test data
    }
    
    @isTest
    static void testBulkOperation() {
        List<Student__c> students = new List<Student__c>();
        
        for (Integer i = 0; i < 200; i++) {
            students.add(new Student__c(
                Name = 'Student ' + i,
                CGPA__c = 7.5
            ));
        }
        
        Test.startTest();
        insert students;
        Test.stopTest();
        
        // Assertions
        System.assertEquals(200, [SELECT COUNT() FROM Student__c]);
    }
}
```

## Commit Message Format

Use clear, descriptive commit messages:

```
[Component] Brief description

Detailed explanation (if needed)

- Bullet point 1
- Bullet point 2
```

**Examples:**
- `[Apex] Add StudentService.getEligibleJobs method`
- `[LWC] Fix refresh bug in myApplications component`
- `[Trigger] Update ApplicationTriggerHandler for bulk processing`
- `[Docs] Update README with API endpoints`

## Pull Request Process

1. Create a feature branch from `main`
   ```bash
   git checkout -b feature/my-feature
   ```

2. Make your changes following the coding standards

3. Write/update tests for your changes

4. Run tests locally
   ```bash
   sf apex run test --test-level RunLocalTests --result-format human
   ```

5. Update documentation if needed

6. Commit your changes with clear messages

7. Push to your branch
   ```bash
   git push origin feature/my-feature
   ```

8. Create a Pull Request with:
   - Clear title and description
   - Link to related issues
   - List of changes made
   - Screenshots (for UI changes)

## Code Review Guidelines

### As a Reviewer
- Check for code quality and standards compliance
- Verify test coverage
- Look for potential governor limit issues
- Ensure bulk-safe operations
- Check for security issues (CRUD/FLS, sharing rules)
- Provide constructive feedback

### As a Contributor
- Respond to feedback promptly
- Make requested changes
- Re-request review when ready
- Keep discussions professional

## Reporting Issues

When reporting bugs, include:
- Clear description of the issue
- Steps to reproduce
- Expected vs actual behavior
- Screenshots (if applicable)
- Salesforce org type (production, sandbox, scratch)
- Error messages and logs

## Feature Requests

For new features, provide:
- Use case and business value
- Proposed solution
- Any alternative approaches considered
- Impact on existing functionality

## Documentation

Update documentation when:
- Adding new features
- Changing existing functionality
- Updating API endpoints
- Modifying architecture

## Questions?

If you have questions about contributing:
- Check existing documentation in `/docs`
- Review closed issues for similar discussions
- Open a new issue with the "question" label

---

Thank you for contributing to the Placement Management System!
