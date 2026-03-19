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
}