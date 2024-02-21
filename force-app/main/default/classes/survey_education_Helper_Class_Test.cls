@istest
public class survey_education_Helper_Class_Test {
    public static testMethod void survey_education_Test() {
        Survey_Education__c se = new Survey_Education__c(
            Multi_Catch__c = 'Ease of coordinating your education program = Very Satisfied Punctuality and preparedness of speaker = Satisfied Professionalism and expertise of speaker = Neutral Teaching methods met the learning needs = Unsatisfied Course material/structure facilitated learning process = Very Unsatisfied',
            Multi_Catch_2__c = 'The education program increased the knowledge and confidence of the majority of the attendees = Strongly Agree',
            Multi_Catch_3__c = 'Do you believe this education program was effective to improve your clinical practice? = No',
            Multi_Catch_4__c = 'Clinical & Medical Affairs Continuing Education Sales Other'
        );
        insert se;
        
        update se;
 
        
        
    }
}