trigger Users on User (after update) {
	Users.onAfterUpdate(Trigger.new, Trigger.oldMap);
}