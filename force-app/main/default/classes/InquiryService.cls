public class InquiryService {

    public static void autoAssignInquiry(List<Inquiry__c> inquiries) {
        List<User> activeUsers = [SELECT Id FROM User WHERE IsActive = TRUE LIMIT 1];
        Id assignedUserId = activeUsers.size() > 0 ? activeUsers[0].Id : null;

        for (Inquiry__c inq : inquiries) {
            if (assignedUserId != null) {
                inq.Assigned_To_User__c = assignedUserId;
            }
            inq.Inquiry_Status__c = 'Assigned';
        }
    }

    public static void sendAutoResponse(List<Inquiry__c> inquiries) {
        for (Inquiry__c inquiry : inquiries) {
            System.debug('Auto-response sent for Inquiry: ' + inquiry.Id);
        }
    }
}