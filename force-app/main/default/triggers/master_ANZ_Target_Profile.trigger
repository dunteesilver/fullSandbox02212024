trigger master_ANZ_Target_Profile on ANZ_Target_Profiles__c (before insert,before update, after insert, after update, before delete, after delete) {
if (Trigger.isBefore) {
        if (Trigger.isInsert) {
          // Call class logic here!
        } 
        if (Trigger.isUpdate) {
          // Call class logic here!
       
       
        }
        if (Trigger.isDelete) {
          // Call class logic here!
        }
      }
    
      if (Trigger.isAfter) {
        if (Trigger.isInsert) {
          // Call class logic here!
        } 
        if (Trigger.isUpdate) {
           System.debug('*** isBefore - isUpdate master_Target_Profile ***');
        updateANZRollingSales addSales = new updateANZRollingSales();
          addSales.getNeedleSales(trigger.new);    
         
         
            
        }
        if (Trigger.isDelete) {
          // Call class logic here!
        }
      }
}