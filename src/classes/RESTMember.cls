	/********************************************************************
* Company: Fielo
* Developer: Juan Pablo Catena
* Created Date: 18/07/2017
* Description: 
********************************************************************/

@RestResource(urlMapping='/V1/members/*')
global with sharing class RESTMember {
	
    @HttpGet
    global static void doActions(){
        RestAPIResponse errorResponse = new RestAPIResponse();
        RestResponse response = RestContext.response;
        response.addHeader('Acept', 'application/json');
        response.addHeader('Content-Type', 'application/json');
        Id memberId = RestContext.request.params.get('memberId');
        //String pointTypeName = 'Point';
        //String balanceFieldApiName;
        //String memberRetrieveQuery;
        FieloPLT__Member__c queriedMember;
        
        try{
            queriedMember = [SELECT FieloPLT__Program__r.GRSPointType__r.FieloPLT__MemberBalanceField__c FROM FieloPLT__Member__c WHERE Id = :memberId LIMIT 1];

            //, FieloPLT__Program__r.GRSMemberFieldsMapping__c

            //balanceFieldApiName = [SELECT FieloPLT__PointType__r.FieloPLT__MemberBalanceField__c FROM FieloPLT__ProgramPointType__c WHERE FieloPLT__PointType__r.Name = :pointTypeName AND FieloPLT__Program__c = :memberProgram].get(0).FieloPLT__PointType__r.FieloPLT__MemberBalanceField__c;
            String memberRetrieveQuery = 'SELECT Name, FieloPLT__Email__c, ' + queriedMember.FieloPLT__Program__r.GRSPointType__r.FieloPLT__MemberBalanceField__c + ' FROM FieloPLT__Member__c WHERE Id = :memberId LIMIT 1';
            queriedMember = Database.query(memberRetrieveQuery);
        } catch(Exception e){
            response.statusCode = 404;
            errorResponse.errorCode = 'BUSINESS_ERROR';
            errorResponse.message = 'Member does not exist';
            response.responseBody = Blob.valueOf(JSON.serialize(errorResponse));
            return;
        }
        response.responseBody = Blob.valueOf(JSON.serialize(new wrapResponse(queriedMember.Name, queriedMember.FieloPLT__Email__c, queriedMember.FieloPLT__Points__c)));
    }
    
    global class RestAPIResponse{
        public String message{get;set;}
        public String errorCode{get;set;}
        
        public RestAPIResponse(){
        }
    }
    
    global class WrapResponse{
        public Map<String,Object> fieldsMap {get; set;}

        public String firstName {get; set;}
        public String lastName {get; set;}
        public String email {get; set;}
        public Decimal pointBalance {get; set;}
        
        public wrapResponse(String fNameParam, /*String lNameParam,*/ String emailParam, Decimal balanceParam){
            firstName = fNameParam;
            //lastName = lNameParam;
            email = emailParam;
            pointBalance = balanceParam;
        }
    }
}