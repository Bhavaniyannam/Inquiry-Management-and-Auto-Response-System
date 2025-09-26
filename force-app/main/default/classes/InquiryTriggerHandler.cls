public class InquiryTriggerHandler {
    public static void beforeInsert(List<Inquiry__c> newInquiries) {
        if (!newInquiries.isEmpty()) {
            // Validate required fields: Customer Name and Email
            for (Inquiry__c inq : newInquiries) {
                if (String.isBlank(inq.Customer_Name__c)) {
                    inq.addError('Customer Name is a required field.');
                }
                if (String.isBlank(inq.Email__c)) {
                    inq.addError('Email is a required field.');
                }
            }

            // Only call autoAssignInquiry if no errors
            Boolean hasErrors = false;
            for (Inquiry__c inq : newInquiries) {
                if (inq.getErrors().size() > 0) {
                    hasErrors = true;
                    break;
                }
            }

            if (!hasErrors) {
                InquiryService.autoAssignInquiry(newInquiries);
            }
        }
    }

    public static void afterInsert(List<Inquiry__c> newInquiries) {
        if (!newInquiries.isEmpty()) {
            InquiryService.sendAutoResponse(newInquiries);
        }
    }

    public static void beforeUpdate(List<Inquiry__c> updatedInquiries, Map<Id, Inquiry__c> oldMap) {
        if (oldMap == null || oldMap.isEmpty()) return;

        for (Inquiry__c inq : updatedInquiries) {
            if (inq != null && oldMap.containsKey(inq.Id) &&
                inq.Inquiry_Status__c != oldMap.get(inq.Id).Inquiry_Status__c) {
                System.debug('Status changed for inquiry: ' + inq.Id);
            }
        }
    }
}