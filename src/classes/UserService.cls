global class UserService {
	global static void enableAdminPermission(Boolean value) {
        Users.validateAdminFields = !value;
    }
}