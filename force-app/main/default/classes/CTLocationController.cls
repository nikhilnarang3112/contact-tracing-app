public with sharing class CTLocationController {
    public static List<Location__c> getRecentStatusChanges(){
        return [SELECT Id, Name, Address__c, Pincode__c, Red_Score__c, Status_Update_Date__c, Status__c FROM Location__c ORDER BY Status_Update_Date__c DESC NULLS LAST LIMIT 100];
    }

    public static List<Location__c> searchLocations(String searchTerm){
        searchTerm += '%';
        return [
            SELECT Id, Name, Address__c, Pincode__c, Red_Score__c, Status_Update_Date__c, Status__c FROM Location__c
            WHERE (
                Name LIKE :searchTerm
                OR Pincode__c LIKE :searchTerm
                OR Address__c LIKE :searchTerm
            )
            ORDER BY Status_Update_Date__c DESC NULLS LAST
        ];
    }

    public static Location__c getLocationById(Id locationId){
        List<Location__c> pList = [SELECT Id, Name, Address__c, Pincode__c, Red_Score__c, Status_Update_Date__c, Status__c FROM Location__c WHERE Id = :locationId];
        if (pList != null && pList.size()>0) {
            return pList[0];
        } else{
            return null;
        }
    }

    public static Map<String, Integer> getStatusCount(){
        Map<String, Integer> statusCountMap = new Map<String, Integer>();
        for(AggregateResult ar : [
            SELECT Status__c, COUNT(Id) FROM Location__c
            GROUP BY Status__c
        ]){
            statusCountMap.put((String)ar.get('Status__c'), (Integer)ar.get('expr0'));
        }
        return statusCountMap;
    }

    public static void updateRedScore(Set<Id> locationIds){
        List<Location__c> locationsToUpdate = new List<Location__c>();
        List<AggregateResult> list_Agr = [SELECT Location__c,COUNT(Person__c) totalRedCount FROM Location_Tracing__c
        WHERE Location__c IN :locationIds 
        AND Person__r.Health_Status__c = 'Red'
        AND Visit_Date__c = LAST_N_DAYS:10
        GROUP BY Location__c];
        for(AggregateResult ar : list_Agr){
            Integer totalRedCount = (Integer)ar.get('totalRedCount');
            Location__c location = new Location__c(
                Id = (Id)ar.get('Location__c'),
                Red_Score__c = totalRedCount,
                Status__c = getStatus(totalRedCount),
                Status_Update_Date__c = Date.today()
            );
            locationsToUpdate.add(location);
        }
        if (!locationsToUpdate.isEmpty()) {
            update locationsToUpdate;
        }
    }

    public static String getStatus(Integer redScore){
        if(redScore == 0){
            return 'Green';
        } else if(redScore <= 5){
            return 'Yellow';
        } else if(redScore <= 10){
            return 'Orange';
        } else{
            return 'Red';
        }
    }
}