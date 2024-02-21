global class Invoice_Daily_Cleanup Implements Schedulable{

    global void execute(SchedulableContext sc){
        Global_Maintenance newGM = new Global_Maintenance();
        newGM.dailyMaintenance('Sales');
    }
}