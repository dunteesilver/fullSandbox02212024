public with sharing class bulkXRefController {
    public List<Cross_Reference__c> xRef;
    private ApexPages.StandardController controller {get; set;}    
    private Cross_Reference_Project__c proj;
    
    public bulkXRefController(ApexPages.StandardController controller) {
        this.controller = controller;
        this.proj = (Cross_Reference_Project__c)controller.getRecord();
    }

    @remoteAction
    public static Boolean pullXref(String dirtyInput, String projectId) {
        List<String> lines = dirtyInput.split('\n');
        Set<String> cleansedLines = new Set<String>();
        List<Cross_Reference_Project_Item__c> newItems = new List<Cross_Reference_Project_Item__c>();
        Set<String> cleansedExisting = new Set<String>();
        List<Cross_Reference_Project_Item__c > lst_CR = [SELECT Id, Competitive_Product_Code__c FROM Cross_Reference_Project_Item__c WHERE Cross_Reference_Project__c =:projectId];
        for(Cross_Reference_Project_Item__c ei: lst_CR){
            cleansedExisting.add(ei.Competitive_Product_Code__c);
        }
        /*for(Cross_Reference_Project_Item__c ei: [SELECT Id, Competitive_Product_Code__c FROM Cross_Reference_Project_Item__c WHERE Cross_Reference_Project__c =:projectId]){
            cleansedExisting.add(ei.Competitive_Product_Code__c);
        }*/
        string c;
        for(String a: lines){
            a = a.trim();
            a = a.toUpperCase();
            c = a.replaceAll('[^A-Za-z0-9]', '');
            if(cleansedExisting.isEmpty() == true || cleansedExisting.contains(c) == false){
                if(cleansedLines.isEmpty() == true || cleansedLines.contains(c) == false){
                    if(c != ''){
                         cleansedLines.add(c);
                    }
                }
            }
        }
        
        for(String b: cleansedLines){
            newItems.add(new Cross_Reference_Project_Item__c(Competitive_Product_Code__c = b, Cross_Reference_Project__c = projectId));
        }

        insert newItems; 

        return true;
    }

    @remoteAction
    public static List<Cross_Reference_Project_Item__c> pullItems(String projectId){
        List<Cross_Reference_Project_Item__c> items = [SELECT Id, Competitive_Product_Code__c, Cross_Reference__c, Cross_Reference_1__c, Cross_Reference_2__c, Cross_Reference_3__c, Cross_Reference__r.Competitor_Product_Code__c, Cross_Reference__r.Competitor_Product_Description__c, Cross_Reference__r.Product__r.Name, Cross_Reference_Project__c FROM Cross_Reference_Project_Item__c WHERE Cross_Reference_Project__c =:projectId];
        
        return items;
    }

    @remoteAction
    public static List<Cross_Reference__c> pullRelationships(String projectId){
        List<Cross_Reference_Project_Item__c> items = [SELECT Id, Competitive_Product_Code__c FROM Cross_Reference_Project_Item__c WHERE Cross_Reference_Project__c =:projectId];
        Set<String> competitorCodes = new Set<String>();
        string product, comp_product;
        for(Cross_Reference_Project_Item__c i: items){
            comp_product = i.Competitive_Product_Code__c;
            product = comp_product.replaceAll('[^A-Z a-z 0-9]', '');
            
            if(!competitorCodes.contains(product)) {
                competitorCodes.add(product);
            }
        }
        List<Cross_Reference__c> rel = [SELECT Id, Product__R.Name, Product__r.Description, Competitor_Product_Code__c, Competitor_Product_Description__c, Competitor_Name__c, Percent_Match__c, Key_Difference__c FROM Cross_Reference__c WHERE Competitor_Code_Cleansed__c in :competitorCodes AND (Status__c = 'Active' OR Status__c = '')];

        return rel;
    }

    @remoteAction
    public static List<Cross_Reference__c> pullDescriptors(String projectId, String xrefId){
        List<Cross_Reference__c> tmpXref = new List<Cross_Reference__c>();
        Set<String> selectedXrefs = new Set<String>();
        if(xrefId != ''){
            tmpXref = [SELECT Id, Product__R.Name, Product__r.Description, Product__r.Each_per_Case__c, Competitor_Product_Code__c, Competitor_Product_Description__c, Competitor_Name__c, Percent_Match__c, Key_Difference__c FROM Cross_Reference__c WHERE Id = :xrefId];
            
        }else{
            List<Cross_Reference_Project_Item__c> tmpItems = pullItems(projectId);
            for(Cross_Reference_Project_Item__c i: tmpItems){
                if(i.Cross_Reference__c != null){
                    selectedXrefs.add(i.Cross_reference__c);
                }
                if(i.Cross_Reference_1__c != null){
                    selectedXrefs.add(i.Cross_reference_1__c);
                }
                if(i.Cross_Reference_2__c != null){
                    selectedXrefs.add(i.Cross_reference_2__c);
                }
                if(i.Cross_Reference_3__c != null){
                    selectedXrefs.add(i.Cross_reference_3__c);
                }
            }
            tmpXref = [SELECT Id, Product__R.Name, Product__r.Description, Product__r.Each_per_Case__c, Competitor_Product_Code__c, Competitor_Product_Description__c, Competitor_Name__c, Percent_Match__c, Key_Difference__c FROM Cross_Reference__c WHERE Id IN :selectedXrefs];
            
        }
        return tmpXref;
    }

    @remoteAction
    public static boolean commitChange(String product, String xrefId, String xrefId1, String xrefId2, String xrefId3, String projectId){
        List<Cross_Reference_Project_Item__c> item = [SELECT Id, Cross_Reference__c FROM Cross_Reference_Project_Item__c WHERE Competitive_Product_Code__c = :product AND Cross_Reference_Project__c = :projectId];
        if(item.isEmpty() == false && xrefId != ''){
            item[0].Cross_Reference__c = xrefId;
            if(xrefId1 != ''){
                item[0].Cross_Reference_1__c = xrefId1;
            }else{
                item[0].Cross_Reference_1__c = null;
            }
            if(xrefId2 != ''){
                item[0].Cross_Reference_2__c = xrefId2;
            }else{
                item[0].Cross_Reference_2__c = null;
            }
            if(xrefId3 != ''){
                item[0].Cross_Reference_3__c = xrefId3;
            }else{
                item[0].Cross_Reference_3__c = null;
            }
            update item;
        }
        return null;
    }

    @remoteAction
    public static boolean removeRecord(String product){
        List<Cross_Reference_Project_Item__c> item = [SELECT Id, Cross_Reference__c FROM Cross_Reference_Project_Item__c WHERE Competitive_Product_Code__c = :product];
        if(item.isEmpty() == false){
            delete item;
        }
        return null;
    }
}