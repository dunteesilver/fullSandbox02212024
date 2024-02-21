({
	loadComplaint : function(component, event, helper) {
        // Load all contact data
		var recordId = component.get("v.recordId");
        var action = component.get("c.getComplaint");
				action.setParams({
					"complaintId": recordId
				});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
							var Complaint = response.getReturnValue();
							//console.log("*** Complaint *** " + Complaint);
							//console.log("*** Complaint.Status__c *** " + Complaint.Status__c);
							//console.log("*** Complaint.TC__c *** " + Complaint.TC__c);
              component.set("v.Complaint", response.getReturnValue());
              component.set("v.Complaint", response.getReturnValue());
            }
            // Display toast message to indicate load status
        });
         $A.enqueueAction(action);
    },

	getResponse : function(component, Complaint, recordId) {
		console.log("*** Complaint.Status__c *** " + Complaint.Status__c);
		console.log("*** Complaint.TC__c *** " + Complaint.TC__c);
        console.log("*** Complaint.Name *** " + Complaint.Name);
        var sfNum = Complaint.Name;
		if(Complaint.Status__c === "Approved" && Complaint.TC__c !== undefined ){
			console.log("*** CREATING TOASTEVENT *** ");
			var toastEvent = $A.get('e.force:showToast');
			toastEvent.setParams({
					'title': 'Warning!',
					'type': 'warning',
					'mode': 'dismissable',
					'message': 'Your Complaint has already been "Approved" and has a "TC#".'
			});
			$A.get("e.force:closeQuickAction").fire()
			toastEvent.fire();
		}
		else{
			var toastEvent = $A.get('e.force:showToast');
			var action = component.get("c.createSapComplaintLightning");
	        action.setParams({
                "complaintIds" : recordId, "sfNum": sfNum
	        });
	        action.setCallback(this, function(response){
	            var state = response.getState();
	            var dataMap = response.getReturnValue();
	            console.log("*** state *** " + state);
	            //alert("Your request has been sent to SAP.  Please check your email for confirmation.");
	            if (state === "SUCCESS") {
	                console.log('State is SUCCESS!');
	                toastEvent.setParams({
	                    'title': 'Success!',
	                    'type': 'success',
	                    'mode': 'dismissable',
	                    'message': 'Your request has been sent to SAP.  Please check your email for confirmation.'
	                });
	                toastEvent.fire();
	                console.log(response.getReturnValue());
	                //component.set(response.getReturnValue());
	            }
	            else{
	                console.log('State is ERROR!');
	                toastEvent.setParams({
	                    'title': 'Error!',
	                    'type': 'error',
	                    'mode': 'dismissable',
	                    'message': 'Your request has been NOT sent to SAP.  Please contact SAP point person for error log.'
	                });
	                toastEvent.fire();
	            }
	        });

	        $A.enqueueAction(action);
	        $A.get("e.force:closeQuickAction").fire()
		}//end of outter else

	}//end of function
})