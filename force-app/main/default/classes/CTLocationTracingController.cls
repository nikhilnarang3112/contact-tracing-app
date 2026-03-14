public with sharing class CTLocationTracingController {
    public static List<Location_Tracing__c> getVistors(Id locationId){
        return [
            SELECT Id, Person__c, Person__r.Token__c, Person__r.Health_Status__c, Location__c, Location__r.Name, Visit_Date__c FROM Location_Tracing__c
            WHERE Location__c = :locationId ORDER BY Visit_Date__c DESC];
    }
    public static List<Location_Tracing__c> getLocationsByPersonIds(Set<Id> personIds){
        return [
            SELECT Id, Person__c, Person__r.Token__c, Person__r.Health_Status__c, Location__c, Location__r.Name, Visit_Date__c FROM Location_Tracing__c
            WHERE Person__c IN :personIds AND Visit_Date__c = LAST_N_DAYS:10
        ];
    }
    public static List<Location_Tracing__c> getLocationsByLocationIds(Set<Id> locationIds){
        return [
            SELECT Id, Person__c, Person__r.Token__c, Person__r.Health_Status__c, Location__c, Location__r.Name, Visit_Date__c FROM Location_Tracing__c
            WHERE Location__c IN :locationIds AND Person__r.Health_Status__c = 'Green' AND Visit_Date__c = LAST_N_DAYS:10
        ];
    }

    public static List<Location_Tracing__c> checkDuplicates(List<Location_Tracing__c> newLocationTraces){
        Set<Id> personIds = new Set<Id>();
        Set<Id> locationIds = new Set<Id>();
        for (Location_Tracing__c ltObj : newLocationTraces) {
            personIds.add(ltObj.Person__c);
            locationIds.add(ltObj.Location__c);
        }
        Map<Id,Set<Id>> personLocationMap = new Map<Id,Set<Id>>();
        for (Location_Tracing__c ltcObj : [
            SELECT Id, Person__c, Location__c FROM Location_Tracing__c
            WHERE Person__c IN :personIds AND Location__c IN :locationIds
        ]) {
            if (!personLocationMap.containsKey(ltcObj.Location__c)) {
                personLocationMap.put(ltcObj.Location__c, new Set<Id>());
            }
            personLocationMap.get(ltcObj.Location__c).add(ltcObj.Person__c);
        }
        List<Location_Tracing__c> duplicates = new List<Location_Tracing__c>();
        for (Location_Tracing__c ltObj : newLocationTraces) {
            if (personLocationMap.containsKey(ltObj.Location__c) && personLocationMap.get(ltObj.Location__c).contains(ltObj.Person__c)) {
                duplicates.add(ltObj);
            }
        }
        return duplicates;
    }
}