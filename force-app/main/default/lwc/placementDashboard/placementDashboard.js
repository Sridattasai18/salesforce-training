import { LightningElement, wire } from 'lwc';
import getDashboardData from '@salesforce/apex/PlacementDashboardController.getDashboardData';

export default class PlacementDashboard extends LightningElement {

    studentCount = 0;
    jobCount = 0;
    applicationCount = 0;
    offerCount = 0;

    @wire(getDashboardData)
    wiredDashboard({ error, data }) {
        if (data) {
            this.studentCount     = data.studentCount;
            this.jobCount         = data.jobCount;
            this.applicationCount = data.applicationCount;
            this.offerCount       = data.offerCount;
        } else if (error) {
            console.error('Dashboard load error:', error);
        }
    }
}
