({
	myAction : function(component, event, helper) {
        
         var action = component.get("c.getAllPhyRecertLst");

        action.setCallback(this, function(response) {
            
            //component.set("{!v.isLoading}", true);
            
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                console.log("resp-->", response.getReturnValue());
                //component.set("v.allPhysiciansLst", response.getReturnValue().physicians);
                //component.set("{!v.isLoading}", false);
            } else {
                //component.set("{!v.isLoading}", false);
                console.log("Failed with state: " + state);
            }
        });
        
        $A.enqueueAction(action);
		
	}
})