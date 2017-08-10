@isTest
private with sharing class TestPrograms {
	
	@isTest static void testProgramInsertOk(){

		FieloPLT__Program__c program = new FieloPLT__Program__c();

		program.GRSMemberFieldset__c = '[ { "grsFieldName":"firstName", "sfFieldName":"FieloPLT__Contact__r.FirstName" }]';
		program.GRSOrderFieldset__c = '[{"grsFieldName":"shipAddress1","sfFieldName":"FieloPLT__Status__c"}]';
		program.GRSOrderItemFieldset__c = '[{"grsFieldName":"name","sfFieldName":"FieloPLT__UnitCost__c"}]';
		insert program;
	}

	@isTest static void testProgramUpdateOk(){

		FieloPLT__Program__c program = new FieloPLT__Program__c();
		insert program;

		program.GRSMemberFieldset__c = '[ { "grsFieldName":"firstName", "sfFieldName":"FieloPLT__Contact__r.FirstName" }]';
		program.GRSOrderFieldset__c = '[{"grsFieldName":"shipAddress1","sfFieldName":"FieloPLT__Status__c"}]';
		program.GRSOrderItemFieldset__c = '[{"grsFieldName":"name","sfFieldName":"FieloPLT__UnitCost__c"}]';
		update program;
	}

	@isTest static void testProgramInsertWrongFormat(){

		FieloPLT__Program__c program = new FieloPLT__Program__c();

		program.GRSMemberFieldset__c = '["grsFieldName":"firstName", "sfFieldName":"FieloPLT__Contact__r.FirstName" }]';
		program.GRSOrderFieldset__c = '["grsFieldName":"shipAddress1","sfFieldName":"FieloPLT__Status__c"}]';
		program.GRSOrderItemFieldset__c = '["grsFieldName":"name","sfFieldName":"FieloPLT__UnitCost__c"}]';
		try{insert program;}catch(Exception e){}
	}

	@isTest static void testProgramUpdateWrongFormat(){

		FieloPLT__Program__c program = new FieloPLT__Program__c();
		insert program;

		program.GRSMemberFieldset__c = '["grsFieldName":"firstName", "sfFieldName":"FieloPLT__Contact__r.FirstName" }]';
		program.GRSOrderFieldset__c = '["grsFieldName":"shipAddress1","sfFieldName":"FieloPLT__Status__c"}]';
		program.GRSOrderItemFieldset__c = '["grsFieldName":"name","sfFieldName":"FieloPLT__UnitCost__c"}]';
		try{update program;}catch(Exception e){}
	}

	@isTest static void testProgramInsertWrongFields(){

		FieloPLT__Program__c program = new FieloPLT__Program__c();

		program.GRSMemberFieldset__c = '[{"grsFieldName":"firstName", "sfFieldName":"FieloPLT__Contact__r.AccountId.WrongField__c" }]';
		program.GRSOrderFieldset__c = '[{"grsFieldName":"shipAddress1","sfFieldName":"FieloPLT__Address__c"}]';
		try{insert program;}catch(Exception e){}
	}

	@isTest static void testProgramInsertNotAllowedFields(){

		FieloPLT__Program__c program = new FieloPLT__Program__c();

		program.GRSMemberFieldset__c = '[{"grsFieldName":"pointBalance", "sfFieldName":"FieloPLT__Points__c"}]';
		program.GRSOrderFieldset__c = '[{"grsFieldName":"shipAddress1","sfFieldName":"FieloPLT__Redemption__c"}]';
		program.GRSOrderItemFieldset__c = '[{"grsFieldName":"name","sfFieldName":"FieloPLT__Quantity__c"}]';
		try{insert program;}catch(Exception e){}
	}

	@isTest static void testProgramInsertRepeatedFields(){

		FieloPLT__Program__c program = new FieloPLT__Program__c();

		program.GRSMemberFieldset__c = '[{"grsFieldName":"firstName", "sfFieldName":"FieloPLT__Contact__r.FirstName" },{"grsFieldName":"firstName", "sfFieldName":"FieloPLT__Contact__r.FirstName" }]';
		program.GRSOrderItemFieldset__c = '[{"grsFieldName":"name","sfFieldName":"FieloPLT__UnitCost__c"},{"grsFieldName":"name","sfFieldName":"FieloPLT__UnitCost__c"}]';
		try{insert program;}catch(Exception e){}
	}

}