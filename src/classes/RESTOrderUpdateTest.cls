@isTest
public class RESTOrderUpdateTest {

    @testSetup static void setup(){
    	//Test Account Creation
		Account testAccount = new Account();
        testAccount.Name = 'Test Account';
        insert testAccount;
		//Test Program Creation
        FieloPLT__Program__c testProgram = new FieloPLT__Program__c();
        testProgram.Name = 'Test Program';
        insert testProgram;

        //Program Point Type and Point Type Id
        FieloPLT__ProgramPointType__c ppt = [SELECT Id, FieloPLT__PointType__c, FieloPLT__RequestPointApproval__c FROM FieloPLT__ProgramPointType__c WHERE FieloPLT__Program__c =: testProgram.Id limit 1];
        testProgram.GRSPointType__c = ppt.FieloPLT__PointType__c;
        testProgram.GRSAccount__c = testAccount.Id;
        update testProgram;

        //Test Member Creation
        FieloPLT__Member__c testMember = new FieloPLT__Member__c();
        testMember.Name = 'Test Member';
        testMember.FieloPLT__Email__c = testMember.Name.deleteWhitespace() + '@fielo.com';
        testMember.FieloPLT__Program__c = testProgram.id;
        insert testMember;

        FieloPLT__Transaction__c trans = new FieloPLT__Transaction__c(FieloPLT__Member__c = testMember.Id, FieloPLT__Points__c = 500);
        trans.FieloPLT__SkipEngine__c = true;
        trans.FieloPLT__IsProcessed__c = true;

        FieloPLT.SObjectService.enableAdminPermission(true);
        insert trans;

        //create a provider order
        FieloPLT__ProviderOrder__c providerOrder = new FieloPLT__ProviderOrder__c(FieloPLT__Account__c = testAccount.Id, GRSOrderNumber__c = '84569');

        //order Items
        List<FieloPLT__RedemptionItem__c> redItems = new List<FieloPLT__RedemptionItem__c>();
        FieloPLT__RedemptionItem__c redItem = new FieloPLT__RedemptionItem__c(FieloPLT__Quantity__c = 1, FieloPLT__Points__c = 20, GRSOrderId__c = '84569-1');
        redItems.add(redItem);

        //call plt api
        FieloPLT__ProviderOrder__c returnedProviderOrder = FieloPLT.RedemptionService.createProviderOrder(testMember.Id, providerOrder, redItems);
    }

    @isTest static void cancelOrderOK(){
        Test.startTest();
        
        RestRequest testRequest = new RestRequest(); 
        RestResponse testResponse = new RestResponse();

        //HTTP Request Type
        testRequest.httpMethod = 'POST';
        //JSON Request Body
        String reqBodyJSON = '{"id": "ABCD1234","orderToken": "ABCDE","type": "cancel","orderId": "84569-1","orderedAt": "2016-08-01 15:09:06","pointCost": 20,"quantity": "1"}';
        RestContext.request = testRequest;
        RestContext.response = testResponse;
 
        //Request URL
        testRequest.requestURI = '/services/apexrest/V1/orders/update/';
        testRequest.requestBody = Blob.valueof(reqBodyJSON);
        
        RESTOrderUpdate.updateOrder();
        
		Test.stopTest();
    }

    @isTest static void cancelOrderWrongId(){
        Test.startTest();
        
        RestRequest testRequest = new RestRequest(); 
        RestResponse testResponse = new RestResponse();

        //HTTP Request Type
        testRequest.httpMethod = 'POST';
        //JSON Request Body
        String reqBodyJSON = '{"id": "ABCD1234","orderToken": "ABCDE","type": "cancel","orderId": "26543-3","orderedAt": "2016-08-01 15:09:06","pointCost": 20,"quantity": "1"}';
        RestContext.request = testRequest;
        RestContext.response = testResponse;
 
        //Request URL
        testRequest.requestURI = '/services/apexrest/V1/orders/update/';
        testRequest.requestBody = Blob.valueof(reqBodyJSON);
        
        RESTOrderUpdate.updateOrder();
        
		Test.stopTest();
    }

    @isTest static void cancelOrderDelivered(){
        FieloPLT__RedemptionItem__c redItem = [SELECT Id FROM FieloPLT__RedemptionItem__c WHERE GRSOrderId__c = '84569-1'];
        redItem.FieloPLT__Status__c = 'Delivered';
        FieloPLT.SObjectService.enableAdminPermission(true);
        update redItem;

        Test.startTest();

        RestRequest testRequest = new RestRequest(); 
        RestResponse testResponse = new RestResponse();

        //HTTP Request Type
        testRequest.httpMethod = 'POST';
        //JSON Request Body
        String reqBodyJSON = '{"id": "ABCD1234","orderToken": "ABCDE","type": "cancel","orderId": "84569-1","orderedAt": "2016-08-01 15:09:06","pointCost": 20,"quantity": "1"}';
        RestContext.request = testRequest;
        RestContext.response = testResponse;
 
        //Request URL
        testRequest.requestURI = '/services/apexrest/V1/orders/update/';
        testRequest.requestBody = Blob.valueof(reqBodyJSON);
        
        RESTOrderUpdate.updateOrder();
        
		Test.stopTest();
    }
}