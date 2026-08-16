import { LightningElement, wire } from 'lwc';
import getStudents from '@salesforce/apex/StudentPortalController.getStudents';

export default class StudentPortal extends LightningElement {
    students = [];
    selectedStudentId = null;
    student = null;
    error;

    @wire(getStudents)
    wiredStudents({ data, error }) {
        if (data && data.length > 0) {
            this.students = data;
            this.selectedStudentId = data[0].Id;
            this.student = data[0];
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.students = [];
            this.student = null;
        }
    }

    get studentOptions() {
        return this.students.map(student => ({
            label: student.Name,
            value: student.Id
        }));
    }

    get hasStudents() {
        return this.students && this.students.length > 0;
    }

    get errorMessage() {
        return this.error?.body?.message ||
               this.error?.body?.pageErrors?.[0]?.message ||
               this.error?.message ||
               'Unable to load students. Please refresh the page and try again.';
    }

    handleStudentChange(event) {
        this.selectedStudentId = event.detail.value;
        this.student = this.students.find(
            student => student.Id === this.selectedStudentId
        );
    }
}
