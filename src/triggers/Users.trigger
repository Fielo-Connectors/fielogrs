trigger Users on User (before update) {
	Users.onBeforeUpdate(Trigger.new, Trigger.oldMap);
}