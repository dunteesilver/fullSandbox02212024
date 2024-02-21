public with sharing class accountGraph {

    public Account acct;
    public LIST<User> currentBU;
    public string currentUser;
    public Date d = date.today();
    public Decimal PFYTD11;
    public Decimal PFYTD12;
    public Decimal PFY;
    public Decimal CFYTD;
    public Integer maxY {get;set;}
    public Integer minY {get;set;}

      public accountGraph(ApexPages.StandardController stdController) {
        List<String> fields = new List<String>();
         if(!test.isRunningTest()){
        /*  fields.add('IA_PFY_2012__c');
          fields.add('IA_PFY_2011__c');
          fields.add('Vascular_PFY_2012__c');
          fields.add('Vascular_PFY_2011__c');
          fields.add('AR_PFY_2012__c');
          fields.add('AR_PFY_2011__c');
          fields.add('R_PFY_2012__c');
          fields.add('R_PFY_2011__c');
          fields.add('surgical_PFY_2012__c');
          fields.add('surgical_PFY_2011__c');
          fields.add('Specialty_PFY_2012__c');
          fields.add('Specialty_PFY_2011__c');*/
          fields.add('SAP_Sold_To__c');
          stdController.addFields(fields);
        }


        this.acct = (Account)stdController.getRecord();

        currentUser = UserInfo.getUserId();
        System.debug('************ USER: ************ ' + currentUser);

        currentBU = [SELECT Business_Unit__c FROM User WHERE Id = :currentUser];

        System.debug('************ Business Unit: ************ ' + currentBU);

    /*    if(currentBU[0].Business_Unit__c == 'Anesthesia'){
            if(acct.AR_PFY_2011__c != null){
              PFYTD11 = (acct.AR_PFY_2011__c / 365) * d.dayOfYear();
             } else {
              PFYTD11 = 0;
             }

            if(acct.AR_PFY_2012__c != null){
              PFYTD12 = (acct.AR_PFY_2012__c / 365) * d.dayOfYear();
              } else {
              PFYTD12 = 0;
              }

            if(acct.A_R_SAP_PFY__c != null){
              PFY = (acct.A_R_SAP_PFY__c / 365) * d.dayOfYear();
              } else {
              PFY = 0;
              }

            if(acct.A_R_SAP_CFYTD__c != null){
               CFYTD = (acct.A_R_SAP_CFYTD__c);
              } else {
               CFYTD = 0;
              }
        }else
        if(currentBU[0].Business_Unit__c == 'Respiratory'){
            if(acct.R_PFY_2011__c != null){
              PFYTD11 = (acct.R_PFY_2011__c / 365) * d.dayOfYear();
             } else {
              PFYTD11 = 0;
             }

            if(acct.R_PFY_2012__c != null){
              PFYTD12 = (acct.R_PFY_2012__c / 365) * d.dayOfYear();
              } else {
              PFYTD12 = 0;
              }

            if(acct.R_PFY__c != null){
              PFY = (acct.R_PFY__c / 365) * d.dayOfYear();
              } else {
              PFY = 0;
              }

            if(acct.R_CFYTD__c != null){
               CFYTD = (acct.R_CFYTD__c);
              } else {
               CFYTD = 0;
              }
        }else
        if(currentBU[0].Business_Unit__c == 'Vascular'){
            if(acct.Vascular_PFY_2011__c != null){
              PFYTD11 = (acct.Vascular_PFY_2011__c / 365) * d.dayOfYear();
             } else {
              PFYTD11 = 0;
             }

            if(acct.Vascular_PFY_2012__c != null){
              PFYTD12 = (acct.Vascular_PFY_2012__c / 365) * d.dayOfYear();
              } else {
              PFYTD12 = 0;
              }

            if(acct.Vascular_PFY__c != null){
              PFY = (acct.Vascular_PFY__c / 365) * d.dayOfYear();
              } else {
              PFY = 0;
              }

            if(acct.Vascular_CFYTD__c != null){
               CFYTD = (acct.Vascular_CFYTD__c);
              } else {
               CFYTD = 0;
              }
        }else
        if(currentBU[0].Business_Unit__c == 'Surgical') {
           if(acct.Surgical_PFY_2011__c != null){
              PFYTD11 = (acct.Surgical_PFY_2011__c / 365) * d.dayOfYear();
             } else {
              PFYTD11 = 0;
             }

            if(acct.Surgical_PFY_2012__c != null){
              PFYTD12 = (acct.Surgical_PFY_2012__c / 365) * d.dayOfYear();
              } else {
              PFYTD12 = 0;
              }

            if(acct.Surgical_PFY__c != null){
              PFY = (acct.Surgical_PFY__c / 365) * d.dayOfYear();
              } else {
              PFY = 0;
              }

            if(acct.Surgical_CFYTD__c != null){
               CFYTD = (acct.Surgical_CFYTD__c);
              } else {
               CFYTD = 0;
              }

        }else
        if(currentBU[0].Business_Unit__c == 'Interventional') {
            if(acct.IA_PFY_2011__c != null){
              PFYTD11 = (acct.IA_PFY_2011__c / 365) * d.dayOfYear();
             } else {
              PFYTD11 = 0;
             }

            if(acct.IA_PFY_2012__c != null){
              PFYTD12 = (acct.IA_PFY_2012__c / 365) * d.dayOfYear();
              } else {
              PFYTD12 = 0;
              }

            if(acct.IA_PFY__c != null){
              PFY = (acct.IA_PFY__c / 365) * d.dayOfYear();
              } else {
              PFY = 0;
              }

            if(acct.IA_CFYTD__c != null){
               CFYTD = (acct.IA_CFYTD__c);
              } else {
               CFYTD = 0;
              }
        }else
        if(currentBU[0].Business_Unit__c == 'Specialty') {
            if(acct.Specialty_PFY_2011__c != null){
              PFYTD11 = (acct.Specialty_PFY_2011__c / 365) * d.dayOfYear();
             } else {
              PFYTD11 = 0;
             }

            if(acct.Specialty_PFY_2012__c != null){
              PFYTD12 = (acct.Specialty_PFY_2012__c / 365) * d.dayOfYear();
              } else {
              PFYTD12 = 0;
              }

            if(acct.Specialty_PFY__c != null){
              PFY = (acct.Specialty_PFY__c / 365) * d.dayOfYear();
              } else {
              PFY = 0;
              }

            if(acct.Specialty_CFYTD__c != null){
               CFYTD = (acct.Specialty_CFYTD__c);
              } else {
               CFYTD = 0;
              }
        }else
        if(currentBU[0].Business_Unit__c == 'Latin America') {
            if(acct.Latam_PFY_2011__c != null){
              PFYTD11 = (acct.Latam_PFY_2011__c / 365) * d.dayOfYear();
             } else {
              PFYTD11 = 0;
             }

            if(acct.Latam_PFY_2012__c != null){
              PFYTD12 = (acct.Latam_PFY_2012__c / 365) * d.dayOfYear();
              } else {
              PFYTD12 = 0;
              }

            if(acct.Latam_PFY__c != null){
              PFY = (acct.Latam_PFY__c / 365) * d.dayOfYear();
              } else {
              PFY = 0;
              }

            if(acct.Latam_CFYTD__c != null){
               CFYTD = (acct.Latam_CFYTD__c);
              } else {
               CFYTD = 0;
              }
        } else {
          PFYTD11 = 0;
          PFYTD12 = 0;
          PFY = 0;
          CFYTD = 0;
        }*/
          PFYTD11 = 0;
          PFYTD12 = 0;
          PFY = 0;
          CFYTD = 0;

        Decimal temp1 = math.min(PFYTD11,PFYTD12);
        Decimal temp2 = math.min(PFY,CFYTD);
        minY = math.min(temp1,temp2).intValue();
        minY = ((minY*0.8)/1000).intValue();

        Decimal temp3 = math.max(PFYTD11,PFYTD12);
        Decimal temp4 = math.max(PFY,CFYTD);
        maxY = math.max(temp3,temp4).intValue();
        maxY = ((maxY*1.2)/1000).intValue();

    }

    public PageReference processcreateContact(){


       PageReference  objP = new Pagereference('/apex/PP_Create_Contact?cid='+acct.SAP_Sold_To__c).setRedirect(True);
       return objP;
    }
    public List<PieWedgeData> getPieData(){

       List<PieWedgeData> data = new List<PieWedgeData>();

       data.add(new PieWedgeData(d.addYears(-3).year()+' YTD',(PFYTD11/1000).setScale(1)));
       data.add(new PieWedgeData(d.addYears(-2).year()+' YTD',(PFYTD12/1000).setScale(1)));
       data.add(new PieWedgeData(d.addYears(-1).year()+' YTD',(PFY/1000).setScale(1)));
       data.add(new PieWedgeData(d.year()+' YTD',(CFYTD/1000).setScale(1)));

       return data;
    }

    // Wrapper class
    public class PieWedgeData
    {
        public String name { get; set; }
        public Decimal data { get; set; }

        public PieWedgeData(String name, Decimal data)
        {
            this.name = name;
            this.data = data;

        }
    }
}