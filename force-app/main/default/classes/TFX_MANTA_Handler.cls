/*********************************************************************
* Description      : Controller Class for Teleflex MANTA Aura Components Bundle.
* Test Class       : TFX_MANTA_Handler_Test
* VisualForce      : TFX_MANTA*.cmp
* Author(s)        : Surya Arvan - surya.arvan@teleflex.com
**********************************************************************/
public class TFX_MANTA_Handler {
    
    public class UserWrapper{
        @AuraEnabled public String usrId {get; set;}
        @AuraEnabled public String usrName {get; set;}
        @AuraEnabled public Boolean usrIsAdmin {get; set;}
    }
    
    public class DateFilterWrapper{
        @AuraEnabled public Date fromDate {get; set;}
        @AuraEnabled public Date toDate {get; set;}
    }
    
    @AuraEnabled
    public static UserWrapper getLoggedInUser(){
        
        UserWrapper usrWrapper = new UserWrapper();
        
        User loggedUser = [select Id, Name from User where Id =: UserInfo.getUserId()];
        
        try{          
            MANTA_Master__c mantaProcObj = [select 
                                            Trainer__c, 
                                            Trainer__r.Name, 
                                            isAdminAccess__c 
                                            from MANTA_Master__c 
                                            where Trainer__c =: UserInfo.getUserId()];usrWrapper.usrId = mantaProcObj.Trainer__c;usrWrapper.usrName = mantaProcObj.Trainer__r.Name;usrWrapper.usrIsAdmin = mantaProcObj.isAdminAccess__c;
        }
        catch(Exception ex){
            usrWrapper.usrId = loggedUser.Id;
            usrWrapper.usrName = loggedUser.Name;
            usrWrapper.usrIsAdmin = false;  
        }
        return usrWrapper;
    }
    
    @AuraEnabled
    public static MANTA_Proctorship_Request__c saveMANTANewRequest(String  newReqObj){
        
        MANTA_Proctorship_Request__c newReqObjToSave = new MANTA_Proctorship_Request__c();
        
        try{
            newReqObjToSave = (MANTA_Proctorship_Request__c)JSON.deserialize(newReqObj, MANTA_Proctorship_Request__c.class);
            //Database.insert(newReqObjToSave, false);
            insert newReqObjToSave;
            
            return newReqObjToSave;
        }
        catch(Exception ex){
            System.debug('exception occured-->'+ex.getLineNumber()+' Ln#-->'+ ex.getLineNumber()+ 'cause--' +ex.getCause());
            return newReqObjToSave;
        }
        
    }
    
    @AuraEnabled
    public static Boolean updateMANTAOpenReq(String  editOpenReqObj){
        
        MANTA_Proctorship_Request__c saveModfdOpenReqObj = (MANTA_Proctorship_Request__c)JSON.deserialize(editOpenReqObj, MANTA_Proctorship_Request__c.class);
        
        if(saveModfdOpenReqObj.Status__c == 'No Trainer Needed' || saveModfdOpenReqObj.Status__c == 'Open (Not Accepted)'){           
            Database.update(saveModfdOpenReqObj, false);
            return true;
        }
        else{            
            try{              
                update saveModfdOpenReqObj;  
                sendEmailToProctorsInAccRegion(saveModfdOpenReqObj);
                return true;
            }
            catch(Exception ex){
                System.debug('in catch===>'+ex);
                return false;
            }
        }
        
    }
    
    @AuraEnabled
    public static Boolean updateMANTAAcceptedReq(String  editAcceptedReqObj){
        
        MANTA_Proctorship_Request__c saveModfdAcceptedReqObj = (MANTA_Proctorship_Request__c)JSON.deserialize(editAcceptedReqObj, MANTA_Proctorship_Request__c.class);   
        try{
            update saveModfdAcceptedReqObj;
            return true;
        }
        catch(Exception ex){
            return false;
        }
        
    }
    
    @AuraEnabled
    public static List<MANTA_Proctorship_Request__c> getAllOrSelHospOpenReqs(String haccId, String regionName){
        
        List<MANTA_Proctorship_Request__c> mantaOpenReqsLst = new List<MANTA_Proctorship_Request__c>();
        
        if(haccId == 'All' && regionName != 'All'){ 
            mantaOpenReqsLst = [select Id,
                                Name,
                                Case_Date__c, 
                                Hospital__r.Name, 
                                Physician__r.Salutation,
                                Physician__r.Name,
                                Physician_NPI_Number__c,
                                Case_Type__c, 
                                Estimated_of_Cases__c, 
                                Case_Initiator__r.Name, 
                                Notes__c,
                                Status__c,
                                Days_Open__c,
                                Region__c
                                from MANTA_Proctorship_Request__c 
                                where Status__c = 'Open (Not Accepted)'
                                and Region__c =: regionName
                                order by CreatedDate desc ]; 
        }
        else if(regionName == 'All' && haccId != 'All'){
            mantaOpenReqsLst = [select Id,
                                Name,
                                Case_Date__c, 
                                Hospital__r.Name, 
                                Physician__r.Salutation,
                                Physician__r.Name, 
                                Physician_NPI_Number__c,
                                Case_Type__c, 
                                Estimated_of_Cases__c, 
                                Case_Initiator__r.Name, 
                                Notes__c,
                                Status__c,
                                Days_Open__c,
                                Region__c
                                from MANTA_Proctorship_Request__c 
                                where Status__c = 'Open (Not Accepted)'
                                and Hospital__c =: haccId
                                order by CreatedDate desc
                               ];
        }
        else if(regionName == 'All' && haccId == 'All'){
            mantaOpenReqsLst = [select Id, 
                                Name,
                                Case_Date__c, 
                                Hospital__r.Name, 
                                Physician__r.Salutation,
                                Physician__r.Name, 
                                Physician_NPI_Number__c,
                                Case_Type__c, 
                                Estimated_of_Cases__c, 
                                Case_Initiator__r.Name, 
                                Notes__c,
                                Status__c,
                                Days_Open__c,
                                Region__c
                                from MANTA_Proctorship_Request__c 
                                where Status__c = 'Open (Not Accepted)'
                                order by CreatedDate desc
                               ];
        }
        else {
            mantaOpenReqsLst = [select Id, 
                                Name,
                                Case_Date__c, 
                                Hospital__r.Name, 
                                Physician__r.Salutation,
                                Physician__r.Name, 
                                Physician_NPI_Number__c,
                                Case_Type__c, 
                                Estimated_of_Cases__c, 
                                Case_Initiator__r.Name, 
                                Notes__c,
                                Status__c,
                                Days_Open__c,
                                Region__c
                                from MANTA_Proctorship_Request__c 
                                where Status__c = 'Open (Not Accepted)'
                                and Hospital__c =: haccId
                                and Region__c =: regionName
                                order by CreatedDate desc
                               ];
        }
        
        
        return mantaOpenReqsLst;
    }
    
    @AuraEnabled
    public static List<MANTA_Proctorship_Request__c> getAllOrSelHospCancelledReqs(String haccId, String regionName){
        
        List<MANTA_Proctorship_Request__c> mantaOpenReqsLst = new List<MANTA_Proctorship_Request__c>();
        
        if(haccId == 'All' && regionName != 'All'){ 
            mantaOpenReqsLst = [select Id, 
                                Name,
                                Case_Date__c, 
                                Hospital__r.Name, 
                                Physician__r.Salutation,
                                Physician__r.Name,
                                Physician_NPI_Number__c,
                                Case_Type__c, 
                                Estimated_of_Cases__c, 
                                Case_Initiator__r.Name, 
                                Notes__c,
                                Status__c,
                                Days_Open__c,
                                Region__c
                                from MANTA_Proctorship_Request__c 
                                where Status__c = 'Cancelled'
                                and Region__c =: regionName
                                order by CreatedDate desc ]; 
        }
        else if(regionName == 'All' && haccId != 'All'){
            mantaOpenReqsLst = [select Id, 
                                Name,
                                Case_Date__c, 
                                Hospital__r.Name, 
                                Physician__r.Salutation,
                                Physician__r.Name, 
                                Physician_NPI_Number__c,
                                Case_Type__c, 
                                Estimated_of_Cases__c, 
                                Case_Initiator__r.Name, 
                                Notes__c,
                                Status__c,
                                Days_Open__c,
                                Region__c
                                from MANTA_Proctorship_Request__c 
                                where Status__c = 'Cancelled'
                                and Hospital__c =: haccId
                                order by CreatedDate desc
                               ];
        }
        else if(regionName == 'All' && haccId == 'All'){
            mantaOpenReqsLst = [select Id,
                                Name,
                                Case_Date__c, 
                                Hospital__r.Name, 
                                Physician__r.Salutation,
                                Physician__r.Name, 
                                Physician_NPI_Number__c,
                                Case_Type__c, 
                                Estimated_of_Cases__c, 
                                Case_Initiator__r.Name, 
                                Notes__c,
                                Status__c,
                                Days_Open__c,
                                Region__c
                                from MANTA_Proctorship_Request__c 
                                where Status__c = 'Cancelled'
                                order by CreatedDate desc
                               ];
        }
        else {
            mantaOpenReqsLst = [select Id, 
                                Name,
                                Case_Date__c, 
                                Hospital__r.Name, 
                                Physician__r.Salutation,
                                Physician__r.Name, 
                                Physician_NPI_Number__c,
                                Case_Type__c, 
                                Estimated_of_Cases__c, 
                                Case_Initiator__r.Name, 
                                Notes__c,
                                Status__c,
                                Days_Open__c,
                                Region__c
                                from MANTA_Proctorship_Request__c 
                                where Status__c = 'Cancelled'
                                and Hospital__c =: haccId
                                and Region__c =: regionName
                                order by CreatedDate desc
                               ];
        }
        
        
        return mantaOpenReqsLst;
    }
    
    //get date filters method to return from and to date default values in app
    @AuraEnabled
    public static DateFilterWrapper getDfltValsForDateFilters(){
        DateFilterWrapper dtFilObj = new DateFilterWrapper();  
        dtFilObj.fromDate = System.today().addMonths(-1);
        dtFilObj.toDate = System.today();
        return dtFilObj;
    }
    
    //Case requests that are archived...calculated from isArchived__c formula field
    @AuraEnabled
    public static List<MANTA_Proctorship_Request__c> getAllOrSelHospArchivedReqs(String haccId, String regionName, Date fromDate, Date toDate){
        List<MANTA_Proctorship_Request__c> mantaOpenReqsLst = new List<MANTA_Proctorship_Request__c>();
        if(haccId == 'All' && regionName != 'All'){ 
            mantaOpenReqsLst = [SELECT Id, 
                                Name,
                                Case_Date__c, 
                                Hospital__r.Name, 
                                Physician__r.Salutation,
                                Physician__r.Name,
                                Physician_NPI_Number__c,
                                Case_Type__c, 
                                Estimated_of_Cases__c, 
                                Case_Initiator__r.Name, 
                                Notes__c,
                                Status__c,
                                Days_Open__c,
                                Region__c,
                                CreatedDate
                                FROM MANTA_Proctorship_Request__c 
                                WHERE isArchived__c = TRUE
                                AND Region__c =: regionName
                                AND CreatedDate >: fromDate
                                AND CreatedDate <: toDate
                                order BY CreatedDate DESC]; 
        }
        else if(regionName == 'All' && haccId != 'All'){
            mantaOpenReqsLst = [SELECT Id, 
                                Name,
                                Case_Date__c, 
                                Hospital__r.Name, 
                                Physician__r.Salutation,
                                Physician__r.Name, 
                                Physician_NPI_Number__c,
                                Case_Type__c, 
                                Estimated_of_Cases__c, 
                                Case_Initiator__r.Name, 
                                Notes__c,
                                Status__c,
                                Days_Open__c,
                                Region__c,
                                CreatedDate
                                FROM MANTA_Proctorship_Request__c 
                                WHERE isArchived__c = TRUE
                                AND Hospital__c =: haccId
                                AND CreatedDate >: fromDate
                                AND CreatedDate <: toDate
                                order BY CreatedDate DESC
                               ];
        }
        else if(regionName == 'All' && haccId == 'All'){
            mantaOpenReqsLst = [SELECT Id, 
                                Name,
                                Case_Date__c, 
                                Hospital__r.Name, 
                                Physician__r.Salutation,
                                Physician__r.Name, 
                                Physician_NPI_Number__c,
                                Case_Type__c, 
                                Estimated_of_Cases__c, 
                                Case_Initiator__r.Name, 
                                Notes__c,
                                Status__c,
                                Days_Open__c,
                                Region__c,
                                CreatedDate
                                FROM MANTA_Proctorship_Request__c 
                                WHERE isArchived__c = TRUE
                                AND CreatedDate >: fromDate
                                AND CreatedDate <: toDate
                                order BY CreatedDate DESC
                               ];
        }
        else {
            mantaOpenReqsLst = [SELECT Id, 
                                Name,
                                Case_Date__c, 
                                Hospital__r.Name, 
                                Physician__r.Salutation,
                                Physician__r.Name, 
                                Physician_NPI_Number__c,
                                Case_Type__c, 
                                Estimated_of_Cases__c, 
                                Case_Initiator__r.Name, 
                                Notes__c,
                                Status__c,
                                Days_Open__c,
                                Region__c,
                                CreatedDate
                                FROM MANTA_Proctorship_Request__c 
                                WHERE isArchived__c = TRUE
                                AND Hospital__c =: haccId
                                AND Region__c =: regionName
                                AND CreatedDate >: fromDate
                                AND CreatedDate <: toDate
                                order BY CreatedDate DESC
                               ];
        } 
        return mantaOpenReqsLst;
    }
    
    
    @AuraEnabled
    public static Boolean getUsrProcForEdit(String  usrId){
        
        try{
            MANTA_Master__c usrProcObj = [select Trainer__c from MANTA_Master__c where Trainer__c =: usrId]; return true;
        }
        catch(Exception ex){
            return false;
        }
    }
    
    @AuraEnabled
    public static List<MANTA_Proctorship_Request__c> getAllOrSelHospAcptdReqs(String haccId, String regionName){
        
        List<MANTA_Proctorship_Request__c> mantaAcceptedReqsLst = new List<MANTA_Proctorship_Request__c>();
        
        if(haccId == 'All' && regionName != 'All'){ 
            mantaAcceptedReqsLst = [select Id, 
                                    Name,
                                    Case_Date__c, 
                                    Hospital__r.Name, 
                                    Physician__r.Salutation,
                                    Physician__r.Name,
                                    Physician_NPI_Number__c,
                                    Case_Type__c, 
                                    Estimated_of_Cases__c, 
                                    Case_Initiator__r.Name, 
                                    Notes__c,
                                    Days_Open__c,
                                    Hospital__r.Shipping_Address_Full__c,
                                    Hospital__r.ShippingAddress,
                                    Hospital__r.ShippingStreet,
                                    Hospital__r.ShippingCity, 
                                    Hospital__r.ShippingCountry, 
                                    Hospital__r.ShippingPostalCode,
                                    Hospital__r.ShippingState,
                                    Proctor__r.Name,
                                    Region__c,
                                    Status__c,
                                    
                                    (select Id, 
                                     Name,
                                     Case_Date__c ,
                                     MANTA_Not_Used__c,
                                     Case_Start_Time__c ,
                                     Deploying_Physician__c,
                                     Deploying_Physician__r.Name ,
                                     Hospital_Name__c,
                                     Hospital_Name__r.Name,
                                     MANTA_Trainer__c,
                                     MANTA_Trainer__r.Name,
                                     MANTA_Trainer_in_Training__c,
                                     MANTA_Trainer_in_Training__r.Name,
                                     Case_Type__c,
                                     Left_Femoral_Vessel_Size__c,
                                     Right_Femoral_Vessel_Size__c,
                                     Tortuosity__c,
                                     Tortuosity_Comments__c,
                                     Calcification__c,
                                     Calcification_Location__c,
                                     Pre_Arteriogram_Taken__c,
                                     Ultrasound_Guided_Access_Used__c,
                                     Depth_1_Measurment__c,
                                     Additional_Access_Notes__c,
                                     Device_Manufacturer__c,
                                     Device__c,
                                     Device_Size__c,
                                     Heparin_Total_at_End_of_Case__c,
                                     ACT_Prior_to_MANTA_Closure__c,
                                     Blood_Pressure_Prior_to_MANTA_Closure__c,
                                     Protamine_Given__c,
                                     Amt_of_Protamine_Given__c,
                                     Time_Protamine_was_Given__c,
                                     Size_of_MANTA_Device_Used__c,
                                     MANTA_Lot_Number__c,
                                     Other_Wire_Used__c,
                                     Time_of_MANTA_Deployment__c,
                                     Post_Arteriogram_Taken__c,
                                     Micropuncture_used_for_access__c,
                                     Reason_MANTA_Not_Used__c
                                     from MANTA_Case_Datas__r
                                     order by CreatedDate desc)
                                    
                                    from MANTA_Proctorship_Request__c 
                                    where Status__c = 'Accepted'
                                    //and isArchived__c = false
                                    and Region__c =: regionName
                                    order by CreatedDate desc
                                   ]; 
        }
        else if(regionName == 'All' && haccId != 'All'){
            mantaAcceptedReqsLst = [select Id, 
                                    Name,
                                    Case_Date__c, 
                                    Hospital__r.Name, 
                                    Physician__r.Salutation,
                                    Physician__r.Name,
                                    Physician_NPI_Number__c,
                                    Case_Type__c, 
                                    Estimated_of_Cases__c, 
                                    Case_Initiator__r.Name, 
                                    Notes__c,
                                    Days_Open__c,
                                    Hospital__r.Shipping_Address_Full__c,
                                    Hospital__r.ShippingAddress,
                                    Hospital__r.ShippingStreet,
                                    Hospital__r.ShippingCity, 
                                    Hospital__r.ShippingCountry, 
                                    Hospital__r.ShippingPostalCode,
                                    Hospital__r.ShippingState,
                                    Proctor__r.Name,
                                    Region__c,
                                    Status__c,
                                    
                                    (select Id, 
                                     Name,
                                     Case_Date__c ,
                                     MANTA_Not_Used__c,
                                     Case_Start_Time__c ,
                                     Deploying_Physician__c,
                                     Deploying_Physician__r.Name ,
                                     Hospital_Name__c,
                                     Hospital_Name__r.Name,
                                     MANTA_Trainer__c,
                                     MANTA_Trainer__r.Name,
                                     MANTA_Trainer_in_Training__c,
                                     MANTA_Trainer_in_Training__r.Name,
                                     Case_Type__c,
                                     Left_Femoral_Vessel_Size__c,
                                     Right_Femoral_Vessel_Size__c,
                                     Tortuosity__c,
                                     Tortuosity_Comments__c,
                                     Calcification__c,
                                     Calcification_Location__c,
                                     Pre_Arteriogram_Taken__c,
                                     Ultrasound_Guided_Access_Used__c,
                                     Depth_1_Measurment__c,
                                     Additional_Access_Notes__c,
                                     Device_Manufacturer__c,
                                     Device__c,
                                     Device_Size__c,
                                     Heparin_Total_at_End_of_Case__c,
                                     ACT_Prior_to_MANTA_Closure__c,
                                     Blood_Pressure_Prior_to_MANTA_Closure__c,
                                     Protamine_Given__c,
                                     Amt_of_Protamine_Given__c,
                                     Time_Protamine_was_Given__c,
                                     Size_of_MANTA_Device_Used__c,
                                     MANTA_Lot_Number__c,
                                     Other_Wire_Used__c,
                                     Time_of_MANTA_Deployment__c,
                                     Post_Arteriogram_Taken__c,
                                     Micropuncture_used_for_access__c,
                                     Reason_MANTA_Not_Used__c
                                     from MANTA_Case_Datas__r
                                     order by CreatedDate desc)
                                    
                                    from MANTA_Proctorship_Request__c 
                                    where Status__c = 'Accepted'
                                    //and isArchived__c = false
                                    and Hospital__c =: haccId
                                    order by CreatedDate desc
                                   ]; 
        }
        else if(regionName == 'All' && haccId == 'All'){
            mantaAcceptedReqsLst = [select Id, 
                                    Name,
                                    Case_Date__c, 
                                    Hospital__r.Name, 
                                    Physician__r.Salutation,
                                    Physician__r.Name,
                                    Physician_NPI_Number__c,
                                    Case_Type__c, 
                                    Estimated_of_Cases__c, 
                                    Case_Initiator__r.Name, 
                                    Notes__c,
                                    Days_Open__c,
                                    Hospital__r.Shipping_Address_Full__c,
                                    Hospital__r.ShippingAddress,
                                    Hospital__r.ShippingStreet,
                                    Hospital__r.ShippingCity, 
                                    Hospital__r.ShippingCountry, 
                                    Hospital__r.ShippingPostalCode,
                                    Hospital__r.ShippingState,
                                    Proctor__r.Name,
                                    Region__c,
                                    Status__c,
                                    
                                    (select Id, 
                                     Name,
                                     Case_Date__c ,
                                     MANTA_Not_Used__c,
                                     Case_Start_Time__c ,
                                     Deploying_Physician__c,
                                     Deploying_Physician__r.Name ,
                                     Hospital_Name__c,
                                     Hospital_Name__r.Name,
                                     MANTA_Trainer__c,
                                     MANTA_Trainer__r.Name,
                                     MANTA_Trainer_in_Training__c,
                                     MANTA_Trainer_in_Training__r.Name,
                                     Case_Type__c,
                                     Left_Femoral_Vessel_Size__c,
                                     Right_Femoral_Vessel_Size__c,
                                     Tortuosity__c,
                                     Tortuosity_Comments__c,
                                     Calcification__c,
                                     Calcification_Location__c,
                                     Pre_Arteriogram_Taken__c,
                                     Ultrasound_Guided_Access_Used__c,
                                     Depth_1_Measurment__c,
                                     Additional_Access_Notes__c,
                                     Device_Manufacturer__c,
                                     Device__c,
                                     Device_Size__c,
                                     Heparin_Total_at_End_of_Case__c,
                                     ACT_Prior_to_MANTA_Closure__c,
                                     Blood_Pressure_Prior_to_MANTA_Closure__c,
                                     Protamine_Given__c,
                                     Amt_of_Protamine_Given__c,
                                     Time_Protamine_was_Given__c,
                                     Size_of_MANTA_Device_Used__c,
                                     MANTA_Lot_Number__c,
                                     Other_Wire_Used__c,
                                     Time_of_MANTA_Deployment__c,
                                     Post_Arteriogram_Taken__c,
                                     Micropuncture_used_for_access__c,
                                     Reason_MANTA_Not_Used__c
                                     from MANTA_Case_Datas__r
                                     order by CreatedDate desc)
                                    
                                    from MANTA_Proctorship_Request__c 
                                    where Status__c = 'Accepted'
                                    //and isArchived__c = false
                                    and Case_Date__c >=: system.today()-14
                                    order by CreatedDate desc
                                   ]; 
        }
        else {
            mantaAcceptedReqsLst = [select Id, 
                                    Name,
                                    Case_Date__c, 
                                    Hospital__r.Name, 
                                    Physician__r.Salutation,
                                    Physician__r.Name,
                                    Physician_NPI_Number__c,
                                    Case_Type__c, 
                                    Estimated_of_Cases__c, 
                                    Case_Initiator__r.Name, 
                                    Notes__c,
                                    Days_Open__c,
                                    Hospital__r.Shipping_Address_Full__c,
                                    Hospital__r.ShippingAddress,
                                    Hospital__r.ShippingStreet,
                                    Hospital__r.ShippingCity, 
                                    Hospital__r.ShippingCountry, 
                                    Hospital__r.ShippingPostalCode,
                                    Hospital__r.ShippingState,
                                    Proctor__r.Name,
                                    Region__c,
                                    Status__c,
                                    
                                    (select Id, 
                                     Name,
                                     Case_Date__c ,
                                     MANTA_Not_Used__c,
                                     Case_Start_Time__c ,
                                     Deploying_Physician__c,
                                     Deploying_Physician__r.Name ,
                                     Hospital_Name__c,
                                     Hospital_Name__r.Name,
                                     MANTA_Trainer__c,
                                     MANTA_Trainer__r.Name,
                                     MANTA_Trainer_in_Training__c,
                                     MANTA_Trainer_in_Training__r.Name,
                                     Case_Type__c,
                                     Left_Femoral_Vessel_Size__c,
                                     Right_Femoral_Vessel_Size__c,
                                     Tortuosity__c,
                                     Tortuosity_Comments__c,
                                     Calcification__c,
                                     Calcification_Location__c,
                                     Pre_Arteriogram_Taken__c,
                                     Ultrasound_Guided_Access_Used__c,
                                     Depth_1_Measurment__c,
                                     Additional_Access_Notes__c,
                                     Device_Manufacturer__c,
                                     Device__c,
                                     Device_Size__c,
                                     Heparin_Total_at_End_of_Case__c,
                                     ACT_Prior_to_MANTA_Closure__c,
                                     Blood_Pressure_Prior_to_MANTA_Closure__c,
                                     Protamine_Given__c,
                                     Amt_of_Protamine_Given__c,
                                     Time_Protamine_was_Given__c,
                                     Size_of_MANTA_Device_Used__c,
                                     MANTA_Lot_Number__c,
                                     Other_Wire_Used__c,
                                     Time_of_MANTA_Deployment__c,
                                     Post_Arteriogram_Taken__c,
                                     Micropuncture_used_for_access__c,
                                     Reason_MANTA_Not_Used__c
                                     from MANTA_Case_Datas__r
                                     order by CreatedDate desc)
                                    
                                    from MANTA_Proctorship_Request__c 
                                    where Status__c = 'Accepted'
                                    //and isArchived__c = false
                                    and Hospital__c =: haccId
                                    and Region__c =: regionName
                                    order by CreatedDate desc
                                   ]; 
        }
        
        
        return mantaAcceptedReqsLst;
    }
    
    @AuraEnabled
    public static List<MANTA_Master__c> getAllProctorsInSF(){
        
        List<MANTA_Master__c> proctorsFrmMantaMstrLst = [select Id, 
                                                         Trainer__c, 
                                                         Trainer__r.Name,
                                                         Trainer__r.Email,
                                                         Trainer__r.Region__c,
                                                         isAdminAccess__c,
                                                         isActive__c
                                                         from MANTA_Master__c
                                                         where Type__c = 'proctor'
                                                         and isActive__c = true
                                                         order by Trainer__r.Name ASC
                                                        ]; 
        
        return proctorsFrmMantaMstrLst;
    }
    
    @AuraEnabled
    public static List<MANTA_Master__c> getProctorByProctorId(String proctorId){
        
        List<MANTA_Master__c> proctorsFrmMantaMstrLst = new List<MANTA_Master__c>();
        
        if(proctorId == 'All'){
            proctorsFrmMantaMstrLst = [select Id, 
                                       Trainer__c, 
                                       Trainer__r.Name,
                                       Trainer__r.Email,
                                       Trainer__r.Region__c,
                                       isAdminAccess__c,
                                       isActive__c
                                       from MANTA_Master__c
                                       where Type__c = 'proctor'
                                       and isActive__c = true
                                       order by Trainer__r.Name ASC
                                      ]; 
        }
        else{
            proctorsFrmMantaMstrLst = [select Trainer__c, 
                                       Trainer__r.Name,
                                       Trainer__r.Email,
                                       Trainer__r.Region__c,
                                       isAdminAccess__c,
                                       isActive__c
                                       from MANTA_Master__c
                                       where Type__c = 'proctor'
                                       and isActive__c = true
                                       and Trainer__c =: proctorId
                                       
                                      ];
        }
        
        
        return proctorsFrmMantaMstrLst;
    }
    
    @AuraEnabled
    public static Boolean addProctorInSF(Id procUsrId){
        
        try{
            MANTA_Master__c usrObj = [select Id, Trainer__c from MANTA_Master__c where Trainer__c =: procUsrId]; return true;
        }
        catch(Exception ex){
            MANTA_Master__c mantaMstrProcObj = new MANTA_Master__c();
            mantaMstrProcObj.Trainer__c = procUsrId;
            mantaMstrProcObj.Type__c = 'proctor';
            mantaMstrProcObj.isActive__c = true;
            Database.insert(mantaMstrProcObj, false);          
            return false;
        }
        
    }
    
    @AuraEnabled
    public static String updateMANTAProctor(String  editProcObj){
        
        MANTA_Master__c saveModfdProcObj = (MANTA_Master__c)JSON.deserialize(editProcObj, MANTA_Master__c.class);
        Database.update(saveModfdProcObj);
        
        return editProcObj;
    }
    
    @AuraEnabled
    public static Map<String, List<SObject>> getAllPhysAndRgnByHospAccId(Id hospAccId) {
        Map<String, List<SObject>> phyAndRegionMap = new Map<String, List<SObject>>();
        List<sObject> northLst = new List<sObject>();
        List<sObject> southLst = new List<sObject>();
        List<sObject> westLst = new List<sObject>();
        Set<String> tset = new Set<String>();
        List<String> sortedvalue = new List<String>(); 
        List<SObject> sobjLst = new List<SObject>();
        
        List<MANTA_Master__c> proctsLst =  getAllProctorsInSF();
        phyAndRegionMap.put('proctors', proctsLst);
        
        List<Contact> pyhsLst =  [SELECT Id, Salutation, Name, Title, Position_Job_Title__c, email, phone 
                                  FROM Contact 
                                  WHERE AccountId =: hospAccId
                                  AND Salutation like 'Dr%'
                                  //AND (Contact.Business_Unit1__c = 'Interventional' OR Contact.Business_Unit1__c = 'Vascular')
                                  AND Name != null
                                  ORDER BY Name ASC];
        phyAndRegionMap.put('physicians', pyhsLst);
        
        //Get region starts here
        //Code to read regions from the custom setting buckets - Surya - W-025962
        List<sObject> rgnLst = [SELECT Name, Region_Zone__c FROM Account_Region__c WHERE Region_Zone__c != NULL];
        for(sObject rgnSObj : rgnLst){
            if(rgnSObj.get('Region_Zone__c') == 'North'){northLst.add(rgnSObj);}
            if(rgnSObj.get('Region_Zone__c') == 'South'){southLst.add(rgnSObj);}
            if(rgnSObj.get('Region_Zone__c') == 'West'){westLst.add(rgnSObj);}
        }
        
        Account accObj = [select Id, Territory_Key__c from Account where Id =: hospAccId];
        
        if(accObj.Territory_Key__c != NULL){
            string poiList = accObj.Territory_Key__c;
            sortedvalue = poiList.split(';');
            sortedvalue.sort();
            tset.addAll(sortedvalue);
        }
        
        /*check standard account team memebers 
* and add thier territories to tset
*/
        Set<Id> accountTeamUsersSet = new Set<Id>();
        for(AccountTeamMember atm: [SELECT UserId 
                                    FROM AccountTeamMember
                                    WHERE AccountId =: hospAccId])
        {
            accountTeamUsersSet.add(atm.UserId);
        }
        if(!accountTeamUsersSet.isEmpty()){
            for(Territory_Master__c tmByUser :[SELECT Id, Territory_Number__c
                                               FROM Territory_Master__c 
                                               WHERE Primary_Territory_User__c IN:accountTeamUsersSet OR Sales_Rep__c IN:accountTeamUsersSet])
            {
                tset.add(tmByUser.Territory_Number__c);
            }
        }
        
        System.debug('territory key vals splitted and added to tset==='+tset);
        Schema.SObjectType convertType = Schema.getGlobalDescribe().get('User');
        Sobject genericObject = convertType.newSObject();  
        
        try{
            List<Territory_Master__c> tmLst = [SELECT Id, Name, Role__c, Business_Unit__c, Primary_Territory_User__c, Sales_Rep__c, Manager__c,
                                               Primary_Territory_User__r.Region__c, Sales_Rep__r.Region__c, Manager__r.Region__c,
                                               Territory_Number__c
                                               FROM Territory_Master__c 
                                               WHERE Territory_Number__c IN : tset
                                               AND Business_Unit__c = 'Interventional'
                                               AND Role__c = 'Sales Rep'
                                               ORDER BY LastModifiedDate DESC
                                               LIMIT 1
                                              ];
            
            if(tmLst.size() > 0 || !tmLst.isEmpty())
            {
                for(Territory_Master__c tm : tmLst){
                    System.debug('tmLst limit 1-->'+tm);
                    if(tset.contains(tm.Territory_Number__c)){
                        if(tm.Sales_Rep__c != NULL){
                            genericObject.put('Region__c', tm.Sales_Rep__r.Region__c);
                            sobjLst.add(genericObject);
                            System.debug('sales rep sobjLst-->'+sobjLst);
                        }
                        else if(tm.Primary_Territory_User__c != NULL){
                            genericObject.put('Region__c', tm.Primary_Territory_User__r.Region__c);
                            sobjLst.add(genericObject);
                            System.debug('primary usr sobjLst-->'+sobjLst);
                        }
                        else{
                            genericObject.put('Region__c', tm.Manager__r.Region__c);
                            sobjLst.add(genericObject);
                            System.debug('mgr sobjLst-->'+sobjLst);
                        }
                    }
                    
                }
            }
            else{
                Set<String> taSet = new Set<String>();
                List<Territory_Assignment__c> taLst = [SELECT Territory_Number__c 
                                                       FROM Territory_Assignment__c
                                                       WHERE Account__c =: hospAccId
                                                       AND Territory_Alignment__r.Active__c = TRUE 
                                                       AND Business_Unit__c = 'Interventional'
                                                       ORDER BY Business_Unit__c];
                for(Territory_Assignment__c ta : taLst){
                    taSet.add(ta.Territory_Number__c);
                }
                Territory_Master__c tm = [SELECT Id, Name, Role__c, Business_Unit__c, Primary_Territory_User__c, Sales_Rep__c, Manager__c,
                                          Primary_Territory_User__r.Region__c, Sales_Rep__r.Region__c, Manager__r.Region__c,
                                          Territory_Number__c
                                          FROM Territory_Master__c 
                                          WHERE Territory_Number__c IN : taSet
                                          AND Business_Unit__c = 'Interventional'
                                          ORDER BY LastModifiedDate DESC
                                          LIMIT 1
                                         ];
                String region = tm.Sales_Rep__r.Region__c != null ? tm.Sales_Rep__r.Region__c : 'Open';
                genericObject.put('Region__c', region);
                sobjLst.add(genericObject);
                System.debug('in else-->'+sobjLst);
            }
        }
        catch(Exception ex){
            genericObject.put('Region__c', 'Open');
            sobjLst.add(genericObject);
            System.debug('in catch-->'+sobjLst);
        }
        phyAndRegionMap.put('region', sobjLst);
        
        if(containsAnyInList(northLst, phyAndRegionMap.get('region'), 'Name', 'Region__c')){
            genericObject.put('Region__c', 'North');
            sobjLst.add(genericObject);
            phyAndRegionMap.put('region', sobjLst);
            System.debug('in north if');
        }
        if(containsAnyInList(southLst, phyAndRegionMap.get('region'), 'Name', 'Region__c')){
            genericObject.put('Region__c', 'South');
            sobjLst.add(genericObject);
            phyAndRegionMap.put('region', sobjLst);
            System.debug('in south if');
        }
        if(containsAnyInList(westLst, phyAndRegionMap.get('region'), 'Name', 'Region__c')){
            genericObject.put('Region__c', 'West');
            sobjLst.add(genericObject);
            phyAndRegionMap.put('region', sobjLst);
            System.debug('in north if');
        }  
        System.debug('in return-->'+phyAndRegionMap.get('region'));
        return phyAndRegionMap;
    }
    
    //method to check if value in first list is present in second list. we can pass field names dynamically to search.
    //params: first list, second list, field one, field two.
    public static Boolean containsAnyInList(List<sObject> toSearch, List<sObject> values, String toSrchField, String valField)
    {
        if (toSearch.size() == 0)
        {
            return false;
        }
        Set<String> fieldList = toSearch[0].getSObjectType().getDescribe().fields.getMap().keySet();
        for (sObject i : values)
        {
            for (sObject j : toSearch)
            {
                for (String k : fieldList)
                {
                    if (String.valueOf(i.get(valField)) == String.valueOf(j.get(toSrchField)))
                    {
                        return true;
                    }
                }
            }
        }
        return false;
    }
    
    
    //below are calender methods
    @AuraEnabled
    public static List<MANTA_Proctorship_Request__c> getMANTACaseEvents(String regionName){
        
        List<MANTA_Proctorship_Request__c> eventlist = new  List<MANTA_Proctorship_Request__c>();
        
        if(regionName == 'All'){
            eventlist =[select Id
                        , Hospital__r.Name
                        , CreatedDate
                        , Case_Date__c
                        , Status__c
                        , Physician__r.Salutation
                        , Physician__r.Name
                        , Case_Type__c
                        , Estimated_of_Cases__c
                        , Case_Initiator__r.Name
                        , Days_Open__c
                        , Notes__c
                        , Proctor__r.Name
                        , Region__c
                        from MANTA_Proctorship_Request__c
                        where Case_Date__c >=: system.today()-14
                       ] ;
        }
        else{
            eventlist =[select Id
                        , Hospital__r.Name
                        , CreatedDate
                        , Case_Date__c
                        , Status__c
                        , Physician__r.Salutation
                        , Physician__r.Name
                        , Case_Type__c
                        , Estimated_of_Cases__c
                        , Case_Initiator__r.Name
                        , Days_Open__c
                        , Notes__c
                        , Proctor__r.Name
                        , Region__c
                        from MANTA_Proctorship_Request__c
                        where Region__c =: regionName 
                        and Case_Date__c >=: system.today()-14
                       ] ;
        }
        
        return eventlist;
    }
    
    
    @AuraEnabled
    public static void updateEvent(String eventid, String eventdate){
        
        MANTA_Proctorship_Request__c updEvntReqFrmCalObj = new MANTA_Proctorship_Request__c();
        updEvntReqFrmCalObj.Id = eventid;
        updEvntReqFrmCalObj.Case_Date__c = Date.valueOf(eventdate);
        
        update updEvntReqFrmCalObj;
    }
    
    
    public static void sendEmailToProctorsInAccRegion(MANTA_Proctorship_Request__c mantaProcReqObj){
        
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>();
        List<MANTA_Master__c> rgnUsrsLst = new List<MANTA_Master__c>();
        List<String> regionsList = new List<String>();
        OrgWideEmailAddress orgEm = [select Id, Address from OrgWideEmailAddress WHERE Address='manta@teleflex.com'];
        User admUsr = [select id from user where name like '%Surya Arvan%'];
        List<Account_Region__c> custSettRgnLst = [SELECT Name FROM Account_Region__c WHERE Region_Zone__c=: mantaProcReqObj.Region__c AND Region_Zone__c != NULL]; 
        for(Account_Region__c accRgnObj : custSettRgnLst){
            regionsList.add(accRgnObj.Name);
        }
        rgnUsrsLst = [SELECT Trainer__r.Email FROM MANTA_Master__c WHERE Trainer__r.Region__c IN : regionsList and isActive__c = true];
        Account hospitalObj = [select id, name from account where id =: mantaProcReqObj.Hospital__c];
        if(rgnUsrsLst.size() == 0)rgnUsrsLst = [SELECT Trainer__r.Email FROM MANTA_Master__c WHERE Trainer__r.Name = 'Surya Arvan']; 
        String caseInitName = [SELECT Name FROM User WHERE id =: mantaProcReqObj.Case_Initiator__c].Name;
        User trainerUsrObj = [SELECT Name, Region__c FROM User WHERE id =: mantaProcReqObj.Proctor__c];
        for(MANTA_Master__c rgnUsrObj : rgnUsrsLst){
            String procEmail = rgnUsrObj.Trainer__r.Email;
            System.debug('procEmail-->'+procEmail);
            if(!String.isBlank(procEmail)){
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.setToAddresses(new String[] {procEmail});
                message.setBccAddresses(new String[] {admUsr.Id});
                message.setOrgWideEmailAddressId(orgEm.Id);   
                message.setReplyTo('manta@teleflex.com');
                message.optOutPolicy = 'SEND';
                message.subject = 'Case Request Accepted';
                message.htmlbody = ' Hello Manta Training Team,<br/><br/>'
                    +'The following proctorship was accepted:<br/>'
                    +'Hospital: <b>'+hospitalObj.Name+'</b><br/>'
                    +'Case Date: <b>'+mantaProcReqObj.Case_Date__c+'</b><br/>'
                    +'Sales Rep: <b>'+caseInitName+'</b><br/>'
                    +'Accepting Trainer: <b>'+trainerUsrObj.Name+'</b><br/>'
                    +'Accepting Trainer Region: <b>'+trainerUsrObj.Region__c+'</b><br/>'
                    +'Hospital Region: <b>'+mantaProcReqObj.Region__c+'</b><br/>'
                    ;
                messages.add(message);
            }
        }
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        if (results[0].success) {
            System.debug('The email was sent successfully.');
        } else {
            System.debug('The email failed to send: '
                         + results[0].errors[0].message);
        } 
    }

    //This method is not in use from 26 Mar, 2021 :: Used subquery to get this data for accepted requests in method getAllOrSelHospAcptdReqs()
    @AuraEnabled
    public static List<MANTA_Case_Data__c> getAllCaseDataRecsForProcId(String openReqId){
        
        List<MANTA_Case_Data__c > caseDataRecsLst = [select Id, 
                                                     Name,
                                                     Case_Date__c ,
                                                     MANTA_Not_Used__c,
                                                     Case_Start_Time__c ,
                                                     Deploying_Physician__c,
                                                     Deploying_Physician__r.Name ,
                                                     Hospital_Name__c,
                                                     Hospital_Name__r.Name,
                                                     MANTA_Trainer__c,
                                                     MANTA_Trainer__r.Name,
                                                     MANTA_Trainer_in_Training__c,
                                                     MANTA_Trainer_in_Training__r.Name,
                                                     Case_Type__c,
                                                     Left_Femoral_Vessel_Size__c,
                                                     Right_Femoral_Vessel_Size__c,
                                                     Tortuosity__c,
                                                     Tortuosity_Comments__c,
                                                     Calcification__c,
                                                     Calcification_Location__c,
                                                     Pre_Arteriogram_Taken__c,
                                                     Ultrasound_Guided_Access_Used__c,
                                                     Depth_1_Measurment__c,
                                                     Additional_Access_Notes__c,
                                                     Device_Manufacturer__c,
                                                     Device__c,
                                                     Device_Size__c,
                                                     Heparin_Total_at_End_of_Case__c,
                                                     ACT_Prior_to_MANTA_Closure__c,
                                                     Blood_Pressure_Prior_to_MANTA_Closure__c,
                                                     Protamine_Given__c,
                                                     Amt_of_Protamine_Given__c,
                                                     Time_Protamine_was_Given__c,
                                                     Size_of_MANTA_Device_Used__c,
                                                     MANTA_Lot_Number__c,
                                                     Other_Wire_Used__c,
                                                     Time_of_MANTA_Deployment__c,
                                                     Post_Arteriogram_Taken__c,
                                                     Micropuncture_used_for_access__c,
                                                     Reason_MANTA_Not_Used__c
                                                     from MANTA_Case_Data__c
                                                     where MANTA_Proctorship_Request__c =: openReqId
                                                     order by CreatedDate desc ];
        
        return caseDataRecsLst;
    }
    
    @AuraEnabled
    public static String saveMANTACaseDataRecs(String  newCaseDataObj){
        
        MANTA_Case_Data__c newCseDtaObjToSave = (MANTA_Case_Data__c)JSON.deserialize(newCaseDataObj, MANTA_Case_Data__c.class);
        Database.insert(newCseDtaObjToSave);      
        return newCaseDataObj;
    }  
    
    @AuraEnabled
    public static void emailCaseDataToUser(String  emailCaseDataObj, String usrId){      
        
        MANTA_Case_Data__c newCseDtaObjToSave = (MANTA_Case_Data__c)JSON.deserialize(emailCaseDataObj, MANTA_Case_Data__c.class);
        
        OrgWideEmailAddress orgEm = [select Id, Address from OrgWideEmailAddress WHERE Address='manta@teleflex.com'];
        User admUsr = [select id from user where name like '%Surya Arvan%'];
        User loggedUsr = [select id, name, email from user where id=: usrId];
        
        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        
        message.setToAddresses(new String[] {loggedUsr.Email});
        message.setBccAddresses(new String[] {admUsr.Id});
        message.setOrgWideEmailAddressId(orgEm.Id);   
        message.setReplyTo('manta@teleflex.com');
        message.optOutPolicy = 'SEND';
        message.subject = 'MANTA Case Data Information';
        message.htmlbody = ' Hello '+ loggedUsr.Name +',<br/><br/>'
            +'Please find the below Case Data information:<br/><br/>'
            +'Case Date: <b>'+newCseDtaObjToSave.Case_Date__c+'</b><br/>'
            +'MANTA Not Used: <b>'+newCseDtaObjToSave.MANTA_Not_Used__c+'</b><br/>'
            +'Case Time: <b>'+newCseDtaObjToSave.Case_Start_Time__c+'</b><br/>'
            +'Hospital: <b>'+newCseDtaObjToSave.Hospital_Name__r.Name+'</b><br/>'
            +'Deploying Physician: <b>'+newCseDtaObjToSave.Deploying_Physician__r.Name+'</b><br/>'
            +'MANTA Trainer: <b>'+newCseDtaObjToSave.MANTA_Trainer__r.Name+'</b><br/>'
            +'MANTA Trainer in Training: <b>'+newCseDtaObjToSave.MANTA_Trainer_in_Training__r.Name+'</b><br/>'
            +'Case Type: <b>'+newCseDtaObjToSave.Case_Type__c+'</b><br/>'
            +'Left Femoral Vessel Size: <b>'+newCseDtaObjToSave.Left_Femoral_Vessel_Size__c+'</b><br/>'
            +'Right Femoral Vessel Size: <b>'+newCseDtaObjToSave.Right_Femoral_Vessel_Size__c+'</b><br/>'
            +'Tortuosity: <b>'+newCseDtaObjToSave.Tortuosity__c+'</b><br/>'
            +'Tortuosity Comments: <b>'+newCseDtaObjToSave.Tortuosity_Comments__c+'</b><br/>'
            +'Clasification: <b>'+newCseDtaObjToSave.Calcification__c+'</b><br/>'
            +'Clasification Location: <b>'+newCseDtaObjToSave.Calcification_Location__c+'</b><br/>'
            +'Pre-Arteriogram Taken: <b>'+newCseDtaObjToSave.Pre_Arteriogram_Taken__c+'</b><br/>'
            +'Ultrasound Guided Access Used: <b>'+newCseDtaObjToSave.Ultrasound_Guided_Access_Used__c+'</b><br/>'
            +'Depth +1 Measurment: <b>'+newCseDtaObjToSave.Depth_1_Measurment__c+'</b><br/>'
            +'Additional Access Notes: <b>'+newCseDtaObjToSave.Additional_Access_Notes__c+'</b><br/>'
            +'Device Manufacturer: <b>'+newCseDtaObjToSave.Device_Manufacturer__c+'</b><br/>'
            +'Device: <b>'+newCseDtaObjToSave.Device__c+'</b><br/>'
            +'Device Size: <b>'+newCseDtaObjToSave.Device_Size__c+'</b><br/>'
            +'Heparin Total at End of Case: <b>'+newCseDtaObjToSave.Heparin_Total_at_End_of_Case__c+'</b><br/>'
            +'ACT Prior to MANTA Closure: <b>'+newCseDtaObjToSave.ACT_Prior_to_MANTA_Closure__c+'</b><br/>'
            +'Blood Pressure Prior to MANTA Closure: <b>'+newCseDtaObjToSave.Blood_Pressure_Prior_to_MANTA_Closure__c+'</b><br/>'
            +'Protamine Given: <b>'+newCseDtaObjToSave.Protamine_Given__c+'</b><br/>'
            +'Amt. of Protamine Given: <b>'+newCseDtaObjToSave.Amt_of_Protamine_Given__c+'</b><br/>'
            +'Time Protamine was Given: <b>'+newCseDtaObjToSave.Time_Protamine_was_Given__c+'</b><br/>'
            +'Size of MANTA Device Used: <b>'+newCseDtaObjToSave.Size_of_MANTA_Device_Used__c+'</b><br/>'
            +'MANTA Lot Number: <b>'+newCseDtaObjToSave.MANTA_Lot_Number__c+'</b><br/>'
            +'Other Wire Used: <b>'+newCseDtaObjToSave.Other_Wire_Used__c+'</b><br/>'
            +'Time of MANTA Deployment: <b>'+newCseDtaObjToSave.Time_of_MANTA_Deployment__c+'</b><br/>'
            +'Post Arteriogram Taken: <b>'+newCseDtaObjToSave.Post_Arteriogram_Taken__c+'</b><br/>'
            +'Micropuncture used for access?: <b>'+newCseDtaObjToSave.Micropuncture_used_for_access__c+'</b><br/>'
            ;
        allmsg.add(message);
        
        try {
            Messaging.sendEmail(allmsg,false);
            return;
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
    }
}