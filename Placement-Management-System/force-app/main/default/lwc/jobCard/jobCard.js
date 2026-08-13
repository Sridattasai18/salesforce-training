import { LightningElement, api } from 'lwc';

export default class JobCard extends LightningElement {

    @api job;

    handleApply() {
        this.dispatchEvent(
            new CustomEvent('apply', {
                detail: this.job.Id
            })
        );
    }
}
