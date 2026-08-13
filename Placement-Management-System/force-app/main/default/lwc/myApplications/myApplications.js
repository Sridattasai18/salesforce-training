import { LightningElement, api, wire, track } from 'lwc';
import getMyApplications from '@salesforce/apex/ApplicationController.getMyApplications';
import { refreshApex } from '@salesforce/apex';

export default class MyApplications extends LightningElement {
    @api studentId;
    @api refreshSignal;
    
    @track applications = [];
    isLoading = true;
    error;
    wiredApplicationsResult;

    @wire(getMyApplications, { studentId: '$studentId' })
    wiredApplications(result) {
        this.wiredApplicationsResult = result;
        const { data, error } = result;
        
        this.isLoading = false;
        
        if (data) {
            this.applications = data;
            this.error = undefined;
        } else if (error) {
            this.error = 'Failed to load applications. Please try again.';
            this.applications = [];
            console.error('Error loading applications:', error);
        }
    }

    get hasApplications() {
        return this.applications && this.applications.length > 0;
    }

    // Watch for refresh signal changes
    @api
    async refreshApplications() {
        this.isLoading = true;
        try {
            await refreshApex(this.wiredApplicationsResult);
        } catch (error) {
            console.error('Error refreshing applications:', error);
        } finally {
            this.isLoading = false;
        }
    }

    // Automatically refresh when refreshSignal changes
    renderedCallback() {
        if (this.refreshSignal !== this.lastRefreshSignal) {
            this.lastRefreshSignal = this.refreshSignal;
            this.refreshApplications();
        }
    }
}
