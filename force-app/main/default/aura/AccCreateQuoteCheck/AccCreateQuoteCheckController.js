({
    handleRecordUpdated: function(component, event, helper) {
        var eventParams = event.getParams();
        if(eventParams.changeType === "LOADED") {
            //console.log("Record is loaded successfully.");
            var ERP = component.get("v.simpleRecord.ERP_Active__c");
            var SAP = component.get("v.simpleRecord.SAP_Sold_To__c");
            //console.log("You loaded a record in " + ERP + "|" + SAP);
            if(ERP||!SAP){
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url": "/apex/PP_Create_Contact?id="+component.get("v.recordId")
                });
                urlEvent.fire();
            }
            else{
                component.set("v.accError", true);
            }
        } else if(eventParams.changeType === "CHANGED") {
            // record is changed
        } else if(eventParams.changeType === "REMOVED") {
            // record is deleted
        } else if(eventParams.changeType === "ERROR") {
            // there’s an error while loading, saving, or deleting the record
        }
    }
})