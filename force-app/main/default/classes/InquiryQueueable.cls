public class InquiryQueueable implements Queueable {
    private List<Id> inquiryIds;

    public InquiryQueueable(List<Id> ids) {
        inquiryIds = ids;
    }

    public void execute(QueueableContext context) {
        List<Inquiry__c> inquiries = [SELECT Id FROM Inquiry__c WHERE Id IN :inquiryIds];
        // Business logic e.g., send notifications
        for (Inquiry__c inquiry : inquiries) {
            System.debug('Queueable processing Inquiry: ' + inquiry.Id);
        }
    }
}