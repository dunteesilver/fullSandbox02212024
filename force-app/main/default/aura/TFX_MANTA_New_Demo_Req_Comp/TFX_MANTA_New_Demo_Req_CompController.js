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
    
    clearForm : function(component, event, helper) {
        $A.get('e.force:refreshView').fire();  
    },
    
    handleSubmit : function(component, event, helper) {
        component.set("{!v.isLoading}", true);
    },
    handleSuccess : function(component, event, helper) {
        component.set("{!v.isLoading}", false);
        var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: "Success!",
                        message: "Demo request successfully added to MANTA app.",
                        type: "success"
                    });
                    toastEvent.fire();
        
         var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:TFX_MANTA_Comp"
            //componentAttributes :{ }
        });
        evt.fire();
    }
})