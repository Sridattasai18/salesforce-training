public with sharing class PlacementDashboardController {

    public class DashboardData {
        @AuraEnabled public Integer studentCount;
        @AuraEnabled public Integer jobCount;
        @AuraEnabled public Integer applicationCount;
        @AuraEnabled public Integer offerCount;
    }

    @AuraEnabled(cacheable=true)
    public static DashboardData getDashboardData() {

        DashboardData data = new DashboardData();

        data.studentCount     = StudentService.getStudentCount();
        data.jobCount         = JobService.getJobCount();
        data.applicationCount = ApplicationService.getApplicationCount();
        data.offerCount       = OfferService.getOfferCount();

        return data;
    }
}
