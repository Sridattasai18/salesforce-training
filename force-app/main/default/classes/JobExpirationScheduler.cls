public with sharing class JobExpirationScheduler implements Schedulable {

    public void execute(SchedulableContext sc) {

        List<Job__c> jobs = [
            SELECT Id, Closing_Date__c, Status__c
            FROM Job__c
            WHERE Closing_Date__c < :Date.today()
            AND Status__c != 'Closed'
        ];

        for (Job__c job : jobs) {
            job.Status__c = 'Closed';
        }

        if (!jobs.isEmpty()) {
            update jobs;
        }

        System.debug('Expired jobs closed: ' + jobs.size());
    }
}
