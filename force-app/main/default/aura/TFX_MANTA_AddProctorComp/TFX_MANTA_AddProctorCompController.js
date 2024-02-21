({
    myAction : function(component, event, helper) {
       component.set("{!v.isLoading}", false);
    }, 
    
    navigateToTFX_MANTA_Comp : function(component, event, helper) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:TFX_MANTA_Comp"
            //componentAttributes :{ }
        });
        evt.fire();
    },
    
    navigateToTFX_MANTA_Proctors_Comp : function(component, event, helper) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:TFX_MANTA_Proctors_Comp"
            //componentAttributes :{ }
        });
        evt.fire();
    },
    
    addProctor : function(component, event, helper) {
        
        component.set("{!v.isLoading}", true);
        
        var action = component.get("c.addProctorInSF");
        action.setParams({
            'procUsrId' : component.get("v.selectedId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                
                if(!response.getReturnValue()){
                    component.set("{!v.isLoading}", false);
                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: "Success!",
                        message: "Proctor successfully added to MANTA app.",
                        type: "success"
                    });
                    toastEvent.fire();
                    
                    var evt = $A.get("e.force:navigateToComponent");
                    evt.setParams({
                        componentDef: "c:TFX_MANTA_Proctors_Comp",
                        componentAttributes :{ 
                            selectedId : component.get("v.selectedId")
                        }
                    });
                    evt.fire();
                }
                else{
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: "Error!",
                        message: "Proctor already exist, Try searching for Proctor or add other!",
                        type: "error"
                    });
                    toastEvent.fire();
                    component.set("{!v.isLoading}", false);
                }
                
            } else {
                console.log("Failed with state: " + state);
            }
        });
        
        $A.enqueueAction(action);
        
        
    }         
    
})