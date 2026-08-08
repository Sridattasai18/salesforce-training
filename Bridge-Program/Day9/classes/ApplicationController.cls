public with sharing class ApplicationController {

    @AuraEnabled(cacheable=true)
    public static List<Job__c> getEligibleJobs() {
        try {
            // Assume a single demo student for now.
            Student__c demoStudent;
            try {
                demoStudent = [SELECT Id, CGPA__c FROM Student__c LIMIT 1];
            } catch(QueryException e) {
                return new List<Job__c>();
            }
            
            Decimal cgpa = demoStudent.CGPA__c != null ? demoStudent.CGPA__c : 0;

            return [
                SELECT Id, Company__c, Location__c, Minimum_CGPA__c, Closing_Date__c, Salary__c
                FROM Job__c
                WHERE Minimum_CGPA__c <= :cgpa
                AND (Closing_Date__c >= TODAY OR Closing_Date__c = null)
                WITH SECURITY_ENFORCED
                ORDER BY CreatedDate DESC
            ];
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching eligible jobs. Please try again later.');
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
