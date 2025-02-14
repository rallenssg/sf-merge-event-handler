trigger AccountTrigger on Account (after delete) {

    AccountMergeEventHandler.handleMerge(Trigger.old);

}