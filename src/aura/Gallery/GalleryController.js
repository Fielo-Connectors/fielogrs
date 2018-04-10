({
	doInit : function(component, event, helper) {
        component.set('v.CanvasParameters','{"route":"' + component.get('v.grsRouteOption') + '"}');
		var action = component.get('c.login');
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === 'SUCCESS') {
                component.set('v.ssoReady',response.getReturnValue());
            } else if (state === 'ERROR') {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
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
            } else if (state === 'ERROR') {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });    
        $A.enqueueAction(action);
	}
})