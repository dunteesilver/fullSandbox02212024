({
	getResponse : function(component, event, helper) {
        var dataMap;
		var recordId = component.get("v.recordId");
        console.log("*** recordId *** " + recordId);
        var toastEvent = $A.get('e.force:showToast');
        var urlEvent = $A.get("e.force:navigateToURL");
        var action = component.get("c.creatQuoteContactLightning");
        action.setParams({
            "cid" : recordId
        });
        action.setCallback(this, function(response){
            console.log("*** In setCallback client side *** ");
            var state = response.getState();
            dataMap = response.getReturnValue();
            console.log('*** response *** ' + dataMap.Id);
            console.log('*** stringify *** ' + JSON.stringify(dataMap));
            console.log("*** state *** " + state);
            //console.log("*** dataMap *** " + dataMap);
            //alert("Your request has been sent to SAP.  Please check your email for confirmation.");
            if (state === "SUCCESS") {
                console.log('State is SUCCESS!');
                urlEvent.setParams({
                  "url": "/"+ dataMap.Id
                });
                urlEvent.fire();
                toastEvent.setParams({
                    'title': 'Success!',
                    'type': 'success',
                    'mode': 'dismissable',
                    'message': 'Price Quote was created.'
                });
                toastEvent.fire();
                
                //$A.get('e.force:refreshView').fire();
                //component.set(response.getReturnValue());
            }
            else{
                console.log('State is ERROR!');
                toastEvent.setParams({
                    'title': 'Error!',
                    'type': 'error',
                    'mode': 'dismissable',
                    'message': 'Price Quote was NOT created.'
                });
                toastEvent.fire();
            }
            
        $A.get("e.force:closeQuickAction").fire();
        });
        //console.log('*** event *** ' + JSON.stringify(event));
        $A.enqueueAction(action);
        //$A.get('e.force:refreshView').fire();
	}//end of function
})