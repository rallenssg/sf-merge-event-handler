public with sharing class AccountMergeEventHandler {

    @TestVisible private static List<MergeEvent__e> mergeEvents= new List<MergeEvent__e>();

    public static void handleMerge(List<Account> accts) {

        for (Account acct : accts) {
            if(acct.MasterRecordId != null) { // checks if this acct was the loser in a merge
                MergeEvent__e mergeEvent = new MergeEvent__e(
                    ObjectName__c = 'Account',
                    MergedRecordID__c = acct.Id,
                    MasterRecordID__c = acct.MasterRecordId,
                    MergedDate__c = System.now()
                );
                mergeEvents.add(mergeEvent);
            }
        }
        if(!mergeEvents.isEmpty()) {
            EventBus.publish(mergeEvents);
        }
    }
}