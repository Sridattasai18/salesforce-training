trigger ApplicationTrigger on Application__c (before insert) {
    ApplicationTriggerHandler.beforeInsert(Trigger.new);
}
