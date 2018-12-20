public class Users {
	public static Boolean validateAdminFields = true;
    
    public static void onBeforeUpdate(List<User> records, Map<Id,User> existingRecords) {
        if(FieloPLT__AdminPermission__c.getInstance(UserInfo.getUserId()) != null && FieloPLT__AdminPermission__c.getInstance(UserInfo.getUserId()).FieloPLT__To__c >= system.now()){
            validateAdminFields = false;
        }
        
        if (validateAdminFields) {
            for(User u: records) {
                if (existingRecords.get(u.Id).MemberId__c != u.MemberId__c) {
                    u.addError(Label.UserFieldEditDisabled);
                }
            }
        }
    }

    public static void onAfterInsert(List<User> records) {
        if(FieloPLT__AdminPermission__c.getInstance(UserInfo.getUserId()) != null && FieloPLT__AdminPermission__c.getInstance(UserInfo.getUserId()).FieloPLT__To__c >= system.now()){
            validateAdminFields = false;
        }

        if (validateAdminFields) {
            Set<Id> contactsIds = new Set<Id>();
            for(User u: records) {
                contactsIds.add(u.ContactId);
            }

            List<FieloPLT__Member__c> members = [SELECT Id,FieloPLT__Type__c,FieloPLT__OrganizationAccount__c,FieloPLT__Contact__c FROM FieloPLT__Member__c WHERE FieloPLT__Contact__c IN :contactsIds];

            Map<Id,Id> memberByContactMap = new Map<Id,Id>();

            for(FieloPLT__Member__c m: members){
                if (m.FieloPLT__Type__c == 'Individual Account' || m.FieloPLT__Type__c == 'Organization Account') {
                    memberByContactMap.put(m.FieloPLT__Contact__c,m.Id);
                } else {
                    memberByContactMap.put(m.FieloPLT__Contact__c,m.FieloPLT__OrganizationAccount__c);
                }
            }
            List<User> users = new List<User>();

            for(User u: records) {
                if(memberByContactMap.containsKey(u.ContactId)){
                    users.add(
                        new User(
                            Id=u.Id,
                            MemberId__c=memberByContactMap.get(u.ContactId)
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