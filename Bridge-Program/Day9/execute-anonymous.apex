List<Application__c> applications =
    new List<Application__c>();

applications.add(
    new Application__c(
        Student__c = '001STUDENTRAHUL',
        Job__c = '001JOBSALESFORCE'
    )
);

applications.add(
    new Application__c(
        Student__c = '001STUDENTANANYA',
        Job__c = '001JOBSALESFORCE'
    )
);

applications.add(
    new Application__c(
        Student__c = '001STUDENTKIRAN',
        Job__c = '001JOBTCS'
    )
);

insert applications;
