public with sharing class OfferService {

    public static Integer getOfferCount() {
        return [SELECT COUNT() FROM Offer_Letter__c];
    }

    public static List<Offer_Letter__c> getIssuedOffers() {
        return [
            SELECT Id, Name,
                   Student__r.Name,
                   Job__r.Name,
                   Offer_Date__c,
                   Status__c
            FROM Offer_Letter__c
            ORDER BY Offer_Date__c DESC
        ];
    }
}
