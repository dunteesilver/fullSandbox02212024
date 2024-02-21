trigger checkSPIFF on Opportunity (Before Insert, Before Update) {
    Opportunity o = trigger.new[0];
    
//    Date validDate;
//    if(o.Revenue_Date__c != null){
//        validDate = o.Revenue_Date__c;
//    }else{
//        validDate = o.CloseDate;
 //   }
    
//    SET<String> oppPOI = new SET<String>();
//    if(o.Product_Of_Interest__c != null){
//        oppPOI.addAll(o.Product_Of_Interest__c.split(';'));
//    }
    
//    Boolean survey = o.Survey_Completed__c;
//    String oppPF = o.Product_Family__c;
//    double oppAMT = o.Amount;
    
//    LIST<SPIFF__c> activeSPIFFs = [SELECT Id, Product_Family__c, Product_Of_Interest__c FROM SPIFF__c WHERE Start_Date__c <= :validDate AND End_Date__c >= :validDate AND ((Product_Family__c = :oppPF AND Product_Of_Interest__c = :oppPOI) OR (Product_Family__c = :oppPF AND Product_Of_Interest__c = '')) AND Survey_Completed__c = :survey AND Minimum_Amount__c <= :oppAMT];

//    if(activeSPIFFs.size() > 0){
//        o.SPIFF_Name__c = activeSPIFFs[0].Id;
//    } else {
//        o.SPIFF_Name__c = null;
//    }
}