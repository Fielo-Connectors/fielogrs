trigger Programs on FieloPLT__Program__c (before insert, before update) {

	if(Trigger.isInsert){
		Programs.onBeforeInsert(Trigger.new);
	}else if(Trigger.isUpdate){
		Programs.onBeforeUpdate(Trigger.new, Trigger.oldMap);
	}
}