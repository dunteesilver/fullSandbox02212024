/*********************************************************************
* Description      : Controller Class for Coaching form on each of Coaching record detail page.
* Test Class       : CoachingSectionsCompHandler_Test
* VF/LiComps       : CoachingSectionsComponent <old> || CoachingSectionsComp_V2 <new>
* Author(s)        : Surya Arvan - surya.arvan@teleflex.com
//initial version work item: W-023151 sprint: 2020.01
//second version work item: W-025869 sprint: 2021.01
**********************************************************************/
global class CoachingSectionsCompHandler {
    
    
    @AuraEnabled
    public static Coaching__c getCoachingDetail(ID coachingID)
    {
        
        Coaching__c thisCoaching = [ select 
                                    NAME,
                                    is_BS_Pre_Call_Plan_Completed__c,
                                    is_BS_Researches_Acc_Completed__c,
                                    is_BS_Researches_Sales_Data_Completed__c,
                                    is_BS_Wri_Actn_Pri_Call_Objs_Completed__c,
                                    is_BS_Wri_Actn_Sec_FallBk_Objs_Completed__c,
                                    BS_Pre_Call_Plan_Comments__c,
                                    BS_Pre_Call_Plan_RSM_Comments__c,
                                    BS_Researches_Acc_Comments__c,
                                    BS_Researches_Acc_RSM_Comments__c,
                                    BS_Researches_Sales_Data_Comments__c,
                                    BS_Researches_Sales_Data_RSM_Comments__c,
                                    BS_Wri_Actn_Pri_Call_Objs_Comments__c,
                                    BS_Wri_Actn_Pri_Call_Objs_RSM_Comments__c,
                                    BS_Wri_Actn_Sec_FallBk_Objs_Comments__c,
                                    BS_Wri_Actn_Sec_FallBk_Objs_RSM_Comments__c,
                                    BS_Pre_Call_Plan_RepProfLvl__c,
                                    BS_Researches_Acc_RepProfLvl__c,
                                    BS_Researches_Sales_Data_RepProfLvl__c,
                                    BS_Wri_Actn_Pri_Call_Objs_RepProfLvl__c,
                                    BS_Wri_Actn_Sec_FallBk_Objs_RepProfLvl__c,
                                    BS_Pre_Call_Plan_RSMProfLvl__c,
                                    BS_Researches_Acc_RSMProfLvl__c,
                                    BS_Researches_Sales_Data_RSMProfLvl__c,
                                    BS_Wri_Actn_Pri_Call_Objs_RSMProfLvl__c,
                                    BS_Wri_Actn_Sec_FallBk_Objs_RSMProfLvl__c,
                                    BS_Rep_Ove_Prof_Lvl__c,
                                    BS_RSM_Ove_Prof_Lvl__c,
                                    
                                    is_Engage_Insight_Completed__c,
                                    Engage_Insight_Comments__c,
                                    Engage_Insight_RSM_Comments__c,
                                    Engage_Insight_RepProfLvl__c,
                                    Engage_Insight_RSMProfLvl__c,
                                    
                                    is_Discover_Prep_High_Imp_Completed__c,
                                    is_Discover_4P_Que_Completed__c,
                                    Discover_Prep_High_Comments__c,
                                    Discover_Prep_High_RSM_Comments__c,
                                    Discover_4P_Que_Comments__c,
                                    Discover_4P_Que_RSM_Comments__c,
                                    Discover_Prep_High_RepProfLvl__c,
                                    Discover_4P_Que_RepProfLvl__c,
                                    Discover_Prep_High_RSMProfLvl__c,
                                    Discover_4P_Que_RSMProfLvl__c,
                                    Discover_Rep_Ove_Prof_Lvl__c,
                                    Discover_RSM_Ove_Prof_Lvl__c,
                                    
                                    is_Magnify_Needs_Completed__c,
                                    Magnify_Needs_Comments__c,
                                    Magnify_Needs_RSM_Comments__c,
                                    Magnify_Needs_RepProfLvl__c,
                                    Magnify_Needs_RSMProfLvl__c,
                                    
                                    is_Pos_Sols_Completed_1__c,
                                    is_Pos_Sols_Completed_2__c,
                                    Pos_Sols_Comments_1__c,
                                    Pos_Sols_RSM_Comments_1__c,
                                    Pos_Sols_Comments_2__c,
                                    Pos_Sols_RSM_Comments_2__c,
                                    Pos_Sols_RepProfLvl_1__c,
                                    Pos_Sols_RepProfLvl_2__c,
                                    Pos_Sols_RSMProfLvl_1__c,
                                    Pos_Sols_RSMProfLvl_2__c,
                                    Pos_Sols_Rep_Ove_Prof_Lvl__c,
                                    Pos_Sols_RSM_Ove_Prof_Lvl__c,
                                    
                                    is_Gain_Commitment_Completed_1__c,
                                    is_Gain_Commitment_Completed_2__c,
                                    is_Gain_Commitment_Completed_3__c,
                                    Gain_Commitment_Comments_1__c,
                                    Gain_Commitment_RSM_Comments_1__c,
                                    Gain_Commitment_Comments_2__c,
                                    Gain_Commitment_RSM_Comments_2__c,
                                    Gain_Commitment_Comments_3__c,
                                    Gain_Commitment_RSM_Comments_3__c,
                                    Gain_Commitment_RepProfLvl_1__c,
                                    Gain_Commitment_RepProfLvl_2__c,
                                    Gain_Commitment_RepProfLvl_3__c,
                                    Gain_Commitment_RSMProfLvl_1__c,
                                    Gain_Commitment_RSMProfLvl_2__c,
                                    Gain_Commitment_RSMProfLvl_3__c,
                                    Gain_Commitment_Rep_Ove_Prof_Lvl__c,
                                    Gain_Commitment_RSM_Ove_Prof_Lvl__c,
                                    
                                    Rep_Comments_Strengths__c,
                                    Rep_Comments_Area_Of_Impvmnt__c,
                                    Rep_Comments_Core_Vals__c,
                                    
                                    Manager_Comments_Strengths__c,
                                    Manager_Comments_Area_Of_Impvmnt__c,
                                    Manager_Comments_Core_Vals__c,
                                    
                                    Director_Comments_Strengths__c,
                                    Director_Comments_Area_Of_Impvmnt__c ,
                                    Director_Comments_Core_Vals__c ,
                                    
                                    Total_Rep_Ove_Prof_Lvl__c,
                                    Total_RSM_Ove_Prof_Lvl__c
                                    
                                    from Coaching__c where ID =: coachingID
                                   ];
        
        //System.debug(':::thisCoaching:::'+thisCoaching);
        
        return thisCoaching;
    }
    
    @AuraEnabled
    public static Coaching__c getCoachingDetail_v2(ID coachingID)
    {
        
        Coaching__c thisCoaching = [ select 
                                    ID,
                                    NAME,
                                    is_Bal_Seller_Completed_v2__c,
                                    Bal_Seller_Rep_Comments_v2__c,
                                    Bal_Seller_Rep_Prof_Lvl_v2__c,
                                    Bal_Seller_RSM_Comments_v2__c,
                                    Bal_Seller_RSM_Prof_Lvl_v2__c,
                                    is_Enge_Discvr_Mag_Completed_v2__c,
                                    Enge_Discvr_Mag_Rep_Comments_v2__c,
                                    Enge_Discvr_Mag_Rep_Prof_Lvl_v2__c,
                                    Enge_Discvr_Mag_RSM_Comments_v2__c,
                                    Enge_Discvr_Mag_RSM_Prof_Lvl_v2__c,
                                    is_Gain_Commitment_Completed_v2__c,
                                    Gain_Commitment_Rep_Comments_v2__c,
                                    Gain_Commitment_Rep_Prof_Lvl_v2__c,
                                    Gain_Commitment_RSM_Comments_v2__c,
                                    Gain_Commitment_RSM_Prof_Lvl_v2__c,
                                    is_Pos_Sols_Completed_v2__c,
                                    Pos_Sols_Rep_Comments_v2__c,
                                    Pos_Sols_Rep_Prof_Lvl_v2__c,
                                    Pos_Sols_RSM_Comments_v2__c,
                                    Pos_Sols_RSM_Prof_Lvl_v2__c,
                                    Total_Rep_Ove_Prof_Lvl_v2__c,
                                    Total_RSM_Ove_Prof_Lvl_v2__c,
                                    Rep_Comments_Strengths_v2__c,
                                    Rep_Comments_Area_Of_Impvmnt_v2__c,
                                    Rep_Comments_Core_Vals_v2__c,
                                    Manager_Comments_Strengths_v2__c,
                                    Manager_Comments_Area_Of_Impvmnt_v2__c,
                                    Manager_Comments_Core_Vals_v2__c,
                                    Director_Comments_Strengths_v2__c,
                                    Director_Comments_Area_Of_Impvmnt_v2__c,
                                    Director_Comments_Core_Vals_v2__c
                                    from Coaching__c where ID =: coachingID
                                   ];

        //System.debug(':::thisCoaching:::'+thisCoaching);
        
        return thisCoaching;
    }
    
    @AuraEnabled
    public static Coaching__c saveCoachingDetail(ID coachingID, Coaching__c newCoaching)
    {
        
        //System.debug('***coachingID***'+coachingID) ;
        //System.debug('***newCoaching***'+newCoaching) ;
        
        Coaching__c updCochngObj = new Coaching__c();
        updCochngObj.ID = coachingID;
        
        updCochngObj.is_BS_Pre_Call_Plan_Completed__c = newCoaching.is_BS_Pre_Call_Plan_Completed__c;
        updCochngObj.is_BS_Researches_Acc_Completed__c = newCoaching.is_BS_Researches_Acc_Completed__c;
        updCochngObj.is_BS_Researches_Sales_Data_Completed__c = newCoaching.is_BS_Researches_Sales_Data_Completed__c;
        updCochngObj.is_BS_Wri_Actn_Pri_Call_Objs_Completed__c = newCoaching.is_BS_Wri_Actn_Pri_Call_Objs_Completed__c;
        updCochngObj.is_BS_Wri_Actn_Sec_FallBk_Objs_Completed__c = newCoaching.is_BS_Wri_Actn_Sec_FallBk_Objs_Completed__c;
        updCochngObj.BS_Pre_Call_Plan_Comments__c = newCoaching.BS_Pre_Call_Plan_Comments__c;
        updCochngObj.BS_Researches_Acc_Comments__c = newCoaching.BS_Researches_Acc_Comments__c;
        updCochngObj.BS_Researches_Sales_Data_Comments__c = newCoaching.BS_Researches_Sales_Data_Comments__c;
        updCochngObj.BS_Wri_Actn_Pri_Call_Objs_Comments__c = newCoaching.BS_Wri_Actn_Pri_Call_Objs_Comments__c;
        updCochngObj.BS_Wri_Actn_Sec_FallBk_Objs_Comments__c = newCoaching.BS_Wri_Actn_Sec_FallBk_Objs_Comments__c;
        updCochngObj.BS_Pre_Call_Plan_RSM_Comments__c = newCoaching.BS_Pre_Call_Plan_RSM_Comments__c;
        updCochngObj.BS_Researches_Acc_RSM_Comments__c = newCoaching.BS_Researches_Acc_RSM_Comments__c;
        updCochngObj.BS_Researches_Sales_Data_RSM_Comments__c = newCoaching.BS_Researches_Sales_Data_RSM_Comments__c;
        updCochngObj.BS_Wri_Actn_Pri_Call_Objs_RSM_Comments__c = newCoaching.BS_Wri_Actn_Pri_Call_Objs_RSM_Comments__c;
        updCochngObj.BS_Wri_Actn_Sec_FallBk_Objs_RSM_Comments__c = newCoaching.BS_Wri_Actn_Sec_FallBk_Objs_RSM_Comments__c;
        updCochngObj.BS_Pre_Call_Plan_RepProfLvl__c = newCoaching.BS_Pre_Call_Plan_RepProfLvl__c;
        updCochngObj.BS_Researches_Acc_RepProfLvl__c = newCoaching.BS_Researches_Acc_RepProfLvl__c;
        updCochngObj.BS_Researches_Sales_Data_RepProfLvl__c = newCoaching.BS_Researches_Sales_Data_RepProfLvl__c;
        updCochngObj.BS_Wri_Actn_Pri_Call_Objs_RepProfLvl__c = newCoaching.BS_Wri_Actn_Pri_Call_Objs_RepProfLvl__c;
        updCochngObj.BS_Wri_Actn_Sec_FallBk_Objs_RepProfLvl__c = newCoaching.BS_Wri_Actn_Sec_FallBk_Objs_RepProfLvl__c;
        updCochngObj.BS_Pre_Call_Plan_RSMProfLvl__c = newCoaching.BS_Pre_Call_Plan_RSMProfLvl__c;
        updCochngObj.BS_Researches_Acc_RSMProfLvl__c = newCoaching.BS_Researches_Acc_RSMProfLvl__c;
        updCochngObj.BS_Researches_Sales_Data_RSMProfLvl__c = newCoaching.BS_Researches_Sales_Data_RSMProfLvl__c;
        updCochngObj.BS_Wri_Actn_Pri_Call_Objs_RSMProfLvl__c = newCoaching.BS_Wri_Actn_Pri_Call_Objs_RSMProfLvl__c;
        updCochngObj.BS_Wri_Actn_Sec_FallBk_Objs_RSMProfLvl__c = newCoaching.BS_Wri_Actn_Sec_FallBk_Objs_RSMProfLvl__c;
        updCochngObj.BS_Rep_Ove_Prof_Lvl__c = newCoaching.BS_Rep_Ove_Prof_Lvl__c;
        updCochngObj.BS_RSM_Ove_Prof_Lvl__c = newCoaching.BS_RSM_Ove_Prof_Lvl__c;
        
        updCochngObj.is_Engage_Insight_Completed__c = newCoaching.is_Engage_Insight_Completed__c;
        updCochngObj.Engage_Insight_Comments__c = newCoaching.Engage_Insight_Comments__c;
        updCochngObj.Engage_Insight_RSM_Comments__c = newCoaching.Engage_Insight_RSM_Comments__c;
        updCochngObj.Engage_Insight_RepProfLvl__c = newCoaching.Engage_Insight_RepProfLvl__c;
        updCochngObj.Engage_Insight_RSMProfLvl__c = newCoaching.Engage_Insight_RSMProfLvl__c;
        
        updCochngObj.is_Discover_Prep_High_Imp_Completed__c = newCoaching.is_Discover_Prep_High_Imp_Completed__c;
        updCochngObj.is_Discover_4P_Que_Completed__c = newCoaching.is_Discover_4P_Que_Completed__c;
        updCochngObj.Discover_Prep_High_Comments__c = newCoaching.Discover_Prep_High_Comments__c;
        updCochngObj.Discover_4P_Que_Comments__c = newCoaching.Discover_4P_Que_Comments__c;
        updCochngObj.Discover_Prep_High_RSM_Comments__c = newCoaching.Discover_Prep_High_RSM_Comments__c;
        updCochngObj.Discover_4P_Que_RSM_Comments__c = newCoaching.Discover_4P_Que_RSM_Comments__c;
        updCochngObj.Discover_Prep_High_RepProfLvl__c = newCoaching.Discover_Prep_High_RepProfLvl__c;
        updCochngObj.Discover_4P_Que_RepProfLvl__c = newCoaching.Discover_4P_Que_RepProfLvl__c;
        updCochngObj.Discover_Prep_High_RSMProfLvl__c = newCoaching.Discover_Prep_High_RSMProfLvl__c;
        updCochngObj.Discover_4P_Que_RSMProfLvl__c = newCoaching.Discover_4P_Que_RSMProfLvl__c;
        updCochngObj.Discover_Rep_Ove_Prof_Lvl__c = newCoaching.Discover_Rep_Ove_Prof_Lvl__c;
        updCochngObj.Discover_RSM_Ove_Prof_Lvl__c = newCoaching.Discover_RSM_Ove_Prof_Lvl__c;
        
        updCochngObj.is_Magnify_Needs_Completed__c = newCoaching.is_Magnify_Needs_Completed__c;
        updCochngObj.Magnify_Needs_Comments__c = newCoaching.Magnify_Needs_Comments__c;
        updCochngObj.Magnify_Needs_RSM_Comments__c = newCoaching.Magnify_Needs_RSM_Comments__c;
        updCochngObj.Magnify_Needs_RepProfLvl__c = newCoaching.Magnify_Needs_RepProfLvl__c;
        updCochngObj.Magnify_Needs_RSMProfLvl__c = newCoaching.Magnify_Needs_RSMProfLvl__c;
        
        updCochngObj.is_Pos_Sols_Completed_1__c = newCoaching.is_Pos_Sols_Completed_1__c;
        updCochngObj.is_Pos_Sols_Completed_2__c = newCoaching.is_Pos_Sols_Completed_2__c;
        updCochngObj.Pos_Sols_Comments_1__c = newCoaching.Pos_Sols_Comments_1__c;
        updCochngObj.Pos_Sols_Comments_2__c = newCoaching.Pos_Sols_Comments_2__c;
        updCochngObj.Pos_Sols_RSM_Comments_1__c = newCoaching.Pos_Sols_RSM_Comments_1__c;
        updCochngObj.Pos_Sols_RSM_Comments_2__c = newCoaching.Pos_Sols_RSM_Comments_2__c;
        updCochngObj.Pos_Sols_RepProfLvl_1__c = newCoaching.Pos_Sols_RepProfLvl_1__c;
        updCochngObj.Pos_Sols_RepProfLvl_2__c = newCoaching.Pos_Sols_RepProfLvl_2__c;
        updCochngObj.Pos_Sols_RSMProfLvl_1__c = newCoaching.Pos_Sols_RSMProfLvl_1__c;
        updCochngObj.Pos_Sols_RSMProfLvl_2__c = newCoaching.Pos_Sols_RSMProfLvl_2__c;
        updCochngObj.Pos_Sols_Rep_Ove_Prof_Lvl__c = newCoaching.Pos_Sols_Rep_Ove_Prof_Lvl__c;
        updCochngObj.Pos_Sols_RSM_Ove_Prof_Lvl__c = newCoaching.Pos_Sols_RSM_Ove_Prof_Lvl__c;
        
        updCochngObj.is_Gain_Commitment_Completed_1__c = newCoaching.is_Gain_Commitment_Completed_1__c;
        updCochngObj.is_Gain_Commitment_Completed_2__c = newCoaching.is_Gain_Commitment_Completed_2__c;
        updCochngObj.is_Gain_Commitment_Completed_3__c = newCoaching.is_Gain_Commitment_Completed_3__c;
        updCochngObj.Gain_Commitment_Comments_1__c = newCoaching.Gain_Commitment_Comments_1__c;
        updCochngObj.Gain_Commitment_Comments_2__c = newCoaching.Gain_Commitment_Comments_2__c;
        updCochngObj.Gain_Commitment_Comments_3__c = newCoaching.Gain_Commitment_Comments_3__c;
        updCochngObj.Gain_Commitment_RSM_Comments_1__c = newCoaching.Gain_Commitment_RSM_Comments_1__c;
        updCochngObj.Gain_Commitment_RSM_Comments_2__c = newCoaching.Gain_Commitment_RSM_Comments_2__c;
        updCochngObj.Gain_Commitment_RSM_Comments_3__c = newCoaching.Gain_Commitment_RSM_Comments_3__c;
        updCochngObj.Gain_Commitment_RepProfLvl_1__c = newCoaching.Gain_Commitment_RepProfLvl_1__c;
        updCochngObj.Gain_Commitment_RepProfLvl_2__c = newCoaching.Gain_Commitment_RepProfLvl_2__c;
        updCochngObj.Gain_Commitment_RepProfLvl_3__c = newCoaching.Gain_Commitment_RepProfLvl_3__c;
        updCochngObj.Gain_Commitment_RSMProfLvl_1__c = newCoaching.Gain_Commitment_RSMProfLvl_1__c;
        updCochngObj.Gain_Commitment_RSMProfLvl_2__c = newCoaching.Gain_Commitment_RSMProfLvl_2__c;
        updCochngObj.Gain_Commitment_RSMProfLvl_3__c = newCoaching.Gain_Commitment_RSMProfLvl_3__c;
        updCochngObj.Gain_Commitment_Rep_Ove_Prof_Lvl__c = newCoaching.Gain_Commitment_Rep_Ove_Prof_Lvl__c;
        updCochngObj.Gain_Commitment_RSM_Ove_Prof_Lvl__c = newCoaching.Gain_Commitment_RSM_Ove_Prof_Lvl__c;
        
        updCochngObj.Rep_Comments_Strengths__c = newCoaching.Rep_Comments_Strengths__c;
        updCochngObj.Rep_Comments_Area_Of_Impvmnt__c = newCoaching.Rep_Comments_Area_Of_Impvmnt__c;
        updCochngObj.Rep_Comments_Core_Vals__c = newCoaching.Rep_Comments_Core_Vals__c;
        
        updCochngObj.Manager_Comments_Strengths__c = newCoaching.Manager_Comments_Strengths__c;
        updCochngObj.Manager_Comments_Area_Of_Impvmnt__c = newCoaching.Manager_Comments_Area_Of_Impvmnt__c;
        updCochngObj.Manager_Comments_Core_Vals__c = newCoaching.Manager_Comments_Core_Vals__c;
        
        updCochngObj.Director_Comments_Strengths__c = newCoaching.Director_Comments_Strengths__c;
        updCochngObj.Director_Comments_Area_Of_Impvmnt__c = newCoaching.Director_Comments_Area_Of_Impvmnt__c;
        updCochngObj.Director_Comments_Core_Vals__c = newCoaching.Director_Comments_Core_Vals__c;
        
        updCochngObj.Total_Rep_Ove_Prof_Lvl__c = newCoaching.Total_Rep_Ove_Prof_Lvl__c;
        updCochngObj.Total_RSM_Ove_Prof_Lvl__c = newCoaching.Total_RSM_Ove_Prof_Lvl__c;
        
        update updCochngObj;
        
        
        
        return updCochngObj;   
    }
    
    @AuraEnabled
    public static Coaching__c saveCoachingDetail_v2(ID coachingID, Coaching__c newCoaching)
    {
        
        //System.debug('***coachingID***'+coachingID) ;
        //System.debug('***newCoaching***'+newCoaching) ;
        
        Coaching__c updCochngObj = new Coaching__c();
        updCochngObj.ID = coachingID;
        
                updCochngObj.is_Bal_Seller_Completed_v2__c = newCoaching.is_Bal_Seller_Completed_v2__c;
                updCochngObj.Bal_Seller_Rep_Comments_v2__c = newCoaching.Bal_Seller_Rep_Comments_v2__c;
                updCochngObj.Bal_Seller_Rep_Prof_Lvl_v2__c = newCoaching.Bal_Seller_Rep_Prof_Lvl_v2__c;
                updCochngObj.Bal_Seller_RSM_Comments_v2__c = newCoaching.Bal_Seller_RSM_Comments_v2__c;
                updCochngObj.Bal_Seller_RSM_Prof_Lvl_v2__c = newCoaching.Bal_Seller_RSM_Prof_Lvl_v2__c;
                
                updCochngObj.is_Enge_Discvr_Mag_Completed_v2__c = newCoaching.is_Enge_Discvr_Mag_Completed_v2__c;
                updCochngObj.Enge_Discvr_Mag_Rep_Comments_v2__c = newCoaching.Enge_Discvr_Mag_Rep_Comments_v2__c;
                updCochngObj.Enge_Discvr_Mag_Rep_Prof_Lvl_v2__c = newCoaching.Enge_Discvr_Mag_Rep_Prof_Lvl_v2__c;
                updCochngObj.Enge_Discvr_Mag_RSM_Comments_v2__c = newCoaching.Enge_Discvr_Mag_RSM_Comments_v2__c;
                updCochngObj.Enge_Discvr_Mag_RSM_Prof_Lvl_v2__c = newCoaching.Enge_Discvr_Mag_RSM_Prof_Lvl_v2__c;
                
                updCochngObj.is_Gain_Commitment_Completed_v2__c = newCoaching.is_Gain_Commitment_Completed_v2__c;
                updCochngObj.Gain_Commitment_Rep_Comments_v2__c = newCoaching.Gain_Commitment_Rep_Comments_v2__c;
                updCochngObj.Gain_Commitment_Rep_Prof_Lvl_v2__c = newCoaching.Gain_Commitment_Rep_Prof_Lvl_v2__c;
                updCochngObj.Gain_Commitment_RSM_Comments_v2__c = newCoaching.Gain_Commitment_RSM_Comments_v2__c;
                updCochngObj.Gain_Commitment_RSM_Prof_Lvl_v2__c = newCoaching.Gain_Commitment_RSM_Prof_Lvl_v2__c;
                
                updCochngObj.is_Pos_Sols_Completed_v2__c = newCoaching.is_Pos_Sols_Completed_v2__c;
                updCochngObj.Pos_Sols_Rep_Comments_v2__c = newCoaching.Pos_Sols_Rep_Comments_v2__c;
                updCochngObj.Pos_Sols_Rep_Prof_Lvl_v2__c = newCoaching.Pos_Sols_Rep_Prof_Lvl_v2__c;
                updCochngObj.Pos_Sols_RSM_Comments_v2__c = newCoaching.Pos_Sols_RSM_Comments_v2__c;
                updCochngObj.Pos_Sols_RSM_Prof_Lvl_v2__c = newCoaching.Pos_Sols_RSM_Prof_Lvl_v2__c;
                
                updCochngObj.Total_Rep_Ove_Prof_Lvl_v2__c = newCoaching.Total_Rep_Ove_Prof_Lvl_v2__c;
                updCochngObj.Total_RSM_Ove_Prof_Lvl_v2__c = newCoaching.Total_RSM_Ove_Prof_Lvl_v2__c;
                
                updCochngObj.Rep_Comments_Strengths_v2__c = newCoaching.Rep_Comments_Strengths_v2__c;
                updCochngObj.Rep_Comments_Area_Of_Impvmnt_v2__c = newCoaching.Rep_Comments_Area_Of_Impvmnt_v2__c;
                updCochngObj.Rep_Comments_Core_Vals_v2__c = newCoaching.Rep_Comments_Core_Vals_v2__c;
                
                updCochngObj.Manager_Comments_Strengths_v2__c = newCoaching.Manager_Comments_Strengths_v2__c;
                updCochngObj.Manager_Comments_Area_Of_Impvmnt_v2__c = newCoaching.Manager_Comments_Area_Of_Impvmnt_v2__c;
                updCochngObj.Manager_Comments_Core_Vals_v2__c = newCoaching.Manager_Comments_Core_Vals_v2__c;
                
                updCochngObj.Director_Comments_Strengths_v2__c = newCoaching.Director_Comments_Strengths_v2__c;
                updCochngObj.Director_Comments_Area_Of_Impvmnt_v2__c = newCoaching.Director_Comments_Area_Of_Impvmnt_v2__c;
                updCochngObj.Director_Comments_Core_Vals_v2__c = newCoaching.Director_Comments_Core_Vals_v2__c;
        
        update updCochngObj;
        
        
        
        return updCochngObj;   
    }
    
    
    @AuraEnabled
    public static FormVisibilityWrapper getUserInfoForCoachingForm()
    {
        String currLoggUserID = UserInfo.getUserId();
        FormVisibilityWrapper formVisibilityWrapperObj = new FormVisibilityWrapper();
        
        List<UserRole>  itGlobalLst = [select ID from UserRole where name like '%Teleflex Global IT%'];
        List<UserRole>  prsdntLst = [select ID from UserRole where name like '%President%'];
        List<UserRole>  dirctrLst = [select ID from UserRole where name like '%Director%'];
        List<UserRole>  mgrLst = [select ID from UserRole where name like '%Manager%' or name like '%Mgr%' or name like '%RSM%'];
        List<UserRole>  repLst = [select ID from UserRole where name like '%Rep%' or name like '%MSR%']; 
        
        for(User isPrsdntUsrObj : [select ID from User where UserRole.ID in : prsdntLst]){
            
            if(isPrsdntUsrObj.ID == ID.valueOf(currLoggUserID)){
                formVisibilityWrapperObj.isRepDisable = false;
                formVisibilityWrapperObj.isRSMDisable = false;
                formVisibilityWrapperObj.isDirDisable = false;
                formVisibilityWrapperObj.notifyDirBool = false;
            }
        }
        
        
        for(User isITUsrObj : [select ID from User where UserRole.ID in : itGlobalLst]){
            
            if(isITUsrObj.ID == ID.valueOf(currLoggUserID)){
                
                formVisibilityWrapperObj.isRepDisable = false;
                formVisibilityWrapperObj.isRSMDisable = false;
                formVisibilityWrapperObj.isDirDisable = false;
                formVisibilityWrapperObj.notifyDirBool = true;
            }
        }
        
        for(User isRepUsrObj : [select ID from User where UserRole.ID in : repLst]){
            
            if(isRepUsrObj.ID == ID.valueOf(currLoggUserID)){
                
                formVisibilityWrapperObj.isRSMDisable = true;
                formVisibilityWrapperObj.isDirDisable = true;
            }
        }
        
        for(User isRSMUsrObj : [select ID from User where UserRole.ID in : mgrLst]){
            
            if(isRSMUsrObj.ID == ID.valueOf(currLoggUserID)){
                
                formVisibilityWrapperObj.isRepDisable = true;
                formVisibilityWrapperObj.isDirDisable = true;
                formVisibilityWrapperObj.notifyDirBool = true;
            }
        }
        
        for(User isDirctrUsrObj : [select ID from User where UserRole.ID in : dirctrLst]){
            
            if(isDirctrUsrObj.ID == ID.valueOf(currLoggUserID)){
                formVisibilityWrapperObj.isRepDisable = true;
                formVisibilityWrapperObj.isRSMDisable = true;
            }
        }
        
        
        //System.debug('formVisibilityWrapperObj++'+formVisibilityWrapperObj);
        
        return formVisibilityWrapperObj;
    }
    
    @AuraEnabled
    public static String getDirEmailAndNotify(ID coachingID)
    {
        
        User managerIDObj = [SELECT ManagerId, Manager_s_Email__c FROM User WHERE Id = : UserInfo.getUserId()]; 
        //ID mgrID = managerIDObj.ManagerId;
        //User dirEmailObj = [SELECT ManagerId,Manager_s_Email__c FROM User WHERE Id = : mgrID]; 
        
        //get record detail link
        String coachingRecLnk = URL.getSalesforceBaseUrl().toExternalForm()+'/'+coachingID;
        
        // grab the email template
        ID templateId = Label.Coaching_Form_Director_Email_Template_ID;
        EmailTemplate emailTemplate = [select Id, Subject, HtmlValue, Body from EmailTemplate where Id =: templateId];
        
        Coaching__c cObj = [Select Id, NAME, LastModifiedBy.NAME FROM Coaching__c WHERE Id=: coachingID];
        
        // process the merge fields
        String subject = emailTemplate.Subject;
        subject = subject.replace('{!Coaching__c.Name}', cObj.NAME);
        subject = subject.replace('{!Coaching__c.Link}', coachingRecLnk);
        subject = subject.replace('{!Coaching__c.LastModifiedBy}', cObj.LastModifiedBy.NAME);
 
        String htmlBody = emailTemplate.HtmlValue;
        //String myCustomString = 'is sent for your review';
        htmlBody = htmlBody.replace('{!Coaching__c.Name}', cObj.NAME);
        htmlBody = htmlBody.replace('{!Coaching__c.LastModifiedBy}', cObj.LastModifiedBy.Name);
        htmlBody = htmlBody.replace('{!Coaching__c.Link}', coachingRecLnk);
        //htmlBody = htmlBody.replace('{!myCustomString}', myCustomString);
        
        String plainBody = emailTemplate.Body;
        plainBody = plainBody.replace('{!Coaching__c.NAME}', cObj.NAME);
        plainBody = plainBody.replace('{!Coaching__c.LastModifiedBy}', cObj.LastModifiedBy.Name);
        plainBody = plainBody.replace('{!Coaching__c.Link}', coachingRecLnk);
        //plainBody = plainBody.replace('{!myCustomString}', myCustomString);
        
        //build the email message
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        
        List<String> emailCCLst = new List<String>();
        emailCCLst.add(UserInfo.getUserEmail());
        
        //email.setReplyTo('surya.arvan@teleflex.com'); 
        email.setReplyTo(managerIDObj.Manager_s_Email__c);
        email.setSenderDisplayName('AEM Coaching Report Team');
        email.setTargetObjectId(managerIDObj.ManagerId); //give director ID for email here.. dirEmailObj.ManagerId
        email.setCcAddresses(emailCCLst);
        email.setSaveAsActivity(false);
        
        email.setSubject(subject);
        email.setHtmlBody(htmlBody);
        email.setPlainTextBody(plainBody);
        
        Messaging.sendEmail(new Messaging.SingleEmailmessage[] {email});

        return managerIDObj.Manager_s_Email__c;
    }
    
    
    public class FormVisibilityWrapper {
        
        @AuraEnabled public Boolean isRepDisable {get;set;} 
        @AuraEnabled public Boolean isRSMDisable {get;set;} 
        @AuraEnabled public Boolean isDirDisable {get;set;}
        @AuraEnabled public Boolean notifyDirBool {get;set;} 
        
    }
    
}