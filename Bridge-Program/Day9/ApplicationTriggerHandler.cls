public class ApplicationTriggerHandler{

    public static void beforeInsert(
        List<Application__c> applications
    ){
        ApplicationService.validateApplications(
            applications
        );
    }

    public static void beforeUpdate(
        List<Application__c> applications,
        Map<Id, Application__c> oldMap
    ){
        ApplicationService.handleStatusUpdates(
            applications,
            oldMap
        );
    }

    public static void afterUpdate(
        List<Application__c> applications,
        Map<Id, Application__c> oldMap
    ){
        PlacementStatusService.processSelections(
            applications,
            oldMap
        );
    }
}
