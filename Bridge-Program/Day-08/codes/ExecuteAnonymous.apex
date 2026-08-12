// =============================================================================
// Day 8 – Execute Anonymous Scripts
// Run each block separately in Developer Console → Execute Anonymous Window
// =============================================================================


// =============================================================================
// TASK 1 – Future Method
// Run this to trigger background placement status update for Datta
// =============================================================================

Student__c s = [
    SELECT Id, Name
    FROM Student__c
    WHERE Name = 'Datta'
    LIMIT 1
];

StudentFutureService.updatePlacementStatus(s.Id);

// Expected: Job submitted to background.
// Placement Status will change from 'Not Placed' → 'Application Submitted'
// Check: Apex Jobs → Job Type = Future → Status = Completed


// =============================================================================
// TASK 2 – Queueable Apex (Offer Post Processing)
// Run this to enqueue background processing after Gopi's offer is accepted
// =============================================================================

Offer__c offer = [
    SELECT Id, Status__c
    FROM Offer__c
    WHERE Status__c = 'Pending'
    LIMIT 1
];

Id jobId = System.enqueueJob(new OfferPostProcessingJob(offer.Id));

System.debug('Queueable Job Enqueued – Job Id: ' + jobId);

// Expected: Job submitted successfully
// Student Placement Status will change → 'Placed'
// Debug log will show: Notification Queued, Audit Created, External Sync Initiated
// Check: Apex Jobs → Job Type = Queueable → Status = Completed


// =============================================================================
// TASK 3 – Queueable Chaining (Sync → Notification)
// Run this to start the two-step chain: External Sync → Notification
// =============================================================================

Offer__c chainOffer = [
    SELECT Id
    FROM Offer__c
    LIMIT 1
];

Id chainJobId = System.enqueueJob(new ExternalPlacementSyncJob(chainOffer.Id));

System.debug('Chain Started – Job Id: ' + chainJobId);

// Expected:
// Job A (ExternalPlacementSyncJob) → runs first
//   Debug: 'External Placement System Synced'
//   Debug: 'PlacementNotificationJob Enqueued'
// Job B (PlacementNotificationJob) → runs second
//   Debug: 'Congratulations Email Sent to: [Student Name]'
// Check: Apex Jobs → Two Queueable jobs → Both Completed


// =============================================================================
// TASK 4 – Batch Apex
// Run this to process all Application records and assign placement categories
// =============================================================================

Database.executeBatch(new PlacementCategoryBatch(), 200);

// Expected:
// Batch starts processing Application records in chunks of 200
// Applications with Package >= 12 → Category = 'Dream'
// Applications with Package < 12  → Category = 'Regular'
// finish() logs: Total Chunks Processed, Errors, Final Status
// Check: Apex Jobs → Job Type = Batch Apex → Status = Completed


// =============================================================================
// TASK 5 – Scheduled Apex
// Run this once to schedule the daily 6 AM batch job
// =============================================================================

String cronExpression = '0 0 6 * * ?';

System.schedule(
    'Daily Placement Category Job',
    cronExpression,
    new ExpiredJobScheduler()
);

// Expected:
// Scheduled job created successfully
// Runs automatically every morning at 6:00 AM
// Starts PlacementCategoryBatch each time it fires
// Check: Setup → Scheduled Jobs → 'Daily Placement Category Job' → Active


// =============================================================================
// CLEANUP – Remove the Scheduled Job if needed
// Run this to find and abort the scheduled job
// =============================================================================

// CronTrigger scheduledJob = [
//     SELECT Id, CronJobDetail.Name
//     FROM CronTrigger
//     WHERE CronJobDetail.Name = 'Daily Placement Category Job'
//     LIMIT 1
// ];
//
// System.abortJob(scheduledJob.Id);
// System.debug('Scheduled Job Aborted');
