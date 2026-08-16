import { LightningElement, api } from 'lwc';

export default class StudentSummary extends LightningElement {
    @api student;

    get studentName() {
        return this.student?.Name || '';
    }

    get department() {
        return this.student?.Department__c || '';
    }

    get cgpa() {
        return this.student?.CGPA__c ?? '';
    }

    get backlogs() {
        return this.student?.Active_Backlogs__c ?? '';
    }

    get hasStudent() {
        return !!this.student;
    }
}
