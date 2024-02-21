@isTest
private class CoachingSectionsCompHandler_Test {
    
    static testMethod void runPositiveTestCases(){
        
        
        UserRole userRoleTest = new UserRole(DeveloperName = 'MyCustomRole', Name = 'Teleflex Global IT');
        insert userRoleTest;
        
        
        
        User usr = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
            LastName = 'test',
            Email = 'test@teleflex.com',
            Username = 'test@teleflex.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            UserRoleId = userRoleTest.Id
        );
        
        insert usr;
        
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Coaching__c coachingObjTest = new Coaching__c();
            //coachingObjTest.NAME = 'Test Coaching Name';
            
            coachingObjTest.is_BS_Researches_Acc_Completed__c = 'Y';
            coachingObjTest.is_BS_Researches_Sales_Data_Completed__c = 'Y';
            coachingObjTest.is_BS_Wri_Actn_Pri_Call_Objs_Completed__c = 'Y';
            coachingObjTest.is_BS_Wri_Actn_Sec_FallBk_Objs_Completed__c = 'Y';
            coachingObjTest.BS_Pre_Call_Plan_Comments__c = 'Y';
            coachingObjTest.BS_Pre_Call_Plan_RSM_Comments__c = 'Y';
            coachingObjTest.BS_Researches_Acc_Comments__c = 'Y';
            coachingObjTest.BS_Researches_Acc_RSM_Comments__c = 'Y';
            coachingObjTest.BS_Researches_Sales_Data_Comments__c = 'Y';
            coachingObjTest.BS_Researches_Sales_Data_RSM_Comments__c = 'Y';
            coachingObjTest.BS_Wri_Actn_Pri_Call_Objs_Comments__c = 'Y';
            coachingObjTest.BS_Wri_Actn_Pri_Call_Objs_RSM_Comments__c = 'Y';
            coachingObjTest.BS_Wri_Actn_Sec_FallBk_Objs_Comments__c = 'Y';
            coachingObjTest.BS_Wri_Actn_Sec_FallBk_Objs_RSM_Comments__c = 'Y';
            coachingObjTest.BS_Pre_Call_Plan_RepProfLvl__c = 0;
            coachingObjTest.BS_Researches_Acc_RepProfLvl__c = 0;
            coachingObjTest.BS_Researches_Sales_Data_RepProfLvl__c = 0;
            coachingObjTest.BS_Wri_Actn_Pri_Call_Objs_RepProfLvl__c = 0;
            coachingObjTest.BS_Wri_Actn_Sec_FallBk_Objs_RepProfLvl__c = 0;
            coachingObjTest.BS_Pre_Call_Plan_RSMProfLvl__c = 0;
            coachingObjTest.BS_Researches_Acc_RSMProfLvl__c = 0;
            coachingObjTest.BS_Researches_Sales_Data_RSMProfLvl__c = 0;
            coachingObjTest.BS_Wri_Actn_Pri_Call_Objs_RSMProfLvl__c = 0;
            coachingObjTest.BS_Wri_Actn_Sec_FallBk_Objs_RSMProfLvl__c = 0;
            coachingObjTest.BS_Rep_Ove_Prof_Lvl__c = 0;
            coachingObjTest.BS_RSM_Ove_Prof_Lvl__c = 0;
            
            coachingObjTest.is_Engage_Insight_Completed__c = 'Y';
            coachingObjTest.Engage_Insight_Comments__c = 'Y';
            coachingObjTest.Engage_Insight_RSM_Comments__c = 'Y';
            coachingObjTest.Engage_Insight_RepProfLvl__c = 0;
            coachingObjTest.Engage_Insight_RSMProfLvl__c = 0;
            
            coachingObjTest.is_Discover_Prep_High_Imp_Completed__c = 'Y';
            coachingObjTest.is_Discover_4P_Que_Completed__c = 'Y';
            coachingObjTest.Discover_Prep_High_Comments__c = 'Y';
            coachingObjTest.Discover_Prep_High_RSM_Comments__c = 'Y';
            coachingObjTest.Discover_4P_Que_Comments__c = 'Y';
            coachingObjTest.Discover_4P_Que_RSM_Comments__c = 'Y';
            coachingObjTest.Discover_Prep_High_RepProfLvl__c = 0;
            coachingObjTest.Discover_4P_Que_RepProfLvl__c = 0;
            coachingObjTest.Discover_Prep_High_RSMProfLvl__c = 0;
            coachingObjTest.Discover_4P_Que_RSMProfLvl__c = 0;
            coachingObjTest.Discover_Rep_Ove_Prof_Lvl__c = 0;
            coachingObjTest.Discover_RSM_Ove_Prof_Lvl__c = 0;
            
            coachingObjTest.is_Magnify_Needs_Completed__c = 'Y';
            coachingObjTest.Magnify_Needs_Comments__c = 'Y';
            coachingObjTest.Magnify_Needs_RSM_Comments__c = 'Y';
            coachingObjTest.Magnify_Needs_RepProfLvl__c = 0;
            coachingObjTest.Magnify_Needs_RSMProfLvl__c = 0;
            
            coachingObjTest.is_Pos_Sols_Completed_1__c = 'Y';
            coachingObjTest.is_Pos_Sols_Completed_2__c = 'Y';
            coachingObjTest.Pos_Sols_Comments_1__c = 'Y';
            coachingObjTest.Pos_Sols_RSM_Comments_1__c = 'Y';
            coachingObjTest.Pos_Sols_Comments_2__c = 'Y';
            coachingObjTest.Pos_Sols_RSM_Comments_2__c = 'Y';
            coachingObjTest.Pos_Sols_RepProfLvl_1__c = 0;
            coachingObjTest.Pos_Sols_RepProfLvl_2__c = 0;
            coachingObjTest.Pos_Sols_RSMProfLvl_1__c = 0;
            coachingObjTest.Pos_Sols_RSMProfLvl_2__c = 0;
            coachingObjTest.Pos_Sols_Rep_Ove_Prof_Lvl__c = 0;
            coachingObjTest.Pos_Sols_RSM_Ove_Prof_Lvl__c = 0;
            
            coachingObjTest.is_Gain_Commitment_Completed_1__c = 'Y';
            coachingObjTest.is_Gain_Commitment_Completed_2__c = 'Y';
            coachingObjTest.is_Gain_Commitment_Completed_3__c = 'Y';
            coachingObjTest.Gain_Commitment_Comments_1__c = 'Y';
            coachingObjTest.Gain_Commitment_RSM_Comments_1__c = 'Y';
            coachingObjTest.Gain_Commitment_Comments_2__c = 'Y';
            coachingObjTest.Gain_Commitment_RSM_Comments_2__c = 'Y';
            coachingObjTest.Gain_Commitment_Comments_3__c = 'Y';
            coachingObjTest.Gain_Commitment_RSM_Comments_3__c = 'Y';
            coachingObjTest.Gain_Commitment_RepProfLvl_1__c = 0;
            coachingObjTest.Gain_Commitment_RepProfLvl_2__c = 0;
            coachingObjTest.Gain_Commitment_RepProfLvl_3__c = 0;
            coachingObjTest.Gain_Commitment_RSMProfLvl_1__c = 0;
            coachingObjTest.Gain_Commitment_RSMProfLvl_2__c = 0;
            coachingObjTest.Gain_Commitment_RSMProfLvl_3__c = 0;
            coachingObjTest.Gain_Commitment_Rep_Ove_Prof_Lvl__c = 0;
            coachingObjTest.Gain_Commitment_RSM_Ove_Prof_Lvl__c = 0;
            
            coachingObjTest.Rep_Comments_Strengths__c = 'Y';
            coachingObjTest.Rep_Comments_Area_Of_Impvmnt__c = 'Y';
            coachingObjTest.Rep_Comments_Core_Vals__c = 'Y';
            
            coachingObjTest.Manager_Comments_Strengths__c = 'Y';
            coachingObjTest.Manager_Comments_Area_Of_Impvmnt__c = 'Y';
            coachingObjTest.Manager_Comments_Core_Vals__c = 'Y';
            
            coachingObjTest.Director_Comments_Strengths__c = 'Y';
            coachingObjTest.Director_Comments_Area_Of_Impvmnt__c = 'Y';
            coachingObjTest.Director_Comments_Core_Vals__c = 'Y';
            
            coachingObjTest.Total_Rep_Ove_Prof_Lvl__c = 0;
            coachingObjTest.Total_RSM_Ove_Prof_Lvl__c = 0;
            
            insert coachingObjTest;
            
            
            
            
            Test.startTest();
            
            
            CoachingSectionsCompHandler.FormVisibilityWrapper formVisibilityWrapperTest = CoachingSectionsCompHandler.getUserInfoForCoachingForm();
            
            String dirEmail = CoachingSectionsCompHandler.getDirEmailAndNotify(coachingObjTest.ID);
            
            Coaching__c thisTstCoachObj = CoachingSectionsCompHandler.getCoachingDetail(coachingObjTest.ID);
            Coaching__c thisTstSaveCoachObj = CoachingSectionsCompHandler.saveCoachingDetail(coachingObjTest.ID, coachingObjTest);
            Coaching__c thisTstCoachObj_v2 = CoachingSectionsCompHandler.getCoachingDetail_v2(coachingObjTest.ID);
            Coaching__c thisTstSaveCoachObj_v2 = CoachingSectionsCompHandler.saveCoachingDetail_v2(coachingObjTest.ID, coachingObjTest);
            
            Test.stopTest();  
            
            System.assertEquals(coachingObjTest.BS_Pre_Call_Plan_Comments__c , thisTstCoachObj.BS_Pre_Call_Plan_Comments__c);
        }  
    }
    
    static testMethod void runPositiveTestCases1(){
        
        UserRole userRoleTest = new UserRole(DeveloperName = 'MyCustomRoleMgr', Name = 'Anesthesia RSM - Central');
        insert userRoleTest;
        
        
        
        User usr = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'TFX Sales Manager Wave User'].Id,
            LastName = 'test',
            Email = 'test@teleflex.com',
            Username = 'test@teleflex.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            UserRoleId = userRoleTest.Id
        );
        
        insert usr;
        
        Test.startTest();
        System.runAs ( new User(Id = usr.Id) ) {
            CoachingSectionsCompHandler.FormVisibilityWrapper formVisibilityWrapperTest = CoachingSectionsCompHandler.getUserInfoForCoachingForm();
            
        }
        Test.stopTest();
    }
    
    
    static testMethod void runPositiveTestCases2(){
        
        UserRole userRoleTest = new UserRole(DeveloperName = 'MyCustomRolePrsdnt', Name = 'Anesthesia President');
        insert userRoleTest;
        
        
        
        User usr = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'TFX Sales Manager Wave User'].Id,
            LastName = 'test',
            Email = 'test@teleflex.com',
            Username = 'test@teleflex.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            UserRoleId = userRoleTest.Id
        );
        
        insert usr;
        
        Test.startTest();
        System.runAs ( new User(Id = usr.Id) ) {
            CoachingSectionsCompHandler.FormVisibilityWrapper formVisibilityWrapperTest = CoachingSectionsCompHandler.getUserInfoForCoachingForm();
            
        }
        Test.stopTest();
    }
    
    static testMethod void runPositiveTestCases3(){
        
        UserRole userRoleTest = new UserRole(DeveloperName = 'MyCustomRolePrsdnt', Name = 'Customer Service Rep');
        insert userRoleTest;
        
        
        
        User usr = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'TFX Sales Manager Wave User'].Id,
            LastName = 'test',
            Email = 'test@teleflex.com',
            Username = 'test@teleflex.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            UserRoleId = userRoleTest.Id
        );
        
        insert usr;
        
        Test.startTest();
        System.runAs ( new User(Id = usr.Id) ) {
            CoachingSectionsCompHandler.FormVisibilityWrapper formVisibilityWrapperTest = CoachingSectionsCompHandler.getUserInfoForCoachingForm();
            
        }
        Test.stopTest();
    }
    
    static testMethod void runPositiveTestCases4(){
        
        UserRole userRoleTest = new UserRole(DeveloperName = 'MyCustomRolePrsdnt', Name = 'Anesthesia Director of Sales');
        insert userRoleTest;
        
        
        
        User usr = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'TFX Sales Manager Wave User'].Id,
            LastName = 'test',
            Email = 'test@teleflex.com',
            Username = 'test@teleflex.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            UserRoleId = userRoleTest.Id
        );
        
        insert usr;
        
        Test.startTest();
        System.runAs ( new User(Id = usr.Id) ) {
            CoachingSectionsCompHandler.FormVisibilityWrapper formVisibilityWrapperTest = CoachingSectionsCompHandler.getUserInfoForCoachingForm();
            
        }
        Test.stopTest();
    }
    
}