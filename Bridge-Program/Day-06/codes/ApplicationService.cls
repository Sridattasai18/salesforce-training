public class ApplicationService {

    public static void validateApplications(List<Application__c> applications){

        Set<Id> studentIds = new Set<Id>();
        Set<Id> jobIds = new Set<Id>();

        for(Application__c app : applications){
            if(app.Student__c != null)
                studentIds.add(app.Student__c);

            if(app.Job__c != null)
                jobIds.add(app.Job__c);
        }

        Map<Id,Student__c> students = new Map<Id,Student__c>(
        [
            SELECT Id,Name,CGPA__c
            FROM Student__c
            WHERE Id IN :studentIds
        ]);

        Map<Id,Job__c> jobs = new Map<Id,Job__c>(
        [
            SELECT Id,Name,Minimum_CGPA__c,Last_Date__c
            FROM Job__c
            WHERE Id IN :jobIds
        ]);

        for(Application__c app : applications){

            Student__c student = students.get(app.Student__c);
            Job__c job = jobs.get(app.Job__c);

            if(student.CGPA__c < job.Minimum_CGPA__c){
                app.addError('CGPA is below job requirement.');
            }

            if(Date.today() > job.Last_Date__c){
                app.addError('Application deadline is over.');
            }

            app.Status__c='Applied';
        }

    }

}
