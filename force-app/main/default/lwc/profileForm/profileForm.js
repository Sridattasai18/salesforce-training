import { LightningElement } from 'lwc';
import NAME_FIELD       from '@salesforce/schema/Student__c.Name';
import DEPARTMENT_FIELD from '@salesforce/schema/Student__c.Department__c';
import CGPA_FIELD       from '@salesforce/schema/Student__c.CGPA__c';
import BACKLOG_FIELD    from '@salesforce/schema/Student__c.Active_Backlogs__c';

const STUDENT_ID = 'a00g500000p5G0RAAU';

export default class ProfileForm extends LightningElement {

    recordId = STUDENT_ID;

    fields = [
        NAME_FIELD,
        DEPARTMENT_FIELD,
        CGPA_FIELD,
        BACKLOG_FIELD
    ];
}
