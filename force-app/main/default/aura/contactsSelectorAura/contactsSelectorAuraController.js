({
    handleNavigate: function(cmp, event) {
        var navigate = cmp.get("v.navigateFlow");
        navigate(event.getParam("action"));
    },
    changeValue : function (component, event, helper) {
        component.set("v.requiredField", 'false');
    },
    HandleRequiredFieldChange : function (component, event, helper) {
        var params =  event.getParams();
        alert(params.value);
    }
});