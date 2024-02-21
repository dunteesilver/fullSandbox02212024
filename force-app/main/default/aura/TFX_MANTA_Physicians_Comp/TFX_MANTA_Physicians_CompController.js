({
    myAction : function(component, event, helper) {
        component.set("v.isLoading", false);
    }, 
    
    navigateToTFX_MANTA_Comp : function(component, event, helper) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:TFX_MANTA_Comp"
            //componentAttributes :{ }
        });
        evt.fire();
    },
    
    createConForAcc : function(component, event, helper) {
        
        var accId = component.get("v.selectedId");
        
        var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            "entityApiName": "Contact",
            defaultFieldValues: {
                Salutation: 'Dr.',
                AccountId: accId,
                Business_Unit1__c : 'Interventional',
                Preferred_language__c : 'English (American)'
            },
                    "navigationLocation" : "LOOKUP",
                    "panelOnDestroyCallback": function(event) {
                        var evt = $A.get("e.force:navigateToComponent");
                        evt.setParams({
                            componentDef: "c:TFX_MANTA_New_Req_Comp"
                        });
                        evt.fire();
                    }
        });
        createRecordEvent.fire(); 
    },
    
    getSelHospPhysicians : function(component, event, helper) {
        
        var action = component.get("c.getAllPhysAndRgnByHospAccId");
        action.setParams({
            'hospAccId' : ''+component.get("v.selectedId")
        });
        action.setCallback(this, function(response) {
            
            component.set("{!v.isLoading}", true);
            
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                component.set("v.allPhysiciansLst", response.getReturnValue().physicians);
                component.set("{!v.isLoading}", false);
            } else {
                component.set("{!v.isLoading}", false);
                console.log("Failed with state: " + state);
            }
        });
        
        $A.enqueueAction(action);
        
    }
    
})