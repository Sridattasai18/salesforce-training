public with sharing class PlacementStatisticsBatch implements Database.Batchable<SObject> {

    public Database.QueryLocator start(Database.BatchableContext bc) {

        return Database.getQueryLocator(
            'SELECT Id, Status__c FROM Application__c'
        );
    }

    public void execute(Database.BatchableContext bc,
                        List<Application__c> scope) {

        Integer selected = 0;

        for (Application__c app : scope) {
            if (app.Status__c == 'Selected') {
                selected++;
            }
        }

        System.debug('Selected applications in this batch: ' + selected);
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('Placement statistics batch completed.');
    }
}
