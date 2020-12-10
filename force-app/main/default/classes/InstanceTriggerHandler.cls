public with sharing class InstanceTriggerHandler {
    public static void onAfterInsert(List<Instance__c> newInstances) {
        List<Account> accountsToUpdate = InstanceTriggerHandlerHelper.recalculateOwnerLicensesAmount(newInstances);
        AccountCrtl.updateAccounts(accountsToUpdate);
    }

    public static void onAfterUpdate(Map<Id,Instance__c> oldInstances, List<Instance__c> newInstances) {
        List<Account> accountsToUpdate = InstanceTriggerHandlerHelper.recalculateOwnerLicensesAmount(oldInstances, newInstances);
        AccountCrtl.updateAccounts(accountsToUpdate);
    }

    public static void onAfterDelete(List<Instance__c> oldInstances) {
        List<Account> accountsToUpdate = InstanceTriggerHandlerHelper.recalculateOwnerLicensesAmount(oldInstances);
        AccountCrtl.updateAccounts(accountsToUpdate);
    }
}
