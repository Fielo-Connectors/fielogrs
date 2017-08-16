/********************************************************************
* Company: Fielo
* Developer: Juan Pablo Catena
* Created Date: 03/08/2017
* Description: 
********************************************************************/
@isTest
public class RESTMemberTest{

        public static testMethod void unitTest(){
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
                testRequest.httpMethod = 'GET';
                //Request URL with invalid member id
                testRequest.requestURI = '/services/apexrest/V1/members/notFoundTest';  
                RestContext.request = testRequest;
                RestContext.response = testResponse;

                RESTMember.getMember();
                //Request URL with valid member id
                testRequest.requestURI = '/services/apexrest/V1/members/' + testMember.id;  

                RESTMember.getMember();

                testProgram.GRSPointType__c = pointTypeId;
                update testProgram;

                RESTMember.getMember();

                Test.stopTest();
    }      
}