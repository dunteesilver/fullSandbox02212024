public class survey_Helper_Class {
    // https://teleflexcma.formstack.com/forms/sfdc2018?uid=123
    // Class that allows the survey URL to be embedded in email. Once clicked it grabs the users Id and then continues on to the survey
    // 16March2018 - ESC
    // Test Class: account_Page_Helper_Test.testSurveyRedirect
    public pagereference redirect(){
        PageReference quote_redirect = New Pagereference('https://teleflexcma.formstack.com/forms/sfdc2018?uid=' + UserInfo.getUserId());
        quote_redirect.setRedirect(true); 
        return quote_redirect;
    }

}