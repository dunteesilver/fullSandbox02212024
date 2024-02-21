trigger oppProbability on Opportunity (before update, before insert) {
/*    System.debug('Made it1! -------');
    for(Opportunity opp: trigger.new){
        if(opp.RecordTypeId == '012E0000000R4kk'){ //Surgical
            OpportunityStage oppStage=[Select DefaultProbability From OpportunityStage where MasterLabel=:opp.stageName];
            opp.Probability = oppStage.DefaultProbability;
            
            opp.Focus__c='';
            
            if(opp.Product_Family__c == 'Instruments'){
                opp.Focus__c='Instruments';
            }
            
            if(opp.Product_Family__c == 'Skin Stapling'){
                opp.Focus__c='Core';
            }
            
            if(opp.Product_Of_Interest__c != Null){
                if(opp.Product_Of_Interest__c.contains('EFx') || opp.Product_Of_Interest__c.contains('Vista') || opp.Product_Of_Interest__c.contains('AE5')){
                    opp.Focus__c='Focus';
                }
                
                
                if(opp.Product_Of_Interest__c.contains('Cholangiography') || opp.Product_Of_Interest__c.contains('Metal') || opp.Product_Of_Interest__c.contains('Polymer') || opp.Product_Family__c == 'Suture'){
                    if(opp.Focus__c != ''){
                        opp.Focus__c=opp.Focus__c + '/Core';
                    }else{
                        opp.Focus__c='Core';
                    }
                }
            }
            //}else if(opp.RecordTypeId == '012E0000000R4Cz' && opp.Product_Of_Interest__c != Null){ //Anesthesia Respiratory
            //Anesthesia & Respiratory
        }
        else if((opp.RecordTypeId == '012E0000000RWQf' || opp.RecordTypeId == '012E0000000RWQg') && opp.Product_Of_Interest__c != Null){ 
            System.debug('Made it2! -------');
            List<String> focusProduct = new List<String>();
            List<String> coreProduct = new List<String>();
            Boolean focus = false;
            Boolean core = false;
            
            focusProduct.add('AutoFuser');
            focusProduct.add('FlexBlock');
            focusProduct.add('StimuQuik');
            focusProduct.add('StimuQuik Echo');
            focusProduct.add('UltraQuik');
            focusProduct.add('DispoLED');
            focusProduct.add('Endobronchial Blockers');
            focusProduct.add('LMA Supreme');
            focusProduct.add('ISO-Gard Mask');
            focusProduct.add('EtCO2 Cannulas');
            focusProduct.add('ConchaSmart Columns/Kits');
            
            coreProduct.add('StimuCath');
            coreProduct.add('Epidurals');
            coreProduct.add('Spinals');
            coreProduct.add('Other Pain Management');
            coreProduct.add('TruLite');
            coreProduct.add('Green RuschLite');
            coreProduct.add('EquipLite');
            coreProduct.add('Reusable Laryngoscopes');
            coreProduct.add('Endotracheal Tubes');
            coreProduct.add('Stylets');
            coreProduct.add('Endobronchial Tubes');
            coreProduct.add('Nasal & Oral Airways');
            coreProduct.add('LMA Unique');
            coreProduct.add('LMA Re-usables');
            coreProduct.add('LMA Fastrach');
            coreProduct.add('Atomization');
            coreProduct.add('Other Airway');
            coreProduct.add('Neptune');
            coreProduct.add('Voldyne');
            coreProduct.add('Pocket Chamber');
            coreProduct.add('Peak Flow Meter');
            coreProduct.add('Filters/HMEs');
            coreProduct.add('Large Volume Nebulizers');
            coreProduct.add('Small Volume Nebulizers');
            coreProduct.add('Hyperinflation/Resuscitation bags');
            coreProduct.add('Other Respiratory');
            
            for(String fp : focusProduct){
                if(opp.Product_Of_Interest__c.contains(fp)){
                    focus = true;
                }
            }
            for(String cp : coreProduct){
                if(opp.Product_Of_Interest__c.contains(cp)){
                    core = true;
                }
            }
            
            if(focus && core){
                opp.AR_Focus_v_Core__c = 'Core/Focus';
            }else if(focus){
                opp.AR_Focus_v_Core__c = 'Focus';
            }else if(core){
                opp.AR_Focus_v_Core__c = 'Core';
            }
        }
    }*/
}