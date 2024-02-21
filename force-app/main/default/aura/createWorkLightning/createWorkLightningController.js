({
	doInit : function(component, event, helper) {
        // Retrieve Case during component initialization
        helper.getCase(component, event, helper);
  	},
  	clickCreate: function(component, event, helper) {
        helper.createWork(component, event, helper);
    }
})