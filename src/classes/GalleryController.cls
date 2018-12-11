public class GalleryController {
    @AuraEnabled
    public static Boolean login(){
        Boolean result = false;
        try {
            Id userId = UserInfo.getUserId();
            User currentUser = [Select Id, FieloGRS__MemberId__c From User Where Id = :userId LIMIT 1];
            result = LoginService.login(currentUser.FieloGRS__MemberId__c) == 'success';
            return result;
        } catch(Exception e) {
			StorefrontService.insertError(e);
		}
        return result;
    }

    @AuraEnabled
    public static FieloPLT__Member__c setCurrentMember(FieloPLT__Member__c member) {
        if (member != null) {
            if (member.Id != null) {
                Id userId = UserInfo.getUserId();
                String memberId = String.valueOf(member.Id);
                List<User> users = Database.query('SELECT Id FROM User WHERE Id = :userId AND FieloGRS__MemberId__c = :memberId');
        
                if (users.isEmpty()) {
                    FieloGRS.UserService.enableAdminPermission(true);
                    User currentUser = new User();
                    currentUser.Id = userId;
                    if (Schema.sObjectType.User.fields.MemberId__c.isUpdateable()) {
                        currentUser.MemberId__c = member.Id;
                    }
                    update currentUser;
                    FieloGRS.UserService.enableAdminPermission(false);
                }
            }
        }
        return member;
    }
}