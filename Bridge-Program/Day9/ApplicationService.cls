public class ApplicationService{

    public static void validateApplications(
        List<Application__c> applications
    ){

        Set<Id> studentIds = new Set<Id>();
        Set<Id> jobIds = new Set<Id>();

        for(Application__c app : applications){
            if(app.Student__c != null){
                studentIds.add(app.Student__c);
            }
            if(app.Job__c != null){
                jobIds.add(app.Job__c);
            }
        }

        Map<Id, Student__c> studentsById =
            new Map<Id, Student__c>([
                SELECT Id,
                       CGPA__c,
                       Active_Backlogs__c
                FROM Student__c
                WHERE Id IN :studentIds
            ]);

        Map<Id, Job__c> jobsById =
            new Map<Id, Job__c>([
                SELECT Id,
                       Minimum_CGPA__c,
                       Allowed_Backlogs__c
                FROM Job__c
                WHERE Id IN :jobIds
            ]);

        for(Application__c app : applications){

            Student__c student =
                studentsById.get(app.Student__c);

            Job__c job =
                jobsById.get(app.Job__c);

            if(student == null || job == null){
                continue;
            }

            if(student.CGPA__c <
               job.Minimum_CGPA__c){
                app.addError(
                    'Student CGPA is below the minimum requirement.'
                );
            }

            if(student.Active_Backlogs__c >
               job.Allowed_Backlogs__c){
                app.addError(
                    'Student exceeds allowed backlog limit.'
                );
            }

            app.Status__c = 'Applied';
        }
    }

    public static void handleStatusUpdates(
        List<Application__c> applications,
        Map<Id, Application__c> oldMap
    ){

        for(Application__c app : applications){

            Application__c oldApp =
                oldMap.get(app.Id);

            if(oldApp.Status__c !=
               app.Status__c){
                app.Last_Status_Change__c =
                    System.today();
            }
        }
    }
}
