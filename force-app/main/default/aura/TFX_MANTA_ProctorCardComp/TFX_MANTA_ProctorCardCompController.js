({
    myAction : function(component, event, helper) {
        
    },
    
    navigateToTFX_MANTA_ProctorCardEdit : function(component, event, helper) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:TFX_MANTA_ProctorCardEdit",
            componentAttributes :
            {
                recId : component.get("v.recId"),
                procId : component.get("v.procId"),
                procName : component.get("v.procName"),
                procEmail : component.get("v.procEmail"),
                procAdmnAcss : component.get("v.procAdmnAcss"),
                procIsActive : component.get("v.procIsActive")
            }
        });
        evt.fire();
    }
})