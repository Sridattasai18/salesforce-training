import { LightningElement, api } from 'lwc';
import NAME_FIELD       from '@salesforce/schema/Student__c.Name';
import DEPARTMENT_FIELD from '@salesforce/schema/Student__c.Department__c';
import CGPA_FIELD       from '@salesforce/schema/Student__c.CGPA__c';
import BACKLOG_FIELD    from '@salesforce/schema/Student__c.Active_Backlogs__c';

export default class ProfileForm extends LightningElement {
    @api studentId;

    get recordId() {
        return this.studentId;
    }

    fields = [
        NAME_FIELD,
        DEPARTMENT_FIELD,
        CGPA_FIELD,
        BACKLOG_FIELD
    ];
}
