trigger ApplicationTrigger on Application__c (before insert, after update) {

    // Day 1: Validate CGPA eligibility before a new application is saved
    if (Trigger.isBefore && Trigger.isInsert) {
        ApplicationTriggerHandler.handleBeforeInsert(Trigger.new);
    }

    // Day 11: Sync selected candidates to external recruitment system
    if (Trigger.isAfter && Trigger.isUpdate) {
        ApplicationTriggerHandler.handleAfterUpdate(Trigger.new, Trigger.oldMap);
    }
}
