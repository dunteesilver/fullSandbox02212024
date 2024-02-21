({
    loadDataToCalendar: function(component, data) {
        //Find Current date for default date
        var d = new Date();
        var month = d.getMonth() + 1;
        var day = d.getDate();
        var currentDate =
            d.getFullYear() +
            "/" +
            (month < 10 ? "0" : "") +
            month +
            "/" +
            (day < 10 ? "0" : "") +
            day;
        
        var self = this;
        $("#calendar").fullCalendar({
            header: {
                left: "prev,next today",
                center: "title",
                right: "month,basicWeek,basicDay"
            },
            selectable: true,
            defaultDate: currentDate,
            editable: true,
            eventLimit: true,
            events: data,
            timeFormat: "H(:mm)", //Using CSS to hide time format. Right now it is in 24 H format to display "0" on beggining of every event removing that will show "12a" represents the start time of your event, i.e. "12 am". You can change the formatting in the calendar options:
            dragScroll: true,
            droppable: true,
            weekNumbers: true,
            eventDrop: function(event, delta, revertFunc) {
                alert(event.title + " was dropped on " + event.start.format());
                
                if (!confirm("Are you sure about this change?")) {
                    revertFunc();
                } else {
                    var eventidObj = event;
                    self.editEvent(component, eventidObj);
                }
                
            },
            eventClick: function(event, jsEvent, view) {  
                
                
                if(event.id.status === 'Open (Not Accepted)' || event.id.status === 'No Trainer Needed'){
                    var evt = $A.get("e.force:navigateToComponent");
                    evt.setParams({
                        componentDef: "c:TFX_MANTA_OpenReqCardEdit",
                        componentAttributes :
                        {
                            openReqId : event.id.id,
                            caseDate : event.id.caseDate,
                            hospitalId : event.id.hospitalId,
                            hospital : event.id.hospitalName,
                            physicianId : event.id.physicianId,
                            physician : event.id.physicianName,
                            caseType : event.id.caseType,
                            numOfCases : event.id.estNumOfCases,
                            caseInitiator : event.id.caseInitiatorName,
                            caseInitID : event.id.caseInitID,
                            daysOpen : event.id.daysOpen,
                            notes : event.id.notes,
                            status : event.id.status,
                            proctor : event.id.proctorId,
                            proctorName : event.id.proctorName,
                            region : event.id.region
                        }
                    });
                    evt.fire();
                }
                else{
                    var evt = $A.get("e.force:navigateToComponent");
                    evt.setParams({
                        componentDef: "c:TFX_MANTA_AcceptedReqCardEdit",
                        componentAttributes :
                        {
                            acceptedReqId : event.id.id,
                            caseDate : event.id.caseDate,
                            hospitalId : event.id.hospitalId,
                            hospital : event.id.hospitalName,
                            region : event.id.region,
                            physicianId : event.id.physicianId,
                            physician : event.id.physicianName,
                            caseType : event.id.caseType,
                            numOfCases : event.id.estNumOfCases,
                            caseInitiator : event.id.caseInitiatorName,
                            caseInitID : event.id.caseInitiator,
                            notes : event.id.notes,
                            status : event.id.status,
                            proctor : event.id.proctorName,
                            proctorId : event.id.proctorId
                        }
                    });
                    evt.fire();
                }
                
                /*var editRecordEvent = $A.get("e.force:editRecord");
        editRecordEvent.setParams({
          recordId: event.id
        });
        editRecordEvent.fire();*/
          
      },
        dayClick: function(date, jsEvent, view) {
            
            if(!confirm("Are you sure you want to open new request on this day?")){
                //do nothing...
            } else {  
                
                var datelist = date
                .format()
                .toString()
                .split("-");
                
                var datetime = new Date(
                    datelist[0],
                    parseInt(datelist[1]) - 1,
                    parseInt(datelist[2]) + 1,
                    0,
                    0,
                    0,
                    0
                );
                
                var evt = $A.get("e.force:navigateToComponent");
                evt.setParams({
                    componentDef: "c:TFX_MANTA_New_Req_Comp",
                    componentAttributes: {
                        usrId: component.get("v.usrId"),
                        usrName: component.get("v.usrName"),
                        showEdit: component.get("v.showEdit"),
                        caseDate: date
                    }
                });
                evt.fire();
                
                /*var createRecordEvent = $A.get("e.force:createRecord");
                                            createRecordEvent.setParams({
                                                "entityApiName": "MANTA_Proctorship_Request__c",
                                                "defaultFieldValues": {
                                                //'Case_Date__c' :  datetime
                                                
                                            }
                                            });
                                            createRecordEvent.fire();*/
            
        }//end of else
      },
        
        eventMouseover: function(event, jsEvent, view) {}
    });
  },
    
    formatFullCalendarData: function(component, events) {
        
        
        var josnDataArray = [];
        var singleEvntArray = [];  
        
        for (var i = 0; i < events.length; i++) {
            
            var startdate = $A.localizationService.formatDate(events[i].Case_Date__c);
            var enddate = $A.localizationService.formatDate(events[i].Case_Date__c);
            
             
            
                if(JSON.stringify(events[i]).includes('Proctor__c') && JSON.stringify(events[i]).includes('Case_Initiator__c')){
                    
                    singleEvntArray.push({
                        id: events[i].Id, 
                        caseDate: events[i].Case_Date__c,
                        hospitalId: events[i].Hospital__r.Id,
                        hospitalName: events[i].Hospital__r.Name, 
                        physicianId: events[i].Physician__r.Id,
                        physicianName: events[i].Physician__r.Name,
                        caseType: events[i].Case_Type__c,
                        estNumOfCases: events[i].Estimated_of_Cases__c,
                        caseInitiatorName: events[i].Case_Initiator__r.Name,
                        caseInitID: events[i].Case_Initiator__c,
                        notes: events[i].Notes__c,
                        daysOpen: events[i].Days_Open__c,
                        status: events[i].Status__c,
                        region: events[i].Region__c,
                        proctorId: events[i].Proctor__c,
                        proctorName: events[i].Proctor__r.Name
                    })  
                }
                else{            
                    
                    singleEvntArray.push({
                        id: events[i].Id, 
                        caseDate: events[i].Case_Date__c,
                        hospitalId: events[i].Hospital__r.Id,
                        hospitalName: events[i].Hospital__r.Name, 
                        physicianId: events[i].Physician__r.Id,
                        physicianName: events[i].Physician__r.Name,
                        caseType: events[i].Case_Type__c,
                        estNumOfCases: events[i].Estimated_of_Cases__c,
                        //caseInitiatorName: events[i].Case_Initiator__r.Name,
                        //caseInitID: events[i].Case_Initiator__c,
                        notes: events[i].Notes__c,
                        daysOpen: events[i].Days_Open__c,
                        status: events[i].Status__c,
                        region: events[i].Region__c
                    }) 
                }
               
                josnDataArray.push({
                title:
                "Hospital: " +
                events[i].Hospital__r.Name +
                "\n Region: " +
                events[i].Region__c +
                "\n Status:" +
                events[i].Status__c,
                start: startdate,
                end: enddate,
                id: singleEvntArray[i]
            });
                
            }       
   
        return josnDataArray;
    },
    
    fetchCalenderEvents: function(component, regionName) {
        
        var action = component.get("c.getMANTACaseEvents");
        action.setParams({
            'regionName' : regionName
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var josnArr = this.formatFullCalendarData(
                    component,
                    response.getReturnValue()
                );
                
                this.loadDataToCalendar(component, josnArr);
                component.set("v.Objectlist", josnArr);
            } else if (state === "ERROR") {
            }
        });
        
        $A.enqueueAction(action);
    },
    
    editEvent: function(component, eventObj) {
        component.set("{!v.isLoading}", true);
        var action = component.get("c.updateEvent");
        
        action.setParams({ eventid: eventObj.id.id, eventdate: eventObj.start.format() });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("{!v.isLoading}", false);
                window.location.reload(); 
            } else if (state === "ERROR") {
                window.location.reload();
            }
        });
        
        $A.enqueueAction(action);
    }
});