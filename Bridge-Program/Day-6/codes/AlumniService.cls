public class AlumniService{

    public static void notifyAlumni(
        List<Application__c> applications,
        Map<Id,Application__c> oldMap){

        for(Application__c app : applications){

            Application__c oldApp = oldMap.get(app.Id);

            if(oldApp.Status__c!='Offer Accepted'
            && app.Status__c=='Offer Accepted'){

                System.debug(
                    'Alumni Office Notified for '
                    +app.Student__c
                );

            }

        }

    }

}
