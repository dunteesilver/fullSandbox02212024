({
    myAction : function(component, event, helper) {
        
        var haccId = ''+component.get("v.selectedId"); 
        var regionName = component.get("v.regionName");
        
        if(haccId.length === 0){
            haccId += 'All';
        }
        if(regionName.length === 0){
            regionName += 'All';
        }
        
        var getDatesAction = component.get("c.getDfltValsForDateFilters");
        getDatesAction.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                component.set("v.fromDate", response.getReturnValue().fromDate);
                component.set("v.toDate", response.getReturnValue().toDate);
                //inner function excutes to get archived cases from date range resp from outer function
                var action = component.get("c.getAllOrSelHospArchivedReqs");
                action.setParams({'haccId' : haccId, 
                                  'regionName' : regionName, 
                                  'fromDate' : component.get("v.fromDate"),
                                  'toDate' : component.get("v.toDate"),
                                 });
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (component.isValid() && state === "SUCCESS") {
                        component.set("v.allArchivedReqsLst", response.getReturnValue());
                        component.set("{!v.isLoading}", false); 
                    } else {
                        console.log("Failed with state: " + state);
                    }
                });
                $A.enqueueAction(action);
            } else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(getDatesAction);
    },
    
    srchArchivedReqsForHosp : function (component, event, helper) {
		component.set("{!v.isLoading}", true);
        var haccId = ''+component.get("v.selectedId"); 
        var regionName = ''+component.get("v.regionName"); 
        var fromDate = ''+component.get("v.fromDate"); 
        var toDate = ''+component.get("v.toDate"); 
       
        if(haccId.length === 0){
            haccId += 'All';
        }
        if(regionName.length === 0){
            regionName += 'All';
        }
       
        var action = component.get("c.getAllOrSelHospArchivedReqs");
        action.setParams({
            'haccId' : haccId,
            'regionName' : regionName,
            'fromDate' : fromDate,
            'toDate' : toDate
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {                
                component.set("v.allArchivedReqsLst", response.getReturnValue());
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
    }
})