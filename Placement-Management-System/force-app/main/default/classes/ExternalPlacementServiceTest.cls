@IsTest
private class ExternalPlacementServiceTest {

    // -------------------------------------------------------
    // Mock: simulates a successful 201 response from the API
    // -------------------------------------------------------
    private class SuccessMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(201);
            res.setBody('{"id":1,"status":"success"}');
            return res;
        }
    }

    // -------------------------------------------------------
    // Mock: simulates a 500 server error from the API
    // -------------------------------------------------------
    private class FailureMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(500);
            res.setBody('{"error":"Internal Server Error"}');
            return res;
        }
    }

    // -------------------------------------------------------
    // Helper: create a fully linked Application record
    // -------------------------------------------------------
    private static Application__c createTestApplication() {
        Student__c student = new Student__c(
            Name              = 'Test Student',
            Email__c          = 'test@example.com',
            CGPA__c           = 8.5,
            Department__c     = 'CSE',
            Roll_Number__c    = 101,
            Active_Backlogs__c = 0,
            Placement_Status__c = 'Not Placed'
        );
        insert student;

        Job__c job = new Job__c(
            Name             = 'Software Engineer',
            Company__c       = 'TechCorp',
            Minimum_CGPA__c  = 7.0,
            Allowed_Backlogs__c = 0,
            Status__c        = 'Open',
            Location__c      = 'Hyderabad',
            Salary__c        = 600000,
            Closing_Date__c  = Date.today().addDays(30)
        );
        insert job;

        Application__c app = new Application__c(
            Student__c       = student.Id,
            Job__c           = job.Id,
            Status__c        = 'Applied',
            Application_Date__c = Date.today()
        );
        insert app;

        return app;
    }

    // -------------------------------------------------------
    // TEST 1: Successful callout logs Success__c = true
    // -------------------------------------------------------
    @IsTest
    static void testSyncSelectedCandidates_Success() {
        Application__c app = createTestApplication();

        Test.setMock(HttpCalloutMock.class, new SuccessMock());

        Test.startTest();
        ExternalPlacementService.syncSelectedCandidates(
            new List<Id>{ app.Id }
        );
        Test.stopTest();

        List<Integration_Log__c> logs = [
            SELECT Success__c, Status_Code__c, Integration_Type__c,
                   Related_Record_Id__c, Error_Message__c
            FROM Integration_Log__c
            WHERE Related_Record_Id__c = :String.valueOf(app.Id)
        ];

        System.assertEquals(1, logs.size(), 'Expected exactly one Integration Log');
        System.assertEquals(true,  logs[0].Success__c,      'Log should be marked successful');
        System.assertEquals(201,   logs[0].Status_Code__c,  'Status code should be 201');
        System.assertEquals('Candidate Sync', logs[0].Integration_Type__c, 'Integration type mismatch');
        System.assertEquals(null,  logs[0].Error_Message__c, 'No error message expected on success');
    }

    // -------------------------------------------------------
    // TEST 2: API 500 response logs Success__c = false
    // -------------------------------------------------------
    @IsTest
    static void testSyncSelectedCandidates_ApiFailure() {
        Application__c app = createTestApplication();

        Test.setMock(HttpCalloutMock.class, new FailureMock());

        Test.startTest();
        ExternalPlacementService.syncSelectedCandidates(
            new List<Id>{ app.Id }
        );
        Test.stopTest();

        List<Integration_Log__c> logs = [
            SELECT Success__c, Status_Code__c
            FROM Integration_Log__c
            WHERE Related_Record_Id__c = :String.valueOf(app.Id)
        ];

        System.assertEquals(1, logs.size(), 'Expected exactly one Integration Log');
        System.assertEquals(false, logs[0].Success__c,     'Log should be marked as failure');
        System.assertEquals(500,   logs[0].Status_Code__c, 'Status code should be 500');
    }

    // -------------------------------------------------------
    // TEST 3: Empty list — no callout, no log
    // -------------------------------------------------------
    @IsTest
    static void testSyncSelectedCandidates_EmptyList() {
        Test.setMock(HttpCalloutMock.class, new SuccessMock());

        Test.startTest();
        ExternalPlacementService.syncSelectedCandidates(new List<Id>());
        Test.stopTest();

        Integer logCount = [SELECT COUNT() FROM Integration_Log__c];
        System.assertEquals(0, logCount, 'No logs should be created for an empty list');
    }

    // -------------------------------------------------------
    // TEST 4: CandidateSyncJob executes and triggers integration
    // -------------------------------------------------------
    @IsTest
    static void testCandidateSyncJob_Execute() {
        Application__c app = createTestApplication();

        Test.setMock(HttpCalloutMock.class, new SuccessMock());

        Test.startTest();
        System.enqueueJob(new CandidateSyncJob(new List<Id>{ app.Id }));
        Test.stopTest();

        List<Integration_Log__c> logs = [
            SELECT Success__c
            FROM Integration_Log__c
            WHERE Related_Record_Id__c = :String.valueOf(app.Id)
        ];

        System.assertEquals(1, logs.size(), 'CandidateSyncJob should create one Integration Log');
        System.assertEquals(true, logs[0].Success__c, 'Integration should be successful');
    }

    // -------------------------------------------------------
    // TEST 5: Trigger fires on Application status → 'Selected'
    //         and enqueues CandidateSyncJob via handleAfterUpdate
    // -------------------------------------------------------
    @IsTest
    static void testTrigger_StatusChangeToSelected_EnqueuesJob() {
        Application__c app = createTestApplication();

        Test.setMock(HttpCalloutMock.class, new SuccessMock());

        Test.startTest();
        app.Status__c = 'Selected';
        update app;
        Test.stopTest();

        // After Test.stopTest(), queued jobs have executed
        List<Integration_Log__c> logs = [
            SELECT Success__c, Status_Code__c
            FROM Integration_Log__c
            WHERE Related_Record_Id__c = :String.valueOf(app.Id)
        ];

        System.assertEquals(1, logs.size(),
            'Updating status to Selected should trigger one Integration Log');
        System.assertEquals(true, logs[0].Success__c,
            'Integration triggered by trigger should succeed');
    }

    // -------------------------------------------------------
    // TEST 6: Status change to non-Selected does NOT enqueue
    // -------------------------------------------------------
    @IsTest
    static void testTrigger_StatusChangeToRejected_DoesNotSync() {
        Application__c app = createTestApplication();

        Test.setMock(HttpCalloutMock.class, new SuccessMock());

        Test.startTest();
        app.Status__c = 'Rejected';
        update app;
        Test.stopTest();

        Integer logCount = [
            SELECT COUNT()
            FROM Integration_Log__c
            WHERE Related_Record_Id__c = :String.valueOf(app.Id)
        ];

        System.assertEquals(0, logCount,
            'Changing status to Rejected should NOT create an Integration Log');
    }
}