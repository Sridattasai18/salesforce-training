public with sharing class StudentTriggerHandler {

    public static void beforeSave(List<Student__c> students) {

        for (Student__c student : students) {

            if (student.CGPA__c != null && student.CGPA__c > 10) {
                student.addError('CGPA cannot be greater than 10.');
            }

            if (student.CGPA__c != null && student.CGPA__c < 0) {
                student.addError('CGPA cannot be negative.');
            }
        }
    }
}
