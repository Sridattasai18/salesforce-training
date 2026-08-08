public with sharing class ApplicationController {

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
