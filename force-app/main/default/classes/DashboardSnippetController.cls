public with sharing class DashboardSnippetController {
    public DashBoardSnippetController(){}

    public string getDashboardHtml(){
        PageReference dbPage = new PageReference('https://teleflex.my.salesforce.com/01ZE0000000kPdi');
        Blob pageBlob = dbPage.getContent();
        return pageBlob.toString();
    }
}