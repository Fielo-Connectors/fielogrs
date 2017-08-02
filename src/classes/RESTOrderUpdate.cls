/********************************************************************
* Company: Fielo
* Developer: Juan Pablo Catena
* Created Date: 18/07/2017
* Description: 
********************************************************************/
@RestResource(urlMapping = '/V1/orders/update/*')
global with sharing class RESTOrderUpdate {
    
    private static String CANCEL = 'cancel';
    
    public class ResponseWrapper{
        public String id;
        public String type;
        public String orderToken;
        public String orderId;
 
        public ResponseWrapper(String id, String type, String orderToken, String orderId){
            this.id = id;
            this.type = type;
            this.orderToken = orderToken;
            this.orderId = orderId;
        }
    }

    @HttpPost
    global static void updateOrder(){
        String requestUri = RestContext.request.requestUri;
        
        RestAPIResponse errorResponse = new RestAPIResponse();
        RestResponse response = RestContext.response;
        response.addHeader('Accept', 'application/json');
        response.addHeader('Content-Type', 'application/json');
        
        Savepoint sp = Database.setSavepoint();
        try{
            Map<String,Object> requestMap = (Map<String,Object>)JSON.deserializeUntyped(RestContext.request.requestBody.toString());
            String actionType = (String)requestMap.get('type');
            if(actionType == 'cancel'){
                String orderId = (String)requestMap.get('orderId');

                FieloPLT__RedemptionItem__c redemptionItem;
                try{
                    redemptionItem = [SELECT Id FROM FieloPLT__RedemptionItem__c WHERE GRSOrderId__c =: orderId];
                }catch(Exception e){
                    response.statusCode = 404;
                    errorResponse.errorcode = 'BUSINESS_ERROR';
                    errorResponse.message = 'Order item not found.';
                    response.responseBody = Blob.valueOf( JSON.serialize(new List<RestAPIResponse>{errorResponse}) );
                    return ;
                }
                FieloPLT.RedemptionItemService.revertRedemptionItems(new List<Id>{redemptionItem.Id});
                
                ResponseWrapper respWrapper = new ResponseWrapper((String)requestMap.get('id'), (String)requestMap.get('type'), (String)requestMap.get('orderToken'), orderId);
                
                response.statusCode = 201;
                response.responseBody = Blob.valueOf( JSON.serialize(respWrapper) );
            } else{
                //error porq me manda otro type
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