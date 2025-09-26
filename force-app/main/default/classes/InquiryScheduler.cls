global class InquiryScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        InquiryBatch batchJob = new InquiryBatch();
        Database.executeBatch(batchJob, 100);
    }
}