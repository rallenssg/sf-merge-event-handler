@isTest
public class AccountMergeEventHandlerTest {

    private static Account winnerAcct;
    private static List<Account> loserAccts;
    private static List<Database.MergeResult> mergeResults;

    @TestSetup static void createAccounts() {

        mergeResults = new List<Database.MergeResult>();

        winnerAcct = new Account(
            Name = 'Winner',
            RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND Name = 'Organization'][0].Id,
            Type = 'Investment Company',
            CurrencyISOCode = 'USD'
            );

        loserAccts = new List<Account> {
            new Account(
            Name = 'Loser1',
            RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND Name = 'Organization'][0].Id,
            Type = 'Investment Company',
            CurrencyISOCode = 'USD'
            ),
            new Account(
            Name = 'Loser2',
            RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND Name = 'Organization'][0].Id,
            Type = 'Investment Company',
            CurrencyISOCode = 'USD'
            )
        };

        try {
            insert winnerAcct;
            insert loserAccts;
        } catch (Exception e) {
            System.debug('ERROR! Exception on Account insert: ' + e.getTypeName() + ' - ' + e.getMessage());
        }
    }
    
    @isTest
    static void testHandleMerge() {

        Test.startTest();

        try {
            mergeResults = Database.merge(winnerAcct, loserAccts);
        } catch(Exception e) {
            System.debug('ERROR! Exception on Account merge: ' + e.getTypeName() + ' - ' + e.getMessage());
            Test.stopTest();
        }

        if (Test.isRunningTest()) {

            System.assert(AccountMergeEventHandler.testMergeEvents.size() > 0, 'Events not published');

            for (Database.MergeResult mergeResult : mergeResults) {
                System.assert(mergeResult.isSuccess(), 'Merge was not a success');
            }
    
            for (MergeEvent__e mergeEvent : AccountMergeEventHandler.testMergeEvents) {
                System.assert(mergeEvent.MasterRecordID__c != null, 'MasterRecordId not published on event');
            }
    
            Test.stopTest();
        }
    }
}