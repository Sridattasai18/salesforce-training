trigger ApplicationTrigger on Application__c(before insert, after update){

    if(Trigger.isBefore && Trigger.isInsert){
        ApplicationService.validateApplications(Trigger.new);
    }

    if(Trigger.isAfter && Trigger.isUpdate){
        StatisticsService.updateStatistics(Trigger.new, Trigger.oldMap);
        NotificationService.sendNotification(Trigger.new, Trigger.oldMap);
        AlumniService.notifyAlumni(Trigger.new, Trigger.oldMap);
    }
}
