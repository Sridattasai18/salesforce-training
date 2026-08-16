import { LightningElement, wire } from 'lwc';
import getDashboardData from '@salesforce/apex/PlacementDashboardController.getDashboardData';

export default class PlacementDashboard extends LightningElement {

    studentCount = 0;
    jobCount = 0;
    applicationCount = 0;
    offerCount = 0;
    errorMessage;

    @wire(getDashboardData)
    wiredDashboard({ error, data }) {
        if (data) {
            this.studentCount     = data.studentCount;
            this.jobCount         = data.jobCount;
            this.applicationCount = data.applicationCount;
            this.offerCount       = data.offerCount;
            this.errorMessage     = undefined;
        } else if (error) {
            this.errorMessage =
                error?.body?.message ||
                error?.body?.pageErrors?.[0]?.message ||
                error?.message ||
                'Unable to load dashboard data. Please refresh the page and try again.';
        }
    }
}
