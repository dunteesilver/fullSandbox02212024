({
	 afterScriptsLoaded : function(component,evt,helper){
       
         var regionName = ''+component.get("v.regionName");
         
         helper.fetchCalenderEvents(component, regionName);
         component.set("{!v.isLoading}", false);
        
    },
    
    getCalEvntsByRgn : function(component,evt,helper){
        
        window.location.reload();

    },
    
    navigateToTFX_MANTA_Comp : function(component, event, helper) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:TFX_MANTA_Comp"
            ,
            componentAttributes :{ 
                usrId: component.get("v.usrId"),
                usrName: component.get("v.usrName"),
                showEdit: component.get("v.showEdit")
            }
        });
        evt.fire();
    },
    
    navigateToTFX_MANTA_Calendar_Bridge_Comp : function(component, event, helper) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:TFX_MANTA_Calendar_Bridge_Comp"
            ,
            componentAttributes :{ 
                usrId: component.get("v.usrId"),
                usrName: component.get("v.usrName"),
                showEdit: component.get("v.showEdit"),
                regionName: component.get("v.regionName")
            }
        });
        evt.fire();
    },
    
     handleClick : function(component, event, helper){ 
      
         var buttonstate = component.get("v.buttonstate");
         component.set("v.buttonstate",!buttonstate);
         if(!buttonstate){
          $("#listcalendar").show();
         $("#calendar").hide();
         $('#listcalendar').fullCalendar({
        	defaultView: 'listWeek',
             listDayFormat : true,
             events : component.get("v.Objectlist")
		});
        
         }
         else{
              $("#calendar").show();
           $("#listcalendar").hide();   
             helper.fetchCalenderEvents(component);
         }
        
    },

})