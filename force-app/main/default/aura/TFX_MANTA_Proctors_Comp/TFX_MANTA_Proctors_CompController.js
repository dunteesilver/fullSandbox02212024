({
	myAction : function(component, event, helper) {
        
        if(component.get("v.selectedId") === undefined){
        var action = component.get("c.getAllProctorsInSF");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                component.set("v.allProctorsLst", response.getReturnValue());
                component.set("{!v.isLoading}", false);
            } else {
                console.log("Failed with state: " + state);
            }
        });
        
        $A.enqueueAction(action);
        }
        else{
            var internalAction = component.get('c.srchProctorById');
            $A.enqueueAction(internalAction);
        }
	},
    
    srchProctorById : function(component, event, helper) {
        
        component.set("{!v.isLoading}", true);
        
        var proctorId = ''+component.get("v.selectedId"); 

        if(proctorId.length === 0){
            proctorId += 'All';
        }
 
        var action = component.get("c.getProctorByProctorId");
        action.setParams({
            'proctorId' : proctorId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
console.log('resp-->', response.getReturnValue());
                component.set("v.allProctorsLst", response.getReturnValue());
                component.set("{!v.isLoading}", false);
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
    
    navigateToTFX_MANTA_AddProctorComp : function(component, event, helper) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:TFX_MANTA_AddProctorComp"
            //componentAttributes :{ }
        });
        evt.fire();
    }
})