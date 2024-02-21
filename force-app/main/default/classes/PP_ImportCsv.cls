//PP_Global_Test_Class (importCsvTest method)
public with sharing class PP_ImportCsv {

	public Price_Quote__c pq {get;set;}
	private ApexPages.StandardController ctrl;

	//import CSV Stuff
	public Blob csvFileBody{get;set;}
	public string csvAsString{get;set;}
	public List<String> csvFileLines{get;set;}
	//end of import CSV Stuff

	public PP_ImportCsv() {
		String strQuoteId = ApexPages.currentPage().getParameters().get('pqid');

		pq = (strQuoteId == null) ? new Price_Quote__c() :
		 [Select Id, Name, Status__c, Commit_Date__c, CreatedDate, LastModifiedDate, Grand_Total__c, Customer_comments__c, Internal_Comments_Only__c,
              Account_Name__r.Name,Account_Name__c, Account_Name__r.Id, Account_Name__r.BillingStreet, Account_Name__r.BillingCity, Account_Name__r.BillingState,
              Account_Name__r.BillingPostalCode, Account_Name__r.BillingCountry, Account_Name__r.SAP_Sold_To__c,Account_Name__r.Account_Group__c, Quote_Description__c, No_Opp__c,
              Expiration_Date__c, Owner_ID__c, Owner_Full_Name__c, Owner_Cell__c, Owner_Phone__c, Owner_Email__c, Contact_Name__r.name, Opportunity__r.Name,
              Business_Unit__c, Contact_Name__r.id, Contact_Name__r.phone, Contact_Name__r.email, LastModifiedById, CreatedById, PRF__c,
              CurrencyIsoCode,Sales_Org_Key__c, Line_Count__c,Owner_Business_Unit__c, InApproval__c,One_Time_Purchase__c, Account_Name__r.Price_List_Type__c
              FROM Price_Quote__c
              WHERE id = :strQuoteId LIMIT 1];

      ctrl = new ApexPages.StandardController(pq);
			system.debug('pq = ' + pq);
	}

	//method to import a CSV
	public PageReference importCSVFile(){
		try{
				csvAsString = csvFileBody.toString();
				System.debug('csvAsString *** ' + csvAsString);
				csvFileLines = csvAsString.split('\n');
				List<String> prodNames = new List<String>();
				Map<String,Decimal> liMap = new Map<String,Decimal>();
				Map<String,Integer> liMapQuan = new Map<String,Integer>();
				List<Price_Quote_Line_Item__c> lines = new List<Price_Quote_Line_Item__c>();
				Decimal dprice;
				Integer quan;
				System.debug('*** csvFileLines.size() *** ' + csvFileLines.size());
				for(Integer i=1;i<csvFileLines.size();i++){
						//Price_Quote_Line_Item__c liObj = new Price_Quote_Line_Item__c() ;
						List<String> csvRecordData = csvFileLines[i].split(',');
						System.debug('*** csvRecordData *** ' + csvRecordData);
                    	System.debug('*** csvRecordData.size() *** ' + csvRecordData.size() );
						System.debug('*** i *** ' + i);
		
						for(Integer k=1;k<csvRecordData.size();k++){
							System.debug('*** csvRecordData.size() *** ' + csvRecordData.size());
                            if(k==1){
                                System.debug('*** k *** ' + k);
                                if(csvRecordData[k] != NULL && csvRecordData[k] != ''){
                                    System.debug('*** IN csvRecordDate[1] IF ***');
									dprice = decimal.valueOf(csvRecordData[1].trim());
									liMap.put(csvRecordData[0],dprice);
									System.debug('*** liMap csvRecordData[1] IF *** ' + liMap);
                                }//end of inner if
                                else{
									System.debug('*** IN csvRecordDate[1] ELSE ***');
									dprice = 0.01;
									liMap.put(csvRecordData[0],dprice);
									System.debug('*** liMap csvRecordData[1] ELSE *** ' + liMap);
								}//end else
                            }//end of outter if

                            if(k==2){
                                System.debug('*** k *** ' + k);
                                System.debug('*** csvRecordData[k] in k==2 *** ' + csvRecordData[k]);
                                if(csvRecordData[k] != NULL && csvRecordData[k] != ''){
                                    System.debug('*** IN csvRecordDate[2] IF ***');
                                    System.debug('*** csvRecordData[2] IN IF *** ' + csvRecordData[2]);
                                    quan = integer.valueOf(csvRecordData[2].trim());
                                    liMapQuan.put(csvRecordData[0],quan);
                                    System.debug('*** liMapQuan csvRecordData[2] IF *** ' + liMapQuan);
                                }//end inner if
                                else{
                                    System.debug('*** IN csvRecordDate[2] ELSE ***');
                                    quan = 1;
                                    liMapQuan.put(csvRecordData[0],quan);
                                    System.debug('*** liMapQuan csvRecordData[2] ELSE *** ' + liMapQuan);
                                }//end else 
                            }//end outter if
                            
						}//end inner for(Integer k=1;k<csvRecordData.size();k++)

						system.debug('liMap ' + liMap);
                    	system.debug('liMapQuan ' + liMapQuan);
						system.debug('csvFileLines['+i+'] ' + csvFileLines[i]);
						prodNames.add(csvRecordData[0]);
				}//end outter for(Integer i=1;i<csvFileLines.size();i++)

				List<Product2> prods = [SELECT Id, Name, List_Price__c, Rep_Price__c, RSM_Price__c, CurrencyIsoCode,
										Director_Price__c, Floor_Price__c, Cost__c, Cost_Formula__c, Description
										FROM Product2
										WHERE Name IN: prodNames AND Sales_Org_Key__c =: pq.Sales_Org_Key__c];

				system.debug('prods *** ' + prods);
				for(Product2 curr : prods){

					//system.debug('price ***' + price);
					//system.debug('dprice ***' + dprice);
					Price_Quote_Line_Item__c obj = new Price_Quote_Line_Item__c();
					obj.Refresh__c = true;
					obj.Price_Quote__c = pq.Id;
					obj.Material_Name__c = curr.Id;
					obj.Product_Description__c = curr.Description;
					obj.List_Price__c = curr.List_Price__c;
					obj.Rep_Price__c = curr.Rep_Price__c;
					obj.RSM_Price__c = curr.RSM_Price__c;
					obj.Director_Price__c = curr.Director_Price__c;
					obj.Floor_Price__c = curr.Floor_Price__c;
					obj.Cost__c = curr.Cost_Formula__c;
					//system.debug('curr.name ***' + curr.Name);
					//system.debug('decimal Price ***' + liMap.get(curr.Name));
					obj.Sales_Price__c = liMap.get(curr.name);
					obj.Quantity__c = liMapQuan.get(curr.name);
					obj.CurrencyIsoCode = curr.CurrencyIsoCode;
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
				 ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'An error has occured while importing data Please make sure input csv file is correct.. (Error: '+e.getMessage()+')');
				 ApexPages.addMessage(errorMessage);
		 }

		 String quoteid = pq.Id;
		 List<Price_Quote_Line_Item__c> check = [SELECT Eligible_Price__c,Id,Material_Name__c,Refresh__c,Sales_Price__c FROM Price_Quote_Line_Item__c WHERE refresh__c = true AND Price_Quote__c =:quoteid];
		 if(check.size() > 0){
			 String query = 'SELECT Eligible_Price__c,Id,Material_Name__c,Refresh__c,Sales_Price__c FROM Price_Quote_Line_Item__c WHERE refresh__c = true AND Price_Quote__c = \''+quoteid+'\'';
			 PP_ImportCsvBatch batch = new PP_ImportCsvBatch(query);
			 Database.executeBatch(batch,50);
			 ID batchprocessid = Database.executeBatch(batch,50);

			 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Your request is being processed.  You will receive an email when your batch job is complete.'));
			 return null;
		 }
		 else{
			 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.label.EMEA_No_line_items_found_for_this_Price_Quote));
			 return null;
		 }

	 }//end of importCsv method

}