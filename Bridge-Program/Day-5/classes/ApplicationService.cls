public class ApplicationService {
    public static String submitApplication(Id studentId, Id jobId) {
        // Retrieve Student
        Student__c student = [SELECT Id, Name, CGPA__c, Active_Backlogs__c FROM Student__c WHERE Id = :studentId LIMIT 1];
        
        // Retrieve Job
        Job__c job = [SELECT Id, Name, Minimum_CGPA__c, Maximum_Backlogs__c FROM Job__c WHERE Id = :jobId LIMIT 1];
        
        // Check Duplicate Application
        List<Application__c> existingApps = [SELECT Id FROM Application__c WHERE Student__c = :studentId AND Job__c = :jobId];
        if (!existingApps.isEmpty()) {
            return 'Student already applied.';
        }
        
        // Validate Eligibility
        if (student.CGPA__c < job.Minimum_CGPA__c) {
            return 'CGPA requirement not met.';
        }
        if (student.Active_Backlogs__c > job.Maximum_Backlogs__c) {
            return 'Backlog requirement not met.';
        }
        
        // Create Application
        Application__c app = new Application__c(
            Student__c = studentId,
            Job__c = jobId,
            Status__c = 'Applied'
        );
        insert app;
        
        return 'Application submitted successfully.';
    }
}
