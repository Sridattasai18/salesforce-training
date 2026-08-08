# Day 9 Notes: Bulk-Safe Trigger Architecture

## What is bulkification?
Bulkification is the process of designing Apex code so that it can process multiple records in a single transaction using collections, bulk SOQL, and bulk DML operations.

## Why use a Trigger Handler?
A Trigger Handler keeps triggers small and delegates business logic to separate classes, improving readability, testing, and maintainability.

## Why use Maps in Apex?
Maps provide fast lookup by record Id and allow previously queried records to be reused without executing additional SOQL queries.

## Difference between Trigger.new and Trigger.old
* **Trigger.new** contains the new version of records.
* **Trigger.old** contains the previous version of records.

## Key Learning Outcomes
* Triggers always receive collections of records.
* SOQL should never be written inside loops.
* DML should never be written inside loops.
* Sets help remove duplicate IDs automatically.
* Maps prevent repeated queries and improve performance.
* Trigger.oldMap is essential for detecting real business changes.
* Thin triggers and reusable service classes create maintainable Salesforce applications.
* Bulk-safe design is required for production Salesforce development.
