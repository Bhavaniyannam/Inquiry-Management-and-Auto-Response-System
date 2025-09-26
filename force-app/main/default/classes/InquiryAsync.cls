public class InquiryAsync {
    @future
    public static void sendConfirmationAsync(Id inquiryId) {
        Inquiry__c inquiry = [SELECT Id FROM Inquiry__c WHERE Id = :inquiryId];
    }
}