public with sharing class InquiryController {
    @AuraEnabled(cacheable=true)
    public static List<Inquiry__c> getInquiries(Id parentId) {
        return [
            SELECT Id, Name, Inquiry_Status__c, Received_Date__c
            FROM Inquiry__c
            WHERE Account__c = :parentId
            LIMIT 50
        ];
    }
}