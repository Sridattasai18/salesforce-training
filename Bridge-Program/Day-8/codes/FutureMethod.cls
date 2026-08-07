/**
 * Task 1 – Future Method
 *
 * Business Requirement:
 * After a student applies for a job, update their Placement Status in the background.
 * The student should not wait for the status update to complete.
 *
 * Solution:
 * Use @future to move the update out of the main transaction.
 */

public class StudentFutureService {

    @future
    public static void updatePlacementStatus(Id studentId) {

        Student__c student = [
            SELECT Id, Name, Placement_Status__c
            FROM Student__c
            WHERE Id = :studentId
        ];

        student.Placement_Status__c = 'Application Submitted';

        update student;

        System.debug('Future Method Executed – Status Updated for: ' + student.Name);
    }

}
