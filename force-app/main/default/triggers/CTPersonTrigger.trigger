trigger CTPersonTrigger on Person__c (before insert,before update, before delete,after insert,after update,after delete,after undelete) {
    switch on Trigger.operationType {
        when BEFORE_INSERT {
            CTPersonTriggerHandler.handleBeforeInsert(Trigger.new);
        }
        when BEFORE_UPDATE {
            CTPersonTriggerHandler.handleBeforeUpdate(Trigger.new, Trigger.oldMap);
        }
        when BEFORE_DELETE {
            CTPersonTriggerHandler.handleBeforeDelete(Trigger.old);
        }
        when AFTER_INSERT {
            CTPersonTriggerHandler.handleAfterInsert(Trigger.new);
        }

        when AFTER_UPDATE {
            CTPersonTriggerHandler.handleAfterUpdate(Trigger.new, Trigger.oldMap);
        }

        when AFTER_DELETE {
            CTPersonTriggerHandler.handleAfterDelete(Trigger.old);
        }

        when AFTER_UNDELETE {
            CTPersonTriggerHandler.handleAfterUndelete(Trigger.new);
        }

        when else {
            // Default Case
        }
    }
}