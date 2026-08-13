public with sharing class JobService {

    public static Integer getJobCount() {
        return [SELECT COUNT() FROM Job__c];
    }

    public static List<Job__c> getOpenJobs() {
        return [
            SELECT Id, Name, Company__c, Minimum_CGPA__c
            FROM Job__c
            WHERE Status__c = 'Open'
            ORDER BY Name
        ];
    }
}
