public with sharing class CTPersonTriggerHandler {

    public static void handleBeforeInsert(List<Person__c> listRecords){
        for (Person__c person : listRecords) {
            person.Health_Status__c = 'Green';
            person.Token__c = CTPersonController.getToken(person.Mobile__c);
        }
    }

    public static void handleBeforeUpdate(List<Person__c> listRecords, Map<Id, Person__c> oldMap){
        for (Person__c person : listRecords) {
            Person__c oldPerson = oldMap.get(person.Id);
            if (person.Health_Status__c != oldPerson.Health_Status__c) {
                person.Status_Update_Date__c = Date.today();
            }
        }
    }

    public static void handleBeforeDelete(List<Person__c> listRecords){

    }

    public static void handleAfterInsert(List<Person__c> listRecords){

    }

    public static void handleAfterUpdate(List<Person__c> listRecords, Map<Id, Person__c> oldMap){
        Set<Id> personIds = new Set<Id>();
        Set<Id> redStatus = new Set<Id>();
        for (Person__c person : listRecords) {
            Person__c oldPerson = oldMap.get(person.Id);
            if (person.Health_Status__c != oldPerson.Health_Status__c) {
                if (person.Health_Status__c == 'Red') {
                    redStatus.add(person.Id);
                }
                personIds.add(person.Id);
            }
        }
        
        Set<Id> alreadyProcessedIds = new Set<Id>();
        alreadyProcessedIds.addAll(redStatus);

        Set<Id> orangeStatus = new Set<Id>();
        Set<Id> yellowStatus = new Set<Id>();

        List<Person__c> peopleToUpdate = new List<Person__c>();

        orangeStatus.addAll(CTPersonController.getCohabitants(redStatus, alreadyProcessedIds));
        Set<Id> primaryContacts = CTPersonController.getPrimaryContacts(redStatus, alreadyProcessedIds);
        orangeStatus.addAll(primaryContacts);
        yellowStatus.addAll(CTPersonController.getNeighbours(redStatus, alreadyProcessedIds));
        yellowStatus.addAll(CTPersonController.getSecondaryContacts(primaryContacts, alreadyProcessedIds));

        for (Id personId : orangeStatus) {
            peopleToUpdate.add(new Person__c(Id = personId, Health_Status__c = 'Orange'));
        }
        for (Id personId : yellowStatus) {
            peopleToUpdate.add(new Person__c(Id = personId, Health_Status__c = 'Yellow'));
        }
        if (!peopleToUpdate.isEmpty()) {
            update peopleToUpdate;
        }

        List<Location_Tracing__c> locationTraces = CTLocationTracingController.getLocationsByPersonIds(personIds);
        Set<Id> locationIds = new Set<Id>();
        for (Location_Tracing__c trace : locationTraces) {
            locationIds.add(trace.Location__c);
        }
        CTLocationController.updateRedScore(locationIds);
    }

    public static void handleAfterDelete(List<Person__c> listRecords){

    }

    public static void handleAfterUndelete(List<Person__c> listRecords){

    }
}