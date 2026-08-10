import { LightningElement, api } from 'lwc';

export default class ApplicationCard extends LightningElement {
    @api application;

    get formattedDate() {
        if (this.application && this.application.Application_Date__c) {
            const dateObj = new Date(this.application.Application_Date__c);
            return dateObj.toLocaleDateString(undefined, {
                day: 'numeric',
                month: 'short',
                year: 'numeric'
            });
        }
        return 'N/A';
    }

    get statusVariant() {
        if (!this.application || !this.application.Status__c) {
            return '';
        }
        
        const status = this.application.Status__c.toLowerCase();
        
        if (status === 'applied' || status === 'submitted') {
            return 'slds-theme_success';
        } else if (status === 'reviewing' || status === 'in progress') {
            return 'slds-theme_warning';
        } else if (status === 'rejected') {
            return 'slds-theme_error';
        } else if (status === 'accepted' || status === 'offered') {
            return 'slds-theme_success';
        }
        
        return '';
    }
}
