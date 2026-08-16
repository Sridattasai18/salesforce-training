import { LightningElement, wire } from 'lwc';
import getStudents from '@salesforce/apex/StudentPortalController.getStudents';

export default class StudentPortal extends LightningElement {
    students = [];
    selectedStudentId;
    student;

    @wire(getStudents)
    wiredStudents({ data, error }) {
        if (data) {
            this.students = data;
            this.selectedStudentId = data[0].Id;
            this.student = data[0];
        }
    }

    get studentOptions() {
        return this.students.map(student => ({
            label: student.Name,
            value: student.Id
        }));
    }

    handleStudentChange(event) {
        this.selectedStudentId = event.detail.value;
        this.student = this.students.find(
            student => student.Id === this.selectedStudentId
        );
    }
}
