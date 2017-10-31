public class StorefrontService {

	private Integer timeout = 30000;
	private String domain;
	private AuthData user_auth;
	private AuthData admin_auth;

	public StorefrontService(String domain) {
		this.domain = domain;
	}

	public void setUserAuth(String user_id, String api_token) {
		this.user_auth = new AuthData();
		this.user_auth.id = user_id;
		this.user_auth.token = api_token;
	}

	public AuthData getUserAuth() {
		return this.user_auth;
	}

	public void setAdminAuth(String user_id, String api_token) {
		this.admin_auth = new AuthData();
		this.admin_auth.id = user_id;
		this.admin_auth.token = api_token;
	}

	public AuthData getAdminAuth() {
		return this.admin_auth;
	}

	public String getUserAuthHeader() {
		return this.getAuthHeader(this.getUserAuth());
	}

	public String getAdminAuthHeader() {
		return this.getAuthHeader(this.getAdminAuth());
	}

	public String getAuthHeader(AuthData auth) {
		Blob auth_encoded = Blob.valueOf(JSON.serialize(auth)); 
		Blob headerValue = Blob.valueOf(auth.id + ':' + EncodingUtil.base64Encode(auth_encoded));
		String auth_header = 'Basic ' + EncodingUtil.base64Encode(headerValue);

		System.debug(auth_header);
		return auth_header;
	}

	public Map<String,Object> getMember() {

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

				if (member.containsKey('error')) {
					Map<String,Object> errorMap = (Map<String,Object>) member.get('error');
					if (errorMap.containsKey('errorMessage')) {
						if (errorMap.get('errorMessage')!='') {
							throw new FieloPLT.FieloException((String)errorMap.get('errorMessage'));
						}
					}
				}

				return member;
			}
		} catch(System.CalloutException e) {
			System.debug('Failed: ' + e.getMessage());
		}
		return null;
	}

	public Map<String,Object> createMember(Map<String,Object> newMember) {
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

				if (member.containsKey('error')) {
					Map<String,Object> errorMap = (Map<String,Object>) member.get('error');
					if (errorMap.containsKey('errorMessage')) {
						if (errorMap.get('errorMessage')!='') {
							throw new FieloPLT.FieloException((String)errorMap.get('errorMessage'));
						}
					}
				}

				return member;
			}

		} catch(System.CalloutException e) {
			System.debug('Failed: ' + e.getMessage());
		}

		return null;
	}

	public Map<String,Object> updateMember(Map<String,Object> member) {

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

				if (member.containsKey('error')) {
					Map<String,Object> errorMap = (Map<String,Object>) member.get('error');
					if (errorMap.containsKey('errorMessage')) {
						if (errorMap.get('errorMessage')!='') {
							throw new FieloPLT.FieloException((String)errorMap.get('errorMessage'));
						}
					}
				}
				
				return member;
			}

		} catch(System.CalloutException e) {
			System.debug('Failed: ' + e.getMessage());
		}

		return null;
	}

	// Wrappers
	public class AuthData {
		public String token;
		public String id;
		public String password;
	}
}