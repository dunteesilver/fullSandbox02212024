global class Build_Open_Order_Summary_Schedule Implements Schedulable{
    // Create 18Jun2018 - ESC
    // Test Class: Invoiced_Global_Test_Class.testScheduledClasses
    global void execute(SchedulableContext sc){
        
        Build_Open_Order_Summary_Batch boos = new Build_Open_Order_Summary_Batch();
        Database.executeBatch(boos);
        
    }
}