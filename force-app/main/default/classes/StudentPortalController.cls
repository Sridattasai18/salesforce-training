public with sharing class StudentPortalController {

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

        Application__c app = new Application__c(
            Student__c = studentId,
            Job__c = jobId,
            Status__c = 'Applied'
        );

        insert app;

        return 'Application submitted successfully';
    }
}
