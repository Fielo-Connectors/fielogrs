({
	doInit : function(component, event, helper) {
        component.set('v.CanvasParameters','{"route":"' + component.get('v.grsRouteOption') + '"}');
		var action = component.get('c.login');
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === 'SUCCESS') {
                component.set('c.ssoReady',response.getReturnValue());
            }
        });
	},
    updateMember: function(component, event, helper){
        var newMember = event.getParam('member');
        // Create the action
        var action = component.get("c.setCurrentMember");        
        if (newMember) {
	        action.setParams({ member : newMember });            
        }
        // Add callback behavior for when response is received
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(state);
            console.log(component.isValid());
            var member = response.getReturnValue();
            if (component.isValid() && state === "SUCCESS") {
                var refreshView = false;
                if(component.get('v.member')!=null) {
                    refreshView = true;
                }
                component.set('v.member', member);
                if (refreshView) {
                    $A.get("e.force:refreshView").fire();
                }
            }
            else {
                console.log("Failed with state: " + state);
            }
        });    
        // Send action off to be executed
        $A.enqueueAction(action);
	}
})