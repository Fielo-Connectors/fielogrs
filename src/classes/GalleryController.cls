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
            System.debug(e);
        }
        return result;
    }

    @AuraEnabled
    public static FieloPLT__Member__c setCurrentMember(FieloPLT__Member__c member) {
        UserService.enableAdminPermission(true);
        update new User(
            Id = UserInfo.getUserId(),
            FieloGRS__MemberId__c = member.Id
        );
        UserService.enableAdminPermission(false);
        return member;
    }
}