public class CustomGalleryController {
	public Boolean renderCatalog {get;set;}
	public LoginService ls {get;set;}
	
	public CustomGalleryController() {
		String loginResult = LoginService.login('a0Hf4000001RBdpEAG');

		renderCatalog = loginResult == 'success' ? true : false;
	}
}