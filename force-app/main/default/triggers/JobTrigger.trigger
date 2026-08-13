trigger JobTrigger on Job__c (
    before insert,
    before update
) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert || Trigger.isUpdate) {
            JobTriggerHandler.beforeSave(Trigger.new);
        }
    }
}
