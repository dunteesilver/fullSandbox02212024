({
	myAction: function(component, event, helper) {
        component.set("{!v.isLoading}", true);
        var coachingID = component.get("v.recordId");
        var action = component.get("c.getCoachingDetail_v2");
        action.setParams({
            coachingID: coachingID
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                component.set("v.newCoaching", response.getReturnValue());
                component.set("v.status", response.getReturnValue().Name);
//alert('v.newCoaching***'+response.getReturnValue().isDisableForm__c);

                var action1 = component.get("c.getUserInfoForCoachingForm");
                
                action1.setCallback(this, function(response) {
                    var state = response.getState();
                    if (component.isValid() && state === "SUCCESS") {
                        
                        component.set("v.formVisibilityWrapperObj", response.getReturnValue());
                        component.set("{!v.isLoading}", false);
//console.log("isDirDisable=="+response.getReturnValue().isDirDisable);
//console.log("isRSMDisable=="+response.getReturnValue().isRSMDisable);
//console.log("isRepDisable=="+response.getReturnValue().isRepDisable);
//console.log("notifyDirBool=="+response.getReturnValue().notifyDirBool);
                        
                        
                    } else {
                        console.log("Failed with state: " + state);
                    }
                });
                $A.enqueueAction(action1);
                
                
                
            } else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
    },
    
    printPage: function(component, event, helper) {
        window.print();
    },
    
    notifyDirector: function(component, event, helper) {

         component.set("{!v.isLoading}", true);
        var coachingID = component.get("v.recordId");
        var action = component.get("c.getDirEmailAndNotify");
        action.setParams({
            coachingID: coachingID
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                component.set("v.dirEmail", response.getReturnValue())  
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    message: 'Email notification sent to '+ component.get("v.dirEmail") +' for further review',
                    type: 'success'
                });
                toastEvent.fire();
                //component.set("{!v.notifyDirectorDisable}", true);
                component.set("{!v.isLoading}", false);
                
            } else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
        
    },
    
     saveCoachingDetails: function(component, event, helper) {
        component.set("{!v.isLoading}", true);
        var coachingID = component.get("v.recordId");
        var newCoaching = component.get("v.newCoaching");
        
        var action = component.get("c.saveCoachingDetail_v2");
        action.setParams({
            coachingID: coachingID,
            newCoaching: newCoaching
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                
                component.set("{!v.isLoading}", false);

                var status = component.get("v.status"); 
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    
                    message: 'Coaching form '+ status +' saved successfully!',
                    type: 'success'
                });
                toastEvent.fire();
                
            } else {
                console.log("Failed with state: " + state);
            }
        });
        
        $A.enqueueAction(action);
        
    },
    
    calRepTotOveProf: function(component, event, helper) {
        var Bal_Seller_Rep_Prof_Lvl_v2 = component.get(
            "v.newCoaching.Bal_Seller_Rep_Prof_Lvl_v2__c"
        );
        var Enge_Discvr_Mag_Rep_Prof_Lvl_v2 = component.get(
            "v.newCoaching.Enge_Discvr_Mag_Rep_Prof_Lvl_v2__c"
        );
        var Pos_Sols_Rep_Prof_Lvl_v2 = component.get(
            "v.newCoaching.Pos_Sols_Rep_Prof_Lvl_v2__c"
        );
        var Gain_Commitment_Rep_Prof_Lvl_v2 = component.get(
            "v.newCoaching.Gain_Commitment_Rep_Prof_Lvl_v2__c"
        );
        
        var Total_Rep_Ove_Prof_Lvl_v2 = helper.calculateOverallProf4Params(
            Bal_Seller_Rep_Prof_Lvl_v2,
            Enge_Discvr_Mag_Rep_Prof_Lvl_v2,
            Pos_Sols_Rep_Prof_Lvl_v2,
            Gain_Commitment_Rep_Prof_Lvl_v2
        );
        
        component.set(
            "v.newCoaching.Total_Rep_Ove_Prof_Lvl_v2__c",
            Total_Rep_Ove_Prof_Lvl_v2
        );
    },
    
    calRSMTotOveProf: function(component, event, helper) {
        var Bal_Seller_RSM_Prof_Lvl_v2 = component.get(
            "v.newCoaching.Bal_Seller_RSM_Prof_Lvl_v2__c"
        );
        var Enge_Discvr_Mag_RSM_Prof_Lvl_v2 = component.get(
            "v.newCoaching.Enge_Discvr_Mag_RSM_Prof_Lvl_v2__c"
        );
        var Pos_Sols_RSM_Prof_Lvl_v2 = component.get(
            "v.newCoaching.Pos_Sols_RSM_Prof_Lvl_v2__c"
        );
        var Gain_Commitment_RSM_Prof_Lvl_v2 = component.get(
            "v.newCoaching.Gain_Commitment_RSM_Prof_Lvl_v2__c"
        );
        
        var Total_RSM_Ove_Prof_Lvl_v2 = helper.calculateOverallProf4Params(
            Bal_Seller_RSM_Prof_Lvl_v2,
            Enge_Discvr_Mag_RSM_Prof_Lvl_v2,
            Pos_Sols_RSM_Prof_Lvl_v2,
            Gain_Commitment_RSM_Prof_Lvl_v2
        );
        
        component.set(
            "v.newCoaching.Total_RSM_Ove_Prof_Lvl_v2__c",
            Total_RSM_Ove_Prof_Lvl_v2
        );
    }
})