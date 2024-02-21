/*
    @Author: Sankarsh
    @Version: 1.0
    @Description: Auto complete and search funtionalty
*/
global class AutoCompleteController {

    public AutoCompleteController(PP_Create_Quote controller) {

    }

    /*Global variables*/
    public String searchedRecordId { get; set; }
    public static list<ResultSet> searchedRecord {get;set;}    
    global AutoCompleteController(PP_Menu ppm){
    
    }
    
    
    @RemoteAction
    global static MaterialWrapper[] getMaterialRecords(String searchText) {
        
        //sObject List
        searchText = '%'+searchText+'%';
        List<MaterialWrapper> resultList = new List<MaterialWrapper>();
        system.debug('*****searchText******'+searchText);
        for( Product2 pr : [Select id,Name from Product2 Where Name Like: searchText Order By Name LIMIT 5]) {
            resultList.add( new MaterialWrapper(pr.id, pr.name));
        }
        
        return resultList;
    }
    
    global class MaterialWrapper{
        public String prId {get;set;} 
        public String prName {get;set;}
        
        public MaterialWrapper(String prId, String prName) {
            this.prId = prId;
            this.prName = prName;
        }
    }
    
    @RemoteAction
    global static ResultSet[] getRecords(String searchText) {
        //sObject List
        searchedRecord = new list<ResultSet>();
        System.debug('--------searchText---------'+searchText);
        //SOSL Text should be more then one charecter
        //System.debug('----------------------'+[Select id,Name,Description from Account WHERE Agreement_Count__c > 0 LIMIT 100]+'--'+[Select Name,id, Description from Product2 LIMIT 100]+'-------'+[select id, Name, Description__c from Contract_Header__c LIMIT 100]);
        if(searchText.length() >0) {
            List<List<SObject>> searchList = [FIND :searchText IN ALL FIELDS RETURNING Account (id,Name,Description WHERE Agreement_Count__c > 0 AND Name != null LIMIT 10), Product2(Name,id, Description LIMIT 10), Contract_Header__c (id, Name, Description__c LIMIT 10)];
            //Adding diffrent object's records in sobject list
            for(List<SObject> o:searchList){
                for(SObject s:o){
                    searchedRecord.add(new autoCompleteController.ResultSet(s));
                } 
            }
        }
        return searchedRecord;
    }
    
    /*getGlobalDescribed*/
    private static list<Schema.SObjectType> gd{
        get{
            if(gd == null){
                gd = Schema.getGlobalDescribe().values();
            }
            return gd ;
        }set;
    }
    
    /*Record Wrapper*/
    global class ResultSet{
        public String Id {get;set;} 
        public String Name{get;set;}
        //public String Description {get;set;}
        public String sObjectName {get;set;}
        public ResultSet(sObject s){
            this.Id = s.Id;
            this.Name = s.get('Name')+'';
           // this.Description = s.get('Description')+'';
            this.sObjectName = getsObjectNameById(Id);            
        }       
        global ResultSet(String Id,String Name){
            this.Id = Id;
            this.Name = Name;
            //this.Description = Description;
            this.sObjectName = getsObjectNameById(Id);            
        }
        /*To get object Name by Id*/
        private String getsObjectNameById(String sObjectId){            
            if(sObjectId != null && sObjectId.trim() != ''){
                for(Schema.SObjectType objectInstance : autoCompleteController.gd){
                    if(objectInstance.getDescribe().getKeyPrefix() == sObjectId.subString(0,3)){    
                        return objectInstance.getDescribe().getLabel();
                    }
                }
            }
            return null;
        }
    }
}