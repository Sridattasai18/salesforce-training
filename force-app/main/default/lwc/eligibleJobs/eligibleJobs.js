import { LightningElement, wire, api } from 'lwc';
import getEligibleJobs from '@salesforce/apex/StudentPortalController.getEligibleJobs';
import applyForJob from '@salesforce/apex/StudentPortalController.applyForJob';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

export default class EligibleJobs extends LightningElement {
    @api studentId;

    jobs;
    wiredResult;

    @wire(getEligibleJobs, { studentId: '$studentId' })
    wiredJobs(result) {
        this.wiredResult = result;
        if (result.data) {
            this.jobs = result.data;
        }
    }

    async handleApply(event) {

        const jobId = event.detail;

        try {
            await applyForJob({
                studentId: this.studentId,
                jobId: jobId
            });

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Application submitted',
                    variant: 'success'
                })
            );

            await refreshApex(this.wiredResult);

        } catch (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: error.body.message,
                    variant: 'error'
                })
            );
        }
    }
}
