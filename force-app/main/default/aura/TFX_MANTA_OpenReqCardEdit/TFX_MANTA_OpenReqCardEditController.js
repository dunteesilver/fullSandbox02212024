({
    myAction : function(component, event, helper) {
        component.set("{!v.isLoading}", false);         
    },
    
    confirmEditOpenReq : function(component, event, helper) {
        component.set("{!v.isLoading}", true);
        component.set("v.editOpenReqObj.Id", component.get("v.openReqId")); 
        component.set("v.editOpenReqObj.Case_Date__c", component.get("v.caseDate"));
        component.set("v.editOpenReqObj.Hospital__c", component.get("v.hospitalId"));
        component.set("v.editOpenReqObj.Physician__c", component.get("v.physicianId"));
        component.set("v.editOpenReqObj.Physician_NPI_Number__c", component.get("v.physicianNPINum"));
        component.set("v.editOpenReqObj.Case_Type__c", component.get("v.caseType"));
        component.set("v.editOpenReqObj.Estimated_of_Cases__c", component.get("v.numOfCases"));
        component.set("v.editOpenReqObj.Case_Initiator__c", component.get("v.caseInitID"));
        component.set("v.editOpenReqObj.Notes__c", component.get("v.notes"));
        component.set("v.editOpenReqObj.Status__c", component.get("v.status"));
        component.set("v.editOpenReqObj.Proctor__c", component.get("v.proctor"));
        component.set("v.editOpenReqObj.Region__c", component.get("v.region"));       
        var status = component.get("v.status");
        var proctor = component.get("v.proctor");
        
        var action = component.get("c.updateMANTAOpenReq");
        action.setParams({
            editOpenReqObj : JSON.stringify(component.get("v.editOpenReqObj"))
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
                    
                    if(status === 'No Trainer Needed' || status === 'Open (Not Accepted)'){
                        var evt = $A.get("e.force:navigateToComponent");
                        evt.setParams({
                            componentDef: "c:TFX_MANTA_Open_Reqs_Comp",
                            componentAttributes :
                            {
                                usrId: component.get("v.usrId"),
                                usrName: component.get("v.usrName"),
                                showEdit: component.get("v.showEdit"),
                                selectedId: component.get("v.hospitalId")
                            }
                        });
                        evt.fire();
                    }
                    else{
                        var evt = $A.get("e.force:navigateToComponent");
                        evt.setParams({
                            componentDef: "c:TFX_MANTA_Accepted_Reqs_Comp",
                            componentAttributes :
                            {
                                usrId: component.get("v.usrId"),
                                usrName: component.get("v.usrName"),
                                showEdit: component.get("v.showEdit"),
                                selectedId: component.get("v.hospitalId")
                            }
                        });
                        evt.fire(); 
                        
                    }
                    
                }
                else{
                    component.set("{!v.isLoading}", false);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        message: 'Trainer does not exist. Please try adding Trainer from Setup or choose another Trainer',
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
    
    navigateToTFX_MANTA_Open_Reqs_Comp : function(component, event, helper) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:TFX_MANTA_Open_Reqs_Comp",
            componentAttributes :
            {
                showEdit : component.get("v.showEdit")
            }
        });
        evt.fire();
    }
})