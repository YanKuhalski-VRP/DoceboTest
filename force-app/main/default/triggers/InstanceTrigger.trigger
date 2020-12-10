trigger InstanceTrigger on Instance__c (after insert, after update, after delete) {
    if (Trigger.isInsert) {
        InstanceTriggerHandler.onAfterInsert(Trigger.new);
    }
    if (Trigger.isDelete) {
        InstanceTriggerHandler.onAfterDelete(Trigger.old);
    }
    if (Trigger.isUpdate) {
        InstanceTriggerHandler.onAfterUpdate(Trigger.oldMap, Trigger.new);
    }
}