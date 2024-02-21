public class master_TriggerHelperClass {    
    
    public static boolean qd(string quickdisable){
        // Checks to make sure that there is a custom setting named "Quick Disabled" and under
        // Manage a setting for 'Case' with 'Enabled' checkbox set to true. Disable the checkbox to
        // disable this trigger (MAY 2015 - ESC)
        // Added additional logic such that if the custom setting does not exist the trigger will fire by default
        // This helps with test classes (OCT 2015 - ESC)
        // Completely re-wrote this little buy to not take a SOQL hit - 08Sept2017 - ESC
        Quick_Disable__c qdRec = Quick_Disable__c.getValues(quickdisable);
        if(qdRec != NULL && qdRec.Enable__c){
            return true;
        }
        else {
            return false;
        }   
    }
    
    
    
    // This class is used and called/set on the child object to ensure that 
    // triggers are not inadvertently fired when an update/upsert to the child happens
    // See 'recursiveBlock' for the actual 'check' logic
    // Nov 2015 - ESC
    private static set<string> blockSet = new set<string>();
    
    public static void recursiveBlockSet(String Obj){
        blockSet.add(Obj);
    }
    
    // This is user and called from the parent object and does the actually checking
    public static boolean recursiveBlock(String Obj){
        // This tells you the object
        // Need to set the object and then from the object query the value
        //sObject addObj = Schema.getGlobalDescribe().get(objName).newSObject();

        if(blockSet.contains(Obj)){
            system.debug('Checking Child Blocking from Updating Parent:' + Obj + ' Status: True');
            return true;
        }
        else{
            system.debug('Checking Child Blocking from Updating Parent:' + Obj + ' Status: False');
            return false;            
        }
    }
    // End Recursive Logic
    
    
    private static set<string> onceSet = new set<string>();
    private static set<Id> beforeSet = new set<Id>(); // 31Aug2017 - ESC
    private static set<Id> afterSet = new set<Id>(); // 31Aug2017 - ESC
    public static void runOnceSetTrue(String cname){
        onceSet.add(cname);
    }    
    
    
    public static boolean superRunOnce(set<Id> sid, String type){
        // New - 31Aug2017 - ESC
        SYSTEM.debug('Running Super Run Once!');
        
        return true;
        /*
        if(beforeSet.containsAll(sid) && type == 'before'){
            return false;
        }
        else{
            system.debug('Adding: ' + sid);
            beforeSet.addAll(sid);
            return true;
        }
        
        if(afterSet.containsAll(sid) && type == 'after'){
            return false;
        }
        else{
            system.debug('Adding: ' + sid);
            afterSet.addAll(sid);
            return true;
        }*/
         
    }
    
    // Use this to reset: master_TriggerHelperClass.runOnce('resetOnceSet');
    public static boolean runOnce(String cname){

        //system.debug('Check Set:' + onceSet);
        if(cname == 'resetOnceSet'){
            onceSet.clear();
            return false;
        }
        else{
            
            system.debug('Check Set:' + onceSet);
            
            if(onceSet.contains(cname)){
                system.debug('-------------- Run only ONCE! ----------------');
                return false;
            }
            else{
                onceSet.add(cname);
                return true;
            }  
        }
        
    }
    
    
}