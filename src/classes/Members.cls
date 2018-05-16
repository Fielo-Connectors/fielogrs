public with sharing class Members {
	public static Boolean validateAdminFields = true;
    
    public static void onAfterUpdate(List<FieloPLT__Member__c> records, Map<Id,FieloPLT__Member__c> existingRecords) {
        if(FieloPLT__AdminPermission__c.getInstance(UserInfo.getUserId()) != null && FieloPLT__AdminPermission__c.getInstance(UserInfo.getUserId()).FieloPLT__To__c >= system.now()){
            validateAdminFields = false;
        }
        if (validateAdminFields) {
        	List<User> users = new List<User>();
            for(FieloPLT__Member__c m: records) {
                if (existingRecords.get(m.Id).FieloPLT__User__c != m.FieloPLT__User__c) {
                	users.add(
                		new User(
                			Id=m.FieloPLT__User__c,
                			MemberId__c = m.Id
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