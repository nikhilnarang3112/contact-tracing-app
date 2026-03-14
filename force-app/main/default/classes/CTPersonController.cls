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
}