@isTest
public class AccountMergeEventHandlerTest {

    private static List<Account> accts;
    private static List<EventBusSubscriber> eventBusSubs;
    private static Database.MergeResult mergeResults;

    @TestSetup static void createAccounts() {
        accts = new List<Account> {
            new Account(
            Name = 'Loser',
            RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND Name = 'Organization'][0].Id,
            Type = 'Investment Company',
            CurrencyISOCode = 'USD'
            ),
            new Account(
            Name = 'Winner',
            RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND Name = 'Organization'][0].Id,
            Type = 'Investment Company',
            CurrencyISOCode = 'USD'
            )
        };
        try {
            insert accts;
        } catch (DmlException e) {
            System.debug(e.getMessage());
        }
    }
    
    @isTest
    static void testHandleMerge() {

        // Create and insert 2 Accounts: one to be merged and one to be the master
        createAccounts();

        Test.startTest();
        
        try {
            mergeResults = Database.merge(accts[1],accts[0]);
        } catch(DmlException e) {
            System.debug(e.getMessage());
        }

        System.assert(mergeResults.isSuccess(), 'Merge was not a success');

        System.assert(AccountMergeEventHandler.mergeEvents.size() > 0, 'Event not published');

        for (MergeEvent__e mergeEvent : AccountMergeEventHandler.mergeEvents) {
            System.assert(mergeEvent.MasterRecordID__c != null, 'MasterRecordId not published on event');
        }

        Test.stopTest();

    }
}