@isTest
public class InquiryFullTest {

    private static Inquiry__c makeInquiry(String status, String source, String type) {
        return new Inquiry__c(
            Name = 'Test_' + String.valueOf(Math.random()),
            Inquiry_Status__c = status,
            Inquiry_Source__c = source,
            Inquiry_Type__c = type
        );
    }

    @isTest
    static void testServiceValidAndEmptyInputs() {
        List<Inquiry__c> inquiries = new List<Inquiry__c> {
            makeInquiry('New', 'Website', 'Product'),
            makeInquiry('Assigned', 'Email', 'Service'),
            makeInquiry('Closed', 'Phone', 'Support')
        };
        insert inquiries;

        InquiryService.autoAssignInquiry(inquiries);
        InquiryService.sendAutoResponse(inquiries);

        InquiryService.autoAssignInquiry(new List<Inquiry__c>());
        InquiryService.sendAutoResponse(new List<Inquiry__c>());
    }

    @isTest
    static void testBeforeInsertAndAfterInsertTriggers() {
        Inquiry__c inq = makeInquiry('New', 'Chat', 'General');
        insert inq;
        List<Inquiry__c> loaded = [SELECT Id, Inquiry_Status__c FROM Inquiry__c WHERE Id = :inq.Id];

        InquiryTriggerHandler.beforeInsert(loaded);
        InquiryTriggerHandler.afterInsert(loaded);

        InquiryTriggerHandler.beforeInsert(new List<Inquiry__c>());
        InquiryTriggerHandler.afterInsert(new List<Inquiry__c>());
    }

    @isTest
    static void testBeforeUpdateTriggerWithStatusChange() {
        Inquiry__c inq = makeInquiry('New', 'Email', 'Product');
        insert inq;

        List<Inquiry__c> updatedList = [SELECT Id, Inquiry_Status__c FROM Inquiry__c WHERE Id = :inq.Id];
        Map<Id, Inquiry__c> oldMap = new Map<Id, Inquiry__c>([SELECT Id, Inquiry_Status__c FROM Inquiry__c WHERE Id = :inq.Id]);

        InquiryTriggerHandler.beforeUpdate(updatedList, oldMap);

        Inquiry__c updatedInq = updatedList[0];
        updatedInq.Inquiry_Status__c = 'Assigned';
        update updatedInq;

        List<Inquiry__c> newList = [SELECT Id, Inquiry_Status__c FROM Inquiry__c WHERE Id = :inq.Id];
        Map<Id, Inquiry__c> newOldMap = new Map<Id, Inquiry__c>([SELECT Id, Inquiry_Status__c FROM Inquiry__c WHERE Id = :inq.Id]);

        InquiryTriggerHandler.beforeUpdate(newList, newOldMap);
    }

    @isTest
    static void testUpdateWithoutStatusChange() {
        Inquiry__c inq = makeInquiry('New', 'Phone', 'Support');
        insert inq;

        inq.Inquiry_Type__c = 'Product';
        update inq;

        List<Inquiry__c> updatedList = [SELECT Id, Inquiry_Status__c, Inquiry_Type__c FROM Inquiry__c WHERE Id = :inq.Id];
        Map<Id, Inquiry__c> oldMap = new Map<Id, Inquiry__c>([SELECT Id, Inquiry_Status__c, Inquiry_Type__c FROM Inquiry__c WHERE Id = :inq.Id]);
        InquiryTriggerHandler.beforeUpdate(updatedList, oldMap);
    }

    @isTest
    static void testBulkInsertAndUpdate() {
        List<Inquiry__c> bulkInsertList = new List<Inquiry__c>();
        for (Integer i = 0; i < 10; i++) {
            bulkInsertList.add(makeInquiry('New', 'Email', 'General'));
        }
        insert bulkInsertList;

        for (Inquiry__c inq : bulkInsertList) {
            inq.Inquiry_Status__c = 'Assigned';
        }
        update bulkInsertList;

        List<Inquiry__c> bulkUpdateList = [SELECT Id, Inquiry_Status__c FROM Inquiry__c WHERE Id IN :bulkInsertList];
        Map<Id, Inquiry__c> oldMap = new Map<Id, Inquiry__c>(bulkUpdateList);

        InquiryTriggerHandler.beforeUpdate(bulkUpdateList, oldMap);
    }

    @isTest
    static void testBatchExecutionAndDelete() {
        List<Inquiry__c> batchList = new List<Inquiry__c>();
        batchList.add(makeInquiry('Assigned', 'Email', 'Support'));
        batchList.add(makeInquiry('Assigned', 'Phone', 'Product'));
        batchList.add(makeInquiry('Closed', 'Website', 'Service'));
        insert batchList;

        Test.startTest();
        Database.executeBatch(new InquiryBatch(), 1);
        Database.executeBatch(new InquiryBatch(), 2);

        delete [SELECT Id FROM Inquiry__c WHERE Inquiry_Status__c = 'Assigned' LIMIT 1];
        Database.executeBatch(new InquiryBatch(), 1);
        Test.stopTest();
    }

    @isTest
    static void testQueueableJobExecution() {
        Inquiry__c rec = makeInquiry('New', 'Other', 'General');
        insert rec;

        Test.startTest();
        System.enqueueJob(new InquiryQueueable(new List<Id>{rec.Id}));
        System.enqueueJob(new InquiryQueueable(new List<Id>()));
        System.enqueueJob(new InquiryQueueable(new List<Id>{rec.Id, '001FAKEID000000AAA'}));
        Test.stopTest();
    }

    @isTest
    static void testSchedulerRun() {
        Test.startTest();
        System.schedule('TestSchedulerRun', '0 0 3 * * ?', new InquiryScheduler());
        Test.stopTest();
    }

    @isTest
    static void testInquiryAsyncSendConfirmation() {
        Inquiry__c inq = makeInquiry('New', 'Chat', 'Product');
        insert inq;

        Test.startTest();
        InquiryAsync.sendConfirmationAsync(inq.Id);
        InquiryAsync.sendConfirmationAsync('001FAKEID000000AAA');
        InquiryAsync.sendConfirmationAsync(null);
        Test.stopTest();
    }

    @isTest
    static void testNegativeCasesAndEmptyLists() {
        Test.startTest();
        InquiryTriggerHandler.beforeInsert(new List<Inquiry__c>());
        InquiryTriggerHandler.afterInsert(new List<Inquiry__c>());
        InquiryTriggerHandler.beforeUpdate(new List<Inquiry__c>(), new Map<Id, Inquiry__c>());
        InquiryService.autoAssignInquiry(new List<Inquiry__c>());
        InquiryService.sendAutoResponse(new List<Inquiry__c>());
        System.enqueueJob(new InquiryQueueable(new List<Id>()));
        Test.stopTest();
    }

    @isTest
    static void testStatusFieldTransitions() {
        Inquiry__c inq = makeInquiry('New', 'Website', 'Support');
        insert inq;

        inq.Inquiry_Status__c = 'Assigned';
        update inq;

        inq.Inquiry_Status__c = 'Closed';
        update inq;

        inq.Inquiry_Status__c = 'Reopened';
        update inq;
    }

    @isTest
    static void testCloneAndModifyRecords() {
        Inquiry__c inq = makeInquiry('New', 'Phone', 'Course');
        insert inq;

        Inquiry__c cloned = inq.clone(false, true);
        cloned.Inquiry_Status__c = 'Assigned';
        insert cloned;

        cloned.Inquiry_Status__c = 'Closed';
        update cloned;
    }
}