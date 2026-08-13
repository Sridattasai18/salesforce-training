import { LightningElement } from 'lwc';

export default class StudentPortal extends LightningElement {

    student = {
        Name: 'Kapil',
        Department__c: 'CSE',
        CGPA__c: 8.5,
        Active_Backlogs__c: 0
    };
}
