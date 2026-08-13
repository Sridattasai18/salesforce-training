import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class StudentProfileForm extends LightningElement {
    @api studentId;

    handleSuccess() {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Profile updated successfully!',
                variant: 'success'
            })
        );

        // Dispatch custom event to notify parent
        const profileUpdatedEvent = new CustomEvent('profileupdated', {
            detail: {
                studentId: this.studentId
            }
        });
        this.dispatchEvent(profileUpdatedEvent);
    }

    handleError(event) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error updating profile',
                message: event.detail.message || 'An error occurred while updating your profile.',
                variant: 'error'
            })
        );
    }

    handleCancel() {
        // Reset the form
        const inputFields = this.template.querySelectorAll('lightning-input-field');
        if (inputFields) {
            inputFields.forEach(field => {
                field.reset();
            });
        }
        
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Cancelled',
                message: 'Changes discarded.',
                variant: 'info'
            })
        );
    }
}
