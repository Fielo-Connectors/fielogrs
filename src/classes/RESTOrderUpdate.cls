/********************************************************************
* Company: Fielo
* Developer: Juan Pablo Catena
* Created Date: 18/07/2017
* Description: 
********************************************************************/
@RestResource(urlMapping = '/v1/orders/update')
global with sharing class RESTOrderUpdate {
    
    private static String CANCEL = 'cancel';
    
    @HttpPost
    global static void doActions(){
        RestAPIResponse errorResponse = new RestAPIResponse();
        RestResponse response = RestContext.response;
        response.addHeader('Acept', 'application/json');
        response.addHeader('Content-Type', 'application/json');
        String actionType = RestContext.request.params.get('type');
        
        if(actionType == CANCEL){
            
        } else{
            //error porq me manda otro type
        }
    }
    
    global class RestAPIResponse{
        public String message{get;set;}
        public String errorCode{get;set;}
        
        public RestAPIResponse(){
        }
    }
    
}