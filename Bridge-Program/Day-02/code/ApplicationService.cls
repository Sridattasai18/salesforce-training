public with sharing class ApplicationService {

    public static void validateApplications(List<Application__c> applications) {

        Set<Id> studentIds = new Set<Id>();
        Set<Id> jobIds = new Set<Id>();

        for (Application__c app : applications) {
            if (app.Student__c != null) studentIds.add(app.Student__c);
            if (app.Job__c != null)     jobIds.add(app.Job__c);
        }

        Map<Id, Student__c> students = new Map<Id, Student__c>(
            [SELECT Id, CGPA__c
             FROM Student__c
             WHERE Id IN :studentIds]
        );

        Map<Id, Job__c> jobs = new Map<Id, Job__c>(
            [SELECT Id, Minimum_CGPA__c
             FROM Job__c
             WHERE Id IN :jobIds]
        );

        Set<String> existingPairs = new Set<String>();

        for (Application__c existing : [
            SELECT Student__c, Job__c
            FROM Application__c
            WHERE Student__c IN :studentIds
            AND Job__c IN :jobIds
        ]) {
            existingPairs.add(existing.Student__c + '-' + existing.Job__c);
        }

        for (Application__c app : applications) {

            Student__c student = students.get(app.Student__c);
            Job__c job         = jobs.get(app.Job__c);

            if (student != null && job != null) {

                if (student.CGPA__c < job.Minimum_CGPA__c) {
                    app.addError('Student does not meet the minimum CGPA requirement.');
                }

                String key = app.Student__c + '-' + app.Job__c;

                if (existingPairs.contains(key)) {
                    app.addError('This student has already applied for this job.');
                }
            }
        }
    }
}
