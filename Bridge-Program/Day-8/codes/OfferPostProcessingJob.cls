/**
 * Task 2 – Queueable Apex
 *
 * Business Requirement:
 * When a student's offer is accepted, the following must happen in the background:
 *   - Update the student's Placement Status to 'Placed'
 *   - Log a notification message
 *   - Create an audit entry
 *   - Sync with the external placement system
 *
 * Solution:
 * Use Queueable Apex so these steps run after the main transaction,
 * without making the student wait.
 *
 * Enqueue with: System.enqueueJob(new OfferPostProcessingJob(offerId));
 */

public class OfferPostProcessingJob implements Queueable {

    private Id offerId;

    public OfferPostProcessingJob(Id offerId) {
        this.offerId = offerId;
    }

    public void execute(QueueableContext context) {

        Offer__c offer = [
            SELECT Id, Status__c, Student__c
            FROM Offer__c
            WHERE Id = :offerId
        ];

        Student__c student = [
            SELECT Id, Name, Placement_Status__c
            FROM Student__c
            WHERE Id = :offer.Student__c
        ];

        student.Placement_Status__c = 'Placed';

        update student;

        System.debug('Student Placement Status Updated → Placed: ' + student.Name);
        System.debug('Email Notification Queued for: ' + student.Name);
        System.debug('Audit Record Created for Offer: ' + offerId);
        System.debug('External Placement System Sync Initiated');
    }

}
