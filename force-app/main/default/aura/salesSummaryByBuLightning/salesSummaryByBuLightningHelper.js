({
	getResponse : function(component, event, helper) {
        //call apex class method
        console.log('*** Starting getResponse Sales Summary by BU *** ' );
        var today = new Date();
        var prevYear = today.getFullYear() - 1;
        var currYear = today.getFullYear();
        console.log('*** today *** ' + today );
        console.log('*** prevYear *** ' + prevYear );
        console.log('*** currYear *** ' + currYear );
        var recordId = component.get("v.recordId");
        var action = component.get('c.initMethod');
        console.log('*** recordId *** ' + recordId );
        action.setParams({
            "acctId": recordId
        });
        action.setCallback(this,function(response){
            //store state of response
            var state = response.getState();
            console.log('*** state *** ' + state );
            if (state === "SUCCESS") {
                //var custs = {};
                var sMapRes = response.getReturnValue().salesMap;
                var saleslistPrev = [];
                var saleslistCurr = [];
                //var saleslistBoth = [];
                var key;
                var subPrev;
                var subCurr;
                
                for(key in sMapRes){
                    subPrev = key.substring(4);
                    subCurr = key.substring(4);
                    console.log('*** key *** ' + key );
                    if(key.indexOf(prevYear) >= 0){
                    	console.log('*** subPrev *** ' + subPrev );
                    	saleslistPrev.push({key: subPrev, value: sMapRes[key]});
                        //saleslistBoth.push({key: subPrev, value: sMapRes[key]});
                    }
                    else if(key.indexOf(currYear) >= 0){
                        console.log('*** subCurr *** ' + subCurr );
                    	saleslistCurr.push({key: subCurr, value: sMapRes[key]});
                        //saleslistBoth.push({key: subCurr, value: sMapRes[key]});
                    }
                        
                }  
                
               // component.set('v.salesMapNew', sMapRes);
                component.set('v.salesMapPrev', saleslistPrev);
                component.set('v.salesMapCurr', saleslistCurr);
                //component.set('v.salesMapBoth', saleslistBoth);
                //set response value in objClassController attribute on component
                console.log('*** saleslistPrev*** ' + JSON.stringify(saleslistPrev ));
                console.log('*** saleslistCurr*** ' + JSON.stringify(saleslistCurr ));
                console.log('*** Ending getResponse Sales Summary by BU *** ' );
                component.set('v.salesObj', response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
})