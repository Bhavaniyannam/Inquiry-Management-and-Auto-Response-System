trigger InquiryTrigger on Inquiry__c (before insert, before update) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            InquiryTriggerHandler.beforeInsert(Trigger.new);
        }
        if (Trigger.isUpdate) {
            InquiryTriggerHandler.beforeUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}