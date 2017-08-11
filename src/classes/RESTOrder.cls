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
 
        public ResponseWrapper(String id, String type, String orderToken, String orderNumber){
            this.id = id;
            this.type = type;
            this.orderToken = orderToken;
            this.orderNumber = orderNumber;
        }
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
            
            if(requestMap.containsKey('order')){
                Map<String,Object> orderMap = (Map<String,Object>)requestMap.get('order');

                String memberId = (String)orderMap.get('employeeId');
                String orderNumber = (String)orderMap.get('orderNumber');

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
                        
                        //required fields
                        FieloPLT__RedemptionItem__c redItem = new FieloPLT__RedemptionItem__c(FieloPLT__Quantity__c = Decimal.valueOf((String)orderItemMap.get('quantity')), GRSOrderId__c = (String)orderItemMap.get('orderId'));
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

                //call plt api
                FieloPLT__ProviderOrder__c returnedProviderOrder = FieloPLT.RedemptionService.createProviderOrder(member.Id, providerOrder, redItems);
                ResponseWrapper respWrapper = new ResponseWrapper((String)requestMap.get('id'), (String)requestMap.get('type'), (String)requestMap.get('orderToken'), returnedProviderOrder.GRSOrderNumber__c);

                response.statusCode = 201;
                response.responseBody = Blob.valueOf( JSON.serialize(respWrapper) );
            }
        }catch(FieloPLT.FieloException e){
            Database.rollback( sp );
            response.statusCode = 404;
            errorResponse.errorcode = 'BUSINESS_ERROR';
            errorResponse.message = e.getMessage();
            response.responseBody = Blob.valueOf( JSON.serialize(new List<RestAPIResponse>{errorResponse}) );
        }
    }
}