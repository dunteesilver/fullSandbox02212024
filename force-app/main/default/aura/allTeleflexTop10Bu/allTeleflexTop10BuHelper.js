({
	getResponse : function(component, event, helper) {
        //call apex class method
        console.log('*** Starting getResponse All Teleflex Top 10 BU *** ' );
        var today = new Date();
        var prevYear = today.getFullYear() - 1;
        var currYear = today.getFullYear();
        console.log('*** today *** ' + today );
        console.log('*** prevYear *** ' + prevYear );
        console.log('*** currYear *** ' + currYear );
        var recordId = component.get("v.recordId");
        var action = component.get('c.getTop10Bu');
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
                var sMapRes = response.getReturnValue().salesMapTop;
                var matMap = response.getReturnValue().prodMap;
                console.log('*** sMapRes *** ' + sMapRes );
                var saleslistPrevTop = [];
                var saleslistCurrTop = [];
                var matMapArray = [];
                //var saleslistBoth = [];
                var key;
                var subPrev;
                var subCurr;
                
                for(key in sMapRes){
                    subPrev = key.substring(0,4);
                    subCurr = key.substring(0,3);
                    console.log('*** key *** ' + key );
                    if(subPrev == "PYTD"){
                    	console.log('*** subPrev *** ' + subPrev );
                        subPrev = key.substring(9);
                        var subPrevProd = subPrev.slice(0,-8);
                        console.log('*** subPrevProd *** ' + subPrevProd );
                    	saleslistPrevTop.push({key: subPrevProd, value: sMapRes[key]});
                        //saleslistBoth.push({key: subPrev, value: sMapRes[key]});
                    }
                    else if(subCurr == "YTD"){
                        console.log('*** subCurr *** ' + subCurr );
                        subCurr = key.substring(8);
                        var subCurrProd = subCurr.slice(0,-8);
                        console.log('*** subCurrProd *** ' + subCurrProd );
                    	saleslistCurrTop.push({key: subCurrProd, value: sMapRes[key]});
                        //saleslistBoth.push({key: subCurr, value: sMapRes[key]});
                    }
                        
                } 
                
                for(key in matMap){
                    console.log('*** key matMap *** ' + key );
                    //console.log('*** matMap[key] *** ' + matMap[key] );
                    matMapArray.push({key: key, value: matMap[key]});
                }
                console.log('*** matMapArray *** ' + JSON.stringify(matMapArray ));
               // component.set('v.salesMapNew', sMapRes);
                component.set('v.salesMapPrevTop', saleslistPrevTop);
                component.set('v.salesMapCurrTop', saleslistCurrTop);
                component.set('v.matMap', matMapArray);
                //set response value in objClassController attribute on component
                console.log('*** saleslistPrevTop *** ' + JSON.stringify(saleslistPrevTop ));
                console.log('*** saleslistCurrTop *** ' + JSON.stringify(saleslistCurrTop ));
                console.log('*** Ending getResponse All Teleflex Top 10 *** ' );
                component.set('v.salesObjTopBu', response.getReturnValue());
                component.set('v.salesObj', response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
})