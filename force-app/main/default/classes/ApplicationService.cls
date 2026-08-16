public with sharing class ApplicationService {

    public class ApplicationException extends Exception {}

    public static Id submitApplication(Id jobId) {
        // Get the current student (first student for demo purposes)
        List<Student__c> students = [
            SELECT Id, CGPA__c
            FROM Student__c
            LIMIT 1
        ];

        if (students.isEmpty()) {
            throw new ApplicationException('No student record found. Please ensure a student is properly configured.');
        }

        Student__c student = students[0];

        List<Job__c> jobs = [
            SELECT Id, Minimum_CGPA__c, Closing_Date__c, Status__c
            FROM Job__c
            WHERE Id = :jobId
        ];

        if (jobs.isEmpty()) {
            throw new ApplicationException('Job posting not found. Please refresh and try again.');
        }

        Job__c job = jobs[0];

        // Check if job is closed
        if (job.Status__c == 'Closed') {
            throw new ApplicationException('This job is no longer accepting applications.');
        }

        // Check closing date
        if (job.Closing_Date__c != null && job.Closing_Date__c < Date.today()) {
            throw new ApplicationException('This job is no longer accepting applications because the closing date has passed.');
        }

        if (student.CGPA__c < job.Minimum_CGPA__c) {
            throw new ApplicationException('You are not eligible for this job. Your CGPA (' + 
                student.CGPA__c + ') is below the required minimum (' + job.Minimum_CGPA__c + ').');
        }

        List<Application__c> existing = [
            SELECT Id
            FROM Application__c
            WHERE Student__c = :student.Id
            AND Job__c = :jobId
            LIMIT 1
        ];

        if (!existing.isEmpty()) {
            throw new ApplicationException('You have already applied for this job. You cannot apply again.');
        }

        Application__c app = new Application__c(
            Student__c = student.Id,
            Job__c = jobId,
            Status__c = 'Applied',
            Application_Date__c = Date.today()
        );

        insert app;
        return app.Id;
    }

    public static Integer getApplicationCount() {
        return [SELECT COUNT() FROM Application__c];
    }

    public static List<Application__c> getApplicationsForStudent(Id studentId) {
        return [
            SELECT Id, Name, Status__c,
                   Job__r.Name,
                   Job__r.Company__c
            FROM Application__c
            WHERE Student__c = :studentId
            ORDER BY CreatedDate DESC
        ];
    }

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
                    app.addError('You are not eligible for this job. Your CGPA (' + 
                        student.CGPA__c + ') is below the required minimum (' + job.Minimum_CGPA__c + ').');
                }

                String key = app.Student__c + '-' + app.Job__c;

                if (existingPairs.contains(key)) {
                    app.addError('You have already applied for this job. You cannot apply again.');
                }
            }
        }
    }
}
