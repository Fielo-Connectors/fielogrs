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

				return member;
			} else {
				throw new FieloPLT.FieloException('Status Code ' + res.getStatusCode() + ', Status: ' + res.getStatus());
			}
		} catch(Exception e) {
			insertError(e);
		}
		return null;
	}

	public Map<String,Object> createMember(Map<String,Object> newMember) {
		System.debug('Calling Storefront API: createSubordinateAccount');
		System.debug(JSON.serializePretty(newMember));

		HttpRequest req = new HttpRequest(); 
		req.setMethod('POST');
		req.setHeader('Content-Type','application/x-www-form-urlencoded'); 
		req.setHeader('Authorization', this.getAdminAuthHeader());
		req.setEndpoint(this.domain + '/client/json.php/createSubordinateAccount');
		req.setTimeout(this.timeout);
		req.setBody('account=' + EncodingUtil.urlEncode( JSON.serialize(newMember) , 'UTF-8') );
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
					if (member.get('error')!=null) {
						Map<String,Object> errorMap = (Map<String,Object>) member.get('error');
						if (errorMap.containsKey('errorMessage')) {
							if (errorMap.get('errorMessage')!='') {
								throw new FieloPLT.FieloException('createMember: ' + (String)errorMap.get('errorMessage'));
							}
						}
					}
				}

				return member;
			} else {
				throw new FieloPLT.FieloException('Status Code ' + res.getStatusCode() + ', Status: ' + res.getStatus());
			}

		} catch(Exception e) {
			insertError(e);
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
		req.setBody('account=' + EncodingUtil.urlEncode( JSON.serialize(member) , 'UTF-8') );

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
					if (member.get('error')!=null) {
						Map<String,Object> errorMap = (Map<String,Object>) member.get('error');
						if (errorMap.containsKey('errorMessage')) {
							if (errorMap.get('errorMessage')!='') {
								throw new FieloPLT.FieloException('updateMember: ' + (String)errorMap.get('errorMessage'));
							}
						}
					}
				}
				
				return member;
			} else {
				throw new FieloPLT.FieloException('Status Code ' + res.getStatusCode() + ', Status: ' + res.getStatus());
			}

		} catch(Exception e) {
			insertError(e);
		}

		return null;
	}

	// Wrappers
	public class AuthData {
		public String token;
		public String id;
		public String password;
	}

	/**
     * @brief       Metodo para insertar un error en la base
     * @details     Dado una excepcion de cualquier tipo el metodo genera un nuevo registro de Error Log con todos los datos de la excepcion, 
     *              la informacion que completa es el numero de linea, mensaje del error, stack trace, el tipo de excepcion y el Id del usuario logueado.
     * @version     10.0
     * @param       except    excepcion que se quiere insertar
     * @return      Void
     * @code{.java}
     *      try{
     *          insert new Account(Name = 'Test Account');
     *      }catch(Exception e){
     *          FieloEE.ErrorService.insertError(e);
     *      }
     * @endcode
     */
	public static void insertError(Exception except){
        FieloPLT__ErrorLog__c error = new FieloPLT__ErrorLog__c();

        Set<String> fieldNamesInsert = new Set<String>();
        
        error.FieloPLT__LineNumber__c = except.getLineNumber();
        error.FieloPLT__Message__c = except.getMessage();
        error.FieloPLT__StackTrace__c = except.getStackTraceString();
        error.FieloPLT__Type__c = except.getTypeName();
        error.FieloPLT__UserId__c = UserInfo.getUserId();
        fieldNamesInsert.add('FieloPLT__LineNumber__c');
        fieldNamesInsert.add('FieloPLT__Message__c');
        fieldNamesInsert.add('FieloPLT__StackTrace__c');
        fieldNamesInsert.add('FieloPLT__Type__c');
        fieldNamesInsert.add('FieloPLT__UserId__c');
        
        if(canInsert(FieloPLT__ErrorLog__c.sObjectType, new List<String>(fieldNamesInsert))){
            insert error;
        }else{
            throw new FieloPLT.FieloException(String.format(Label.fieloplt.security_error_object_not_insertable, new List<String>{'FieloPLT__ErrorLog__c'}));
        }
    }
    
    public static Boolean canInsert(SObjectType objType, List<String> fieldNames){
		DescribeSObjectResult objDesc = objType.getDescribe();
		Map<String,Schema.SObjectField> errorLogFields = Schema.SObjectType.FieloPLT__ErrorLog__c.fields.getMap();

		if( !objDesc.isCreateable() ){
			return false;
		}
		for ( String fieldName : fieldNames ) {
			if(!errorLogFields.get(fieldName).getDescribe().isCreateable()){
				return false;
			}
		}
		return true;
	}
}