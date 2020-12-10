 /**
    @author Yan Kuhalski
    @description class that includes all logic that is called from InstanceTriggerHandler to handle changes of Instances
*/
public with sharing class InstanceTriggerHandlerHelper {
    private static final String STANDART_TYPE_NAME = 'Standard Instance';
    private static final String TRAIL_TYPE_NAME = 'Trial Instance';

    /**
        @description Find new or deleted instances owners and set new licenses total amount value
        @param  List<Instance__c> of new or deleted instances
        @return List<Instance__c> of accounts with changed licenses total amount value
    */
    public static List<Account> recalculateOwnerLicensesAmount(List<Instance__c> instances) {
        List<Instance__c> standartInstances = new List<Instance__c>();
        List<Id> standartOwnersId = new List<Id>();

        for (Instance__c newInstance : instances) {
            if(newInstance.Type__c == STANDART_TYPE_NAME) {
                standartInstances.add(newInstance);
                standartOwnersId.add(newInstance.Account__c);
            }
        }

        Map<Id, Account> instancesOwners = new Map<Id, Account> ([
            SELECT Total_Licenses__c
            FROM Account
            WHERE Id IN : standartOwnersId
        ]);

        Boolean isInsertTrigger = Trigger.isExecuting && Trigger.isInsert;
        Boolean isDeleteTrigger = Trigger.isExecuting && Trigger.isDelete;

        for (Instance__c standartInstance : standartInstances) {
            if (isInsertTrigger) {
                instancesOwners.get(standartInstance.Account__c).Total_Licenses__c += standartInstance.Licenses__c;
            }
            if (isDeleteTrigger) {
                instancesOwners.get(standartInstance.Account__c).Total_Licenses__c -= standartInstance.Licenses__c;
            }
        }

        return instancesOwners.values();
    }

    /**
        @description Find updated instances owners and set new licenses total amount value
        @param  Map<Id,Instance__c> map of old instances
                List<Instance__c> list of updated instances
        @return List of accounts with changed licenses total amount value
    */
    public static List<Account> recalculateOwnerLicensesAmount(Map<Id,Instance__c> oldInstances, List<Instance__c> newInstances) {
        List<Id> accountToUpdateIds = new List<Id>();
        List<Instance__c> instancesWithNewType = new List<Instance__c>();
        List<Instance__c> instancesWithNewLicensesValue = new List<Instance__c>();
        
        for (Instance__c newInstance : newInstances) {
            Instance__c oldInstance = oldInstances.get(newInstance.Id);
            if (oldInstance.Type__c == TRAIL_TYPE_NAME && newInstance.Type__c == STANDART_TYPE_NAME) {
                accountToUpdateIds.add(newInstance.Account__c);
                instancesWithNewType.add(newInstance);
            } else if (oldInstance.Licenses__c != newInstance.Licenses__c) {
                accountToUpdateIds.add(newInstance.Account__c);
                instancesWithNewLicensesValue.add(newInstance);
            }
        }
        
        Map<Id, Account> instancesOwners = new Map<Id, Account> ([
            SELECT Total_Licenses__c
            FROM Account
            WHERE Id IN : accountToUpdateIds
        ]);
        
        for (Instance__c instanceWithNewType : instancesWithNewType) {
            instancesOwners.get(instanceWithNewType.Account__c).Total_Licenses__c += instanceWithNewType.Licenses__c;
        }

        for (Instance__c instanceWithNewLicensesValue : instancesWithNewLicensesValue) {
            instancesOwners.get(instanceWithNewLicensesValue.Account__c).Total_Licenses__c += 
            (instanceWithNewLicensesValue.Licenses__c - oldInstances.get(instanceWithNewLicensesValue.Id).Licenses__c);
        }

        return instancesOwners.values();
    }
}
