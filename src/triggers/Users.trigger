trigger Users on User (before update, after insert) {
	if(Trigger.isUpdate){
		Users.onBeforeUpdate(Trigger.new, Trigger.oldMap);
	}
	if(Trigger.isInsert){
		Users.onAfterInsert(Trigger.new);		
	}

}