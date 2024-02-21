({
  doInit: function(component, event, helper) {
    /*var value = [
      { type: "Contact", id: "0032S00002AINNYQA5", label: "navigate" }
    ];
    component
      .find("lookup")
      .get("v.body")[0]
      .set("v.values", value);*/

    var recID = component.get("v.recordId");

    var urlEvent = $A.get("e.force:navigateToURL");
    urlEvent.setParams({
      url: "/apex/CXSalesRepLookup?id=" + recID
    });
    urlEvent.fire();
  }
});