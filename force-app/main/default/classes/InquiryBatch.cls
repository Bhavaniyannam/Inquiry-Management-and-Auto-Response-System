public class InquiryBatch implements Database.Batchable<SObject> {

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            [SELECT Id FROM Inquiry__c WHERE Inquiry_Status__c = 'Assigned']
        );
    }

    public void execute(Database.BatchableContext bc, List<Inquiry__c> scope) {
        for (Inquiry__c inq : scope) {
            inq.Inquiry_Status__c = 'Closed';
        }
        update scope;
    }

    public void finish(Database.BatchableContext bc) {
        // Optional finish logic here
    }
}