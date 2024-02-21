({
    doInit : function(component, event, helper) {
        var recordId = component.get("v.recordId");
        var action = component.get("c.updateImageUrl");
        console.log("*** recordId updateImageUrl*** " + recordId);
        action.setParams({
            "recordId": recordId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "type": "success",
                    "message": "The images are updated successfully."
                });
                toastEvent.fire();
            }
            else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type": "error",
                    "message": "There was an issue in image update process."
                });
                toastEvent.fire();
            }
            // Close the quick action
            var closeQuickAction = $A.get("e.force:closeQuickAction");
            closeQuickAction.fire();
        });
        $A.enqueueAction(action);
    }
})