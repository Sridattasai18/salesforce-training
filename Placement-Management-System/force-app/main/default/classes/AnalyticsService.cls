public with sharing class AnalyticsService {

    public static Map<String, Integer> applicationsPerJob() {

        Map<String, Integer> result = new Map<String, Integer>();

        for (AggregateResult ar : [
            SELECT Job__r.Name jobName,
                   COUNT(Id) total
            FROM Application__c
            GROUP BY Job__r.Name
        ]) {
            result.put(
                (String)  ar.get('jobName'),
                (Integer) ar.get('total')
            );
        }

        return result;
    }

    public static Integer selectedApplications() {

        return [
            SELECT COUNT()
            FROM Application__c
            WHERE Status__c = 'Selected'
        ];
    }

    public static Map<String, Integer> jobsPerCompany() {

        Map<String, Integer> result = new Map<String, Integer>();

        for (AggregateResult ar : [
            SELECT Company__c company,
                   COUNT(Id) total
            FROM Job__c
            GROUP BY Company__c
        ]) {
            result.put(
                (String)  ar.get('company'),
                (Integer) ar.get('total')
            );
        }

        return result;
    }
}
