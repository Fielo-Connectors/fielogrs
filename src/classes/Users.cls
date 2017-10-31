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
}