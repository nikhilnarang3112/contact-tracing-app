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
        Map<Id, String> personMap = new Map<Id, String>();
        Set<Id> redPersonIds = new Set<Id>();
        for (Person__c person : listRecords) {
            Person__c oldPerson = oldMap.get(person.Id);
            if (person.Health_Status__c != oldPerson.Health_Status__c) {
                if (person.Health_Status__c == 'Red') {
                    redPersonIds.add(person.Id);
                }
                personMap.put(person.Id, person.Health_Status__c);
            }
        }
        List<People_Tracing__c> traces = CTPeopleTracingController.getTracesByPersonIds(redPersonIds);
        List<Person__c> updatedPeople = new List<Person__c>();
        List<String> redOrangeTokens = new List<String>{'Red','Orange'};
        List<String> redOrangeYellowTokens = new List<String>{'Red','Orange','Yellow'};
        for (People_Tracing__c pt : traces) {
            String person1Status = personMap.get(pt.Person_1__c);
            String person2Status = personMap.get(pt.Person_2__c);
            if (pt.Contact_Type__c == 'Cohabitant') {
                if (redPersonIds.contains(pt.Person_1__c) && !redOrangeTokens.contains(person2Status)) {
                    updatedPeople.add(new Person__c(Id = pt.Person_2__c, Health_Status__c = 'Orange'));
                } else if (redPersonIds.contains(pt.Person_2__c) && !redOrangeTokens.contains(person1Status)) {
                    updatedPeople.add(new Person__c(Id = pt.Person_1__c, Health_Status__c = 'Orange'));
                }
            } else if (pt.Contact_Type__c == 'Neighbour') {
                if (redPersonIds.contains(pt.Person_1__c) && !redOrangeYellowTokens.contains(person2Status)) {
                    updatedPeople.add(new Person__c(Id = pt.Person_2__c, Health_Status__c = 'Yellow'));
                } else if (redPersonIds.contains(pt.Person_2__c) && !redOrangeYellowTokens.contains(person1Status)) {
                    updatedPeople.add(new Person__c(Id = pt.Person_1__c, Health_Status__c = 'Yellow'));
                }
            }
        }
        if (!updatedPeople.isEmpty()) {
            update updatedPeople;
        }
    }

    public static void handleAfterDelete(List<Person__c> listRecords){

    }

    public static void handleAfterUndelete(List<Person__c> listRecords){

    }
}