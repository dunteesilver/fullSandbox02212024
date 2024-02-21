//PP_Global_Test_Class (importCsvTest method)
public with sharing class PP_ImportCsvPrf {

	public PRF__c prf {get;set;}
	private ApexPages.StandardController ctrl;

	//import CSV Stuff
	public Blob csvFileBody{get;set;}
	public string csvAsString{get;set;}
	public String[] csvFileLines{get;set;}
	//end of import CSV Stuff

	public PP_ImportCsvPrf() {
		String strPrfId = ApexPages.currentPage().getParameters().get('id');

		prf = (strPrfId == null) ? new Prf__c() :
					[SELECT Id, Name, Data_Driven_Justification__c, Owner_Full_Name__c, Agreement_Type__c, Eligible_Distributor__c,GPO_Affiliation__c,
					 Current_Annual_Purchases__c, Estimated_Annual_Purchases__c, Preferred_Start_Date__c, Preferred_End_Date__c, Requisition_Date__c,
					 PRF_Name__c, Owner_Business_Unit__c, Account__r.Name, Account__r.BillingStreet, Account__r.BillingCity,Sales_Deal__c,Valid_To__c,
					 Account__r.Id, Account__r.BillingState, Account__r.BillingPostalCode, Account__r.BillingCountry,CurrencyIsoCode,Valid_From__c,
					 Account__r.SAP_Sold_To__c, Contact__r.Id, Contact__r.name, Contact__r.email, Territory__c, Territory__r.Territory_Number__c,
					 Territory__r.Territory_Name__c,Status__c, Additional_Accounts__c,Sales_Org_Key__c, LastModifiedById, LastModifiedDate, Owner_ID__c,
					 CreatedById, CreatedDate, Price_Quote__c, Price_Quote__r.Name, Price_Quote__r.Price_Quote_Name__c, Line_Count__c, Owner_Email__c
					 FROM PRF__c
					 WHERE id = :ApexPages.currentPage().getParameters().get('id')
					 LIMIT 1];

      ctrl = new ApexPages.StandardController(prf);
			system.debug('prf = ' + prf);
	}

	//method to import a CSV
	public PageReference importCSVFile(){
		try{
				csvAsString = csvFileBody.toString();
				csvFileLines = csvAsString.split('\n');
				List<String> prodNames = new List<String>();
				Map<String,Decimal> liMap = new Map<String,Decimal>();
				Map<String,Integer> liMapQuan = new Map<String,Integer>();
				List<Prf_Line_Item__c> lines = new List<Prf_Line_Item__c>();
				Decimal dprice;
				Integer quan;

				for(Integer i=1;i<csvFileLines.size();i++){
						//Price_Quote_Line_Item__c liObj = new Price_Quote_Line_Item__c() ;
						string[] csvRecordData = csvFileLines[i].split(',');
						if(csvRecordData[1] != NULL){
							dprice = decimal.valueOf(csvRecordData[1].trim());
							liMap.put(csvRecordData[0],dprice);
						}
						else{
							dprice = 0.01;
							liMap.put(csvRecordData[0],dprice);
						}

						system.debug('liMap ' + liMap);
						system.debug('csvFileLines['+i+'] ' + csvFileLines[i]);
						prodNames.add(csvRecordData[0]);

				}
				List<Product2> prods = [SELECT Id, Name, List_Price__c, Rep_Price__c, RSM_Price__c,
										Director_Price__c, Floor_Price__c, Cost__c, Cost_Formula__c,
										Distributor_List__c, Alt_Site_List__c, CurrencyIsoCode, Description
										FROM Product2
										WHERE Name IN: prodNames AND Sales_Org_Key__c =: prf.Sales_Org_Key__c];

				for(Product2 curr : prods){

					//system.debug('price ***' + price);
					//system.debug('dprice ***' + dprice);
					Prf_Line_Item__c obj = new Prf_Line_Item__c();
					obj.Refresh__c = true;
					obj.Prf__c = prf.Id;
					obj.Material_Name__c = curr.Id;
					obj.List_Price__c = curr.List_Price__c;
					obj.Rep_Price__c = curr.Rep_Price__c;
					obj.RSM_Price__c = curr.RSM_Price__c;
					obj.Director_Price__c = curr.Director_Price__c;
					obj.Floor_Price__c = curr.Floor_Price__c;
					obj.Cost__c = curr.Cost_Formula__c;
					//system.debug('curr.name ***' + curr.Name);
					//system.debug('decimal Price ***' + liMap.get(curr.Name));
					obj.Requested_Price__c = liMap.get(curr.name);
					obj.CurrencyIsoCode = curr.CurrencyIsoCode;
					obj.Product_Description__c = curr.Description;
					//obj.Row_Order__c = lineCount + 1;
					lines.add(obj);
				}

				try{
					insert lines; // insert line items with just standard pricing
				}
				catch(Exception e){
					ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'An error has occured while trying to insert materials.  Please make sure input csv file is correct.. (Error: '+e.getMessage()+')');
				}

		 }//end of outter try
		 catch (Exception e)
		 {
				 ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'An error has occured while importing data.  Please make sure input csv file is correct.. (Error: '+e.getMessage()+')');
				 ApexPages.addMessage(errorMessage);
		 }

		 String prfid = prf.Id;
		 List<Prf_Line_Item__c> check = [SELECT Eligible_Price__c,Id,Material_Name__c,Refresh__c,Requested_Price__c
		 																FROM Prf_Line_Item__c
																		WHERE refresh__c = true AND Prf__c =:prfid];
		 if(check.size() > 0){
			 String query = 'SELECT Eligible_Price__c,Id,Material_Name__c,Refresh__c,Requested_Price__c FROM Prf_Line_Item__c WHERE refresh__c = true AND Prf__c = \''+prfid+'\'';
			 PP_ImportCsvBatch batch = new PP_ImportCsvBatch(query);
			 Database.executeBatch(batch,50);
			 ID batchprocessid = Database.executeBatch(batch,50);

			 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Your request is being processed.  You will receive an email when your batch job is complete.'));
			 return null;
		 }
		 else{
			 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'No line items found for this PRF.'));
			 return null;
		 }

	 }//end of importCsv method

}