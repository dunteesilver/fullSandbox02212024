({
  myAction: function(component, event, helper) {
    component.set("{!v.isLoading}", false);
    component.set(
      "{!v.newCaseDataObj.Hospital_Name__c}",
      component.get("v.hospital")
    );
    component.set(
      "{!v.newCaseDataObj.MANTA_Proctorship_Request__c}",
      component.get("v.openReqId")
    );

    var action = component.get("c.getSelHospRgnAndPhys");
    $A.enqueueAction(action);
  },

  saveNewCaseData: function(component, event, helper) {
    component.set("{!v.isLoading}", true);

    component.set(
      "{!v.newCaseDataObj.Hospital_Name__c}",
      component.get("v.hospitalId")
    );

    var caseDate = component.get("v.newCaseDataObj.Case_Date__c");
    var physician = component.get("v.newCaseDataObj.Deploying_Physician__c");
    var mantaTrainer = component.get("v.newCaseDataObj.MANTA_Trainer__c");
    var caseType = component.get("v.newCaseDataObj.Case_Type__c");
    var tortuosity = component.get("v.newCaseDataObj.Tortuosity__c");
    var clasification = component.get("v.newCaseDataObj.Calcification__c");
    var preArteriogramTaken = component.get(
      "v.newCaseDataObj.Pre_Arteriogram_Taken__c"
    );
    var ultrasound_Guided_Access_Used = component.get(
      "v.newCaseDataObj.Ultrasound_Guided_Access_Used__c"
    );
    var device = component.get("v.newCaseDataObj.Device__c");
    var size_of_MANTA_Device_Used = component.get(
      "v.newCaseDataObj.Size_of_MANTA_Device_Used__c"
    );
    var MANTA_Lot_Number = component.get(
      "v.newCaseDataObj.MANTA_Lot_Number__c"
    );
    var post_Arteriogram_Taken = component.get(
      "v.newCaseDataObj.Post_Arteriogram_Taken__c"
    );
    var MANTA_Not_Used = component.get("v.newCaseDataObj.MANTA_Not_Used__c");
    var Reason_MANTA_Not_Used = component.get(
      "v.newCaseDataObj.Reason_MANTA_Not_Used__c"
    );
    var Time_to_Hemostasis = component.get(
      "v.newCaseDataObj.Time_to_Hemostasis__c"
    );

    if (MANTA_Not_Used !== true) {
      if (
        caseDate.length === 0 ||
        physician.length === 0 ||
        mantaTrainer.length === 0 ||
        caseType.length === 0 ||
        tortuosity.length === 0 ||
        clasification.length === 0 ||
        preArteriogramTaken.length === 0 ||
        ultrasound_Guided_Access_Used.length === 0 ||
        device.length === 0 ||
        size_of_MANTA_Device_Used.length === 0 ||
        MANTA_Lot_Number.length === 0 ||
        post_Arteriogram_Taken.length === 0 ||
        Time_to_Hemostasis.length === 0
      ) {
        component.set(
          "{!v.newCaseDataObj.Hospital_Name__c}",
          component.get("v.hospital")
        );
        component.set("{!v.isLoading}", false);
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
          message: "We hit a snag. Please fill all of the required fields",
          type: "error"
        });
        toastEvent.fire();
      } else {
        component.set("{!v.isLoading}", true);

        var newCaseDataObj = JSON.stringify(component.get("v.newCaseDataObj"));

        var action = component.get("c.saveMANTACaseDataRecs");
        action.setParams({
          newCaseDataObj: newCaseDataObj
        });
        action.setCallback(this, function(response) {
          var state = response.getState();
          if (component.isValid() && state === "SUCCESS") {
            if (Time_to_Hemostasis === "10 or more") {
              component.set("{!v.isLoading}", false);
              var toastEvent = $A.get("e.force:showToast");
              toastEvent.setParams({
                message: "New Case Data " + status + " saved successfully!",
                type: "success"
              });
              toastEvent.fire();

              component.set("v.showConfirmDialog", true);
            } else {
              component.set("{!v.isLoading}", false);
              var evt = $A.get("e.force:navigateToComponent");
              evt.setParams({
                componentDef: "c:TFX_MANTA_Accepted_Reqs_Comp",
                componentAttributes: {
                  usrId: component.get("v.usrId"),
                  usrName: component.get("v.usrName"),
                  showEdit: component.get("v.showEdit"),
                  selectedId: component.get("v.newCaseDataObj.Hospital_Name__c")
                }
              });
              evt.fire();
            }
          } else {
            console.log("Failed with state: " + state);
          }
        });

        $A.enqueueAction(action);
      }
    } else {
      if (caseDate.length === 0 || Reason_MANTA_Not_Used.length === 0) {
        component.set(
          "{!v.newCaseDataObj.Hospital_Name__c}",
          component.get("v.hospital")
        );
        component.set("{!v.isLoading}", false);
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
          message: "We hit a snag. Please fill all of the required fields",
          type: "error"
        });
        toastEvent.fire();
      } else {
        component.set("{!v.isLoading}", true);

        var newCaseDataObj = JSON.stringify(component.get("v.newCaseDataObj"));

        var action = component.get("c.saveMANTACaseDataRecs");
        action.setParams({
          newCaseDataObj: newCaseDataObj
        });
        action.setCallback(this, function(response) {
          var state = response.getState();
          if (component.isValid() && state === "SUCCESS") {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
              message: "New Case Data " + status + " saved successfully!",
              type: "success"
            });
            toastEvent.fire();

            var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
              componentDef: "c:TFX_MANTA_Accepted_Reqs_Comp",
              componentAttributes: {
                usrId: component.get("v.usrId"),
                usrName: component.get("v.usrName"),
                showEdit: component.get("v.showEdit")
              }
            });
            evt.fire();
          } else {
            console.log("Failed with state: " + state);
          }
        });

        $A.enqueueAction(action);
      }
    }
  },

  getSelHospRgnAndPhys: function(component, event, helper) {
    var action = component.get("c.getAllPhysAndRgnByHospAccId");
    action.setParams({
      hospAccId: "" + component.get("v.hospitalId")
    });
    component.set("{!v.isLoading}", true);
    action.setCallback(this, function(response) {
      var state = response.getState();
      if (component.isValid() && state === "SUCCESS") {
        component.set(
          "v.allPhysiciansLst",
          response.getReturnValue().physicians
        );
        component.set("v.allProctorsLst", response.getReturnValue().proctors);
        component.set(
          "v.newReqObj.Region__c",
          response.getReturnValue().region[0].Region__c
        );
        component.set("{!v.isLoading}", false);
      } else {
        component.set("v.allPhysiciansLst", "");
        component.set("v.allProctorsLst", "");
        component.set("v.newReqObj.Region__c", "N/A");
        component.set("{!v.isLoading}", false);
        console.log("Failed with state: " + state);
      }
    });

    $A.enqueueAction(action);
  },

  navigateToTFX_MANTA_Accepted_Reqs_Comp: function(component, event, helper) {
    var evt = $A.get("e.force:navigateToComponent");
    evt.setParams({
      componentDef: "c:TFX_MANTA_Accepted_Reqs_Comp",
      componentAttributes: {
        usrId: component.get("v.usrId"),
        usrName: component.get("v.usrName"),
        showEdit: component.get("v.showEdit")
      }
    });
    evt.fire();
  },

  clearForm: function(component, event, helper) {
    $A.get("e.force:refreshView").fire();
  },

  handleConfirmDialogYes: function(component, event, helper) {
    component.set("v.showConfirmDialog", false);
    var urlEvent = $A.get("e.force:navigateToURL");
    urlEvent.setParams({
      url:
        window.location.origin +
        "/lightning/o/Complaint__c/new?useRecordTypeCheck=1"
    });
    urlEvent.fire();
  },

  handleConfirmDialogNo: function(component, event, helper) {
    component.set("v.showConfirmDialog", false);
    var evt = $A.get("e.force:navigateToComponent");
    evt.setParams({
      componentDef: "c:TFX_MANTA_Accepted_Reqs_Comp",
      componentAttributes: {
        usrId: component.get("v.usrId"),
        usrName: component.get("v.usrName"),
        showEdit: component.get("v.showEdit"),
        selectedId: component.get("v.newCaseDataObj.Hospital_Name__c")
      }
    });
    evt.fire();
  }
});