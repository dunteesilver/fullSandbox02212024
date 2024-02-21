({
	myAction : function(component, event, helper) {
        component.set("{!v.isLoading}", false);
        /*
        component.set('v.mapMarkers', [
            {
                location: {
                    Street: component.get("v.streetName"),
                    City: component.get("v.cityName"),
                    State: component.get("v.stateName"),
                    Country: component.get("v.countryName"),
                },

                title: component.get("v.hospital")
            }
        ]);
        
        component.set("{!v.isLoading}", false);
        
        var openReqId = component.get("v.openReqId");
        
        var action = component.get("c.getAllCaseDataRecsForProcId");
        action.setParams({
            'openReqId' : openReqId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                component.set("v.caseDataObjLst", response.getReturnValue());
            } else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
        */		
	},
    
     createNewCaseData : function(component, event, helper) {

       var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:TFX_MANTA_New_Case_Data_Comp",
            componentAttributes: {
                usrId: component.get("v.usrId"),
                usrName: component.get("v.usrName"),
                showEdit: component.get("v.showEdit"),
                openReqId: component.get("v.openReqId"),
                hospitalId: component.get("v.hospitalId"),
                hospital: component.get("v.hospital")
            }
        });
        evt.fire();
         
    },

    
    navigateToTFX_MANTA_AcceptedReqCardEdit : function(component, event, helper) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:TFX_MANTA_AcceptedReqCardEdit",
            componentAttributes :
            {
                acceptedReqId : component.get("v.openReqId"),
                caseDate : component.get("v.caseDate"),
                hospitalId : component.get("v.hospitalId"),
                hospital : component.get("v.hospital"),
                region : component.get("v.region"),
                physicianId : component.get("v.physicianId"),
                physician : component.get("v.physician"),
                allPhysiciansLst : component.get("v.allPhysiciansLst"),
                proctor : component.get("v.proctorName"),
                proctorId : component.get("v.proctorId"),
                caseType : component.get("v.caseType"),
                numOfCases : component.get("v.numOfCases"),
                caseInitiator : component.get("v.caseInitiator"),
                caseInitID : component.get("v.caseInitID"),
                notes : component.get("v.notes"),
                status : component.get("v.status"),
                usrId : component.get("v.usrId"),
                showEdit : component.get("v.showEdit")
            }
        });
        evt.fire();
    }



    
})