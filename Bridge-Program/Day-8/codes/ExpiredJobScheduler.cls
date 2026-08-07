/**
 * Task 5 – Scheduled Apex
 *
 * Business Requirement:
 * Every morning at 6 AM, the placement system should automatically:
 *   - Start the PlacementCategoryBatch
 *   - Recalculate placement categories for all applications
 *
 * Why Scheduled Apex?
 * This is a recurring daily task. Instead of someone manually running the batch,
 * Scheduled Apex fires automatically at the defined time.
 *
 * Schedule with:
 *   String cron = '0 0 6 * * ?';
 *   System.schedule('Daily Placement Category Job', cron, new ExpiredJobScheduler());
 *
 * CRON breakdown:
 *   '0 0 6 * * ?'
 *    | | | | | └── Day of Week (any)
 *    | | | | └──── Month (every month)
 *    | | | └────── Day of Month (every day)
 *    | | └──────── Hour (6 AM)
 *    | └────────── Minute (0)
 *    └──────────── Second (0)
 */

public class ExpiredJobScheduler implements Schedulable {

    public void execute(SchedulableContext sc) {

        System.debug('Scheduled Job Fired – Starting PlacementCategoryBatch');

        Database.executeBatch(new PlacementCategoryBatch(), 200);

        System.debug('PlacementCategoryBatch Started Successfully');
    }

}
