@isTest
public class MockUpFactory {
	public static Contact testContact;

	public static void inicializeData() {
		User u = [SELECT Id,Name,UserRoleId,ProfileId FROM User WHERE Username='engineering2@fielo.com'];

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

	        //Test Account creation
	        Account accountTest = new Account(Name='Test Account',OwnerId=u.Id);
	        insert accountTest;

	        //Test Member Creation
	        FieloPLT__Member__c testMember = new FieloPLT__Member__c();
	        testMember.Name = 'Test Member';
	        testMember.FieloPLT__Email__c = testMember.Name.deleteWhitespace() + '@fielo.com';
	        testMember.FieloPLT__Program__c = testProgram.id;
	        testMember.FieloPLT__User__c = UserInfo.getUserId();
	        insert testMember;

	        //Test Contact creation
	        testContact = new Contact();
	        testContact.lastName = 'Test Contact';
	        testContact.email = 'test2@fielo.com';
	        testContact.AccountId = accountTest.Id;
	        insert testContact;

	        FieloPLT__Member__c testMember2 = new FieloPLT__Member__c();
	        testMember2.Name = 'Test MemberId';
	        testMember2.FieloPLT__Email__c = 'test2@fielo.com';
	        testMember2.FieloPLT__Program__c = testProgram.id;
	        testMember2.FieloPLT__Contact__c = testContact.Id;
	        testMember2.FieloPLT__Account__c = accountTest.Id;
	        insert testMember2;



	        User testUser = new User(
				FirstName = 'Test',
				LastName = 'User',
				MemberId__c = testMember.Id,
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

	public static Contact getStandardContact(){
		return testContact;
	}
	
}