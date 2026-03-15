public with sharing class CTPeopleTracingController {
    public static List<People_Tracing__c> getTraces(Id recordId){
        return [
            SELECT Id, Name, Contact_Date__c, Contact_Type__c, Person_1__c, Person_2__c FROM People_Tracing__c
            WHERE Id = :recordId ORDER BY Contact_Date__c DESC
        ];
    }
    public static List<People_Tracing__c> checkDuplicates(List<People_Tracing__c> traces){
        List<People_Tracing__c> existingTraces = [
            SELECT Id, Name, Contact_Date__c, Contact_Type__c, Person_1__c, Person_2__c FROM People_Tracing__c
            WHERE Id = :recordId ORDER BY Contact_Date__c DESC
        ];
        List<People_Tracing__c> duplicates = new List<People_Tracing__c>();
        for(People_Tracing__c trace : traces){
            for(People_Tracing__c existingTrace : existingTraces){
                if(trace.Contact_Date__c == existingTrace.Contact_Date__c &&
                   trace.Contact_Type__c == existingTrace.Contact_Type__c &&
                   trace.Person_1__c == existingTrace.Person_1__c &&
                   trace.Person_2__c == existingTrace.Person_2__c){
                    duplicates.add(trace);
                }
            }
        }
        return duplicates;
    }
}