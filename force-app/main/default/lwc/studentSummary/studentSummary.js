import { LightningElement, api } from 'lwc';

export default class StudentSummary extends LightningElement {
    @api studentId;
    @api refreshSignal;
}
