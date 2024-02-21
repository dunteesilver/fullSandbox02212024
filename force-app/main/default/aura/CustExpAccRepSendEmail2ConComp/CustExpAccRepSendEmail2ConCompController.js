({
	myAction : function(component, event, helper) {
        
        var conId = component.get("v.recordId");
        var action = component.get("c.fetchContact");
        action.setParams({"conId" : conId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            component.set("v.conObj", response.getReturnValue());
        });
        $A.enqueueAction(action); 
		
	},
    sendCXAccRepEmail : function(component, event, helper) {
        
        var conObj = component.get("v.conObj");
        var action = component.get("c.sendCXAccRepEmailTemp2Con");
        action.setParams({"conObj" : conObj});
        action.setCallback(this, function(response) {
            var state = response.getState();
            component.set("v.message", response.getReturnValue());
        });
        $A.enqueueAction(action); 
		
	}
})