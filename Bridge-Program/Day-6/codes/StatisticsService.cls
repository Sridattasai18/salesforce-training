public class StatisticsService{

    public static void updateStatistics(
        List<Application__c> newApps,
        Map<Id,Application__c> oldMap){

        Integer selectedCount = 0;

        for(Application__c app : newApps){

            Application__c oldApp = oldMap.get(app.Id);

            if(oldApp.Status__c!='Selected'
            && app.Status__c=='Selected'){

                selectedCount++;

            }

        }

        System.debug('New Selected Students : '+selectedCount);

    }

}
