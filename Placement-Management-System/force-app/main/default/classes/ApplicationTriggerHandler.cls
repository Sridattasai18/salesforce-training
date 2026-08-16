public with sharing class ApplicationTriggerHandler {

    public static void beforeInsert(List<Application__c> applications) {

        Set<Id> studentIds = new Set<Id>();
        Set<Id> jobIds = new Set<Id>();

        for (Application__c app : applications) {
            if (app.Student__c != null) studentIds.add(app.Student__c);
            if (app.Job__c != null)     jobIds.add(app.Job__c);
        }

        Map<Id, Student__c> studentMap = new Map<Id, Student__c>(
            [
                SELECT Id, CGPA__c, Active_Backlogs__c
                FROM Student__c
                WHERE Id IN :studentIds
            ]
        );

        Map<Id, Job__c> jobMap = new Map<Id, Job__c>(
            [
                SELECT Id, Minimum_CGPA__c, Allowed_Backlogs__c
                FROM Job__c
                WHERE Id IN :jobIds
            ]
        );

        Set<String> existingApplications = new Set<String>();

        for (Application__c existing : [
            SELECT Student__c, Job__c
            FROM Application__c
            WHERE Student__c IN :studentIds
            AND Job__c IN :jobIds
        ]) {
            existingApplications.add(existing.Student__c + '-' + existing.Job__c);
        }

        for (Application__c app : applications) {

            Student__c student = studentMap.get(app.Student__c);
            Job__c job         = jobMap.get(app.Job__c);

            if (student == null || job == null) continue;

            if (student.CGPA__c < job.Minimum_CGPA__c) {
                app.addError('You are not eligible for this job. Your CGPA (' + 
                    student.CGPA__c + ') is below the required minimum (' + job.Minimum_CGPA__c + ').');
            }

            if (student.Active_Backlogs__c > job.Allowed_Backlogs__c) {
                app.addError('You are not eligible for this job. You have ' + 
                    student.Active_Backlogs__c + ' active backlogs but this job allows only ' + 
                    job.Allowed_Backlogs__c + '.');
            }

            String key = app.Student__c + '-' + app.Job__c;

            if (existingApplications.contains(key)) {
                app.addError('You have already applied for this job. You cannot apply again.');
            }
        }
    }

    public static void afterInsert(List<Application__c> applications) {

        for (Application__c app : applications) {
            System.enqueueJob(new ApplicationPostProcessingJob(app.Id));
        }
    }

    public static void handleAfterUpdate(List<Application__c> newList, Map<Id, Application__c> oldMap) {
        List<Id> selectedAppIds = new List<Id>();

        for (Application__c app : newList) {
            Application__c oldApp = oldMap.get(app.Id);

            if (oldApp.Status__c != 'Selected' && app.Status__c == 'Selected') {
                selectedAppIds.add(app.Id);
            }
        }

        if (!selectedAppIds.isEmpty()) {
            System.enqueueJob(new CandidateSyncJob(selectedAppIds));
        }
    }
}
