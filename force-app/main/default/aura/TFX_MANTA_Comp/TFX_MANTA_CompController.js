({
    myAction: function(component, event, helper) {
        var url = $A.get("$Resource.MANTA_Component_Homepage_Img");
        component.set("v.backgroundImageURL", url);
        
        var action = component.get("c.getLoggedInUser");
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (component.isValid() && state === "SUCCESS") {
                
                if (response.getReturnValue().usrIsAdmin) {
                    
                    component.set("v.showSetup", response.getReturnValue().usrIsAdmin);
                }
                component.set("v.usrId", response.getReturnValue().usrId);
                component.set("v.usrName", response.getReturnValue().usrName);
                component.set("v.showEdit", 'true');
                component.set("{!v.isLoading}", false);
                
                
            } else {
                console.log("action Failed with state: " + state);
            }
        });
        
        $A.enqueueAction(action);
        
        
    },
    
    navigateToTFX_MANTA_New_Req_Comp: function(component, event, helper) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:TFX_MANTA_New_Req_Comp",
            componentAttributes: {
                usrId: component.get("v.usrId"),
                usrName: component.get("v.usrName"),
                showEdit: component.get("v.showEdit")
            }
        });
        evt.fire();
    },
    
    navigateToTFX_MANTA_Open_Reqs_Comp: function(component, event, helper) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:TFX_MANTA_Open_Reqs_Comp",
            componentAttributes: {
                usrId: component.get("v.usrId"),
                usrName: component.get("v.usrName"),
                showEdit: component.get("v.showEdit")
            }
        });
        evt.fire();
    },
    
    navigateToTFX_MANTA_Accepted_Reqs_Comp: function(component, event, helper) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:TFX_MANTA_Accepted_Reqs_Comp",
            componentAttributes: {
                usrId: component.get("v.usrId"),
                usrName: component.get("v.usrName"),
                showEdit: component.get("v.showEdit")
            }
        });
        evt.fire();
    },
    
    navigateToTFX_MANTA_Cancelled_Reqs_Comp: function(component, event, helper) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:TFX_MANTA_Cancelled_Reqs_Comp",
            componentAttributes: {
                usrId: component.get("v.usrId"),
                usrName: component.get("v.usrName")
            }
        });
        evt.fire();
    },
    
    navigateToTFX_MANTA_Archived_Reqs_Comp: function(component, event, helper) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:TFX_MANTA_Archived_Reqs_Comp",
            componentAttributes: {
                usrId: component.get("v.usrId"),
                usrName: component.get("v.usrName"),
                showEdit: component.get("v.showEdit")
            }
        });
        evt.fire();
    },
    
    navigateToTFX_MANTA_SetupOptionsCard: function(component, event, helper) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:TFX_MANTA_SetupOptionsCard",
            componentAttributes: {
                usrId: component.get("v.usrId"),
                usrName: component.get("v.usrName"),
                showSetup: component.get("v.showSetup")
            }
        });
        evt.fire();
    },
    
    navigateToTFX_MANTA_VideosComp: function(component, event, helper) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:TFX_MANTA_VideosComp"
            /*,
            componentAttributes :{ 
                usrId : component.get("v.usrId"),
                usrName : component.get("v.usrName")
            }*/
        });
        evt.fire();
    },
    
    navigateToTFX_MANTA_CalenderComp: function(component, event, helper) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:TFX_MANTA_CalenderComp"
            ,
            componentAttributes :{ 
                usrId: component.get("v.usrId"),
                usrName: component.get("v.usrName"),
                showEdit: component.get("v.showEdit"),
                regionName: 'All'
            }
        });
        evt.fire();
    },
    
    navigateToDemoRequestForm : function(component, event, helper) {
       
        /* Salesforce case# 00028701 - navigation changed from demo request component to sample request.
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:TFX_MANTA_New_Demo_Req_Comp"
            ,
            componentAttributes :{ 
                usrId: component.get("v.usrId"),
                usrName: component.get("v.usrName"),
                showEdit: component.get("v.showEdit"),
                regionName: 'All'
            }
        });
        evt.fire();
        */
        
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/apex/Sample_Requests?gs=off"
        });
        urlEvent.fire();
        
        //window.open('/apex/Sample_Requests?gs=off','_top');

    }
    
});