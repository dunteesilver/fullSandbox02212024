public class TargetProfileTriggerHandlerUtility {
    public void accountSaturationTpRangeCalculator(List<Target_Profile__c> newTargetProfile){
        String hospitalRecordTypeID = Schema.SObjectType.Target_Profile__c.getRecordTypeInfosByName().get('Hospital').getRecordTypeId();
        String preHospitalRecordTypeID = Schema.SObjectType.Target_Profile__c.getRecordTypeInfosByName().get('Pre-Hospital').getRecordTypeId();
        String otherRecordTypeID = Schema.SObjectType.Target_Profile__c.getRecordTypeInfosByName().get('Other').getRecordTypeId();
        for(Target_Profile__c tpRec: newTargetProfile){
            if(tpRec.X911_Calls_actual__c != null){
                tpRec.Cardiac_Arrest_Calls_actual__c = (tpRec.X911_Calls_actual__c*0.01);
            }
            
            
            if(tpRec.RecordTypeId == hospitalRecordTypeID){
                //Setting Range
                if(tpRec.H_IO_Account_Saturation__c < 33){
                    tpRec.Account_Saturation_Range__c = '<33%';
                } else if(tpRec.H_IO_Account_Saturation__c > 33 && tpRec.H_IO_Account_Saturation__c < 66){
                    tpRec.Account_Saturation_Range__c = '33%-66%';
                } else {
                    tpRec.Account_Saturation_Range__c = '>66%';
                }
                
                Integer Trauma_Center_Level = 0;
                //Adult_Trauma_Center_Level__c not Blank/NA but Pediatric_Trauma_Center_Level__c is Blank/NA use Adult_Trauma_Center_Level__c
                if(
                    !(
                        String.isBlank(tpRec.Adult_Trauma_Center_Level__c) || 
                        tpRec.Adult_Trauma_Center_Level__c == 'NA'
                    ) && 
                    ( 
                        String.isBlank(tpRec.Pediatric_Trauma_Center_Level__c) || 
                        tpRec.Pediatric_Trauma_Center_Level__c == 'NA'
                    )
                ){
                    Trauma_Center_Level = Integer.valueOf(tpRec.Adult_Trauma_Center_Level__c);
                }
                //Pediatric_Trauma_Center_Level__c not Blank/NA but Adult_Trauma_Center_Level__c is Blank/NA use Pediatric_Trauma_Center_Level__c
                else if(
                    (
                        String.isBlank(tpRec.Adult_Trauma_Center_Level__c) || 
                        tpRec.Adult_Trauma_Center_Level__c == 'NA'
                    ) && 
                    !( 
                        String.isBlank(tpRec.Pediatric_Trauma_Center_Level__c) || 
                        tpRec.Pediatric_Trauma_Center_Level__c == 'NA'
                    )
                ){
                    Trauma_Center_Level = Integer.valueOf(tpRec.Pediatric_Trauma_Center_Level__c);
                }
                //Both are not Blank/NA but Adult_Trauma_Center_Level__c <= Pediatric_Trauma_Center_Level__c use Adult_Trauma_Center_Level__c
                else if(
                    !(
                        String.isBlank(tpRec.Adult_Trauma_Center_Level__c) || 
                        tpRec.Adult_Trauma_Center_Level__c == 'NA'
                    ) && 
                    !( 
                        String.isBlank(tpRec.Pediatric_Trauma_Center_Level__c) || 
                        tpRec.Pediatric_Trauma_Center_Level__c == 'NA'
                    ) &&
                    Integer.valueOf(tpRec.Adult_Trauma_Center_Level__c) <= Integer.valueOf(tpRec.Pediatric_Trauma_Center_Level__c)
                ){
                    Trauma_Center_Level = Integer.valueOf(tpRec.Adult_Trauma_Center_Level__c);
                }
                //Both are not Blank/NA but Pediatric_Trauma_Center_Level__c <= Adult_Trauma_Center_Level__c use Pediatric_Trauma_Center_Level__c
                else if(
                    !(
                        String.isBlank(tpRec.Adult_Trauma_Center_Level__c) || 
                        tpRec.Adult_Trauma_Center_Level__c == 'NA'
                    ) && 
                    !( 
                        String.isBlank(tpRec.Pediatric_Trauma_Center_Level__c) || 
                        tpRec.Pediatric_Trauma_Center_Level__c == 'NA'
                    ) &&
                    Integer.valueOf(tpRec.Pediatric_Trauma_Center_Level__c) <= Integer.valueOf(tpRec.Adult_Trauma_Center_Level__c)
                ){
                    Trauma_Center_Level = Integer.valueOf(tpRec.Pediatric_Trauma_Center_Level__c);
                }
                
                if(
                    Trauma_Center_Level == 1
                    ||
                    (
                        Trauma_Center_Level == 0 &&
                        (
                                tpRec.Last_Year_Eaches__c > 240 || 
                                tpRec.Central_Line_IO_Potential__c > 240
                        )
                    )
                ){
                    tpRec.IO_Potential_Range__c  = 'A+';
                    tpRec.Actual_IO_Potential_Number__c = 365 + (tpRec.Last_Year_Eaches__c != null ? tpRec.Last_Year_Eaches__c : 0) + (tpRec.Central_Line_IO_Potential__c != null ? tpRec.Central_Line_IO_Potential__c : 0);
                } else if(
                    Trauma_Center_Level == 2
                    ||
                    (
                        Trauma_Center_Level == 0 &&
                        ((tpRec.Last_Year_Eaches__c <= 240 && tpRec.Last_Year_Eaches__c >= 180)
                         || (tpRec.Central_Line_IO_Potential__c <= 240 && tpRec.Central_Line_IO_Potential__c >= 180))
                    )
                ){
                    tpRec.IO_Potential_Range__c  = 'A';
                    tpRec.Actual_IO_Potential_Number__c = 180 + (tpRec.Last_Year_Eaches__c != null ? tpRec.Last_Year_Eaches__c : 0) + (tpRec.Central_Line_IO_Potential__c != null ? tpRec.Central_Line_IO_Potential__c : 0);
                } else if(
                    Trauma_Center_Level == 3
                    ||
                    (
                        Trauma_Center_Level == 0 && 
                        ((tpRec.Last_Year_Eaches__c < 180 && tpRec.Last_Year_Eaches__c >= 120)
                         || (tpRec.Central_Line_IO_Potential__c < 180 && tpRec.Central_Line_IO_Potential__c >= 120))
                    )
                ){
                    tpRec.IO_Potential_Range__c  = 'B';
                    tpRec.Actual_IO_Potential_Number__c = 90 + (tpRec.Last_Year_Eaches__c != null ? tpRec.Last_Year_Eaches__c : 0) + (tpRec.Central_Line_IO_Potential__c != null ? tpRec.Central_Line_IO_Potential__c : 0);
                } else {
                    tpRec.IO_Potential_Range__c  = 'C';
                    tpRec.Actual_IO_Potential_Number__c = 45 + (tpRec.Last_Year_Eaches__c != null ? tpRec.Last_Year_Eaches__c : 0) + (tpRec.Central_Line_IO_Potential__c != null ? tpRec.Central_Line_IO_Potential__c : 0);
                }
            }
            else {
                tpRec.Actual_IO_Potential_Number__c = (tpRec.X911_Calls_actual__c == null) ? tpRec.Estimated_IO_Potential_eaches__c : tpRec.IO_Potential_eaches__c;
                
                if(tpRec.RecordTypeId == preHospitalRecordTypeID){
                    if(tpRec.Actual_Account_Saturation__c  < 33){
                        tpRec.Account_Saturation_Range__c = '<33%';
                    } else if(tpRec.Actual_Account_Saturation__c > 33 && tpRec.Actual_Account_Saturation__c < 66){
                        tpRec.Account_Saturation_Range__c = '33%-66%';
                    } else {
                        tpRec.Account_Saturation_Range__c  = '>66%';
                    }
                    
                    if(tpRec.Last_Year_Eaches__c > 240 || tpRec.IO_Potential_for_Reporting__c > 240){
                        tpRec.IO_Potential_Range__c  = 'A+';
                    } else if((tpRec.Last_Year_Eaches__c < 241 && tpRec.Last_Year_Eaches__c >= 141)
                              || (tpRec.IO_Potential_for_Reporting__c < 241 && tpRec.IO_Potential_for_Reporting__c >= 141)){
                                  tpRec.IO_Potential_Range__c  = 'A';
                              } else if((tpRec.Last_Year_Eaches__c <= 140 && tpRec.Last_Year_Eaches__c >= 60)
                                        || (tpRec.IO_Potential_for_Reporting__c <= 140 && tpRec.IO_Potential_for_Reporting__c >= 60)){
                                            tpRec.IO_Potential_Range__c  = 'B';
                                        } else {
                                            tpRec.IO_Potential_Range__c  = 'C';
                                        }
                }
                
                if(tpRec.RecordTypeId == otherRecordTypeID){
                    tpRec.IO_Potential_Range__c  = 'O';
                }
            }
        }
    }
    public void accountSaturationTpRangeCalculatorForAccount(List<Target_Profile__c> newTargetProfile){
        Map<Id, Account> accountToUpdate = new Map<Id, Account>();
        String hospitalRecordTypeID = Schema.SObjectType.Target_Profile__c.getRecordTypeInfosByName().get('Hospital').getRecordTypeId();
        String preHospitalRecordTypeID = Schema.SObjectType.Target_Profile__c.getRecordTypeInfosByName().get('Pre-Hospital').getRecordTypeId();
        String otherRecordTypeID = Schema.SObjectType.Target_Profile__c.getRecordTypeInfosByName().get('Other').getRecordTypeId();
        
        for(Target_Profile__c tpRec: newTargetProfile){
            System.debug('After'+tpRec.Last_Year_Eaches__c+'@'+tpRec.IO_Potential_for_Reporting__c );
            if(tpRec.RecordTypeId == hospitalRecordTypeID){
                if(tpRec.Last_Year_Eaches__c > 240 || tpRec.IO_Potential_for_Reporting__c > 240){
                    if(!accountToUpdate.containsKey(tpRec.Account__c)){
                        accountToUpdate.put(tpRec.Account__c, new Account(Id=tpRec.Account__c, Target_Profile_TP_Range__c='A+'));
                    }
                } else if((tpRec.Last_Year_Eaches__c < 241 && tpRec.Last_Year_Eaches__c >= 141)
                          || (tpRec.IO_Potential_for_Reporting__c < 241 && tpRec.IO_Potential_for_Reporting__c >= 141)){
                              if(!accountToUpdate.containsKey(tpRec.Account__c)){
                                  accountToUpdate.put(tpRec.Account__c, new Account(Id=tpRec.Account__c, Target_Profile_TP_Range__c='A'));
                              }
                          } else if((tpRec.Last_Year_Eaches__c <= 140 && tpRec.Last_Year_Eaches__c >= 60)
                                    || (tpRec.IO_Potential_for_Reporting__c <= 140 && tpRec.IO_Potential_for_Reporting__c >= 60)){
                                        if(!accountToUpdate.containsKey(tpRec.Account__c)){
                                            accountToUpdate.put(tpRec.Account__c, new Account(Id=tpRec.Account__c, Target_Profile_TP_Range__c='B'));
                                        }
                                    } else {
                                        if(!accountToUpdate.containsKey(tpRec.Account__c)){
                                            accountToUpdate.put(tpRec.Account__c, new Account(Id=tpRec.Account__c, Target_Profile_TP_Range__c='C'));
                                        }
                                    }
            }
            else if(tpRec.RecordTypeId == preHospitalRecordTypeID){
                if(tpRec.Last_Year_Eaches__c > 240 || tpRec.IO_Potential_for_Reporting__c > 240){
                    if(!accountToUpdate.containsKey(tpRec.Account__c)){
                        accountToUpdate.put(tpRec.Account__c, new Account(Id=tpRec.Account__c, Target_Profile_TP_Range__c='A+'));
                    }
                } else if((tpRec.Last_Year_Eaches__c < 241 && tpRec.Last_Year_Eaches__c >= 141)
                          || (tpRec.IO_Potential_for_Reporting__c < 241 && tpRec.IO_Potential_for_Reporting__c >= 141)){
                              if(!accountToUpdate.containsKey(tpRec.Account__c)){
                                  accountToUpdate.put(tpRec.Account__c, new Account(Id=tpRec.Account__c, Target_Profile_TP_Range__c='A'));
                              }
                          } else if((tpRec.Last_Year_Eaches__c <= 140 && tpRec.Last_Year_Eaches__c >= 60)
                                    || (tpRec.IO_Potential_for_Reporting__c <= 140 && tpRec.IO_Potential_for_Reporting__c >= 60)){
                                        if(!accountToUpdate.containsKey(tpRec.Account__c)){
                                            accountToUpdate.put(tpRec.Account__c, new Account(Id=tpRec.Account__c, Target_Profile_TP_Range__c='B'));
                                        }
                                    } else {
                                        if(!accountToUpdate.containsKey(tpRec.Account__c)){
                                            accountToUpdate.put(tpRec.Account__c, new Account(Id=tpRec.Account__c, Target_Profile_TP_Range__c='C'));
                                        }
                                    }
            }
        }
        if(!accountToUpdate.isEmpty()){
            update accountToUpdate.values();
        }
    }
    public void setTargetProfileAccountId(List<Target_Profile__c> newTargetProfile){
        for(Target_Profile__c tpRec: newTargetProfile){
            if(String.isNotBlank(tpRec.Account__c)){
                tpRec.Other__c = tpRec.Account__c;
                tpRec.Account_Duplicate__c = tpRec.Account__c;
            }
        }
    }
}