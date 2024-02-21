({
    myAction : function(component, event, helper) {
        
        var action = component.get('c.getSalesRepAccDetailsWithSales');
        
        var surveykey = component.get("v.pageReference.state.c__surveykey");
        
        action.setParams({"surveykey" : surveykey});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                component.set("v.cxSalesRepAccountList", response.getReturnValue());
                component.set('v.mycols', [
                    {label: 'Customer Code', fieldName: 'custCode', type: 'text'},
                    {label: 'Customer Name', fieldName: 'accName', type: 'text'},
                    {label: 'Business Unit', fieldName: 'businessUnit', type: 'text'},
                    {label: 'Yes', fieldName: 'yesChk', type: 'boolean', editable: true},
                    {label: 'No', fieldName: 'noChk', type: 'boolean', editable: true},
                    {label: 'If no, then do you know who?', fieldName: 'if_no_then_do_you_know_who', type: 'text', editable: true}
                ]);
                
            }
        });
        $A.enqueueAction(action);
        
    },
    
    saveSalesRepFeedback : function(component, event, helper) {
        
        var draftvals = event.getParam('draftValues');
        
        for(var i in draftvals){
            if(draftvals[i].yesChk === true && draftvals[i].noChk === true){
                
                component.set('v.errors', {
                    
                    table: {
                        title: 'Your entry cannot be saved.',
                        messages: [
                            'Pleae check mark either Yes or No'
                        ]
                    }
                });
                
                
            }
            else{
                var strJSONcxSalesRepAccountList = JSON.stringify(component.get("v.cxSalesRepAccountList"));
                var draftValues = JSON.stringify(event.getParam('draftValues'));
                var action = component.get("c.saveSalesRepFeedbackDetails");
                action.setParams({"updSalRepAccLst" : draftValues});
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    component.set("v.cxSalesRepAccountList", response.getReturnValue());
                    $A.get('e.force:refreshView').fire(); 
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        message: 'Your feedback is saved, Thank you!',
                        type: 'success'
                    });
                    toastEvent.fire();
                });
                $A.enqueueAction(action);   
            }
        }
        
    }
})