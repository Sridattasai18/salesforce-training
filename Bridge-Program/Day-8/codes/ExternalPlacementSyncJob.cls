/**
 * Task 3 – Queueable Chaining (Job A)
 *
 * Business Requirement:
 * After a student's offer is processed, two background steps must happen in order:
 *   Step 1 → Sync placement data with the external system
 *   Step 2 → Send a notification email to the student
 *
 * Solution:
 * Use Queueable Chaining.
 * After ExternalPlacementSyncJob completes, it enqueues PlacementNotificationJob.
 *
 * This guarantees the sync always runs before the notification is sent.
 *
 * Enqueue with: System.enqueueJob(new ExternalPlacementSyncJob(offerId));
 */

public class ExternalPlacementSyncJob implements Queueable {

    private Id offerId;

    public ExternalPlacementSyncJob(Id offerId) {
        this.offerId = offerId;
    }

    public void execute(QueueableContext context) {

        Offer__c offer = [
            SELECT Id, Student__c, Status__c
            FROM Offer__c
            WHERE Id = :offerId
        ];

        System.debug('External Placement System Synced for Offer: ' + offerId);
        System.debug('Sync Completed – Student: ' + offer.Student__c);

        // Chain to the next job
        System.enqueueJob(new PlacementNotificationJob(offerId));

        System.debug('PlacementNotificationJob Enqueued – Chain Continues');
    }

}
