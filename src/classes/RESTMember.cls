    /********************************************************************
* Company: Fielo
* Developer: Juan Pablo Catena
* Created Date: 18/07/2017
* Description: 
********************************************************************/

@RestResource(urlMapping='/V1/members/*')
global with sharing class RESTMember {
    
    @HttpGet
    global static void getMember(){
        String requestUri = RestContext.request.requestUri;
        String memberId = requestUri.substring( requestUri.indexOf('/members/')  , requestUri.length() );
        memberId = memberId.replace('/members/', '');

        RestAPIResponse errorResponse = new RestAPIResponse();
        RestResponse response = RestContext.response;
        response.addHeader('Acept', 'application/json');
        response.addHeader('Content-Type', 'application/json');
        
        try{
            FieloPLT__Member__c queriedMember = [SELECT FieloPLT__Program__r.GRSPointType__r.FieloPLT__MemberBalanceField__c, FieloPLT__Program__r.GRSMemberFieldset__c FROM FieloPLT__Member__c WHERE Id = :memberId LIMIT 1];
            
            if(queriedMember.FieloPLT__Program__r.GRSPointType__r == null || String.isBlank(queriedMember.FieloPLT__Program__r.GRSPointType__r.FieloPLT__MemberBalanceField__c)){
                response.statusCode = 404;
                errorResponse.errorCode = 'BUSINESS_ERROR';
                errorResponse.message = 'Point type configuration missing';
                response.responseBody = Blob.valueOf(JSON.serialize(errorResponse));
                return;
            }

            String pointBalanceField = queriedMember.FieloPLT__Program__r.GRSPointType__r.FieloPLT__MemberBalanceField__c;

            Set<String> fieldsetToQuery = new Set<String>{pointBalanceField};
            List<FieldWrapper> memberFieldset;
            if(String.isNotBlank(queriedMember.FieloPLT__Program__r.GRSMemberFieldset__c)){
                //parse de json con fieldset casteado a wrapper interno
                memberFieldset = (List<FieldWrapper>)JSON.deserializeStrict(queriedMember.FieloPLT__Program__r.GRSMemberFieldset__c, List<FieldWrapper>.class);
                
                for(FieldWrapper mf : memberFieldset){
                    fieldsetToQuery.add(mf.sfFieldName);
                }
            }

            String memberRetrieveQuery = 'SELECT ' + String.join(new List<String>(fieldsetToQuery),',') + ' FROM FieloPLT__Member__c WHERE Id =: memberId LIMIT 1';
            queriedMember = Database.query(memberRetrieveQuery);

            //creo mapa para devolver de string,object
            Map<String,Object> returnMap = new Map<String,Object>();

            //seteo el point balance
            returnMap.put('pointBalance', queriedMember.get(pointBalanceField));

            if(memberFieldset != null){
                // Locale special treatment
                List<String> language_parts;
                Boolean isLocale;
                //loop de json fieldset
                for(FieldWrapper mf : memberFieldset){
                    // Locale special treatment
                    isLocale = mf.isLocale != null ? mf.isLocale : false;
                    
                    // cargo los campos en el mapa
                    // +Locale special treatment
                    if (isLocale) {
                        language_parts = ((String)getFieldValue(queriedMember, mf.sfFieldName)).split('_', 2);
                        returnMap.put(mf.grsFieldName, language_parts[0]);
                    } else {
                        returnMap.put(mf.grsFieldName, getFieldValue(queriedMember, mf.sfFieldName));
                    }
                }
            }

            response.responseBody = Blob.valueOf(JSON.serialize(returnMap));
        } catch(Exception e){
            response.statusCode = 404;
            errorResponse.errorCode = 'BUSINESS_ERROR';
            //errorResponse.message = 'Member does not exist';
            errorResponse.message = e.getMessage() + ' --- ' + e.getStackTraceString();
            response.responseBody = Blob.valueOf(JSON.serialize(errorResponse));
            return;
        }
    }

    private static Object getFieldValue(FieloPLT__Member__c member, String sfFieldName){
        //split para campos a segundo o tercer nivel
        String[] fieldNameSplited = sfFieldName.split('\\.');
        SObject relationObject = member;
        Integer index = 0;
        for(; index < fieldNameSplited.size() - 1; index++){
            relationObject = relationObject.getSObject(fieldNameSplited[index].removeEnd('Id'));
            if(relationObject == null)
                return null;
        }

        return relationObject.get(fieldNameSplited[index]);
    }
}