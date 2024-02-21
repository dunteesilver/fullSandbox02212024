({
	getCase : function(component, event, helper) {
        // Load all contact data
		var recordId = component.get("v.recordId");
        var action = component.get("c.getCase");
        console.log("*** recordId getCase*** " + recordId);
				action.setParams({
					"caseId": recordId
				});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var Case = response.getReturnValue();
                console.log("*** Case *** " + Case);
                component.set("v.Case", response.getReturnValue());
                component.set("v.Case", response.getReturnValue());
            }
            // Display toast message to indicate load status
        });
         $A.enqueueAction(action);
    },
	createWork: function(component, event, helper) {
        var recordId = component.get("v.recordId");
        var newWork = component.get("v.newWork");
        var caseObj = component.get("v.Case");
        //console.log('*** case1 *** ' + caseObj.Subject);
        //newWork.agf__Assignee__c = component.find("workOwner").get("v.value");
        newWork.agf__Subject__c = component.find("workSubject").get("v.value");
        newWork.agf__Details__c = component.find("workDetails").get("v.value");
        //newWork.agf__Type__c = component.find("workType").get("v.value");
        //var workSubject = component.find("workSubject").get("v.value");
        var toastEvent = $A.get('e.force:showToast');
        var action = component.get("c.createWorkObject");
        //console.log('*** workSubject *** '+ workSubject);
        console.log('*** recordId *** '+ recordId); 
        console.log('*** newWork *** '+ newWork); 
        action.setParams({
            "newWork": newWork, "caseObj": caseObj 
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            console.log('*** state *** '+ state); 
            var dataMap = '';
            if (component.isValid() && state === "SUCCESS") {
                dataMap = response.getReturnValue();
                if(dataMap.status == 'success'){
                    toastEvent.setParams({
                        'title': 'SUCCESS!',
                        'type': 'success',
                        'mode': 'dismissable',
                        'message': dataMap.message
                    });
                    toastEvent.fire();
                    //component.set("v.newWork", response.getReturnValue());
                }//end nested if
                else{
                    toastEvent.setParams({
                        'title': 'ERROR!',
                        'type': 'error',
                        'mode': 'dismissable',
                        'message': dataMap.message
                    });
                    toastEvent.fire();
                }//end nested else   
            }//end outter if
            else{
                toastEvent.setParams({
                    'title': 'ERROR!',
                    'type': 'error',
                    'mode': 'dismissable',
                    'message': dataMap.message
                });
                toastEvent.fire();
            }//end else
        });
        $A.enqueueAction(action);
        $A.get('e.force:refreshView').fire();
    }
})