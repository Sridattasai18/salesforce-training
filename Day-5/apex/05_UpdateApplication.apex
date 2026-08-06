Application__c app = [
    SELECT Id, Status__c
    FROM Application__c
    WHERE Student__r.Name='Vithal'
    LIMIT 1
];

app.Status__c='Selected';

update app;
