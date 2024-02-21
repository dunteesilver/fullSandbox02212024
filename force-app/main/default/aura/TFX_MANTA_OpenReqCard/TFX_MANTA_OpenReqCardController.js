({
    myAction : function(component, event, helper) {
        
    },
    
    navigateToTFX_MANTA_OpenReqCardEdit : function(component, event, helper) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:TFX_MANTA_OpenReqCardEdit",
            componentAttributes :
            {
                openReqId : component.get("v.openReqId"),
                caseDate : component.get("v.caseDate"),
                hospitalId : component.get("v.hospitalId"),
                hospital : component.get("v.hospital"),
                region : component.get("v.region"),
                physicianId : component.get("v.physicianId"),
                physician : component.get("v.physician"),
                physicianNPINum : component.get("v.physicianNPINum"),
                caseType : component.get("v.caseType"),
                numOfCases : component.get("v.numOfCases"),
                caseInitiator : component.get("v.caseInitiator"),
                caseInitID : component.get("v.caseInitID"),
                daysOpen : component.get("v.daysOpen"),
                notes : component.get("v.notes"),
                status : component.get("v.status"),
                usrId : component.get("v.usrId"),
                showEdit : component.get("v.showEdit")
            }
        });
        evt.fire();
    }
})