public with sharing class JobTriggerHandler {

    public static void beforeSave(List<Job__c> jobs) {

        Date today = Date.today();

        for (Job__c job : jobs) {

            if (job.Minimum_CGPA__c != null && job.Minimum_CGPA__c > 10) {
                job.addError('Minimum CGPA cannot exceed 10. Please enter a value between 0 and 10.');
            }

            if (job.Closing_Date__c != null && job.Closing_Date__c < today) {
                job.Status__c = 'Closed';
            }
        }
    }
}
