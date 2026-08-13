@RestResource(urlMapping='/placement/*')
global with sharing class PlacementApi {

    @HttpGet
    global static String doGet() {

        String path = RestContext.request.requestURI;

        if (path.endsWith('/jobs')) {
            return getJobs();
        }

        if (path.endsWith('/students')) {
            return getStudents();
        }

        return JSON.serialize(
            new Map<String, String>{
                'message' => 'Placement API'
            }
        );
    }

    @HttpPost
    global static String doPost() {

        String path = RestContext.request.requestURI;

        if (path.endsWith('/apply')) {
            return applyForJob();
        }

        RestContext.response.statusCode = 404;

        return JSON.serialize(
            new Map<String, String>{
                'error' => 'Endpoint not found'
            }
        );
    }

    private static String getJobs() {

        List<Job__c> jobs = [
            SELECT Id,
                   Name,
                   Company__c,
                   Location__c,
                   Salary__c,
                   Status__c
            FROM Job__c
            ORDER BY Name
        ];

        return JSON.serialize(jobs);
    }

    private static String getStudents() {

        List<Student__c> students = [
            SELECT Id,
                   Name,
                   Department__c,
                   CGPA__c
            FROM Student__c
            ORDER BY Name
        ];

        return JSON.serialize(students);
    }

    private static String applyForJob() {

        String body = RestContext.request.requestBody.toString();

        Map<String, Object> data =
            (Map<String, Object>) JSON.deserializeUntyped(body);

        Application__c app = new Application__c(
            Student__c = (String) data.get('studentId'),
            Job__c     = (String) data.get('jobId'),
            Status__c  = 'Applied'
        );

        insert app;

        return JSON.serialize(
            new Map<String, String>{
                'status'        => 'success',
                'applicationId' => app.Id
            }
        );
    }
}
