import { LightningElement, track } from 'lwc';
import getCurrentStudent from '@salesforce/apex/ApplicationController.getCurrentStudent';

export default class StudentPortal extends LightningElement {
    @track currentStudentId;
    @track refreshSignal = 0;
    @track applicationRefreshSignal = 0;

    connectedCallback() {
        this.loadCurrentStudent();
    }

    async loadCurrentStudent() {
        try {
            const student = await getCurrentStudent();
            if (student) {
                this.currentStudentId = student.Id;
            }
        } catch (error) {
            console.error('Error loading current student:', error);
        }
    }

    handleProfileUpdate() {
        // Increment refresh signal to trigger child component updates
        this.refreshSignal++;
        
        // Also refresh eligible jobs as CGPA might have changed
        const eligibleJobsComponent = this.template.querySelector('c-eligible-jobs');
        if (eligibleJobsComponent) {
            eligibleJobsComponent.refreshJobs();
        }
    }

    handleApplicationCreated() {
        // Increment application refresh signal to update MyApplications
        this.applicationRefreshSignal++;
    }
}
