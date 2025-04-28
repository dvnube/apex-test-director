/**
 * In this example, the AccountScenes is a class that contains two inner
 * classes, each representing a scene for creating Account records and that can
 * be chained and reused across different unit tests.
 */
@IsTest
public class AccountScenes {
    public class Base extends TestScene {
        public override Map<String, Object> build(Map<String, Object> params) {
            Account record = new Account(
                Name = params.containsKey('Name')
                    ? (String) params.get('Name')
                    : 'John Smith'
            );

            insert record;

            return new Map<String, Object>{
                'account' => record,
                'accountId' => record.Id
            };
        }
    }

    public class Many extends TestScene {
        public override Map<String, Object> build(Map<String, Object> params) {
            List<Account> records = new List<Account>();

            for (Integer i = 0; i < 10; i++) {
                records.add(new Account(Name = 'John Smith No.  ' + i));
            }

            insert records;

            List<Id> accountIds = new List<Id>();

            for (Account a : records) {
                accountIds.add(a.Id);
            }

            return new Map<String, Object>{
                'accounts' => records,
                'accountIds' => accountIds
            };
        }
    }

    /**
     * In this self test, it is demonstrated how to use the TestDirector class
     * to run the scenes in a specific order and how to access the output of
     * each scene (for assertions, for example).
     */
    @IsTest
    static void selfTest() {
        Test.startTest();
        TestDirector director = new TestDirector()
            .startWith(new AccountScenes.Base())
            .then(new AccountScenes.Many())
            .action();
        Test.stopTest();

        List<Account> accounts = [SELECT Id FROM Account];

        Assert.isNotNull(accounts, 'Accounts should not be null');
        Assert.isTrue(accounts.size() == 11, 'There should be 11 accounts');

        List<Account> listOfAccountsFromTheSecondScene = (List<Account>) director.getAllScenarioParams()
            .get('accounts');

        Assert.isNotNull(
            listOfAccountsFromTheSecondScene,
            'Accounts should not be null'
        );
        Assert.areEqual(
            10,
            listOfAccountsFromTheSecondScene.size(),
            'There should be 10 accounts'
        );

        listOfAccountsFromTheSecondScene = (List<Account>) director.getSceneOutput(
                1
            )
            .get('accounts');

        Assert.isNotNull(
            listOfAccountsFromTheSecondScene,
            'Accounts should not be null'
        );
        Assert.areEqual(
            10,
            listOfAccountsFromTheSecondScene.size(),
            'There should be 10 accounts'
        );
    }
}
