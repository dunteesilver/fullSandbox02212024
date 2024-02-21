trigger master_Contact on Contact (before insert, before update, after insert, after update)  {
    
    if(Trigger.isInsert && Trigger.isBefore && master_TriggerHelperClass.runOnce('CONTACT-INSERT-BEFORE')){
        System.debug('--- INSERT and BEFORE trigger (master_Contact) ----');
        contact_Helper_Class.eloquaContactBU(Trigger.new,Trigger.oldmap,'insert');
        contact_Helper_Class.getSalesRepForMANTACon(Trigger.New);
    }
    if(Trigger.isInsert && Trigger.isAfter && master_TriggerHelperClass.runOnce('CONTACT-INSERT-AFTER')){
        System.debug('---- INSERT and AFTER trigger (master_Contact) ----');
    }

    if(Trigger.isUpdate && Trigger.isBefore && master_TriggerHelperClass.runOnce('CONTACT-UPDATE-BEFORE')){
        System.debug('---- UPDATE and BEFORE trigger (master_Contact) ----');
        contact_Helper_Class.eloquaContactBU(Trigger.new,Trigger.oldmap,'update');
        contact_Helper_Class.getSalesRepForMANTACon(Trigger.New);

    }
    if(Trigger.isUpdate && Trigger.isAfter && master_TriggerHelperClass.runOnce('CONTACT-UPDATE-AFTER')){
        System.debug('--- UPDATE and AFTER trigger (master_Contact) runOnce ----');
    }
}