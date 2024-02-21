trigger master_Target_Profile on Target_Profile__c (before insert, before update, after insert, after update, before delete, after delete) {
    
      if (Trigger.isBefore) {
        TargetProfileTriggerHandlerUtility handlerObj = new TargetProfileTriggerHandlerUtility();
        if (Trigger.isInsert) {
          handlerObj.accountSaturationTpRangeCalculator(trigger.new);
          handlerObj.setTargetProfileAccountId(trigger.new);
        } 
        if (Trigger.isUpdate) {
          handlerObj.accountSaturationTpRangeCalculator(trigger.new);
          handlerObj.setTargetProfileAccountId(trigger.new);
        }
        if (Trigger.isDelete) {
          // Call class logic here!
        }
      }
    
      if (Trigger.isAfter) {
        TargetProfileTriggerHandlerUtility handlerObj = new TargetProfileTriggerHandlerUtility();
        if (Trigger.isInsert) {
          handlerObj.accountSaturationTpRangeCalculatorForAccount(trigger.new);
        } 
        if (Trigger.isUpdate) {
          handlerObj.accountSaturationTpRangeCalculatorForAccount(trigger.new);
          System.debug('*** isBefore - isUpdate master_Target_Profile ***');
          updateRollingSales addSales = new updateRollingSales();
          addSales.getNeedleSales(trigger.new);
        }
        if (Trigger.isDelete) {
          // Call class logic here!
        }
      }
}