/********************************************************************
* Company: Fielo
* Developer: Juan Pablo Catena
* Created Date: 10/08/2017
* Description: 
********************************************************************/
@isTest
public class RESTOrderTest{

    public static testMethod void unitTest(){
		//Test Account Creation
		Account testAccount = new Account();
        testAccount.Name = 'Test Account';
        insert testAccount;
		//Test Program Creation
        FieloPLT__Program__c testProgram = new FieloPLT__Program__c();
        testProgram.Name = 'Test Program';
        testProgram.FieloPLT__OnlineTransactionProcessing__c = true;
        testProgram.GRSMemberFieldset__c = '[{"grsFieldName":"email","sfFieldName":"FieloPLT__Email__c"},{"grsFieldName":"firstName","sfFieldName":"FieloPLT__Contact__r.FirstName"},{"grsFieldName":"lastName","sfFieldName":"FieloPLT__Contact__r.LastName"}]';
        insert testProgram;

        //Program Point Type and Point Type Id
        FieloPLT__ProgramPointType__c ppt = [SELECT Id, FieloPLT__PointType__c, FieloPLT__RequestPointApproval__c FROM FieloPLT__ProgramPointType__c WHERE FieloPLT__Program__c =: testProgram.Id limit 1];
        ppt.FieloPLT__RequestPointApproval__c = true;
        update ppt;
        Id pointTypeId = ppt.FieloPLT__PointType__c;

        //Test Member Creation
        FieloPLT__Member__c testMember = new FieloPLT__Member__c();
        testMember.Name = 'Test Member';
        testMember.FieloPLT__Email__c = testMember.Name.deleteWhitespace() + '@fielo.com';
        testMember.FieloPLT__Program__c = testProgram.id;
        insert testMember;

        Test.startTest();
        RestRequest testRequest = new RestRequest(); 
        RestResponse testResponse = new RestResponse();

        //HTTP Request Type
        testRequest.httpMethod = 'POST';
        //JSON Request Body
        String reqBodyJSON = '{"id":"ABCD1234","type":"redeem","orderToken":"ABCDE","order":{"businessAddress":"Here is a business address","employeeId":"' + testMember.id + '","orderItems":{"0":{"catalogCode":"CA_MRCH_GRS2","catalogName":"Merchandise CA-GRS2","description":"Two hearts are better than one. Beautiful heart shape diamond pendant ","lineItemId":1,"name":"Diamore Diamond Heart Shape Pendant, 10k Gold, I2-I3","orderId":"15150-1","orderedAt":"2016-08-01 15:09:06","pointCost":1,"quantity":"1"}},"orderNumber":"15150","totalPointCost":20,"totalPointCostLessPointsPurchased":20,"pin":"ABCD1234","pointsPurchased":0,"pointsPurchasedCost":0,"pointsPurchasedCurrency":null,"shipAddress1":"500 Main St","shipAddress2":"","shipCity":"Toronto","shipCompany":"","shipCountry":"CA","shipEmail":"test@GRSstorefront.com","shipName":"John Smith","shipPostal":"M1S2N3","shipProvinceState":"ON","shipTelephone":"001 416 555-8888"}}';
        RestContext.request = testRequest;
        RestContext.response = testResponse;
 
        //Request URL
        testRequest.requestURI = '/services/apexrest/V1/orders/';
        testRequest.requestBody = Blob.valueof(reqBodyJSON);
        
        RESTOrder.createOrder();
        
        testProgram.GRSAccount__c = testAccount.Id;
        update testProgram;        
        
        RESTOrder.createOrder();
        
        testProgram.GRSPointType__c = pointTypeId;
        update testProgram;      

        RESTOrder.createOrder();
        
        //Adjust transaction created to grant points
		FieloPLT__Transaction__c trans = new FieloPLT__Transaction__c(FieloPLT__Member__c = testMember.Id, FieloPLT__Points__c = 500);
		trans.FieloPLT__SkipEngine__c = true;
		trans.FieloPLT__IsProcessed__c = true;

		FieloPLT.SObjectService.enableAdminPermission(true);
		insert trans;

        testProgram.GRSOrderFieldset__c = '[{"grsFieldName":"shipAddress1","sfFieldName":"FieloPLT__Status__c"}]';
		testProgram.GRSOrderItemFieldset__c = '[{"grsFieldName":"lineItemId","sfFieldName":"FieloPLT__UnitCost__c"}]';
        update testProgram;      
        
        RESTOrder.createOrder();
        
        Test.stopTest();

    }
}