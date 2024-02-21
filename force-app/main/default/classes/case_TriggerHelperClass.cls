public class case_TriggerHelperClass {

    private static boolean run = true;
        
    public static boolean qe(){
        // Checks to make sure that there is a custom setting named "Quick Disabled" and under
		// Manage a setting for 'Case' with 'Enabled' checkbox set to true. Disable the checkbox to
		// disable this trigger.
    	Quick_Disable__c qd = Quick_Disable__c.getInstance('Case');
        
        if (qd.Enable__c){
            return true;
        }
        else {
            return false;
        }
    }
    
    public static boolean runOnce(){
        if(run){
            run = false;
            return true;
        }
        else{
            return run;
        }
    }
    
    
    
}