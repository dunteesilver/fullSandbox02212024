public class Zip_Code_Territories_Lookup {
    
    private final Zip_Code_Territories__c zipt;

    public Zip_Code_Territories_Lookup(ApexPages.StandardController stdController) {

        this.zipt = (Zip_Code_Territories__c)stdController.getRecord();
   
    }
    public Territory_User__c getAlt_Care() {
        Try{
            return [SELECT User__r.Name, Territory_Master__r.Id  
                    FROM Territory_User__c 
                    WHERE Territory_Master__r.Name = :this.zipt.Alternate_Care__c
                    LIMIT 1];
       }
        catch(exception ex) {
            return null;
        }
        
    }
    public Territory_User__c getAnesthesia() {
        Try {
            return [SELECT User__r.Name, Territory_Master__r.Id  
                    FROM Territory_User__c 
                    WHERE Territory_Master__r.Name = :this.zipt.Anesthesia__c
                    LIMIT 1];
        }
        catch(exception ex) {
            return NULL;
        }
        
    }
    
     public Territory_User__c getEMS()  {
        Try {
            return [SELECT User__r.Name, Territory_Master__r.Id  
                    FROM Territory_User__c 
                    WHERE Territory_Master__r.Name = :this.zipt.EMS__c
                    LIMIT 1];
        }
        catch(exception ex) {
            return NULL;
        }
        
    }
    
     public Territory_User__c getIA()  {
        Try {
            return [SELECT User__r.Name, Territory_Master__r.Id  
                    FROM Territory_User__c 
                    WHERE Territory_Master__r.Name = :this.zipt.IA__c
                    LIMIT 1];
        }
        catch(exception ex) {
            return NULL;
        }
        
    }
    public Territory_User__c getRespiratory()  {
        try {
            return [SELECT User__r.Name, Territory_Master__r.Id  
                    FROM Territory_User__c 
                    WHERE Territory_Master__r.Name = :this.zipt.Respiratory__c
                    LIMIT 1];
        }
        catch(exception ex){
            return NULL;
        }
        
    }
     public Territory_User__c getSurg_Inst()  {
        try {
            return [SELECT User__r.Name, Territory_Master__r.Id  
                    FROM Territory_User__c 
                    WHERE Territory_Master__r.Name = :this.zipt.Surgical_Instruments__c
                    LIMIT 1];
        }
        catch(exception ex) {
            return NULL;
        }
        
    }
    
    public Territory_User__c getSurg_Disp()  {
         Try{
            return [SELECT User__r.Name, Territory_Master__r.Id  
                    FROM Territory_User__c 
                    WHERE Territory_Master__r.Name = :this.zipt.Surgical_Disposables__c
                    LIMIT 1];
       }
        catch(exception ex) {
            return null;
        }
        
    }
    
    public Territory_User__c getUrology()  {
        try {
            return [SELECT User__r.Name, Territory_Master__r.Id  
                    FROM Territory_User__c 
                    WHERE Territory_Master__r.Name = :this.zipt.Urology__c
                    LIMIT 1];
        }
        catch(exception ex) {
            return NULL;
        }
        
    }
    
    public Territory_User__c getVascular()  {
        try {
            return [SELECT User__r.Name, Territory_Master__r.Id  
                    FROM Territory_User__c 
                    WHERE Territory_Master__r.Name = :this.zipt.Vascular__c
                    LIMIT 1];
        }
        catch(exception ex) {
            return NULL;
        }
        
    }
  
    
        
}