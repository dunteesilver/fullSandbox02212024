({
    myAction : function(component, event, helper) {
        
        component.set('v.mycolumn', [
            {label: 'Name', fieldName: 'contactName', type: 'text'},
            {label: 'Role', fieldName: 'role', type: 'Text'},
            {label: 'Title', fieldName: 'title', type: 'text'},
			{label: 'Email', fieldName: 'email', type: 'text'}            
        ]);
        
        var action = component.get("c.getWGinfoForRecID");
        action.setParams({
            'wgRecId' : ''+component.get("v.recordId")
        });
        component.set("{!v.isLoading}", true);
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                component.set("v.ocrObjLst", response.getReturnValue())
                console.log("resp-->", response.getReturnValue());
                component.set("{!v.isLoading}", false);
            } else {
                component.set("{!v.isLoading}", false);
                console.log("Failed with state: " + state);
            }
        });
        
        $A.enqueueAction(action);
        
    },
    

 // common reusable function for toggle sections
    toggleSection : function(component, event, helper) {
        // dynamically get aura:id name from 'data-auraId' attribute
        var sectionAuraId = event.target.getAttribute("data-auraId");
        // get section Div element using aura:id
        var sectionDiv = component.find(sectionAuraId).getElement();
        /* The search() method searches for 'slds-is-open' class, and returns the position of the match.
         * This method returns -1 if no match is found.
        */
        var sectionState = sectionDiv.getAttribute('class').search('slds-is-open'); 
        
        // -1 if 'slds-is-open' class is missing...then set 'slds-is-open' class else set slds-is-close class to element
        if(sectionState == -1){
            sectionDiv.setAttribute('class' , 'slds-section slds-is-open');
        }else{
            sectionDiv.setAttribute('class' , 'slds-section slds-is-close');
        }
    }
    
})