({
	myAction : function(component, event, helper) {
        window.print();
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
	}
})