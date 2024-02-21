({
    myAction : function(component, event, helper) {
        						//get phys
                                var action1 = component.get("c.getAllPhysAndRgnByHospAccId");
                                action1.setParams({
                                    'hospAccId' : ''+component.get("v.hospitalId")
                                });
                                action1.setCallback(this, function(response) {
                                    
                                    var state = response.getState();
                                    if (component.isValid() && state === "SUCCESS") {
                                        component.set("v.allPhysiciansLst", response.getReturnValue().physicians);
                                        component.set("{!v.isLoading}", false);
                                    } else {
                                        component.set("v.allPhysiciansLst", "");
                                        component.set("{!v.isLoading}", false);
                                        console.log("Failed with state: " + state);
                                    }
                                });
                                
                                $A.enqueueAction(action1);
    },
    
    setChangedPhy : function(component, event, helper) {
       component.set("v.newPhyId", component.get("v.physicianId")); 
    },
    
    confirmEditAcceptedReq : function(component, event, helper) {
        component.set("{!v.isLoading}", true);
        
        component.set("v.editAcceptedReqObj.Id", component.get("v.acceptedReqId")); 
        component.set("v.editAcceptedReqObj.Case_Date__c", component.get("v.caseDate"));
        component.set("v.editAcceptedReqObj.Hospital__c", component.get("v.hospitalId"));
        component.set("v.editAcceptedReqObj.Physician__c", component.get("v.newPhyId"));
        component.set("v.editAcceptedReqObj.Case_Type__c", component.get("v.caseType"));
        component.set("v.editAcceptedReqObj.Case_Initiator__c", component.get("v.caseInitID"));
        component.set("v.editAcceptedReqObj.Status__c", component.get("v.status"));
        component.set("v.editAcceptedReqObj.Proctor__c", component.get("v.proctorId"));
        component.set("v.editAcceptedReqObj.Region__c", component.get("v.region"));
        component.set("v.editAcceptedReqObj.Notes__c", component.get("v.notes"));
        component.set("v.editAcceptedReqObj.Estimated_of_Cases__c", component.get("v.numOfCases"));
        
        console.log('resp-->'+JSON.stringify(component.get("v.editAcceptedReqObj")));
        
        var action = component.get("c.updateMANTAAcceptedReq");
        action.setParams({
            editAcceptedReqObj : JSON.stringify(component.get("v.editAcceptedReqObj"))
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                if(response.getReturnValue()){
                    component.set("{!v.isLoading}", false);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        message: 'Confirm Proctorship Request '+ status +' saved successfully!',
                        type: 'success'
                    });
                    toastEvent.fire();
                    
                    var evt = $A.get("e.force:navigateToComponent");
                    evt.setParams({
                        componentDef: "c:TFX_MANTA_Accepted_Reqs_Comp",
                        componentAttributes :
                        {
                            showEdit : component.get("v.showEdit")
                        }
                    });
                    evt.fire();  
                }
                else{
                    component.set("{!v.isLoading}", false);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        message: 'Update Failed...Please try again.',
                        type: 'error'
                    });
                    toastEvent.fire();
                }
                
                
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
    
    navigateToTFX_MANTA_Accepted_Reqs_Comp : function(component, event, helper) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:TFX_MANTA_Accepted_Reqs_Comp",
            componentAttributes :
            {
                showEdit : component.get("v.showEdit")
            }
        });
        evt.fire();
    }
})