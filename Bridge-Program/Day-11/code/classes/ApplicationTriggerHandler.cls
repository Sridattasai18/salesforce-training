public class ApplicationTriggerHandler {
    
    public static void handleAfterUpdate(List<Application__c> newList, Map<Id, Application__c> oldMap) {
        List<Id> selectedAppIds = new List<Id>();
        
        for (Application__c app : newList) {
            Application__c oldApp = oldMap.get(app.Id);
            
            // Detect status change to 'Selected'
            if (oldApp.Status__c != 'Selected' && app.Status__c == 'Selected') {
                selectedAppIds.add(app.Id);
            }
        }
        
        // Enqueue async job if candidates were selected
        if (!selectedAppIds.isEmpty()) {
            System.enqueueJob(new CandidateSyncJob(selectedAppIds));
        }
    }
}
