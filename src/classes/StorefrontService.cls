global class StorefrontService {

	private Integer timeout = 30000;
	private String domain;
	private AuthData user_auth;
	private AuthData admin_auth;

	global StorefrontService(String domain) {
		this.domain = domain;
	}

	global void setUserAuth(String user_id, String api_token) {
		this.user_auth = new AuthData();
		this.user_auth.id = user_id;
		this.user_auth.token = api_token;
	}

	global AuthData getUserAuth() {
		return this.user_auth;
	}

	global void setAdminAuth(String user_id, String api_token) {
		this.admin_auth = new AuthData();
		this.admin_auth.id = user_id;
		this.admin_auth.token = api_token;
	}

	global AuthData getAdminAuth() {
		return this.admin_auth;
	}

	global String getUserAuthHeader() {
		return this.getAuthHeader(this.getUserAuth());
	}

	global String getAdminAuthHeader() {
		return this.getAuthHeader(this.getAdminAuth());
	}

	global String getAuthHeader(AuthData auth) {
		Blob auth_encoded = Blob.valueOf(JSON.serialize(auth)); 
		Blob headerValue = Blob.valueOf(auth.id + ':' + EncodingUtil.base64Encode(auth_encoded));
		String auth_header = 'Basic ' + EncodingUtil.base64Encode(headerValue);

		System.debug(auth_header);
		return auth_header;
	}

	global Map<String,Object> getMember() {

		System.debug('Calling Storefront API: getMemberAccount');

		//call API and see if this member exists
		HttpRequest req = new HttpRequest();
		req.setMethod('GET');
		req.setHeader('Content-Type','application/x-www-form-urlencoded');        
		req.setHeader('Authorization', this.getUserAuthHeader());
		req.setEndpoint(this.domain + '/client/json.php/getMemberAccount');
		req.setTimeout(this.timeout);

		try {
			Http http = new Http();
			HTTPResponse res = http.send(req);
			System.debug(res.toString());
			System.debug(res.getBody());

			// Parse entire JSON response.
			if (res.getStatusCode() == 200 || res.getStatusCode() == 201 || res.getStatusCode() == 202) {

				Map<String,Object> member = (Map<String,Object>) JSON.deserializeUntyped(res.getBody());
				System.debug(member);

				return member;
			}
		} catch(System.CalloutException e) {
			System.debug('Failed: ' + e.getMessage());
		}
		return null;
	}

	global Map<String,Object> createMember(Map<String,Object> newMember) {
		System.debug('Calling Storefront API: createSubordinateAccount');
		System.debug(newMember);

		HttpRequest req = new HttpRequest(); 
		req.setMethod('POST');
		req.setHeader('Content-Type','application/x-www-form-urlencoded'); 
		req.setHeader('Authorization', this.getAdminAuthHeader());
		req.setEndpoint(this.domain + '/client/json.php/createSubordinateAccount');
		req.setTimeout(this.timeout);
		req.setBody('account='+JSON.serialize(newMember));
		System.debug(req.getBody());

		try {

			Http http = new Http();
			HTTPResponse res = http.send(req);
			System.debug(res.toString());   
			System.debug(res.getBody());

			// Parse entire JSON response.
			if (res.getStatusCode() == 200 || res.getStatusCode() == 201 || res.getStatusCode() == 202) {

				Map<String,Object> member = (Map<String,Object>) JSON.deserializeUntyped(res.getBody());
				System.debug(member);

				return member;
			}

		} catch(System.CalloutException e) {
			System.debug('Failed: ' + e.getMessage());
		}

		return null;
	}

	global Map<String,Object> updateMember(Map<String,Object> member) {

		System.debug('Calling Storefront API: updateSubordinateAccount');
		System.debug(member);

		HttpRequest req = new HttpRequest(); 
		req.setMethod('POST');
		req.setHeader('Content-Type','application/x-www-form-urlencoded');        
		req.setHeader('Authorization', this.getAdminAuthHeader());
		req.setEndpoint(this.domain + '/client/json.php/updateSubordinateAccount');
		req.setTimeout(this.timeout);
		req.setBody('account='+JSON.serialize(member));

		try {

			Http http = new Http();
			HTTPResponse res = http.send(req);
			System.debug(res.toString());
			System.debug(res.getBody());

			// Parse entire JSON response.
			if (res.getStatusCode() == 200 || res.getStatusCode() == 201 || res.getStatusCode() == 202) {

				member = (Map<String,Object>) JSON.deserializeUntyped(res.getBody());
				System.debug(member);

				return member;
			}

		} catch(System.CalloutException e) {
			System.debug('Failed: ' + e.getMessage());
		}

		return null;
	}

	global MemberSsoSessionWrapper createSsoSession() {
		System.debug('Calling Storefront API: createSsoSession');

		//call API and see if this member exists
		HttpRequest req = new HttpRequest();
		req.setMethod('GET');
		req.setHeader('Content-Type','application/x-www-form-urlencoded');        
		req.setHeader('Authorization', this.getAdminAuthHeader());
		req.setEndpoint(this.domain + '/client/json.php/createSsoSession');
		req.setTimeout(this.timeout);

		try {
			Http http = new Http();
			HTTPResponse res = http.send(req);
			System.debug(res.toString());
			System.debug(res.getBody());

			// Parse entire JSON response.
			if (res.getStatusCode() == 200 || res.getStatusCode() == 201 || res.getStatusCode() == 202) {

				JSONParser parser = JSON.createParser(res.getBody());
				System.debug(parser);

				MemberSsoSessionWrapper session = (MemberSsoSessionWrapper)parser.readValueAs(MemberSsoSessionWrapper.class);
				System.debug(session);

				return session;
			}
		} catch(System.CalloutException e) {
			System.debug('Failed: ' + e.getMessage());
		}
		return null;
	}

	global MemberSsoSessionWrapper getSsoSession() {
		System.debug('Calling Storefront API: getSsoSession');

		//call API and see if this member exists
		HttpRequest req = new HttpRequest();
		req.setMethod('GET');
		req.setHeader('Content-Type','application/x-www-form-urlencoded');        
		req.setHeader('Authorization', this.getUserAuthHeader());
		req.setEndpoint(this.domain + '/client/json.php/getSsoSession');
		req.setTimeout(this.timeout);
		req.setBody('options=[{"name":"layout","value":"0"}]');

		try {
			Http http = new Http();
			HTTPResponse res = http.send(req);
			System.debug(res.toString());
			System.debug(res.getBody());

			// Parse entire JSON response.
			if (res.getStatusCode() == 200 || res.getStatusCode() == 201 || res.getStatusCode() == 202) {

				JSONParser parser = JSON.createParser(res.getBody());
				System.debug(parser);

				MemberSsoSessionWrapper session = (MemberSsoSessionWrapper)parser.readValueAs(MemberSsoSessionWrapper.class);
				System.debug(session);

				return session;
			}
		} catch(System.CalloutException e) {
			System.debug('Failed: ' + e.getMessage());
		}
		return null;
	}

	global class MemberSsoSessionWrapper {
		global String sessionId;
		global String url;
	}

	// Wrappers
	global class AuthData {
		global String token;
		global String id;
		global String password;
	}

	global class MemberAccountMetadataWrapper {
		global String id;
		global String name;
		global String data;
	}

	global class MemberHierarchyRoleWrapper {
		global String hierarchyRoleId;
		global String hierarchyNodeCode;
		global Integer hierarchyRoleNodeAccess;
	}

	global class MemberAccountWrapper {
		global String id;
		global String employeeId;
		global String firstName;
		global String lastName;
		global String email;
		global String address1;
		global String address2;
		global String city;
		global String postalCode;
		global String provinceState;
		global String country;
		global String telephone;
		global String language;
		global String hireDate;
		global Integer balance;
		global Integer lifetimePointsAwarded;
		global Integer lifetimePointsRedeemed;
		global Map<String,String> credentials;
		global Map<String,String> accessGroups;
		global String locale;
		global String hierarchyNodeCode;
		global Map<String,MemberHierarchyRoleWrapper> hierarchyRoles;
		global Map<String,MemberAccountMetadataWrapper> metadata;
		global Integer totalUnderAdministration;
		global String created;
		global String deleted;
	    
	    public void setUserData(FieloPLT__Member__c member) {
	        List<String> language_parts = member.FieloPLT__User__r.LanguageLocaleKey.split('_', 2);

	        this.employeeId = member.Id;
	        this.firstName = member.FieloPLT__User__r.FirstName;
	        this.lastName = member.FieloPLT__User__r.LastName;
	        this.email = member.FieloPLT__Email__c;
	        
	        //address
	        this.address1 = member.FieloPLT__User__r.Street;
	        //this.address2 = u.Street;
	        this.city = member.FieloPLT__User__r.City;
	        this.postalCode = member.FieloPLT__User__r.PostalCode;
	        this.provinceState = member.FieloPLT__User__r.State;
	        this.country = language_parts[1];
	        
	        //parse phone #
	        //this.tel_countrycode = u.Phone;
	        //this.tel_areacode = u.Phone;
	        this.telephone = member.FieloPLT__User__r.Phone;
	        
	        //parse language
	        this.language = language_parts[0];
	    }
	}

	global class NewMemberAccountWrapper {
		global String employeeId;
		global String firstName;
		global String lastName;
		global String email;
		global String address1;
		global String address2;
		global String city;
		global String postalCode;
		global String provinceState;
		global String country;
		global String telephone;
		global String language;
		global String hireDate;
		global List<String> accessGroups;
		global String hierarchyNodeCode;
		global List<MemberHierarchyRoleWrapper> hierarchyRoles;
		global List<MemberAccountMetadataWrapper> metadata;
		global Boolean sendWelcomeLetter;

		global NewMemberAccountWrapper() {
			this.accessGroups = new List<String>();
			this.hierarchyRoles = new List<MemberHierarchyRoleWrapper>();
			this.metadata = new List<MemberAccountMetadataWrapper>();
		}

		public void setUserData(FieloPLT__Member__c member) {
			List<String> language_parts = member.FieloPLT__User__r.LanguageLocaleKey.split('_', 2);

			this.employeeId = member.Id;
			this.firstName = member.FieloPLT__User__r.FirstName;
			this.lastName = member.FieloPLT__User__r.LastName;
			this.email = member.FieloPLT__Email__c;

			//address
			this.address1 = member.FieloPLT__User__r.Street;
			//this.address2 = u.Street;
			this.city = member.FieloPLT__User__r.City;
			this.postalCode = member.FieloPLT__User__r.PostalCode;
			this.provinceState = member.FieloPLT__User__r.State;
			this.country = language_parts[1];

			//parse phone #
			//this.tel_countrycode = u.Phone;
			//this.tel_areacode = u.Phone;
			this.telephone = member.FieloPLT__User__r.Phone;

			//parse language
			this.language = language_parts[0];

			//this.hireDate = "";
			this.hierarchyNodeCode = 'ROOT';
		}
	}
}