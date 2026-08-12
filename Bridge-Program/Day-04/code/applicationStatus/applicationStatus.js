import { LightningElement } from 'lwc';

export default class ApplicationStatus extends LightningElement {
    status = 'Not Applied';

    updateStatus() {
        this.status = 'Applied';
    }
}
