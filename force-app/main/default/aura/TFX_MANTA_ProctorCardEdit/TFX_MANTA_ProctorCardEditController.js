({
	myAction : function(component, event, helper) {

	},
    
    confirmEditProctor : function(component, event, helper) {
        
        component.set("v.editProcObj.Id", component.get("v.recId")); 
        component.set("v.editProcObj.Trainer__c", component.get("v.procId"));
        component.set("v.editProcObj.isAdminAccess__c ", component.get("v.procAdmnAcss"));
        component.set("v.editProcObj.isActive__c ", component.get("v.procIsActive"));
        
        var action = component.get("c.updateMANTAProctor");
        action.setParams({
            editProcObj : JSON.stringify(component.get("v.editProcObj"))
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    
                    message: 'Trainer data updated succesfully!',
                    type: 'success'
                });
                toastEvent.fire();
                
                var evt = $A.get("e.force:navigateToComponent");
                evt.setParams({
                    componentDef: "c:TFX_MANTA_Proctors_Comp"
                    //componentAttributes :{ }
                });
                evt.fire();
                
            } else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);

        
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
    }
})