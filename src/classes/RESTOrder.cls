/********************************************************************
* Company: Fielo
* Developer: Juan Pablo Catena
* Created Date: 18/07/2017
* Description: 
********************************************************************/
@RestResource(urlMapping = '/V1/orders/*')
global with sharing class RESTOrder {
    
    public class ResponseWrapper{
        public String id;
        public String type;
        public String orderToken;
        public String orderNumber;
 
        public ResponseWrapper(String id, String type, String orderToken){
            this.id = id;
            this.type = type;
            this.orderToken = orderToken;
        }

        public void setOrderNumber(String orderNumber){
            this.orderNumber = orderNumber;
        }
    }

    private class FieldWrapper{
        public String grsFieldName;
        public String sfFieldName;
    }

    @HttpPost
    global static void createOrder(){
        String requestUri = RestContext.request.requestUri;
        
        RestAPIResponse errorResponse = new RestAPIResponse();
        RestResponse response = RestContext.response;
        response.addHeader('Accept', 'application/json');
        response.addHeader('Content-Type', 'application/json');
        
        Savepoint sp = Database.setSavepoint();
        try{
            Map<String,Object> requestMap = (Map<String,Object>)JSON.deserializeUntyped(RestContext.request.requestBody.toString());
            ResponseWrapper respWrapper = new ResponseWrapper((String)requestMap.get('id'), (String)requestMap.get('type'), (String)requestMap.get('orderToken'));
            
            if(requestMap.containsKey('order')){
                Map<String,Object> orderMap = (Map<String,Object>)requestMap.get('order');

                String memberId = (String)orderMap.get('employeeId');
                String orderNumber = (String)orderMap.get('orderNumber');
                respWrapper.setOrderNumber(orderNumber);

                FieloPLT__Member__c member = [SELECT Id, FieloPLT__Program__r.GRSAccount__c, FieloPLT__Program__r.GRSPointType__r.FieloPLT__RedemptionItemBalanceField__c, FieloPLT__Program__r.GRSOrderFieldset__c, FieloPLT__Program__r.GRSOrderItemFieldset__c FROM FieloPLT__Member__c WHERE Id =: memberId LIMIT 1];

                if(member.FieloPLT__Program__r.GRSAccount__c == null){
                    response.statusCode = 404;
                    errorResponse.errorCode = 'BUSINESS_ERROR';
                    errorResponse.message = 'Account provider configuration missing';
                    response.responseBody = Blob.valueOf(JSON.serialize(errorResponse));
                    return;
                }

                if(member.FieloPLT__Program__r.GRSPointType__r == null || String.isBlank(member.FieloPLT__Program__r.GRSPointType__r.FieloPLT__RedemptionItemBalanceField__c)){
                    response.statusCode = 404;
                    errorResponse.errorCode = 'BUSINESS_ERROR';
                    errorResponse.message = 'Point type configuration missing';
                    response.responseBody = Blob.valueOf(JSON.serialize(errorResponse));
                    return;
                }

                //set required fields
                FieloPLT__ProviderOrder__c providerOrder = new FieloPLT__ProviderOrder__c(FieloPLT__Account__c = member.FieloPLT__Program__r.GRSAccount__c, GRSOrderNumber__c = orderNumber);

                //fieldset order
                if(String.isNotBlank(member.FieloPLT__Program__r.GRSOrderFieldset__c)){
                    //parse de json con fieldset casteado a wrapper interno
                    List<FieldWrapper> orderFieldset = (List<FieldWrapper>)JSON.deserializeStrict(member.FieloPLT__Program__r.GRSOrderFieldset__c, List<FieldWrapper>.class);
                    
                    for(FieldWrapper fw : orderFieldset){
                        providerOrder.put(fw.sfFieldName, orderMap.get(fw.grsFieldName));
                    }
                }

                //order Items
                List<FieloPLT__RedemptionItem__c> redItems = new List<FieloPLT__RedemptionItem__c>();
                if(orderMap.containsKey('orderItems')){
                    //parse order items fieldset
                    List<FieldWrapper> orderItemFieldset;
                    if(String.isNotBlank(member.FieloPLT__Program__r.GRSOrderItemFieldset__c)){
                        //parse de json con fieldset casteado a wrapper interno
                        orderItemFieldset = (List<FieldWrapper>)JSON.deserializeStrict(member.FieloPLT__Program__r.GRSOrderItemFieldset__c, List<FieldWrapper>.class);
                    }

                    Map<String,Object> orderItemsMap = (Map<String,Object>)orderMap.get('orderItems');
                    for(Object orderItem : orderItemsMap.values()){
                        Map<String,Object> orderItemMap = (Map<String,Object>)orderItem;
                        FieloPLT__RedemptionItem__c redItem = new FieloPLT__RedemptionItem__c(FieloPLT__Quantity__c = Decimal.valueOf((String)orderItemMap.get('quantity')));
                        redItem.put(member.FieloPLT__Program__r.GRSPointType__r.FieloPLT__RedemptionItemBalanceField__c, orderItemMap.get('pointCost'));

                        //fieldset order item
                        if(orderItemFieldset != null){
                            for(FieldWrapper fw : orderItemFieldset){
                                redItem.put(fw.sfFieldName, orderItemMap.get(fw.grsFieldName));
                            }
                        }

                        redItems.add(redItem);
                    }
                }

                insert providerOrder;
                //call plt api
                //FieloPLT.RedemptionService.createProviderOrder(member.Id, providerOrder, redItems);

                /*if( MemberService.isMemberBlocked(memberId) == true ){
                    response.message = Label.ErrorFieloAccountBlocked;
                    response.errorcode = 'FIELO_ACCOUNT_BLOCKED';
                    resp.statusCode = 404;
                    resp.responseBody = Blob.valueOf( JSON.serialize(new List<RestAPIResponse>{response}) );
                }*/
                response.statusCode = 201;
                response.responseBody = Blob.valueOf( JSON.serialize(respWrapper) );
            }
        }catch(FieloPLT.FieloException e){
            Database.rollback( sp );
            response.statusCode = 404;
            errorResponse.errorcode = 'BUSINESS_ERROR';
            errorResponse.message = e.getMessage();
            response.responseBody = Blob.valueOf( JSON.serialize(new List<RestAPIResponse>{errorResponse}) );
        }catch(DMlException e){
            Database.rollback( sp );
            String message = e.getDMLMessage(0);
            system.debug(e.getDmlType(0));
            if( StatusCode.CANNOT_INSERT_UPDATE_ACTIVATE_ENTITY == e.getDmlType(0) || message.contains('DomainException') ){
                response.statusCode = 403;
                errorResponse.errorcode = 'DOMAIN_EXCEPTION';
                if( message.contains('Permission to') && message.contains(' denied') ){
                    message = message.substring(message.indexOf('Permission'), message.indexOf(' denied') + 8);
                }
                errorResponse.message = message;
            }else if(StatusCode.REQUIRED_FIELD_MISSING == e.getDmlType(0)){ // || StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION == e.getDmlType(0))
                response.statusCode = 400;
                errorResponse.errorcode = 'REQUIRED_FIELD_MISSING';
                errorResponse.message = message;
            }else{
                response.statusCode = 400;
                errorResponse.errorcode = 'BUSINESS_ERROR';
                errorResponse.message = e.getDMLMessage(0);
            }
            response.responseBody = Blob.valueOf( JSON.serialize(new List<RestAPIResponse>{errorResponse}) );
        }
    }
}