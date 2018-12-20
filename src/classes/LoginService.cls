global class LoginService {
    private static String adjustmentMemo = 'Balance credit adjustment to match source';

	global static String login(Id memberId) {
        Id currentMemberId = memberId;

		String query = 'SELECT Id, ' +
            'FieloPLT__Program__r.GRSAccount__c, ' +
            'FieloPLT__Program__r.GRSPointType__r.FieloPLT__RedemptionItemBalanceField__c, ' +
            'FieloPLT__Program__r.GRSPointType__r.FieloPLT__MemberBalanceField__c, ' +
            'FieloPLT__Program__r.GRSMemberFieldset__c, ' +
            'FieloPLT__Program__r.GRSMetadataFieldSet__c, ' +
            'FieloPLT__Type__c, ' +
            'FieloPLT__IsManager__c, ' +
            'FieloPLT__OrganizationAccount__c ' +
            'FROM FieloPLT__Member__c WHERE Id =: currentMemberId LIMIT 1';

        FieloPLT__Member__c member;
        Id userId = UserInfo.getUserId();

        try{
            member = (FieloPLT__Member__c) Database.query(query);
        } catch (Exception e) {
            throw new FieloPLT.FieloException (Label.MemberNotFound.replace('{0}',currentMemberId));
        }

        if ( member.FieloPLT__Type__c == 'Organization Contributor' && member.FieloPLT__IsManager__c ) {
            // Retrieve Organization Account Instead
            currentMemberId = member.FieloPLT__OrganizationAccount__c;
        }

        if ( member != null ) {
            query = 'SELECT RecordId, HasEditAccess FROM UserRecordAccess WHERE UserId = :userId AND RecordId = :currentMemberId';

            UserRecordAccess access = (UserRecordAccess) Database.query(query);

            if (member.FieloPLT__Type__c == 'Organization Contributor' && !member.FieloPLT__IsManager__c) {
                throw new FieloPLT.FieloException (Label.UserCannotAccessMember.replace('{0}',userId).replace('{1}',currentMemberId));
            } else if (member.FieloPLT__Type__c == 'Individual Account' || member.FieloPLT__Type__c == 'Organization Account') {
                if (!access.HasEditAccess) {
                    throw new FieloPLT.FieloException (Label.UserCannotAccessMember.replace('{0}',userId).replace('{1}',currentMemberId));
                }
            }

            String pointBalanceField = member.FieloPLT__Program__r.GRSPointType__r.FieloPLT__MemberBalanceField__c;
            Set<String> fieldsetToQuery = new Set<String>{pointBalanceField};

            List<FieldWrapper> memberFieldset;
            if(String.isNotBlank(member.FieloPLT__Program__r.GRSMemberFieldset__c)){
                //parse de json con fieldset casteado a wrapper interno
                memberFieldset = (List<FieldWrapper>)JSON.deserialize(member.FieloPLT__Program__r.GRSMemberFieldset__c, List<FieldWrapper>.class);
                
                for(FieldWrapper mf : memberFieldset){
                    fieldsetToQuery.add(mf.sfFieldName);
                }
            }
            List<Map<String,String>> metadataFieldset;
            if(String.isNotBlank(member.FieloPLT__Program__r.GRSMetadataFieldSet__c)){
                metadataFieldset = (List<Map<String,String>>)JSON.deserialize(member.FieloPLT__Program__r.GRSMetadataFieldSet__c, List<Map<String,String>>.class);
                
                for(Map<String,String> mdf : metadataFieldset){
                    if (mdf.containsKey('id') && mdf.containsKey('name') && mdf.containsKey('fieldName')) {
                        fieldsetToQuery.add(mdf.get('fieldName'));
                    }
                }
            }

            String memberRetrieveQuery = 'SELECT ' + String.join(new List<String>(fieldsetToQuery),',') + ' FROM FieloPLT__Member__c WHERE Id =: currentMemberId LIMIT 1';

            member = Database.query(memberRetrieveQuery);
            
            Settings__c grsSettings = Settings__c.getInstance(UserInfo.getProfileId());
            
            String domain = grsSettings.Domain__c;
            String apiKey = grsSettings.ApiKey__c;
            String adminId = grsSettings.AdminId__c;

            StorefrontService sfs = new StorefrontService(domain);
            sfs.setUserAuth(member.Id, apiKey);
            sfs.setAdminAuth(adminId, apiKey);

            Map<String,Object> grsMember = sfs.getMember();

            Boolean createMember = grsMember == null ?
                true :
                grsMember.containsKey('id') ?
                    ( grsMember.get('id') != null ? false : true ) :
                    true;

            Map<String,Object> memberData = new Map<String,Object>();

            memberData.put('pointBalance', member.get(pointBalanceField));
            memberData.put('accessGroups', (Object)new List<String>{'defaultStorefrontExternalMember'});
            memberData.put('hierarchyNodeCode', 'ROOT');
            // Locale special treatment
            List<String> language_parts;
            Boolean isLocale;

            for(FieldWrapper mf : memberFieldset){
                // Locale special treatment
                isLocale = mf.isLocale != null ? mf.isLocale : false;

                // cargo los campos en el mapa
                // +Locale special treatment
                if (isLocale) {
                    language_parts = ((String)getFieldValue(member, mf.sfFieldName)).split('_', 2);
                    memberData.put(mf.grsFieldName, language_parts[0]);
                } else {
                    memberData.put(mf.grsFieldName, getFieldValue(member, mf.sfFieldName));
                }
            }

            if (metadataFieldset!=null) {
                List<Map<String,Object>> metadataList = new List<Map<String,Object>>(); 
                Map<String,Object> metadata;
                for (Map<String,String> mdf: metadataFieldset) {
                    if (mdf.containsKey('id') && mdf.containsKey('name') && (mdf.containsKey('fieldName') || mdf.containsKey('dataValue'))) {
                        metadata = new Map<String,Object>();
                        metadata.put('id',(Object)mdf.get('id'));
                        metadata.put('name',(Object)mdf.get('name'));
                        if (mdf.containsKey('fieldName') && !mdf.containsKey('dataValue')) {
                            metadata.put('data',(Object)getFieldValue(member, mdf.get('fieldName')));
                        }
                        if (!mdf.containsKey('fieldName') && mdf.containsKey('dataValue')) {
                            metadata.put('data',(Object)mdf.get('dataValue'));
                        }
                        if (metadata.containsKey('id') && metadata.containsKey('name') && metadata.containsKey('data')) {
                            metadataList.add(metadata);
                        }
                    }
                }
                memberData.put('metadata', (Object)metadataList);
            }
            

            //do we need to create or update the member?
            if (createMember) {
                grsMember = sfs.createMember(memberData);
            } else {
                memberData.put('id', grsMember.get('id'));
                grsMember = sfs.updateMember(memberData);
            }
            
            System.debug('Member Initiated');
            System.debug(JSON.serializePretty(grsMember));

            System.debug('Creating Session');

            if (grsMember != null) {
                return 'success';
            }
            return 'fail';
        } else {
            return 'fail';
        }
    }

    private static Object getFieldValue(FieloPLT__Member__c member, String sfFieldName){
        //split para campos a segundo o tercer nivel
        String[] fieldNameSplited = sfFieldName.split('\\.');
        SObject relationObject = member;
        Integer index = 0;
        for(; index < fieldNameSplited.size() - 1; index++){
            relationObject = relationObject.getSObject(fieldNameSplited[index].removeEnd('Id'));
            if(relationObject == null)
                return null;
        }

        return relationObject.get(fieldNameSplited[index]);
    }
}