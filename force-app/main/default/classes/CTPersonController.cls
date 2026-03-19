public with sharing class CTPersonController {
    public static String getToken(String mobileNo){
        return EncodingUtil.base64Encode(Crypto.generateDigest('MD5', Blob.valueOf(mobileNo)));
    }

    public static List<Person__c> getRecentHealthChanges(){
        return [SELECT Id,Name,Mobile__c,Token__c,Status_Update_Date__c,Health_Status__c FROM Person__c ORDER BY Status_Update_Date__c DESC NULLS LAST LIMIT 100];
    }

    public static List<Person__c> searchPeople(String searchTerm){
        searchTerm += '%';
        return [
            SELECT Id,Name,Mobile__c,Token__c,Status_Update_Date__c,Health_Status__c FROM Person__c
            WHERE (
                Name LIKE :searchTerm
                OR Mobile__c LIKE :searchTerm
                OR Token__c LIKE :searchTerm
            )
            ORDER BY Status_Update_Date__c DESC NULLS LAST
        ];
    }

    public static Person__c getPersonById(Id personId){
        List<Person__c> pList = [SELECT Id,Name,Mobile__c,Token__c,Status_Update_Date__c,Health_Status__c FROM Person__c WHERE Id = :personId];
        if (pList != null && pList.size()>0) {
            return pList[0];
        } else{
            return null;
        }
    }

    public static Map<String, Integer> getHealthStatusCount(){
        Map<String, Integer> healthStatusCountMap = new Map<String, Integer>();
        for(AggregateResult ar : [
            SELECT Health_Status__c, COUNT(Id) FROM Person__c
            group by Health_Status__c
        ]){
            healthStatusCountMap.put((String)ar.get('Health_Status__c'), (Integer)ar.get('expr0'));
        }
        return healthStatusCountMap;
    }

    public static Set<Id> getCohabitants(Set<Id> personIds,Set<Id> alreadyProcessedIds){
        Set<Id> cohabitants = new Set<Id>();
        List<String> healthStatus = new List<String>{'Green','Yellow'};
        List<People_Tracing__c> traces = [
            SELECT Person_1__c, Person_2__c FROM People_Tracing__c
            WHERE (Person_1__c IN :personIds OR Person_2__c IN :personIds)
            AND Contact_Type__c = 'Cohabitant'
            AND (Person_1__r.Health_Status__c IN :healthStatus
            OR Person_2__r.Health_Status__c IN :healthStatus)
        ];
        for (People_Tracing__c trace : traces) {
            if (!alreadyProcessedIds.contains(trace.Person_1__c)) {
                cohabitants.add(trace.Person_1__c);
                alreadyProcessedIds.add(trace.Person_1__c);
            } else if (!alreadyProcessedIds.contains(trace.Person_2__c)) {
                cohabitants.add(trace.Person_2__c);
                alreadyProcessedIds.add(trace.Person_2__c);
            }
        }
        return cohabitants;
    }

    public static Set<Id> getNeighbours(Set<Id> personIds, Set<Id> alreadyProcessedIds){
        Set<Id> neighbours = new Set<Id>();
        List<People_Tracing__c> traces = [
            SELECT Person_1__c, Person_2__c FROM People_Tracing__c
            WHERE (Person_1__c IN :personIds OR Person_2__c IN :personIds)
            AND Contact_Type__c = 'Neighbour'
            AND (Person_1__r.Health_Status__c = 'Green'
            OR Person_2__r.Health_Status__c = 'Green')
        ];
        for (People_Tracing__c trace : traces) {
            if (!alreadyProcessedIds.contains(trace.Person_1__c)) {
                neighbours.add(trace.Person_1__c);
                alreadyProcessedIds.add(trace.Person_1__c);
            } else if (!alreadyProcessedIds.contains(trace.Person_2__c)) {
                neighbours.add(trace.Person_2__c);
                alreadyProcessedIds.add(trace.Person_2__c);
            }
        }
        return neighbours;
    }

    public static Set<Id> getPrimaryContacts(Set<Id> personIds, Set<Id> alreadyProcessedIds){
        Set<Id> primaryContacts = new Set<Id>();
        List<String> healthStatus = new List<String>{'Green','Yellow'};
        List<People_Tracing__c> traces = [
            SELECT Person_1__c, Person_2__c FROM People_Tracing__c
            WHERE (Person_1__c IN :personIds OR Person_2__c IN :personIds)
            AND Contact_Type__c = 'Other'
            AND Contact_Date__c = LAST_N_DAYS:10
            AND (Person_1__r.Health_Status__c IN :healthStatus
            OR Person_2__r.Health_Status__c IN :healthStatus)
        ];
        for (People_Tracing__c trace : traces) {
            if (!alreadyProcessedIds.contains(trace.Person_1__c)) {
                primaryContacts.add(trace.Person_1__c);
                alreadyProcessedIds.add(trace.Person_1__c);
            } else if (!alreadyProcessedIds.contains(trace.Person_2__c)) {
                primaryContacts.add(trace.Person_2__c);
                alreadyProcessedIds.add(trace.Person_2__c);
            }
        }
        return primaryContacts;
    }

    public static Set<Id> getSecondaryContacts(Set<Id> primaryContactIds, Set<Id> alreadyProcessedIds){
        Set<Id> secondaryContactIds = new Set<Id>();
        List<People_Tracing__c> traces = [
            SELECT Person_1__c, Person_2__c FROM People_Tracing__c
            WHERE (Person_1__c IN :primaryContactIds OR Person_2__c IN :primaryContactIds)
            AND Contact_Type__c = 'Other'
            AND Contact_Date__c = LAST_N_DAYS:10
            AND (Person_1__r.Health_Status__c = 'Green'
            OR Person_2__r.Health_Status__c = 'Green')
        ];
        for (People_Tracing__c trace : traces) {
            if (!alreadyProcessedIds.contains(trace.Person_1__c)) {
                secondaryContactIds.add(trace.Person_1__c);
                alreadyProcessedIds.add(trace.Person_1__c);
            } else if (!alreadyProcessedIds.contains(trace.Person_2__c)) {
                secondaryContactIds.add(trace.Person_2__c);
                alreadyProcessedIds.add(trace.Person_2__c);
            }
        }
        return secondaryContactIds;
    }
}