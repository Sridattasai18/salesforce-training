public class PlacementStatusService{

    public static void processSelections(
        List<Application__c> applications,
        Map<Id, Application__c> oldMap
    ){

        Set<Id> selectedStudentIds =
            new Set<Id>();

        for(Application__c app : applications){

            Application__c oldApp =
                oldMap.get(app.Id);

            if(oldApp.Status__c != 'Selected'
               && app.Status__c == 'Selected'){

                selectedStudentIds.add(
                    app.Student__c
                );
            }
        }

        if(selectedStudentIds.isEmpty()){
            return;
        }

        List<Student__c> studentsToUpdate =
            new List<Student__c>();

        for(Student__c student : [
            SELECT Id,
                   Placement_Status__c
            FROM Student__c
            WHERE Id IN :selectedStudentIds
        ]){

            student.Placement_Status__c =
                'Placed';

            studentsToUpdate.add(student);
        }

        if(!studentsToUpdate.isEmpty()){
            update studentsToUpdate;
        }
    }
}
