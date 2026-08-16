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
        try {
            String body = RestContext.request.requestBody.toString();

            Map<String, Object> data =
                (Map<String, Object>) JSON.deserializeUntyped(body);

            String studentId = (String) data.get('studentId');
            String jobId = (String) data.get('jobId');

            if (String.isBlank(studentId) || String.isBlank(jobId)) {
                RestContext.response.statusCode = 400;
                return JSON.serialize(
                    new Map<String, String>{
                        'error' => 'Both studentId and jobId are required'
                    }
                );
            }

            Application__c app = new Application__c(
                Student__c = studentId,
                Job__c = jobId,
                Status__c = 'Applied',
                Application_Date__c = Date.today()
            );

            insert app;

            RestContext.response.statusCode = 201;
            return JSON.serialize(
                new Map<String, String>{
                    'status' => 'success',
                    'applicationId' => app.Id,
                    'message' => 'Application submitted successfully'
                }
            );

        } catch (DmlException e) {
            RestContext.response.statusCode = 400;
            return JSON.serialize(
                new Map<String, String>{
                    'error' => 'Unable to create application',
                    'message' => e.getDmlMessage(0)
                }
            );
        } catch (JSONException e) {
            RestContext.response.statusCode = 400;
            return JSON.serialize(
                new Map<String, String>{
                    'error' => 'Invalid request format. Please provide valid JSON with studentId and jobId.'
                }
            );
        } catch (Exception e) {
            RestContext.response.statusCode = 500;
            return JSON.serialize(
                new Map<String, String>{
                    'error' => 'An unexpected error occurred while processing your application'
                }
            );
        }
    }
}
