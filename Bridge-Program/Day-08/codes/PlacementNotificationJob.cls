/**
 * Task 3 – Queueable Chaining (Job B)
 *
 * Business Requirement:
 * After the external placement sync completes, send a notification email to the student.
 *
 * This job is always started by ExternalPlacementSyncJob.
 * It never runs before the sync is done — that ordering is guaranteed by chaining.
 *
 * Design Note:
 * PlacementNotificationJob is the second and final step in the Queueable chain.
 * If additional steps were needed (e.g., reporting), they could be chained here too.
 */

public class PlacementNotificationJob implements Queueable {

    private Id offerId;

    public PlacementNotificationJob(Id offerId) {
        this.offerId = offerId;
    }

    public void execute(QueueableContext context) {

        Offer__c offer = [
            SELECT Id, Student__c, Status__c
            FROM Offer__c
            WHERE Id = :offerId
        ];

        Student__c student = [
            SELECT Id, Name
            FROM Student__c
            WHERE Id = :offer.Student__c
        ];

        System.debug('Congratulations Email Sent to: ' + student.Name);
        System.debug('Notification Chain Completed for Offer: ' + offerId);
    }

}
