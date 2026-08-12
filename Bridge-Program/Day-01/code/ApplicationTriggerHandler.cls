public class ApplicationTriggerHandler {

    // Day 1: Block applications where student CGPA is below job minimum
    public static void handleBeforeInsert(List<Application__c> newList) {

        // Collect all student and job IDs first (bulk-safe: no queries in loops)
        Set<Id> studentIds = new Set<Id>();
        Set<Id> jobIds = new Set<Id>();

        for (Application__c app : newList) {
            if (app.Student__c != null) studentIds.add(app.Student__c);
            if (app.Job__c != null)     jobIds.add(app.Job__c);
        }

        // One query for students, one for jobs
        Map<Id, Student__c> studentMap = new Map<Id, Student__c>(
            [SELECT Id, Name, CGPA__c FROM Student__c WHERE Id IN :studentIds]
        );

        Map<Id, Job__c> jobMap = new Map<Id, Job__c>(
            [SELECT Id, Name, Minimum_CGPA__c FROM Job__c WHERE Id IN :jobIds]
        );

        // Validate each application
        for (Application__c app : newList) {
            Student__c student = studentMap.get(app.Student__c);
            Job__c     job     = jobMap.get(app.Job__c);

            if (student != null && job != null) {
                if (student.CGPA__c < job.Minimum_CGPA__c) {
                    app.addError(
                        'Student is not eligible for this job because the CGPA requirement is not met.'
                    );
                }
            }
        }
    }

    // Day 11: Enqueue async job when application status changes to Selected
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
