public class ExternalPlacementService {
    
    public static void syncSelectedCandidates(List<Id> applicationIds) {
        
        // Query selected applications with related student and job data
        List<Application__c> applications = [
            SELECT Id, Name, Status__c, 
                   Student__c, Student__r.Name, Student__r.Email__c,
                   Job__c, Job__r.Name, Job__r.Company__c
            FROM Application__c
            WHERE Id IN :applicationIds
            WITH SECURITY_ENFORCED
        ];
        
        for (Application__c app : applications) {
            try {
                // Build payload for external API
                Map<String, Object> payload = new Map<String, Object>();
                payload.put('candidateName', app.Student__r.Name);
                payload.put('email', app.Student__r.Email__c);
                payload.put('jobTitle', app.Job__r.Name);
                payload.put('company', app.Job__r.Company__c);
                payload.put('applicationId', app.Id);
                payload.put('status', app.Status__c);
                
                String requestBody = JSON.serialize(payload);
                
                // Make HTTP callout using Named Credential
                HttpRequest req = new HttpRequest();
                req.setEndpoint('callout:Recruitment_API/posts');
                req.setMethod('POST');
                req.setHeader('Content-Type', 'application/json');
                req.setBody(requestBody);
                
                Http http = new Http();
                HttpResponse res = http.send(req);
                
                // Log successful integration
                logIntegration(
                    app.Id, 
                    requestBody, 
                    res.getBody(), 
                    res.getStatusCode(), 
                    res.getStatusCode() >= 200 && res.getStatusCode() < 300, 
                    null
                );
                
            } catch (Exception e) {
                // Log failed integration
                logIntegration(
                    app.Id, 
                    null, 
                    null, 
                    500, 
                    false, 
                    e.getMessage()
                );
            }
        }
    }
    
    private static void logIntegration(
        Id recordId, 
        String request, 
        String response, 
        Integer statusCode, 
        Boolean success, 
        String error
    ) {
        Integration_Log__c log = new Integration_Log__c();
        log.Related_Record_Id__c = String.valueOf(recordId);
        log.Integration_Type__c = 'Candidate Sync';
        log.Request_Body__c = request != null && request.length() > 131072 
            ? request.substring(0, 131072) 
            : request;
        log.Response_Body__c = response != null && response.length() > 131072 
            ? response.substring(0, 131072) 
            : response;
        log.Status_Code__c = statusCode;
        log.Success__c = success;
        log.Error_Message__c = error != null && error.length() > 131072 
            ? error.substring(0, 131072) 
            : error;
        log.Timestamp__c = System.now();
        
        insert log;
    }
}