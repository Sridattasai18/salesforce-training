import { LightningElement, wire } from 'lwc';
import getEligibleJobs from '@salesforce/apex/StudentPortalController.getEligibleJobs';
import applyForJob from '@salesforce/apex/StudentPortalController.applyForJob';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

const STUDENT_ID = 'a00g500000p5G0RAAU';

export default class EligibleJobs extends LightningElement {

    jobs;
    wiredResult;

    @wire(getEligibleJobs, { studentId: STUDENT_ID })
    wiredJobs(result) {
        this.wiredResult = result;
        if (result.data) {
            this.jobs = result.data;
        }
    }

    async handleApply(event) {

        const jobId = event.target.dataset.id;

        try {
            await applyForJob({
                studentId: STUDENT_ID,
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
