import { LightningElement, track, wire } from 'lwc';
import FORM_FACTOR from '@salesforce/client/formFactor';
import getContacts from '@salesforce/apex/ContactSearchCtrl.getContactsNew';
export default class Datatable extends LightningElement
{
    @track selectedConsCnt = 0;
		@track searchTerm = '';
    @track selectedContacts = {};
    @track contacts = [];
    handleSearch(event)
    {
        this.searchTerm = event.target.value.toLowerCase();
        this.filterContacts();
    }
    handleSelection(event)
    {
        const accountId = event.target.name;
        this.selectedContacts = { ...this.selectedContacts, [accountId]: event.target.checked };
				if(event.target.checked==true) {
        this.selectedConsCnt++;
    } else {
        this.selectedConsCnt--;
    } 
				console.log('selected contacts==>', this.selectedConsCnt);
    }
    filterContacts()
    {
        this.contacts = this.contacts.map(account => ({
            ...account,
            isSelected: this.selectedContacts[account.Id] || false
        }));
    }
    @wire(getContacts, { searchTerm: '$searchTerm' })
    wiredContacts({ error, data }) {
        if (data) {
            this.contacts = data.map(account => ({
                ...account,
                isSelected: this.selectedContacts[account.Id] || false
            }));
        } else if (error) {
            console.error('Error fetching contacts: ', error);
        }
    }

    connectedCallback() {
        this.handleFormFactor();
    }

    handleFormFactor() {
        if (FORM_FACTOR === "Large") {
            this.deviceType = "Desktop/Laptop";
        } else if (FORM_FACTOR === "Medium") {
            this.deviceType = "Tablet";
        } else if (FORM_FACTOR === "Small") {
            this.deviceType = "Mobile";
        }
    }
}