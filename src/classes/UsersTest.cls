@isTest
private with sharing class UsersTest {
	@testSetup static void testSetup() {
		UserRole r = new UserRole(DeveloperName = 'CustomRole', Name = 'Custom Role');
		insert r;

		Id profileId = [select id from profile where name='System Administrator'].Id;
		User tester = new User(
			FirstName = 'Tester',
			LastName = 'User',
			Username = 'engineering2@fielo.com',
			Email = 'engineering@fielo.com',
			Alias = 'engineer',
			CommunityNickname = 'engineering',
			TimeZoneSidKey = UserInfo.getTimeZone().getID(),
			LocaleSidKey = UserInfo.getLocale(),
			EmailEncodingKey = 'ISO-8859-1',
			ProfileId = profileId,
			UserRoleId = r.Id,
			LanguageLocaleKey = UserInfo.getLocale()
		);

		insert tester;
		
	}

	@isTest static void testProgramUpdateNok(){
		MockUpFactory.inicializeData();
		FieloPLT__Member__c member = [Select Id, Name From FieloPLT__Member__c WHERE Name = 'Test Member'];
		User testUser = [Select Id, FirstName, MemberId__c From User Where Username = 'a@grstest.com' LIMIT 1];

		testUser.MemberId__c = null;

		try{
			update testUser;
		} catch(Exception e) {}

		testUser = [Select Id, FirstName, MemberId__c From User Where Username = 'a@grstest.com' LIMIT 1];

		System.assertEquals(member.Id,testUser.MemberId__c);
	}

	@isTest static void testProgramUpdateOk(){
		MockUpFactory.inicializeData();
		FieloPLT__Member__c member = [Select Id, Name From FieloPLT__Member__c WHERE Name = 'Test Member'];
		User testUser = [Select Id, FirstName, MemberId__c From User Where Username = 'a@grstest.com' LIMIT 1];

		testUser.MemberId__c = null;

		try{
			Users.validateAdminFields = false;
			update testUser;
			Users.validateAdminFields = true;

		} catch(Exception e) {
			Users.validateAdminFields = true;
		}

		testUser = [Select Id, FirstName, MemberId__c From User Where Username = 'a@grstest.com' LIMIT 1];

		System.assertEquals(null,testUser.MemberId__c);
	}

	@isTest static void testSettingMemberId(){
		User u = [SELECT Id,Name,UserRoleId,ProfileId FROM User WHERE Username='engineering2@fielo.com'];
		Id profileId = [select id from profile where name='Partner Community User'].id;
		System.runAs(u){

			MockUpFactory.inicializeData();

				Contact testContact = MockUpFactory.getStandardContact();
				User testUser2 = new User(
				FirstName = 'Test',
				LastName = 'User2',
				ContactId = testContact.Id,
				Username = 'a2@grstest.com',
				Email = 'a2@grstest.com',
				Alias = 'grstest2',
				CommunityNickname = 'grstest2',
				TimeZoneSidKey = UserInfo.getTimeZone().getID(),
				LocaleSidKey = UserInfo.getLocale(),
				EmailEncodingKey = 'ISO-8859-1',
				ProfileId = profileId,
				LanguageLocaleKey = UserInfo.getLocale()
			);

			insert testUser2;

			FieloPLT__Member__c member = [Select Id, Name From FieloPLT__Member__c WHERE Name='Test MemberId'];
			User testUser = [Select Id, FirstName, MemberId__c From User Where Username = 'a2@grstest.com' LIMIT 1];

			System.assertEquals(member.Id,testUser.MemberId__c);
		}
	}
}