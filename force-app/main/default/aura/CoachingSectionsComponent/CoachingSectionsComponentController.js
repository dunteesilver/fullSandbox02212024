({ 
    myAction: function(component, event, helper) {
        
        var coachingID = component.get("v.recordId");
        var action = component.get("c.getCoachingDetail");
        action.setParams({
            coachingID: coachingID
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                component.set("v.newCoaching", response.getReturnValue());
                component.set("v.status", response.getReturnValue().Name);
                //alert('v.newCoaching***'+response.getReturnValue().isDisableForm__c);
                //
                //
                var action1 = component.get("c.getUserInfoForCoachingForm");
                
                action1.setCallback(this, function(response) {
                    var state = response.getState();
                    if (component.isValid() && state === "SUCCESS") {
                        component.set("v.formVisibilityWrapperObj", response.getReturnValue());
                        console.log("isDirDisable=="+response.getReturnValue().isDirDisable);
                        console.log("isRSMDisable=="+response.getReturnValue().isRSMDisable);
                        console.log("isRepDisable=="+response.getReturnValue().isRepDisable);
                        
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
                
            } else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
        
    },
    
    // function automatic called by aura:waiting event  
    showSpinner: function(component, event, helper) {
        // make Spinner attribute true for displaying loading spinner 
        component.set("v.spinner", true); 
    },
    
    // function automatic called by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
        // make Spinner attribute to false for hiding loading spinner    
        component.set("v.spinner", false);
    },
    
    saveCoachingDetails: function(component, event, helper) {
        component.set("v.spinner", true);
        var coachingID = component.get("v.recordId");
        var newCoaching = component.get("v.newCoaching");
        
        var action = component.get("c.saveCoachingDetail");
        action.setParams({
            coachingID: coachingID,
            newCoaching: newCoaching
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                
                component.set("v.spinner", false);
                //component.set("v.showSuccess", true);
                //
                var status = component.get("v.status");
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    
                    message: 'Coaching form '+ status +' saved successfully!',
                    type: 'success'
                });
                toastEvent.fire();
                
            } else {
                console.log("Failed with state while saving: ", response);
            }
        });
        
        $A.enqueueAction(action);
        
    },
    
    calBalSellRepOveProf: function(component, event, helper) {
        var BS_Pre_Call_Plan_RepProfLvl = component.get(
            "v.newCoaching.BS_Pre_Call_Plan_RepProfLvl__c"
        );
        var BS_Researches_Acc_RepProfLvl = component.get(
            "v.newCoaching.BS_Researches_Acc_RepProfLvl__c"
        );
        var BS_Researches_Sales_Data_RepProfLvl = component.get(
            "v.newCoaching.BS_Researches_Sales_Data_RepProfLvl__c"
        );
        var BS_Wri_Actn_Pri_Call_Objs_RepProfLvl = component.get(
            "v.newCoaching.BS_Wri_Actn_Pri_Call_Objs_RepProfLvl__c"
        );
        var BS_Wri_Actn_Sec_FallBk_Objs_RepProfLvl = component.get(
            "v.newCoaching.BS_Wri_Actn_Sec_FallBk_Objs_RepProfLvl__c"
        );
        
        var BS_Rep_Ove_Prof_Lvl = helper.calculateOverallProf5Params(
            BS_Pre_Call_Plan_RepProfLvl,
            BS_Researches_Acc_RepProfLvl,
            BS_Researches_Sales_Data_RepProfLvl,
            BS_Wri_Actn_Pri_Call_Objs_RepProfLvl,
            BS_Wri_Actn_Sec_FallBk_Objs_RepProfLvl
        );
        
        component.set("v.newCoaching.BS_Rep_Ove_Prof_Lvl__c", BS_Rep_Ove_Prof_Lvl);
        
        var totFunc = component.get("c.calRepTotOveProf");
        $A.enqueueAction(totFunc);
    },
    
    calBalSellRSMOveProf: function(component, event, helper) {
        var BS_Pre_Call_Plan_RSMProfLvl = component.get(
            "v.newCoaching.BS_Pre_Call_Plan_RSMProfLvl__c"
        );
        var BS_Researches_Acc_RSMProfLvl = component.get(
            "v.newCoaching.BS_Researches_Acc_RSMProfLvl__c"
        );
        var BS_Researches_Sales_Data_RSMProfLvl = component.get(
            "v.newCoaching.BS_Researches_Sales_Data_RSMProfLvl__c"
        );
        var BS_Wri_Actn_Pri_Call_Objs_RSMProfLvl = component.get(
            "v.newCoaching.BS_Wri_Actn_Pri_Call_Objs_RSMProfLvl__c"
        );
        var BS_Wri_Actn_Sec_FallBk_Objs_RSMProfLvl = component.get(
            "v.newCoaching.BS_Wri_Actn_Sec_FallBk_Objs_RSMProfLvl__c"
        );
        
        var BS_RSM_Ove_Prof_Lvl = helper.calculateOverallProf5Params(
            BS_Pre_Call_Plan_RSMProfLvl,
            BS_Researches_Acc_RSMProfLvl,
            BS_Researches_Sales_Data_RSMProfLvl,
            BS_Wri_Actn_Pri_Call_Objs_RSMProfLvl,
            BS_Wri_Actn_Sec_FallBk_Objs_RSMProfLvl
        );
        
        component.set("v.newCoaching.BS_RSM_Ove_Prof_Lvl__c", BS_RSM_Ove_Prof_Lvl);
        
        var totFunc = component.get("c.calRSMTotOveProf");
        $A.enqueueAction(totFunc);
    },
    
    calDiscNeedsRepOveProf: function(component, event, helper) {
        var Discover_Prep_High_RepProfLvl = component.get(
            "v.newCoaching.Discover_Prep_High_RepProfLvl__c"
        );
        var Discover_4P_Que_RepProfLvl = component.get(
            "v.newCoaching.Discover_4P_Que_RepProfLvl__c"
        );
        
        var Discover_Rep_Ove_Prof_Lvl = helper.calculateOverallProf2Params(
            Discover_Prep_High_RepProfLvl,
            Discover_4P_Que_RepProfLvl
        );
        
        component.set(
            "v.newCoaching.Discover_Rep_Ove_Prof_Lvl__c",
            Discover_Rep_Ove_Prof_Lvl
        );
        
        var totFunc = component.get("c.calRepTotOveProf");
        $A.enqueueAction(totFunc);
    },
    
    calDiscNeedsRSMOveProf: function(component, event, helper) {
        var Discover_Prep_High_RSMProfLvl = component.get(
            "v.newCoaching.Discover_Prep_High_RSMProfLvl__c"
        );
        var Discover_4P_Que_RSMProfLvl = component.get(
            "v.newCoaching.Discover_4P_Que_RSMProfLvl__c"
        );
        
        var Discover_RSM_Ove_Prof_Lvl = helper.calculateOverallProf2Params(
            Discover_Prep_High_RSMProfLvl,
            Discover_4P_Que_RSMProfLvl
        );
        
        component.set(
            "v.newCoaching.Discover_RSM_Ove_Prof_Lvl__c",
            Discover_RSM_Ove_Prof_Lvl
        );
        
        var totFunc = component.get("c.calRSMTotOveProf");
        $A.enqueueAction(totFunc);
    },
    
    calPosSolsRepOveProf: function(component, event, helper) {
        var Pos_Sols_RepProfLvl_1 = component.get(
            "v.newCoaching.Pos_Sols_RepProfLvl_1__c"
        );
        var Pos_Sols_RepProfLvl_2 = component.get(
            "v.newCoaching.Pos_Sols_RepProfLvl_2__c"
        );
        
        var Pos_Sols_Rep_Ove_Prof_Lvl = helper.calculateOverallProf2Params(
            Pos_Sols_RepProfLvl_1,
            Pos_Sols_RepProfLvl_2
        );
        
        component.set(
            "v.newCoaching.Pos_Sols_Rep_Ove_Prof_Lvl__c",
            Pos_Sols_Rep_Ove_Prof_Lvl
        );
        
        var totFunc = component.get("c.calRepTotOveProf");
        $A.enqueueAction(totFunc);
    },
    
    calPosSolsRSMOveProf: function(component, event, helper) {
        var Pos_Sols_RSMProfLvl_1 = component.get(
            "v.newCoaching.Pos_Sols_RSMProfLvl_1__c"
        );
        var Pos_Sols_RSMProfLvl_2 = component.get(
            "v.newCoaching.Pos_Sols_RSMProfLvl_2__c"
        );
        
        var Pos_Sols_RSM_Ove_Prof_Lvl = helper.calculateOverallProf2Params(
            Pos_Sols_RSMProfLvl_1,
            Pos_Sols_RSMProfLvl_2
        );
        
        component.set(
            "v.newCoaching.Pos_Sols_RSM_Ove_Prof_Lvl__c",
            Pos_Sols_RSM_Ove_Prof_Lvl
        );
        
        var totFunc = component.get("c.calRSMTotOveProf");
        $A.enqueueAction(totFunc);
    },
    
    calGainCmtRepOveProf: function(component, event, helper) {
        var Gain_Commitment_RepProfLvl_1 = component.get(
            "v.newCoaching.Gain_Commitment_RepProfLvl_1__c"
        );
        var Gain_Commitment_RepProfLvl_2 = component.get(
            "v.newCoaching.Gain_Commitment_RepProfLvl_2__c"
        );
        var Gain_Commitment_RepProfLvl_3 = component.get(
            "v.newCoaching.Gain_Commitment_RepProfLvl_3__c"
        );
        
        var Gain_Commitment_Rep_Ove_Prof_Lvl = helper.calculateOverallProf3Params(
            Gain_Commitment_RepProfLvl_1,
            Gain_Commitment_RepProfLvl_2,
            Gain_Commitment_RepProfLvl_3
        );
        
        component.set(
            "v.newCoaching.Gain_Commitment_Rep_Ove_Prof_Lvl__c",
            Gain_Commitment_Rep_Ove_Prof_Lvl
        );
        
        var totFunc = component.get("c.calRepTotOveProf");
        $A.enqueueAction(totFunc);
    },
    
    calGainCmtRSMOveProf: function(component, event, helper) {
        var Gain_Commitment_RSMProfLvl_1 = component.get(
            "v.newCoaching.Gain_Commitment_RSMProfLvl_1__c"
        );
        var Gain_Commitment_RSMProfLvl_2 = component.get(
            "v.newCoaching.Gain_Commitment_RSMProfLvl_2__c"
        );
        var Gain_Commitment_RSMProfLvl_3 = component.get(
            "v.newCoaching.Gain_Commitment_RSMProfLvl_3__c"
        );
        
        var Gain_Commitment_RSM_Ove_Prof_Lvl = helper.calculateOverallProf3Params(
            Gain_Commitment_RSMProfLvl_1,
            Gain_Commitment_RSMProfLvl_2,
            Gain_Commitment_RSMProfLvl_3
        );
        
        component.set(
            "v.newCoaching.Gain_Commitment_RSM_Ove_Prof_Lvl__c",
            Gain_Commitment_RSM_Ove_Prof_Lvl
        );
        
        var totFunc = component.get("c.calRSMTotOveProf");
        $A.enqueueAction(totFunc);
    },
    
    calRepTotOveProf: function(component, event, helper) {
        var BS_Rep_Ove_Prof_Lvl = component.get(
            "v.newCoaching.BS_Rep_Ove_Prof_Lvl__c"
        );
        var Engage_Insight_RepProfLvl = component.get(
            "v.newCoaching.Engage_Insight_RepProfLvl__c"
        );
        var Discover_Rep_Ove_Prof_Lvl = component.get(
            "v.newCoaching.Discover_Rep_Ove_Prof_Lvl__c"
        );
        var Magnify_Needs_RepProfLvl = component.get(
            "v.newCoaching.Magnify_Needs_RepProfLvl__c"
        );
        var Pos_Sols_Rep_Ove_Prof_Lvl = component.get(
            "v.newCoaching.Pos_Sols_Rep_Ove_Prof_Lvl__c"
        );
        var Gain_Commitment_Rep_Ove_Prof_Lvl = component.get(
            "v.newCoaching.Gain_Commitment_Rep_Ove_Prof_Lvl__c"
        );
        
        var Total_Rep_Ove_Prof_Lvl = helper.calculateOverallProf6Params(
            BS_Rep_Ove_Prof_Lvl,
            Engage_Insight_RepProfLvl,
            Discover_Rep_Ove_Prof_Lvl,
            Magnify_Needs_RepProfLvl,
            Pos_Sols_Rep_Ove_Prof_Lvl,
            Gain_Commitment_Rep_Ove_Prof_Lvl
        );
        
        component.set(
            "v.newCoaching.Total_Rep_Ove_Prof_Lvl__c",
            Total_Rep_Ove_Prof_Lvl
        );
    },
    
    calRSMTotOveProf: function(component, event, helper) {
        var BS_RSM_Ove_Prof_Lvl = component.get(
            "v.newCoaching.BS_RSM_Ove_Prof_Lvl__c"
        );
        var Engage_Insight_RSMProfLvl = component.get(
            "v.newCoaching.Engage_Insight_RSMProfLvl__c"
        );
        var Discover_RSM_Ove_Prof_Lvl = component.get(
            "v.newCoaching.Discover_RSM_Ove_Prof_Lvl__c"
        );
        var Magnify_Needs_RSMProfLvl = component.get(
            "v.newCoaching.Magnify_Needs_RSMProfLvl__c"
        );
        var Pos_Sols_RSM_Ove_Prof_Lvl = component.get(
            "v.newCoaching.Pos_Sols_RSM_Ove_Prof_Lvl__c"
        );
        var Gain_Commitment_RSM_Ove_Prof_Lvl = component.get(
            "v.newCoaching.Gain_Commitment_RSM_Ove_Prof_Lvl__c"
        );
        
        var Total_RSM_Ove_Prof_Lvl = helper.calculateOverallProf6Params(
            BS_RSM_Ove_Prof_Lvl,
            Engage_Insight_RSMProfLvl,
            Discover_RSM_Ove_Prof_Lvl,
            Magnify_Needs_RSMProfLvl,
            Pos_Sols_RSM_Ove_Prof_Lvl,
            Gain_Commitment_RSM_Ove_Prof_Lvl
        );
        
        component.set(
            "v.newCoaching.Total_RSM_Ove_Prof_Lvl__c",
            Total_RSM_Ove_Prof_Lvl
        );
    }
});