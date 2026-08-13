public with sharing class ApplicationPostProcessingJob implements Queueable {

    private Id applicationId;

    public ApplicationPostProcessingJob(Id applicationId) {
        this.applicationId = applicationId;
    }

    public void execute(QueueableContext context) {

        Application__c app = [
            SELECT Id, Status__c
            FROM Application__c
            WHERE Id = :applicationId
            LIMIT 1
        ];

        System.debug('Processing application: ' + app.Id);

        if (app.Status__c == 'Applied') {
            System.debug('Notification would be sent here.');
        }

        System.debug('Analytics refresh would happen here.');
    }
}
