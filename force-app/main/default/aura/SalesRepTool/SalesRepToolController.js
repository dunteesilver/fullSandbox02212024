({
    myAction : function(component, event, helper) {
        var accSfId = component.get("v.recordId");
        component.set("v.accSfId", accSfId);
        
        var action = component.get("c.getProductsDetailsInternal");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                console.log("response of products: ", response.getReturnValue());
                component.set("v.productsLst", response.getReturnValue());  
                component.set("{!v.isLoading}", false);
            } else {
                console.log("Failed with state: " + state);
                var errors = action.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        alert(errors[0].message);
                        component.set("{!v.isLoading}", false);
                    }
                }
            }
        });
        $A.enqueueAction(action);
    },
    getProdArea : function(component, event, helper) {
        component.set("{!v.isLoading}", true);
        var action = component.get("c.getProductAreaVals");
        action.setParams({
            prodCatVal : event.getSource().get("v.value")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                console.log("response of products area: ", response.getReturnValue());
                component.set("v.productsAreaLst", response.getReturnValue()); 
                component.set("v.prodAreaVal", response.getReturnValue()[0]);
                component.set("{!v.isLoading}", false);
            } else {
                console.log("Failed with state: " + state);
                var errors = action.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        alert(errors[0].message);
                        component.set("{!v.isLoading}", false);
                    }
                }
            }
        });
        $A.enqueueAction(action);
    },
    fetchRealTimeData : function(component, event, helper) {
        if((component.get("v.accSfId") === undefined || component.get("v.accSfId").length  === 0)
           && (component.get("v.prodCatVal") === undefined || component.get("v.prodCatVal").length  === 0
               || component.get("v.prodItem") === undefined || component.get("v.prodItem").length  === 0)){
            
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                message: "We hit a snag. Please fill all the required fields",
                type: "error"
            });
            toastEvent.fire();
        } else {
            component.set("{!v.isLoading}", true);
            var prodInfoMap = component.get("v.prodInfoMap");
            prodInfoMap['accSfId'] = ""+component.get("v.accSfId");
            if(component.get("v.itemSrchChkbox") === true){
                prodInfoMap['ItemNumber'] = component.get("v.prodItem");
                prodInfoMap['prodCatVal'] = '';
                prodInfoMap['prodAreaVal'] = '';
            }
            else if(component.get("v.itemSrchChkbox") === false){
                prodInfoMap['prodCatVal'] = component.get("v.prodCatVal");
                prodInfoMap['prodAreaVal'] = component.get('v.prodAreaVal');
                prodInfoMap['ItemNumber'] = ''; 
            }
            console.log("prodInfoMap: " + JSON.stringify(prodInfoMap));
            var action = component.get("c.connect2GetSalesRepLookupInfoFromSAP");
            action.setParams({
                prodInfoMap : prodInfoMap
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (component.isValid() && state === "SUCCESS") {
                    console.log("response: ", response.getReturnValue());
                    component.set("v.salesRepsList", response.getReturnValue());
                    component.set("v.message", response.getReturnValue()[0].message);
                    component.set("{!v.isLoading}", false);
                } else {
                    console.log("Failed with state: " + state);
                    var errors = action.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            alert(errors[0].message);
                            component.set("{!v.isLoading}", false);
                        }
                    }
                }
            });
            $A.enqueueAction(action);
        }
    }
})