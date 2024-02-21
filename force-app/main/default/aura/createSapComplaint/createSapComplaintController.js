({
	doInit : function(component, event, helper) {
        // Retrieve Complaint during component initialization
        helper.loadComplaint(component, event, helper);
  },

	calloutCtrl : function(component, event, helper) {
        var recordId = component.get("v.recordId");
        var Complaint = component.get("v.Complaint");
        //console.log("*** recordId *** " + recordId);
        //console.log("*** Complaint *** " + Complaint);
        helper.getResponse(component, Complaint, recordId);
  },
})