public with sharing class StudentPortalController {

    @AuraEnabled(cacheable=true)
    public static List<Student__c> getStudents() {
        return [
            SELECT Id, Name, Department__c, CGPA__c, Active_Backlogs__c
            FROM Student__c
            ORDER BY Name
        ];
    }

    @AuraEnabled(cacheable=true)
    public static List<Job__c> getEligibleJobs(Id studentId) {

        Student__c student = [
            SELECT CGPA__c, Active_Backlogs__c
            FROM Student__c
            WHERE Id = :studentId
            LIMIT 1
        ];

        return [
            SELECT Id,
                   Name,
                   Company__c,
                   Minimum_CGPA__c,
                   Allowed_Backlogs__c,
                   Location__c,
                   Salary__c,
                   Closing_Date__c
            FROM Job__c
            WHERE Minimum_CGPA__c <= :student.CGPA__c
            AND Allowed_Backlogs__c >= :student.Active_Backlogs__c
            AND Status__c = 'Open'
            ORDER BY Closing_Date__c ASC
        ];
    }

    @AuraEnabled
    public static String applyForJob(Id studentId, Id jobId) {
        try {
            // Validate student exists
            List<Student__c> students = [
                SELECT Id, CGPA__c, Active_Backlogs__c
                FROM Student__c
                WHERE Id = :studentId
                LIMIT 1
            ];

            if (students.isEmpty()) {
                throw new AuraHandledException('Student record not found. Please refresh and try again.');
            }

            Student__c student = students[0];

            // Validate job exists and is open
            List<Job__c> jobs = [
                SELECT Id, Name, Minimum_CGPA__c, Allowed_Backlogs__c, 
                       Closing_Date__c, Status__c
                FROM Job__c
                WHERE Id = :jobId
                LIMIT 1
            ];

            if (jobs.isEmpty()) {
                throw new AuraHandledException('Job posting not found. Please refresh and try again.');
            }

            Job__c job = jobs[0];

            // Check if job is closed
            if (job.Status__c == 'Closed') {
                throw new AuraHandledException('This job is no longer accepting applications.');
            }

            // Check closing date
            if (job.Closing_Date__c != null && job.Closing_Date__c < Date.today()) {
                throw new AuraHandledException('This job is no longer accepting applications because the closing date has passed.');
            }

            // Check CGPA eligibility
            if (student.CGPA__c < job.Minimum_CGPA__c) {
                throw new AuraHandledException('You are not eligible for this job. Your CGPA (' + 
                    student.CGPA__c + ') is below the required minimum (' + job.Minimum_CGPA__c + ').');
            }

            // Check backlog eligibility
            if (student.Active_Backlogs__c > job.Allowed_Backlogs__c) {
                throw new AuraHandledException('You are not eligible for this job. You have ' + 
                    student.Active_Backlogs__c + ' active backlogs but this job allows only ' + 
                    job.Allowed_Backlogs__c + '.');
            }

            // Check for duplicate application
            Integer existingCount = [
                SELECT COUNT()
                FROM Application__c
                WHERE Student__c = :studentId
                AND Job__c = :jobId
            ];

            if (existingCount > 0) {
                throw new AuraHandledException('You have already applied for this job. You cannot apply again.');
            }

            // Create application
            Application__c app = new Application__c(
                Student__c = studentId,
                Job__c = jobId,
                Status__c = 'Applied',
                Application_Date__c = Date.today()
            );

            insert app;

            return 'Application submitted successfully';

        } catch (DmlException e) {
            throw new AuraHandledException('Unable to submit your application. Please try again or contact support.');
        } catch (AuraHandledException e) {
            throw e;
        } catch (Exception e) {
            throw new AuraHandledException('An unexpected error occurred while submitting your application. Please try again.');
        }
    }
}