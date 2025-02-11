trigger AccountTrigger_AfterDelete on Account (after delete) {

    AccountMergeEventHandler.handleMerge(Trigger.old);

}