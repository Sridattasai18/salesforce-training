public with sharing class ApplicationTriggerHandler {

    public static void beforeInsert(List<Application__c> applications) {
        ApplicationService.validateApplications(applications);
    }
}
