public with sharing class ApplicationService {

    public class ApplicationException extends Exception {}

    public static Id submitApplication(Id jobId) {
        // Assume a single demo student for now.
        Student__c demoStudent;
        try {
            demoStudent = [SELECT Id, CGPA__c FROM Student__c LIMIT 1];
        } catch(QueryException e) {
            throw new ApplicationException('No student records found in the system for this demo.');
        }

        Job__c job;
        try {
            job = [SELECT Id, Minimum_CGPA__c, Closing_Date__c 
                   FROM Job__c WHERE Id = :jobId LIMIT 1];
        } catch(QueryException e) {
            throw new ApplicationException('The specified job could not be found.');
        }

        // Prevent duplicate applications
        Integer existingAppCount = [SELECT COUNT() FROM Application__c 
                                    WHERE Student__c = :demoStudent.Id AND Job__c = :jobId];
        if (existingAppCount > 0) {
            throw new ApplicationException('You have already applied for this job.');
        }

        // Validate CGPA
        if (demoStudent.CGPA__c == null || demoStudent.CGPA__c < job.Minimum_CGPA__c) {
            throw new ApplicationException('Your CGPA does not meet the minimum requirement for this job.');
        }

        // Validate Deadline
        if (job.Closing_Date__c != null && job.Closing_Date__c < Date.today()) {
            throw new ApplicationException('The deadline to apply for this job has passed.');
        }

        // Create Application__c
        Application__c app = new Application__c();
        app.Student__c = demoStudent.Id;
        app.Job__c = job.Id;
        app.Status__c = 'Applied';

        insert app;
        return app.Id;
    }
}
