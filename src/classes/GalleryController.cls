public class GalleryController {
    @AuraEnabled
    public static Boolean login(){
        try{
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
        } catch (DmlException e) {
            throw new AuraHandledException(e.getDmlMessage(0));
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return null;
    }

    @AuraEnabled
    public static FieloPLT__Member__c setCurrentMember(FieloPLT__Member__c member) {
        try{
            if (member != null) {
                if (member.Id != null) {
                    Id userId = UserInfo.getUserId();
                    Id userMemberId = member.Id;
                    String memberId = String.valueOf(member.Id);

                    // Flexible Membership
                    FieloPLT__Member__c currentmember;

                    if ( Schema.sObjectType.FieloPLT__Member__c.isAccessible() ) {
                        currentmember = [SELECT Id, FieloPLT__Type__c, FieloPLT__IsManager__c, FieloPLT__OrganizationAccount__c FROM FieloPLT__Member__c WHERE Id = :memberId LIMIT 1];
                    } else {
                        throw new FieloPLT.FieloException('There are no permissions to read FieloPLT__Member__c');
                    }
                    if ( currentmember.FieloPLT__Type__c == 'Organization Contributor' && currentmember.FieloPLT__IsManager__c ) {
                        // Retrieve Organization Account Instead
                        userMemberId = member.FieloPLT__OrganizationAccount__c;
                    }

                    List<User> users = Database.query('SELECT Id FROM User WHERE Id = :userId AND FieloGRS__MemberId__c = :memberId');
            
                    if (users.isEmpty()) {
                        FieloGRS.UserService.enableAdminPermission(true);
                        User currentUser = new User();
                        currentUser.Id = userId;
                        if (Schema.sObjectType.User.fields.MemberId__c.isUpdateable()) {
                            currentUser.MemberId__c = userMemberId;
                        }
                        update currentUser;
                        FieloGRS.UserService.enableAdminPermission(false);
                    }
                }
            }
            return member;
        } catch (DmlException e) {
            throw new AuraHandledException(e.getDmlMessage(0));
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return null;
    }
}