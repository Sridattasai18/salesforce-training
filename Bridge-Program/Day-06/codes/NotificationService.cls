public class NotificationService{

    public static void sendNotification(
        List<Application__c> applications,
        Map<Id,Application__c> oldMap){

        for(Application__c app : applications){

            Application__c oldApp = oldMap.get(app.Id);

            if(oldApp.Status__c != app.Status__c){

                System.debug(
                    'Notification : '
                    +app.Student__c+
                    ' Status changed to '
                    +app.Status__c
                );

            }

        }

    }

}
