public with sharing class CTPeopleTracingController {
    public static List<People_Tracing__c> getTraces(Id personId){
        return [
            SELECT Id, Contact_Date__c, Person_1__c, Person_1__r.Health_Status__c, Person_1__r.Token__c, Person_2__c, Person_2__r.Health_Status__c, Person_2__r.Token__c FROM People_Tracing__c
            WHERE Person_1__c = :personId OR Person_2__c = :personId ORDER BY Contact_Date__c DESC
        ];
    }
    public static List<People_Tracing__c> checkDuplicates(List<People_Tracing__c> traces){
        Set<Id> personIds = new Set<Id>();
        for(People_Tracing__c trace : traces){
            personIds.add(trace.Person_1__c);
            personIds.add(trace.Person_2__c);
        }
        List<People_Tracing__c> existingTraces = [
            SELECT Id, Name, Contact_Date__c, Contact_Type__c, Person_1__c, Person_2__c FROM People_Tracing__c
            WHERE Person_1__c IN :personIds OR Person_2__c IN :personIds
        ];
        Map<Id, Set<Id>> personPersonMap = new Map<Id, Set<Id>>();
        for(People_Tracing__c trace : existingTraces){
            if(!personPersonMap.containsKey(trace.Person_1__c)){
                personPersonMap.put(trace.Person_1__c, new Set<Id>());
            }
            personPersonMap.get(trace.Person_1__c).add(trace.Person_2__c);
            if(!personPersonMap.containsKey(trace.Person_2__c)){
                personPersonMap.put(trace.Person_2__c, new Set<Id>());
            }
            personPersonMap.get(trace.Person_2__c).add(trace.Person_1__c);
        }
        List<People_Tracing__c> duplicates = new List<People_Tracing__c>();
        for(People_Tracing__c trace : traces){
            if(personPersonMap.containsKey(trace.Person_1__c) && personPersonMap.get(trace.Person_1__c).contains(trace.Person_2__c)){
                duplicates.add(trace);
            } else if(personPersonMap.containsKey(trace.Person_2__c) && personPersonMap.get(trace.Person_2__c).contains(trace.Person_1__c)){
                duplicates.add(trace);
            }
        }
        return duplicates;
    }
}