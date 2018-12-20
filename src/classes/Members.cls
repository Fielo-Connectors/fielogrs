public with sharing class Members {
    public static Boolean validateAdminFields = true;
    
    public static void onAfterUpdate(List<FieloPLT__Member__c> records, Map<Id,FieloPLT__Member__c> existingRecords) {
        if(FieloPLT__AdminPermission__c.getInstance(UserInfo.getUserId()) != null && FieloPLT__AdminPermission__c.getInstance(UserInfo.getUserId()).FieloPLT__To__c >= system.now()){
            validateAdminFields = false;
        }
        if (validateAdminFields) {
            Set<Id> memberIds = new Map<Id, FieloPLT__Member__c>(records).keyset();

            Map<Id, FieloPLT__Member__c> membersMap = new Map<Id, FieloPLT__Member__c>([SELECT Id, FieloPLT__Type__c, FieloPLT__OrganizationAccount__c FROM FieloPLT__Member__c WHERE Id IN :memberIds]);
        	List<User> users = new List<User>();
            Id memberId;
            for(FieloPLT__Member__c m: records) {
                if (existingRecords.get(m.Id).FieloPLT__User__c != m.FieloPLT__User__c) {
                    memberId = membersMap.get(m.Id).FieloPLT__Type__c == 'Organization Contributor' ?
                        membersMap.get(m.Id).FieloPLT__OrganizationAccount__c :
                        m.Id;

                	users.add(
                		new User(
                			Id=m.FieloPLT__User__c,
                			MemberId__c = memberId
                		)
                	);
                }
            }
            if (!users.isEmpty()) {
                UserService.enableAdminPermission(true);
            	update users;
                UserService.enableAdminPermission(false);
            }
        }
    }
}