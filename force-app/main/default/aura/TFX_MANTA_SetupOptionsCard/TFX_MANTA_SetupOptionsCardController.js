({
	myAction : function(component, event, helper) {
		
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
    
    navigateToTFX_MANTA_Physicians_Comp : function(component, event, helper) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:TFX_MANTA_Physicians_Comp"
            //componentAttributes :{ }
        });
        evt.fire();
    }
    
})