({
    myAction : function(component, event, helper) {
	component.set("{!v.isLoading}", false);  
    },
    
    editCaseDataById : function(component, event, helper) {
        
        var editRecordEvent = $A.get("e.force:editRecord");
        editRecordEvent.setParams({
            "entityApiName": "MANTA_Case_Data__c"
            ,
            "recordId": component.get("v.caseDataObj.Id")
        });
        editRecordEvent.fire();
    },
    
    sendCaseDataToLoggedInUser : function(component, event, helper) {
        
        component.set("{!v.isLoading}", true);
    
        var emailCaseDataObj = JSON.stringify(component.get("v.caseDataObj"));
        var usrId = ''+component.get("{!v.usrId}");
        
        var action = component.get("c.emailCaseDataToUser");
        action.setParams({'emailCaseDataObj' : emailCaseDataObj, 'usrId' : usrId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                
                component.set("{!v.isLoading}", false);
                
                var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        message: 'Email sent successfully!',
                        type: 'success'
                    });
                    toastEvent.fire();
                 
            } else {
                console.log("Failed with state: " + state);
            }
        });
        
        $A.enqueueAction(action);
        
    }
    
})