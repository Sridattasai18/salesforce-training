/**
 * Task 4 – Batch Apex
 *
 * Business Requirement:
 * The placement office has imported 120,000 Application records.
 * Each application needs a Placement Category assigned:
 *   - Package >= 12 LPA  →  Category = 'Dream'
 *   - Package < 12 LPA   →  Category = 'Regular'
 *
 * Why Batch Apex?
 * Processing 120,000 records in a single transaction would exceed Governor Limits.
 * Batch Apex breaks the work into chunks of 200, each with its own set of limits.
 *
 * Execute with: Database.executeBatch(new PlacementCategoryBatch(), 200);
 */

public class PlacementCategoryBatch implements Database.Batchable<SObject> {

    /**
     * start() – Runs once at the beginning.
     * Returns the full list of Application records to process.
     */
    public Database.QueryLocator start(Database.BatchableContext bc) {

        return Database.getQueryLocator(
            'SELECT Id, Placement_Category__c, Package__c FROM Application__c'
        );
    }

    /**
     * execute() – Runs once per chunk (up to 200 records per call).
     * Assigns Placement Category based on Package value.
     */
    public void execute(Database.BatchableContext bc, List<Application__c> scope) {

        for (Application__c app : scope) {

            if (app.Package__c >= 12) {
                app.Placement_Category__c = 'Dream';
            } else {
                app.Placement_Category__c = 'Regular';
            }
        }

        update scope;
    }

    /**
     * finish() – Runs once after all chunks are processed.
     * Confirms the batch completed successfully.
     */
    public void finish(Database.BatchableContext bc) {

        AsyncApexJob job = [
            SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems
            FROM AsyncApexJob
            WHERE Id = :bc.getJobId()
        ];

        System.debug('Batch Completed');
        System.debug('Total Chunks Processed: ' + job.TotalJobItems);
        System.debug('Errors: ' + job.NumberOfErrors);
        System.debug('Final Status: ' + job.Status);
    }

}
