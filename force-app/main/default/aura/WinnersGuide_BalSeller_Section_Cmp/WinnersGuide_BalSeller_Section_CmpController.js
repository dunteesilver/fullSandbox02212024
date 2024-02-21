({
    myAction : function(component, event, helper) {
    component.set("{!v.isLoading}", true);
        var wgId = component.get("v.recordId");
        var action = component.get("c.getWGDetails");
        action.setParams({
            wgId : wgId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                component.set("v.newVPSWinGuide", response.getReturnValue());
                component.set("{!v.isLoading}", false);   
            } else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
    },
    saveWGBalSelSectionDetails: function(component, event, helper) {
        component.set("{!v.isLoading}", true);
        var newVPSWinGuide = component.get("v.newVPSWinGuide");
        var action = component.get("c.saveWGBalSellerDetails");
        action.setParams({
            newVPSWinGuide : JSON.stringify(component.get("v.newVPSWinGuide"))
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                component.set("{!v.isLoading}", false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    message: component.get("v.newVPSWinGuide.Name") +' saved successfully!',
                    type: 'success'
                });
                toastEvent.fire();
            } else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
    }
})