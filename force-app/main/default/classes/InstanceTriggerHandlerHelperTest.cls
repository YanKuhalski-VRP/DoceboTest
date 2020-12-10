@isTest
public class InstanceTriggerHandlerHelperTest {
    private static final String ACCOUNT_NAME = 'Yan Test Account';
    private static final Decimal AMOUNT_OF_LICENSES = 15;
    private static final String STANDART_TYPE_NAME = 'Standard Instance';
    private static final String TRAIL_TYPE_NAME = 'Trial Instance';
    
    @TestSetup
    static void makeData(){
        Account ownerAccount = new Account (
            Name = ACCOUNT_NAME
        );
        insert ownerAccount;
        insert new Instance__c  (
            Account__c = ownerAccount.Id, 
            Licenses__c = AMOUNT_OF_LICENSES,
            Type__c = STANDART_TYPE_NAME
        );
        insert new Instance__c  (
            Account__c = ownerAccount.Id, 
            Licenses__c = AMOUNT_OF_LICENSES,
            Type__c = TRAIL_TYPE_NAME
        );
    }

    @isTest
    public static void shouldUpdateAccountAfterInstanceInsert() {
        Account oldOwnerAccount  = [
            SELECT Total_Licenses__c
            FROM Account 
            WHERE Name =: ACCOUNT_NAME
            LIMIT 1
        ];
         
        Test.startTest();
        insert new Instance__c  (
            Account__c = oldOwnerAccount.Id, 
            Licenses__c = AMOUNT_OF_LICENSES,
            Type__c = STANDART_TYPE_NAME
        );
        Test.stopTest();

        Account ownerAccount  = [
            SELECT Total_Licenses__c
            FROM Account 
            WHERE Id =: oldOwnerAccount.Id
            LIMIT 1
        ];

        System.assertEquals(oldOwnerAccount.Total_Licenses__c + AMOUNT_OF_LICENSES, ownerAccount.Total_Licenses__c);
    }

    @isTest
    public static void shouldUpdateAccountAfterInstanceDelete() {
        Account ownerAccount  = [
            SELECT Total_Licenses__c,
            (
                SELECT Id
                FROM Instances__r
            )
            FROM Account 
            WHERE Name =: ACCOUNT_NAME
            LIMIT 1
        ];

        Test.startTest();
        delete ownerAccount.Instances__r;
        Test.stopTest();

        ownerAccount  = [
            SELECT Total_Licenses__c
            FROM Account 
            WHERE Id =: ownerAccount.Id
            LIMIT 1
        ];

        System.assertEquals(0, ownerAccount.Total_Licenses__c);
    }

    @isTest
    public static void shouldUpdateAccountAfterInstanceTypeUpdate() {
        Account oldOwnerAccount  = [
            SELECT Total_Licenses__c,
            (
                SELECT Licenses__c
                FROM Instances__r
                WHERE Type__c =: TRAIL_TYPE_NAME
            )
            FROM Account 
            WHERE Name =: ACCOUNT_NAME
            LIMIT 1
        ];

        Decimal changes = 0 ;
        for (Instance__c instance : oldOwnerAccount.Instances__r) {
            changes += instance.Licenses__c;
            instance.Type__c = STANDART_TYPE_NAME;
        }

        Test.startTest();
        update oldOwnerAccount.Instances__r;
        Test.stopTest();

        Account ownerAccount  = [
            SELECT Total_Licenses__c
            FROM Account 
            WHERE Id =: oldOwnerAccount.Id
            LIMIT 1
        ];

        System.assertEquals(oldOwnerAccount.Total_Licenses__c + changes, ownerAccount.Total_Licenses__c);
    }

    @isTest
    public static void shouldUpdateAccountAfterInstanceLicensesAmount() {
        Account oldOwnerAccount  = [
            SELECT Total_Licenses__c,
            (
                SELECT Licenses__c
                FROM Instances__r
                WHERE Type__c =: STANDART_TYPE_NAME
            )
            FROM Account 
            WHERE Name =: ACCOUNT_NAME
            LIMIT 1
        ];

        Decimal changes = 0 ;
        for (Instance__c instance : oldOwnerAccount.Instances__r) {
            changes += instance.Licenses__c;
            instance.Licenses__c = instance.Licenses__c*2;
        }

        Test.startTest();
        update oldOwnerAccount.Instances__r;
        Test.stopTest();

        Account ownerAccount  = [
            SELECT Total_Licenses__c
            FROM Account 
            WHERE Id =: oldOwnerAccount.Id
            LIMIT 1
        ];

        System.assertEquals(oldOwnerAccount.Total_Licenses__c + changes, ownerAccount.Total_Licenses__c);
    }
}
