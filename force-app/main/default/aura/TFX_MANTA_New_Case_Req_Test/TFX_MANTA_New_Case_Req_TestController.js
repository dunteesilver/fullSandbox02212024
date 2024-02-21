({
	myAction : function(component, event, helper) {
		  component.set("{!v.isLoading}", false);
        component.set("v.newReqObj.Case_Date__c", component.get("v.caseDate"));
	},
        getSelHospRgnAndPhys : function(component, event, helper) {
        
        var action = component.get("c.getAllPhysAndRgnByHospAccId");
        action.setParams({
            'hospAccId' : ''+component.get("v.hospitalAccObj.Hospital__c")
        });
        component.set("{!v.isLoading}", true);
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                component.set("v.allPhysiciansLst", response.getReturnValue().physicians);
                component.set("v.newReqObj.Region__c", response.getReturnValue().region[0].Region__c );
console.log('getSelHospRgnAndPhys-->', response.getReturnValue());
                component.set("{!v.isLoading}", false);
            } else {
                component.set("v.allPhysiciansLst", "");
                component.set("v.newReqObj.Region__c", "N/A");
                component.set("{!v.isLoading}", false);
                console.log("Failed with state: " + state);
            }
        });
        
        $A.enqueueAction(action);
        
    }
})