public with sharing class AccountMergeEventHandler {

    @TestVisible private static List<MergeEvent__e> testMergeEvents = new List<MergeEvent__e>();

    public static void handleMerge(List<Account> accts) {

        List<MergeEvent__e> mergeEvents = new List<MergeEvent__e>();
        List<Database.Error> errs = new List<Database.Error>();

        for (Account acct : accts) {
            if (acct.MasterRecordId != null) { // checks if this acct was the loser in a merge
                mergeEvents.add(new MergeEvent__e(
                    ObjectName__c = 'Account',
                    MergedRecordID__c = acct.Id,
                    MasterRecordID__c = acct.MasterRecordId,
                    MergedDate__c = System.now())
                );
            }
        }

        if (!mergeEvents.isEmpty()) {

            List<Database.SaveResult> results = EventBus.publish(mergeEvents); //save publish results

            for (Integer i = 0; i < results.size(); i++) {

                if (!results.get(i).isSuccess()) { // event publish failed
                    errs.addAll(results.get(i).getErrors());
                } else if (Test.isRunningTest()) { // add mergeEvent at i to static variable if test is running and result at i was a success
                    testMergeEvents.add(mergeEvents.get(i));
                }
            }

            for (Database.Error err : errs) {
                System.debug('ERROR! Merge Event publish error: ' + err.getMessage() + ': ' + System.now());
            }
        }
    }
}