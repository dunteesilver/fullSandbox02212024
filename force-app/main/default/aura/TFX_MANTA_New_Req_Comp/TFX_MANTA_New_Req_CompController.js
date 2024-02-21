({
    myAction : function(component, event, helper) {
        component.set("{!v.isLoading}", false);
        component.set("v.newReqObj.Case_Date__c", component.get("v.caseDate"));
    },
    
    saveNewReq : function(component, event, helper) {
        
        component.set("{!v.isLoading}", true);
        
        var hospName = component.get("v.hospitalAccObj.Hospital__c");
        var caseDate = component.get("v.newReqObj.Case_Date__c");
        var physician = component.get("v.hospitalAccObj.Physician__c");
        var estCases = component.get("v.newReqObj.Estimated_of_Cases__c");
        var caseType = component.get("v.newReqObj.Case_Type__c");
        
        if( hospName === undefined
           || caseDate === null
           || physician === undefined
           || estCases === undefined
           || caseType === undefined
           || hospName === ''
           || caseDate === ''
           || physician === ''
           || estCases === ''
           || caseType === ''
          )
            
            
            
            {
               
                component.set("{!v.isLoading}", false);
                var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        
                        message: 'We hit a snag. These required fields must be filled: Hospital, Case Date, Physician, Estimated # of Cases and Case Type',
                        type: 'error'
                    });
                    toastEvent.fire();
            }   
        
        else{
            component.set("{!v.isLoading}", true);
            component.set("v.newReqObj.Case_Initiator__c", component.get("v.usrId"));
            component.set("v.newReqObj.Hospital__c", component.get("v.hospitalAccObj.Hospital__c"));
            component.set("v.newReqObj.Physician__c", component.get("v.hospitalAccObj.Physician__c"));
            
            var newReqObj = JSON.stringify(component.get("v.newReqObj"));
            
            var action = component.get("c.saveMANTANewRequest");
            action.setParams({
                newReqObj: newReqObj
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (component.isValid() && state === "SUCCESS") {
console.log('resp new-->', response.getReturnValue());                    
                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        
                        message: 'New Proctorship Request '+ status +' saved successfully!',
                        type: 'success'
                    });
                    toastEvent.fire();
                    
                   var evt = $A.get("e.force:navigateToComponent");
                    evt.setParams({
                        componentDef: "c:TFX_MANTA_Open_Reqs_Comp",
                        componentAttributes: {
                            usrId: component.get("v.usrId"),
                            usrName: component.get("v.usrName"),
                            showEdit: component.get("v.showEdit"),
                            selectedId: component.get("v.hospitalAccObj.Hospital__c")
                        }
                    });
                    evt.fire();
                    
                } else {
                    console.log("Failed with state: " + state);
                }
            });
            
            $A.enqueueAction(action);
        }   
    },
    
    navigateToTFX_MANTA_Comp : function(component, event, helper) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:TFX_MANTA_Comp"
            //componentAttributes :{ }
        });
        evt.fire();
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
        
    },
    
    clearForm : function(component, event, helper) {
           $A.get('e.force:refreshView').fire();  
    }
})