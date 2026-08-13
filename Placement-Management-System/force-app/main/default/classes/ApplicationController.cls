public with sharing class ApplicationController {

    @AuraEnabled(cacheable=true)
    public static Student__c getCurrentStudent() {
        try {
            // Return first student for demo purposes
            // In production, this would use UserInfo to find the student record
            return [SELECT Id, Name, CGPA__c, Email__c, Department__c 
                    FROM Student__c 
                    WITH SECURITY_ENFORCED
                    LIMIT 1];
        } catch (QueryException e) {
            return null;
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<Application__c> getMyApplications(Id studentId) {
        try {
            if (studentId == null) {
                return new List<Application__c>();
            }
            
            return [
                SELECT Id, Name, Job__c, Job__r.Name, Job__r.Company__c,
                       Status__c, Application_Date__c
                FROM Application__c
                WHERE Student__c = :studentId
                WITH SECURITY_ENFORCED
                ORDER BY Application_Date__c DESC, CreatedDate DESC
            ];
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching applications: ' + e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<Job__c> getEligibleJobs() {
        try {
            // DEBUG VERSION: Return all jobs to verify LWC is working
            // TODO: Add eligibility filters back after confirming data flow
            return [
                SELECT Id, Name, Company__c, Location__c, Minimum_CGPA__c, Closing_Date__c, Salary__c
                FROM Job__c
                ORDER BY Name
            ];
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching eligible jobs: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static Id submitApplication(Id jobId) {
        try {
            return ApplicationService.submitApplication(jobId);
        } catch (ApplicationService.ApplicationException e) {
            throw new AuraHandledException(e.getMessage());
        } catch (Exception e) {
            throw new AuraHandledException('An unexpected error occurred while processing your application.');
        }
    }
}
