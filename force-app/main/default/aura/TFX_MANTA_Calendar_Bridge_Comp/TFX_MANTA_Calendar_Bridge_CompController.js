({
	getCalEvntsByRgn : function(component, event, helper) {
        
         var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:TFX_MANTA_CalenderComp"
            ,
            componentAttributes :{ 
                usrId: component.get("v.usrId"),
                usrName: component.get("v.usrName"),
                showEdit: component.get("v.showEdit"),
                regionName: component.get("v.regionName")
            }
        });
        evt.fire();
		
	},
    
    refreshPage : function(component, event, helper) {
        window.location.reload();
    }
})