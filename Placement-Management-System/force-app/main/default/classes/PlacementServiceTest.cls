@IsTest
private class PlacementServiceTest {
    
    @IsTest
    static void testGetEligibleStudents() {
        
        Student__c s = new Student__c(
            Name = 'Test Student',
            Email__c = 'test@example.com',
            CGPA__c = 9,
            Department__c = 'CSE',
            Roll_Number__c = 999,
            Active_Backlogs__c = 0,
            Placement_Status__c = 'Not Placed'
        );
        
        insert s;
        
        Test.startTest();
        
        List<Student__c> result = 
            PlacementService.getEligibleStudents(8);
        
        Test.stopTest();
        
        System.assertEquals(1, result.size());
    }
}
