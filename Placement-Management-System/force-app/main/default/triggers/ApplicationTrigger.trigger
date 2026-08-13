trigger ApplicationTrigger on Application__c (
    before insert,
    after insert
) {

    if (Trigger.isBefore && Trigger.isInsert) {
        ApplicationTriggerHandler.beforeInsert(Trigger.new);
    }

    if (Trigger.isAfter && Trigger.isInsert) {
        ApplicationTriggerHandler.afterInsert(Trigger.new);
    }
}
