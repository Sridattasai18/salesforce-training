public with sharing class StudentService {

    public static Integer getStudentCount() {
        return [SELECT COUNT() FROM Student__c];
    }

    public static List<Student__c> getAllStudents() {
        return [
            SELECT Id, Name, Department__c, CGPA__c
            FROM Student__c
            ORDER BY Name
        ];
    }
}
