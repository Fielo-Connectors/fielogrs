@isTest
private class MemberTest {

	@testSetup static void testSetup(){
		//Test Program Creation
	        FieloPLT__Program__c testProgram = new FieloPLT__Program__c();
	        testProgram.Name = 'Test Program';
	        testProgram.FieloPLT__OnlineTransactionProcessing__c = true;
	        testProgram.GRSMemberFieldset__c = '[{"grsFieldName":"employeeId","sfFieldName":"Id"},{"grsFieldName":"firstName","sfFieldName":"FieloPLT__Contact__r.FirstName"},{"grsFieldName":"lastName","sfFieldName":"FieloPLT__Contact__r.LastName"},{"grsFieldName":"email","sfFieldName":"FieloPLT__Email__c"},{"grsFieldName":"address1","sfFieldName":"FieloPLT__Contact__r.MailingStreet"},{"grsFieldName":"city","sfFieldName":"FieloPLT__Contact__r.MailingCity"},{"grsFieldName":"postalCode","sfFieldName":"FieloPLT__Contact__r.MailingPostalCode"},{"grsFieldName":"provinceState","sfFieldName":"FieloPLT__Contact__r.MailingStateCode"},{"grsFieldName":"country","sfFieldName":"FieloPLT__Contact__r.MailingCountryCode"},{"grsFieldName":"telephone","sfFieldName":"FieloPLT__Contact__r.Phone"},{"grsFieldName":"language","sfFieldName":"FieloPLT__User__r.LanguageLocaleKey","isLocale":true}]';
	        insert testProgram;

	        //Program Point Type and Point Type Id
	        FieloPLT__ProgramPointType__c ppt = [SELECT Id, FieloPLT__PointType__c, FieloPLT__RequestPointApproval__c FROM FieloPLT__ProgramPointType__c WHERE FieloPLT__Program__c =: testProgram.Id limit 1];
	        ppt.FieloPLT__RequestPointApproval__c = true;
	        update ppt;
	        Id pointTypeId = ppt.FieloPLT__PointType__c;
	        
	        testProgram.GRSPointType__c = pointTypeId;
	        update testProgram;

	        //Test Member Creation
	        FieloPLT__Member__c testMember = new FieloPLT__Member__c();
	        testMember.Name = 'Test Member';
	        testMember.FieloPLT__Email__c = testMember.Name.deleteWhitespace() + '@fielo.com';
	        testMember.FieloPLT__Program__c = testProgram.id;
	        testMember.FieloPLT__User__c = UserInfo.getUserId();
	        insert testMember;



	        User testUser = new User(
				FirstName = 'Test',
				LastName = 'User',
				Username = 'a@grstest.com',
				Email = 'a@grstest.com',
				Alias = 'grstest',
				CommunityNickname = 'grstest',
				TimeZoneSidKey = UserInfo.getTimeZone().getID(),
				LocaleSidKey = UserInfo.getLocale(),
				EmailEncodingKey = 'ISO-8859-1',
				ProfileId = UserInfo.getProfileId(),
				LanguageLocaleKey = UserInfo.getLocale()
			);

			insert testUser;
	}
	
	@isTest static void test_method_one() {
		FieloPLT__Member__c testMember = [Select Id, Name From FieloPLT__Member__c WHERE Name='Test Member'];
		User testUser = [Select Id, FirstName, MemberId__c From User Where Username = 'a@grstest.com' LIMIT 1];
		testMember.FieloPLT__User__c = testUser.Id;
		update testMember;

		FieloPLT__Member__c member = [Select Id, Name From FieloPLT__Member__c WHERE Name='Test Member'];
		User user = [Select Id, FirstName, MemberId__c From User Where Username = 'a@grstest.com' LIMIT 1];

		System.assertEquals(member.Id,user.MemberId__c);
	}
	
	
}