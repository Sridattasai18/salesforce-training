import { LightningElement, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getEligibleJobs from '@salesforce/apex/ApplicationController.getEligibleJobs';
import submitApplication from '@salesforce/apex/ApplicationController.submitApplication';
import { refreshApex } from '@salesforce/apex';

export default class EligibleJobs extends LightningElement {
    @track jobs = [];
    isLoading = true;
    error;
    wiredJobsResult;

    @wire(getEligibleJobs)
    wiredJobs(result) {
        this.wiredJobsResult = result;
        const { data, error } = result;
        if (data) {
            this.jobs = data;
            this.error = undefined;
            this.isLoading = false;
        } else if (error) {
            this.error = 'Failed to load eligible jobs. Please try again later.';
            this.jobs = [];
            this.isLoading = false;
            console.error('Error loading jobs:', error);
        }
    }

    get hasJobs() {
        return this.jobs && this.jobs.length > 0;
    }

    async handleApply(event) {
        const jobId = event.detail.jobId;
        this.isLoading = true;
        this.error = undefined;

        try {
            await submitApplication({ jobId: jobId });
            
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Application submitted successfully!',
                    variant: 'success'
                })
            );
            
            await this.refreshJobs();
        } catch (err) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Application Failed',
                    message: err.body ? err.body.message : 'An error occurred while submitting your application.',
                    variant: 'error'
                })
            );
        } finally {
            this.isLoading = false;
        }
    }

    async refreshJobs() {
        try {
            await refreshApex(this.wiredJobsResult);
        } catch (err) {
            console.error('Error refreshing jobs:', err);
        }
    }
}
