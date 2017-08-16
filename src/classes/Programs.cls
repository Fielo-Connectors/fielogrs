public with sharing class Programs {
	
	public static void onBeforeInsert(List<FieloPLT__Program__c> programs){
		List<FieloPLT__Program__c> programsToAnalize = new List<FieloPLT__Program__c>();
		Boolean queryPointTypes = false;
		for(FieloPLT__Program__c program : programs){
			if(program.GRSMemberFieldset__c != null || program.GRSOrderFieldset__c != null || program.GRSOrderItemFieldset__c != null){
				programsToAnalize.add(program);
				if(program.GRSOrderItemFieldset__c != null){
					queryPointTypes = true;
				}
			}
		}

		analizeProgramFieldsets(programsToAnalize, null, queryPointTypes);
	}

	public static void onBeforeUpdate(List<FieloPLT__Program__c> programs, Map<Id,FieloPLT__Program__c> existingPrograms){
		List<FieloPLT__Program__c> programsToAnalize = new List<FieloPLT__Program__c>();
		Boolean queryPointTypes = false;
		for(FieloPLT__Program__c program : programs){
			if((program.GRSMemberFieldset__c != null && program.GRSMemberFieldset__c != existingPrograms.get(program.Id).GRSMemberFieldset__c) || (program.GRSOrderFieldset__c != null && program.GRSOrderFieldset__c != existingPrograms.get(program.Id).GRSOrderFieldset__c) || (program.GRSOrderItemFieldset__c != null && program.GRSOrderItemFieldset__c != existingPrograms.get(program.Id).GRSOrderItemFieldset__c)){				
				programsToAnalize.add(program);
				if(program.GRSOrderItemFieldset__c != null && program.GRSOrderItemFieldset__c != existingPrograms.get(program.Id).GRSOrderItemFieldset__c){

					queryPointTypes = true;
				}
			}
		}

		analizeProgramFieldsets(programsToAnalize, existingPrograms, queryPointTypes);
	}

	private static void analizeProgramFieldsets(List<FieloPLT__Program__c> programs, Map<Id,FieloPLT__Program__c> existingPrograms, Boolean queryPointTypes){
		//Set<String> memberNotAllowedFields = new Set<String>{'pointBalance'};
		Set<String> orderNotAllowedFields = new Set<String>{'FieloPLT__Points__c','FieloPLT__Redemption__c','FieloPLT__Account__c','GRSOrderNumber__c'};
		Set<String> redItemNotAllowedFields = new Set<String>{'FieloPLT__Points__c','FieloPLT__Redemption__c','FieloPLT__Quantity__c','GRSOrderId__c'};
		
		Set<String> grsMemberAllowedFields = new Set<String>{'firstName','lastName','email','address1','address2','country','city','provinceState','telephone','language'};
		Set<String> grsOrderAllowedFields = new Set<String>{'businessAddress','totalPointCost','totalPointCostLessPointsPurchased','pin','pointsPurchased','pointsPurchasedCost','pointsPurchasedCurrency','shipAddress1','shipAddress2','shipCity','shipCompany','shipCountry','shipEmail','shipName','shipPostal','shipProvinceState','shipTelephone'};
		Set<String> grsOrderItemAllowedFields = new Set<String>{'catalogCode','catalogName','description','lineItemId','name','orderedAt'};

		if(queryPointTypes){
			for(FieloPLT__Program__c program : [SELECT (SELECT FieloPLT__PointType__r.FieloPLT__RedemptionItemBalanceField__c FROM FieloPLT__ProgramPointTypes__r) FROM FieloPLT__Program__c WHERE Id in : programs]){
				for(FieloPLT__ProgramPointType__c programPointType : program.FieloPLT__ProgramPointTypes__r){
					redItemNotAllowedFields.add(programPointType.FieloPLT__PointType__r.FieloPLT__RedemptionItemBalanceField__c);
				}
			}
		}

		if(existingPrograms == null){
			for(FieloPLT__Program__c program : programs){
				if(program.GRSMemberFieldset__c != null){
					try{
						validateJsonFieldSet(program.GRSMemberFieldset__c, FieloPLT__Member__c.SObjectType, 'read', null, grsMemberAllowedFields);
					}catch(Exception e){
						program.addError(e.getMessage());
					}
				}
				if(program.GRSOrderFieldset__c != null){
					try{
						validateJsonFieldSet(program.GRSOrderFieldset__c, FieloPLT__ProviderOrder__c.SObjectType, 'write', orderNotAllowedFields, grsOrderAllowedFields);
					}catch(Exception e){
						program.addError(e.getMessage());
					}
				}
				if(program.GRSOrderItemFieldset__c != null){
					try{
						validateJsonFieldSet(program.GRSOrderItemFieldset__c, FieloPLT__RedemptionItem__c.SObjectType, 'write', redItemNotAllowedFields, grsOrderItemAllowedFields);
					}catch(Exception e){
						program.addError(e.getMessage());
					}
				}
			}
		}else{
			for(FieloPLT__Program__c program : programs){
				if(program.GRSMemberFieldset__c != null && program.GRSMemberFieldset__c != existingPrograms.get(program.Id).GRSMemberFieldset__c){
					try{
						validateJsonFieldSet(program.GRSMemberFieldset__c, FieloPLT__Member__c.SObjectType, 'read', null, grsMemberAllowedFields);
					}catch(Exception e){
						program.addError(e.getMessage());
					}
				}
				if(program.GRSOrderFieldset__c != null && program.GRSOrderFieldset__c != existingPrograms.get(program.Id).GRSOrderFieldset__c){
					try{
						validateJsonFieldSet(program.GRSOrderFieldset__c, FieloPLT__ProviderOrder__c.SObjectType, 'write', orderNotAllowedFields, grsOrderAllowedFields);
					}catch(Exception e){
						program.addError(e.getMessage());
					}
				}
				if(program.GRSOrderItemFieldset__c != null && program.GRSOrderItemFieldset__c != existingPrograms.get(program.Id).GRSOrderItemFieldset__c){
					try{
						validateJsonFieldSet(program.GRSOrderItemFieldset__c, FieloPLT__RedemptionItem__c.SObjectType, 'write', redItemNotAllowedFields, grsOrderItemAllowedFields);
					}catch(Exception e){
						program.addError(e.getMessage());
					}
				}
			}
		}
	}

	private static void validateJsonFieldSet(String jsonFieldset, Schema.SobjectType sobjectType, String operation, Set<String> notAllowedFields, Set<String> grsAllowedFields){
		List<FieldWrapper> fieldset = (List<FieldWrapper>)JSON.deserializeStrict(jsonFieldset, List<FieldWrapper>.class);
        
        DescribeSObjectResult objectDescribe = sobjectType.getDescribe();
        Map<String,Schema.SObjectField> existingFields = objectDescribe.fields.getMap();//.keySet();
        Set<String> sfFieldNameAdded = new Set<String>();

        Set<String> repeatedFields = new Set<String>();
        for(FieldWrapper fw : fieldset){
    		//verify if the field exists in salesforce
            Boolean fieldExists = operation == 'read' ? validateFieldExistence(existingFields, fw.sfFieldName) : existingFields.containsKey(fw.sfFieldName);
            if(!fieldExists){
            	throw new FieloPLT.FieloException('The field ' + fw.sfFieldName + ' does not belong to the ' + objectDescribe.getName());
            }

            //verify if the field exists in GRS
            if(!grsAllowedFields.contains(fw.grsFieldName)){
            	throw new FieloPLT.FieloException('The field ' + fw.grsFieldName + ' does not exist in GRS system.');
            }
            
            //checks repetead fields in the fieldset
            if(operation == 'read'){
            	if(repeatedFields.contains(fw.grsFieldName)){
            		throw new FieloPLT.FieloException('The field ' + fw.grsFieldName + ' was already mapped with other field.');
            	}else{
            		repeatedFields.add(fw.grsFieldName);
            	}
    		}else if(operation == 'write'){
    			//checks if the field is allowed
    			if(notAllowedFields != null && notAllowedFields.contains(fw.sfFieldName)){
    				throw new FieloPLT.FieloException('The field ' + fw.sfFieldName + ' is not allowed to use in the fieldset.');
    			}

    			if(repeatedFields.contains(fw.sfFieldName)){
            		throw new FieloPLT.FieloException('The field ' + fw.sfFieldName + ' was already mapped with other field.');
            	}else{
            		repeatedFields.add(fw.sfFieldName);
            	}
    		}

        }
	}

	private static Boolean validateFieldExistence(Map<String,Schema.SObjectField> existingFields, String sfFieldName){
        //split para campos a segundo o tercer nivel
        String[] fieldNameSplited = sfFieldName.split('\\.');

        Map<String,Schema.SObjectField> existingObjectFields = existingFields;
        String fieldToEvaluate = fieldNameSplited[0];

        Integer index = 0;
        for(; index < fieldNameSplited.size() - 1; index++){
            String lookupField = fieldNameSplited[index].replace('__r','__c');
            fieldToEvaluate = fieldNameSplited[index + 1];
            if(!existingObjectFields.containsKey(lookupField))
            	return false;

            existingObjectFields = existingObjectFields.get(lookupField).getDescribe().getReferenceTo()[0].getDescribe().fields.getMap();
        }

        return existingObjectFields.containsKey(fieldToEvaluate);
    }

}