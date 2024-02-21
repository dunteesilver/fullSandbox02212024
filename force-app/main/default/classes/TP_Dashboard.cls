public With Sharing class TP_Dashboard {
    public transient List<Target_Profile__c> recssaturation33eachesAPlus {get; private set;}
    public transient List<Target_Profile__c> recssaturation3366eachesAPlus {get; private set;}
    public transient List<Target_Profile__c> recssaturation66eachesAPlus {get; private set;}
    public transient List<Target_Profile__c> recssaturation33eachesA {get; private set;}
    public transient List<Target_Profile__c> recssaturation3366eachesA {get; private set;}
    public transient List<Target_Profile__c> recssaturation66eachesA {get; private set;}
    public transient List<Target_Profile__c> recssaturation33eachesB {get; private set;}
    public transient List<Target_Profile__c> recssaturation3366eachesB {get; private set;}
    public transient List<Target_Profile__c> recssaturation66eachesB {get; private set;}
    public transient List<Target_Profile__c> recssaturation33eachesC {get; private set;}
    public transient List<Target_Profile__c> recssaturation3366eachesC {get; private set;}
    public transient List<Target_Profile__c> recssaturation66eachesC {get; private set;}
   /* public transient List<Target_Profile__c> recssaturation33eachesMD {get; private set;}
    public transient List<Target_Profile__c> recssaturation3366eachesMD {get; private set;}
    public transient List<Target_Profile__c> recssaturation66eachesMD {get; private set;}*/
    public transient Integer recssaturation33eachesAPlusTotal {get; private set;}
    public transient Integer recssaturation3366eachesAPlusTotal {get; private set;}
    public transient Integer recssaturation66eachesAPlusTotal {get; private set;}
    public transient Integer recssaturation33eachesATotal {get; private set;}
    public transient Integer recssaturation3366eachesATotal {get; private set;}
    public transient Integer recssaturation66eachesATotal {get; private set;}
    public transient Integer recssaturation33eachesBTotal {get; private set;}
    public transient Integer recssaturation3366eachesBTotal {get; private set;}
    public transient Integer recssaturation66eachesBTotal {get; private set;}
    public transient Integer recssaturation33eachesCTotal {get; private set;}
    public transient Integer recssaturation3366eachesCTotal {get; private set;}
    public transient Integer recssaturation66eachesCTotal {get; private set;}
  /*  public transient Integer recssaturation33eachesMDTotal {get; private set;} 
    public transient Integer recssaturation3366eachesMDTotal {get; private set;}
    public transient Integer recssaturation66eachesMDTotal {get; private set;}*/
    
    public TP_Dashboard() {
        String queryStr = 'SELECT Id,Name,Account__r.Name FROM Target_Profile__c WHERE ';
        Id userId = UserInfo.getUserId();
        Set<Id> accountIds = new Set<Id>();
            
        List<Territory_Master__c> territories = [SELECT Id FROM Territory_Master__c WHERE Sales_Rep__c=:userId];
        //system.debug('territories:'+territories);
        If(territories != null && territories.size() > 0){
            List<Territory_Assignment__c> territoryAssignments = [SELECT Id, account__c FROM Territory_Assignment__c WHERE territory__c IN:territories AND Account__r.Target_Profiles_Count__c!=0];
            //system.debug('territoryAssignments:'+territoryAssignments);
            If(territoryAssignments != null && territoryAssignments.size() > 0){
                for(Territory_Assignment__c ta:territoryAssignments){
                    accountIds.add(ta.account__c);
                }
                //system.debug('accountIds:'+accountIds);
            }
            if(accountIds.size()>0){
                queryStr += 'Account__c IN:accountIds AND ';
            }
        }
        String saturation33eachesAPlusAllQuery = queryStr+'IO_potential_Range__c=\'A+\' AND Account_Saturation_Range__c = \'<33%\' ';
        List<Target_Profile__c> recssaturation33eachesAPlusAll = database.query(saturation33eachesAPlusAllQuery);
        recssaturation33eachesAPlusTotal = recssaturation33eachesAPlusAll.Size();
        recssaturation33eachesAPlus = getRecords(recssaturation33eachesAPlusAll);
        
        String saturation3366eachesAPlusAllQuery = queryStr+'IO_potential_Range__c=\'A+\' AND Account_Saturation_Range__c = \'33%-66%\' ';
        List<Target_Profile__c> recssaturation3366eachesAPlusAll = database.query(saturation3366eachesAPlusAllQuery);
        recssaturation3366eachesAPlusTotal = recssaturation3366eachesAPlusAll.Size();
        recssaturation3366eachesAPlus = getRecords(recssaturation3366eachesAPlusAll);
        
        String saturation66eachesAPlusAllQuery = queryStr+'IO_potential_Range__c=\'A+\' AND Account_Saturation_Range__c = \'>66%\' ';
        List<Target_Profile__c> recssaturation66eachesAPlusAll = database.query(saturation66eachesAPlusAllQuery);
        recssaturation66eachesAPlusTotal = recssaturation66eachesAPlusAll.Size();
        recssaturation66eachesAPlus = getRecords(recssaturation66eachesAPlusAll);
        
        String saturation33eachesAAllQuery = queryStr+'IO_potential_Range__c=\'A\' AND Account_Saturation_Range__c = \'<33%\' ';
        List<Target_Profile__c> recssaturation33eachesAAll = database.query(saturation33eachesAAllQuery);
        recssaturation33eachesATotal = recssaturation33eachesAAll.Size();
        recssaturation33eachesA = getRecords(recssaturation33eachesAAll);
        
        String saturation3366eachesAAllQuery = queryStr+'IO_potential_Range__c=\'A\' AND Account_Saturation_Range__c = \'33%-66%\' ';
        List<Target_Profile__c> recssaturation3366eachesAAll = database.query(saturation3366eachesAAllQuery);
        recssaturation3366eachesATotal = recssaturation3366eachesAAll.Size();
        recssaturation3366eachesA = getRecords(recssaturation3366eachesAAll);
        
        String saturation66eachesAAllQuery = queryStr+'IO_potential_Range__c=\'A\' AND Account_Saturation_Range__c = \'>66%\' ';
        List<Target_Profile__c> recssaturation66eachesAAll = database.query(saturation66eachesAAllQuery);
        recssaturation66eachesATotal = recssaturation66eachesAAll.Size();
        recssaturation66eachesA = getRecords(recssaturation66eachesAAll);
        
        
        String saturation33eachesBAllQuery = queryStr+'IO_potential_Range__c=\'B\' AND Account_Saturation_Range__c = \'<33%\' ';
        List<Target_Profile__c> recssaturation33eachesBAll = database.query(saturation33eachesBAllQuery);
        recssaturation33eachesBTotal = recssaturation33eachesBAll.Size();
        recssaturation33eachesB = getRecords(recssaturation33eachesBAll);
        
        String saturation3366eachesBAllQuery = queryStr+'IO_potential_Range__c=\'B\' AND Account_Saturation_Range__c = \'33%-66%\' ';
        List<Target_Profile__c> recssaturation3366eachesBAll = database.query(saturation3366eachesBAllQuery);
        recssaturation3366eachesBTotal = recssaturation3366eachesBAll.Size();
        recssaturation3366eachesB = getRecords(recssaturation3366eachesBAll);
        
        String saturation66eachesBAllQuery = queryStr+'IO_potential_Range__c=\'B\' AND Account_Saturation_Range__c = \'>66%\' ';
        List<Target_Profile__c> recssaturation66eachesBAll = database.query(saturation66eachesBAllQuery);
        recssaturation66eachesBTotal = recssaturation66eachesBAll.Size();
        recssaturation66eachesB = getRecords(recssaturation66eachesBAll);
        
        
        String saturation33eachesCAllQuery = queryStr+'IO_potential_Range__c=\'C\' AND Account_Saturation_Range__c = \'<33%\' ';
        List<Target_Profile__c> recssaturation33eachesCAll = database.query(saturation33eachesCAllQuery);
        recssaturation33eachesCTotal = recssaturation33eachesCAll.Size();
        recssaturation33eachesC = getRecords(recssaturation33eachesCAll);
        
       

        
       
        String saturation3366eachesCAllQuery = queryStr+'IO_potential_Range__c=\'C\' AND Account_Saturation_Range__c = \'33%-66%\' ';
        List<Target_Profile__c> recssaturation3366eachesCAll = database.query(saturation3366eachesCAllQuery);
        recssaturation3366eachesCTotal = recssaturation3366eachesCAll.Size();
        recssaturation3366eachesC = getRecords(recssaturation3366eachesCAll);
        
        
        String saturation66eachesCAllQuery = queryStr+'IO_potential_Range__c=\'C\' AND Account_Saturation_Range__c = \'>66%\' ';
        List<Target_Profile__c> recssaturation66eachesCAll = database.query(saturation66eachesCAllQuery);
        recssaturation66eachesCTotal = recssaturation66eachesCAll.Size();
        recssaturation66eachesC = getRecords(recssaturation66eachesCAll);
        
     /*   String saturation33eachesMDAllQuery = queryStr+'IO_potential_Range__c=\'MD\' AND Account_Saturation_Range__c = \'<33%\' ';
        List<Target_Profile__c> recssaturation33eachesMDAll = database.query(saturation33eachesMDAllQuery);
        recssaturation33eachesMDTotal = recssaturation33eachesMDAll.Size();
        recssaturation33eachesMD = getRecords(recssaturation33eachesMDAll);
        
        String saturation3366eachesMDAllQuery = queryStr+'IO_potential_Range__c=\'MD\' AND Account_Saturation_Range__c = \'33%-66%\' ';
        List<Target_Profile__c> recssaturation3366eachesMDAll = database.query(saturation3366eachesMDAllQuery);
        recssaturation3366eachesMDTotal = recssaturation3366eachesMDAll.Size();
        recssaturation3366eachesMD = getRecords(recssaturation3366eachesMDAll);
        
       
         String saturation66eachesMDAllQuery = queryStr+'IO_potential_Range__c=\'MD\' AND Account_Saturation_Range__c = \'>66%\' ';
        List<Target_Profile__c> recssaturation66eachesMDAll = database.query(saturation66eachesMDAllQuery);
        recssaturation66eachesMDTotal = recssaturation66eachesMDAll.Size();
        recssaturation66eachesMD = getRecords(recssaturation66eachesMDAll);*/
        
    }//end of constructor
    public List<Target_Profile__c> getRecords(List<Target_Profile__c> allRecord){
        List<Target_Profile__c> recsToDisplay = new List<Target_Profile__c>();
        If(allRecord.Size() > 5)
        {
            for(integer i=0; i<5; i++){
                recsToDisplay.add(allRecord[i]);
            }
        }
        else{
            recsToDisplay.addAll(allRecord);
        }
        System.debug('recsToDisplay:'+recsToDisplay+'|All:'+allRecord);
        return recsToDisplay;
    }
}