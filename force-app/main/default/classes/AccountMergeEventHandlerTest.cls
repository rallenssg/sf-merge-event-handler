@isTest
public class AccountMergeEventHandlerTest {
  private static Account winnerAcct = new Account();
  private static List<Account> loserAccts = new List<Account>();

  private static void createAccounts() {
    winnerAcct = new Account(
      Name = 'Winner',
      RecordTypeId = [
        SELECT Id
        FROM RecordType
        WHERE SobjectType = 'Account' AND Name = 'Organization'
      ][0]
      .Id,
      Type = 'Investment Company',
      CurrencyISOCode = 'USD'
    );

    loserAccts = new List<Account>{
      new Account(
        Name = 'Loser1',
        RecordTypeId = [
          SELECT Id
          FROM RecordType
          WHERE SobjectType = 'Account' AND Name = 'Organization'
        ][0]
        .Id,
        Type = 'Investment Company',
        CurrencyISOCode = 'USD'
      ),
      new Account(
        Name = 'Loser2',
        RecordTypeId = [
          SELECT Id
          FROM RecordType
          WHERE SobjectType = 'Account' AND Name = 'Organization'
        ][0]
        .Id,
        Type = 'Investment Company',
        CurrencyISOCode = 'USD'
      )
    };

    try {
      insert winnerAcct;
      insert loserAccts;
    } catch (Exception e) {
      System.debug(
        'ERROR! Exception on Account insert: ' +
          e.getTypeName() +
          ' - ' +
          e.getMessage()
      );
    }
  }

  @isTest
  static void testHandleMerge() {
    List<Database.MergeResult> mergeResults = new List<Database.MergeResult>();

    createAccounts();

    Test.startTest();

    try {
      mergeResults = Database.merge(winnerAcct, loserAccts);
    } catch (Exception e) {
      System.debug(
        'ERROR! Exception on Account merge: ' +
          e.getTypeName() +
          ' - ' +
          e.getMessage()
      );
      System.assert(false, 'Merge failed!');
    }

    Test.stopTest();

    for (Database.MergeResult mergeResult : mergeResults) {
      System.assert(mergeResult.isSuccess(), 'Merge was not a success');
    }

    System.assert(
      AccountMergeEventHandler.testMergeEvents.size() > 0,
      'Events not published'
    );
    System.assertEquals(
      loserAccts.size(),
      AccountMergeEventHandler.testMergeEvents.size(),
      'Mismatch in expected vs. actual published events'
    );

    for (MergeEvent__e mergeEvent : AccountMergeEventHandler.testMergeEvents) {
      System.assertEquals(
        winnerAcct.Id,
        mergeEvent.MasterRecordID__c,
        'Incorrect MasterRecordId published'
      );
    }
  }
}
