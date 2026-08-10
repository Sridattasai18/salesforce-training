import { LightningElement } from 'lwc';

export default class WelcomeMessage extends LightningElement {
    message = '';
    isVisible = false;

    showMessage() {
        this.message = 'Welcome to Vishnu Placement Portal!';
        this.isVisible = true;
    }
}
