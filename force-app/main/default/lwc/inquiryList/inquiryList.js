import { LightningElement, api, wire } from 'lwc';
import getInquiries from '@salesforce/apex/InquiryController.getInquiries';

const columns = [
    { label: 'Inquiry Name', fieldName: 'Name' },
    { label: 'Inquiry Status', fieldName: 'Inquiry_Status__c' },
    { label: 'Received Date', fieldName: 'Received_Date__c', type: 'date' }
];

export default class InquiryList extends LightningElement {
    @api recordId; // Current record ID

    columns = columns;

    @wire(getInquiries, { parentId: '$recordId' })
    inquiries;
}