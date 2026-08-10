// Run these in Developer Console → Debug → Open Execute Anonymous Window

// 1. Check if Job records exist
System.debug('=== ALL JOBS ===');
List<Job__c> allJobs = [SELECT Id, Name, Company__c, Salary__c, Location__c, Minimum_CGPA__c, Closing_Date__c FROM Job__c];
System.debug('Total Jobs: ' + allJobs.size());
for(Job__c j : allJobs) {
    System.debug('Job: ' + j.Name + ' | Company: ' + j.Company__c + ' | CGPA: ' + j.Minimum_CGPA__c + ' | Deadline: ' + j.Closing_Date__c);
}

// 2. Check if Student records exist
System.debug('\n=== ALL STUDENTS ===');
List<Student__c> allStudents = [SELECT Id, Name, CGPA__c, Department__c, Email__c FROM Student__c];
System.debug('Total Students: ' + allStudents.size());
for(Student__c s : allStudents) {
    System.debug('Student: ' + s.Name + ' | CGPA: ' + s.CGPA__c + ' | Dept: ' + s.Department__c);
}

// 3. Test the ApplicationController method
System.debug('\n=== TEST getEligibleJobs() ===');
List<Job__c> eligibleJobs = ApplicationController.getEligibleJobs();
System.debug('Eligible Jobs Count: ' + eligibleJobs.size());
for(Job__c j : eligibleJobs) {
    System.debug('Eligible Job: ' + j.Name + ' | Company: ' + j.Company__c);
}
