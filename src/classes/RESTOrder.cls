/********************************************************************
* Company: Fielo
* Developer: Juan Pablo Catena
* Created Date: 18/07/2017
* Description: 
********************************************************************/
@RestResource(urlMapping = '/v1/orders/*')
global with sharing class RESTOrder {
    
    private static String CREATE = 'redeem';
    private static String CANCEL = 'cancel';
    
    @HttpPost
    global static void doActions(){
        RestAPIResponse errorResponse = new RestAPIResponse();
        RestResponse response = RestContext.response;
        response.addHeader('Acept', 'application/json');
        response.addHeader('Content-Type', 'application/json');
        String actionType = RestContext.request.params.get('type');
        
        
        if(actionType == CREATE){
            
        } else if(actionType == CANCEL){
            
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
    
    global class WrapResponse{
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