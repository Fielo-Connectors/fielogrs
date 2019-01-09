public class GalleryController {
    @AuraEnabled
    public static Boolean login(){
        try{
            Boolean result = false;
            Id userId = UserInfo.getUserId();
            User currentUser = [Select Id, FieloGRS__MemberId__c From User Where Id = :userId LIMIT 1];
            result = LoginService.login(currentUser.FieloGRS__MemberId__c) == 'success';
            return result;
        } catch (DmlException e) {
            StorefrontService.insertError(e);
            throw new AuraHandledException(e.getDmlMessage(0));
        } catch (Exception e) {
            StorefrontService.insertError(e);
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

                    // CRUD / FLS Check
                    if ( !Schema.sObjectType.FieloPLT__Member__c.isAccessible() )
                        throw new FieloPLT.FieloException(String.format(Label.fieloplt.security_error_object_not_readable, new List<String>{'FieloPLT__Member__c'}));
                    if ( !Schema.sObjectType.FieloPLT__Member__c.fields.FieloPLT__Type__c.isAccessible() )
                        throw new FieloPLT.FieloException(String.format(Label.fieloplt.security_error_field_not_readable, new List<String>{'FieloPLT__Member__c','FieloPLT__Type__c'}));

                    if ( !Schema.sObjectType.FieloPLT__Member__c.fields.FieloPLT__IsManager__c.isAccessible() )
                        throw new FieloPLT.FieloException(String.format(Label.fieloplt.security_error_field_not_readable, new List<String>{'FieloPLT__Member__c','FieloPLT__IsManager__c'}));
                    
                    if ( !Schema.sObjectType.FieloPLT__Member__c.fields.FieloPLT__OrganizationAccount__c.isAccessible() )
                        throw new FieloPLT.FieloException(String.format(Label.fieloplt.security_error_field_not_readable, new List<String>{'FieloPLT__Member__c','FieloPLT__OrganizationAccount__c'}));

                    currentmember = [SELECT Id, FieloPLT__Type__c, FieloPLT__IsManager__c, FieloPLT__OrganizationAccount__c FROM FieloPLT__Member__c WHERE Id = :memberId LIMIT 1];

                    // Sharring Check
                    UserRecordAccess access = (UserRecordAccess) Database.query('SELECT RecordId, HasEditAccess FROM UserRecordAccess WHERE UserId = :userId AND RecordId = :currentMemberId');

                    if (!access.HasEditAccess)
                        throw new FieloPLT.FieloException (Label.UserCannotAccessMember.replace('{0}',userId).replace('{1}',currentmember.Id));

                    if ( currentmember.FieloPLT__Type__c == 'Organization Contributor' && currentmember.FieloPLT__IsManager__c ) {
                        // Retrieve Organization Account Instead
                        userMemberId = member.FieloPLT__OrganizationAccount__c;
                    } else {
                        throw new FieloPLT.FieloException('This is a non manager Organization contributor');
                    }

                    List<User> users = Database.query('SELECT Id, FieloGRS__MemberId__c FROM User WHERE Id = :userId');
            
                    if ( !users.isEmpty() && (Id)users[0].MemberId__c != userMemberId) {
                        FieloGRS.UserService.enableAdminPermission(true);
                        User currentUser = new User();
                        currentUser.Id = userId;
                        if (Schema.sObjectType.User.fields.MemberId__c.isUpdateable()) {
                            currentUser.MemberId__c = userMemberId;
                        } else {
                            throw new FieloPLT.FieloException(String.format(Label.fieloplt.security_error_field_not_updateable, new List<String>{'User','FieloGRS__MemberId__c'}));
                        }
                        update currentUser;
                        FieloGRS.UserService.enableAdminPermission(false);
                    }
                }
            }
            return member;
        } catch (DmlException e) {
            StorefrontService.insertError(e);
            throw new AuraHandledException(e.getDmlMessage(0));
        } catch (Exception e) {
            StorefrontService.insertError(e);
            throw new AuraHandledException(e.getMessage());
        }
        return null;
    }
}