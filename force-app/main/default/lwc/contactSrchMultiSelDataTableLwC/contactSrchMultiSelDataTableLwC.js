import { refreshApex } from '@salesforce/apex';
import { LightningElement, track, wire, api } from 'lwc';
import { FlowAttributeChangeEvent } from 'lightning/flowSupport';
import FORM_FACTOR from '@salesforce/client/formFactor';
import getContacts from '@salesforce/apex/ContactSearchCtrl.getContacts';
export default class Datatable extends LightningElement
{
    @api accountRecId;
    @api selectedContacts = {};
    @api selectedContactsToFlow = [];
    @track selectedContactsToFlow_temp = [];
    @track contacts = [];
    @track contacts_temp = [];
    @track searchTerm = '';
    @track selectedConsCnt = 0;

    handleSearch(event)
    {
        this.searchTerm = event.target.value.toLowerCase();
        if(this.searchTerm === '')
        {
            refreshApex(this.wiredContacts);
        }
        this.filterContacts();
    }

    handleSelection(event)
    {                             
        const contactId = event.target.name;

        Object.keys(this.selectedContactsToFlow).forEach(property => {
            if(!(this.selectedContactsToFlow_temp.includes(this.selectedContactsToFlow[property]))){
                                            this.selectedContactsToFlow_temp.push(this.selectedContactsToFlow[property]);
            }
        });
        if(event.target.checked==true) {

            if(this.selectedContactsToFlow.length>0 && this.selectedContactsToFlow_temp.includes(this.selectedContactsToFlow[contactId])){

            } else{
                                            this.selectedContactsToFlow_temp.push(contactId);
            }
            this.selectedContactsToFlow = this.selectedContactsToFlow_temp;
        }
        else
        {
            this.selectedContactsToFlow_temp = this.selectedContactsToFlow_temp.filter(value => value !== contactId);
            this.selectedContactsToFlow = this.selectedContactsToFlow_temp;
        }

        this.selectedConsCnt = this.selectedContactsToFlow.length;

        this.dispatchEvent(new FlowAttributeChangeEvent('selectedContactsToFlow', this.selectedContactsToFlow));
        //this.dispatchEvent(new FlowAttributeChangeEvent('selectedContacts', this.selectedContacts));
    }

    filterContacts()
    {
        this.contacts = this.contacts.map(contact => ({
                                        ...contact,
                                        isSelected: this.selectedContacts[contact.Id] || false
        }));
    }


    @wire(getContacts, { searchTerm: '$searchTerm', accountRecId: '$accountRecId' })
    wiredContacts({ error, data }) {

        if (data) {
            this.contacts = data.map(contact => ({
                                            ...contact,
                                            isSelected: this.selectedContacts[contact.Id] || false
            }));         
        } else if (error) {
            console.error('Error fetching contacts: ', error);
        }

        if (this.selectedContactsToFlow.length>0) {                                                                                                           

            Object.keys(this.selectedContactsToFlow).forEach(property => {
                this.contacts_temp = this.contacts.map(contactObj => {
                    if (contactObj.Id === this.selectedContactsToFlow[property]) {
                        return { ...contactObj, isSelected: true };
                    }
                    return contactObj;
                });
                this.contacts = this.contacts_temp;
            });
        } else if (error) {
            console.error('Error assigning selected contacts: ', error);
        }
        this.selectedConsCnt = this.selectedContactsToFlow.length;
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