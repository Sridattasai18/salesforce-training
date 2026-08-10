import { LightningElement, api } from 'lwc';

export default class JobCard extends LightningElement {
    @api job;
    isApplying = false;

    get formattedDeadline() {
        if (this.job && this.job.Closing_Date__c) {
            // Basic date formatting, matching standard localization
            const dateObj = new Date(this.job.Closing_Date__c);
            return dateObj.toLocaleDateString(undefined, {
                day: 'numeric',
                month: 'short',
                year: 'numeric'
            });
        }
        return 'No deadline';
    }

    handleApplyClick() {
        this.isApplying = true;
        
        const applyEvent = new CustomEvent('apply', {
            detail: {
                jobId: this.job.Id
            }
        });
        
        this.dispatchEvent(applyEvent);
        
        // Reset the applying state after a short delay, 
        // normally the parent component's refresh and spinner will overlay this anyway.
        setTimeout(() => {
            this.isApplying = false;
        }, 2000);
    }
}
