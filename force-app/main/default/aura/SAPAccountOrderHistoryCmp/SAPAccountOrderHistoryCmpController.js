({
	myAction : function(component, event, helper) {
		var accSfId = component.get("v.recordId");
        component.set("v.accSfId", accSfId);
	}
})