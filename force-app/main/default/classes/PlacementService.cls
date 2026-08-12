public with sharing class PlacementService {
    
    public static List<Student__c> getEligibleStudents(Decimal minimumCGPA) {
        return [
            SELECT Id, Name, CGPA__c
            FROM Student__c
            WHERE CGPA__c >= :minimumCGPA
        ];
    }
    
    public static List<Student__c> getStudentsByDepartment(String department) {
        return [
            SELECT Id, Name, Department__c
            FROM Student__c
            WHERE Department__c = :department
        ];
    }
    
    public static Application__c createApplication(Id studentId, Id jobId) {
        Application__c app = new Application__c(
            Student__c = studentId,
            Job__c = jobId,
            Status__c = 'Applied',
            Application_Date__c = Date.today()
        );
        
        insert app;
        return app;
    }
}
