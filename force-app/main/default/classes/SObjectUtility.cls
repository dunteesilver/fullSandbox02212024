/*********************************************************************
* Description      : utility class to deal with methods related to sobject operations.
* Test Class       : SObjectUtilityTest.apxc
* Author(s)        : Surya Arvan - surya.arvan@teleflex.com
* Date         	   : 04/25/2023
* Work Item		   : W-
**********************************************************************/
public class SObjectUtility {
    
    
    public static List<String> getChkBoxFieldAPINames(String sObjName){
        Schema.DescribeSObjectResult contractUserDescribe = Schema.getGlobalDescribe().get(sObjName).getDescribe();
        Map<String, Schema.SObjectField> contractUserFields = contractUserDescribe.fields.getMap();
        List<String> checkboxFields = new List<String>();
        for (String fieldName : contractUserFields.keySet()) {
            Schema.SObjectField field = contractUserFields.get(fieldName);
            Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
            if (fieldDescribe.getType() == Schema.DisplayType.BOOLEAN) {
                checkboxFields.add(fieldName);
            }
        }
        return checkboxFields;
    }
    
    public static List<String> getChkBoxFieldLabelNames(String sObjName){
        Schema.DescribeSObjectResult contractUserDescribe = Schema.getGlobalDescribe().get(sObjName).getDescribe();
        Map<String, Schema.SObjectField> contractUserFields = contractUserDescribe.fields.getMap();
        List<String> checkboxFields = new List<String>();
        for (String fieldName : contractUserFields.keySet()) {
            Schema.SObjectField field = contractUserFields.get(fieldName);
            Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
            if (fieldDescribe.getType() == Schema.DisplayType.BOOLEAN) {
                if(fieldDescribe.getLabel().contains('Division')){
                    checkboxFields.add(fieldDescribe.getLabel());
                }
            }
        }
        return checkboxFields;
    }
    public static Map<String, String> getAllChkBoxFieldAPIAndLabelNames(String sObjName){
        Schema.DescribeSObjectResult contractUserDescribe = Schema.getGlobalDescribe().get(sObjName).getDescribe();
        Map<String, Schema.SObjectField> contractUserFields = contractUserDescribe.fields.getMap();
        Map<String, String> checkboxFieldsMap = new Map<String,String>();
        for (String fieldName : contractUserFields.keySet()) {
            Schema.SObjectField field = contractUserFields.get(fieldName);
            Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
            if (fieldDescribe.getType() == Schema.DisplayType.BOOLEAN) {
                checkboxFieldsMap.put(fieldDescribe.getLabel(), fieldName);
            }
        }
        return checkboxFieldsMap;
    }
    
    public static List<Contract_User__c> getContractUserRecords(List<Id> newIds){
        List<Contract_User__c> listOfContractUsers=new List<Contract_User__c>();
        List<String> fieldsToQuery=getChkBoxFieldAPINames('Contract_User__c');
        if(fieldsToQuery!=NULL){
            String queryString = 'SELECT User__r.id, Pricing_Tier_Access__c';
            for (String field : fieldsToQuery) {
                queryString += ', ' + field;
            }
            queryString += ', Name FROM Contract_User__c WHERE Id IN :newIds LIMIT 1000';
            listOfContractUsers =Database.query(queryString);
        }
        return listOfContractUsers;
        
    }
    
    public static void main(List<Id> newIds){
        
        
        map<String, Id> groupMap = new map<String, Id>();
        for(Group g : [SELECT Name, Id FROM GROUP
                       WHERE Name = 'Pricing Portal'
                       OR Name like '%Division%'
                       OR Name like 'Pricing Tier%'])
        {
            groupMap.put(g.Name, g.Id);
            system.debug('g.name:' + g.name + ' g.Id ' + g.id);
        }
        
        
        
        List<String> ppUserChkbxkFieldLst = SObjectUtility.getChkBoxFieldAPINames('Contract_User__c');
        String query='SELECT Pricing_Tier_Access__c, ';        
        for(String s : ppUserChkbxkFieldLst)
        {
            query += s + ',';
        }
        query += 'User__r.id, Name FROM Contract_User__c WHERE Id IN :newIds';
        for(Contract_User__c cu : Database.query(query)){
            cu.get('AT_Division_10__c');
        }
    }
    /*
//method to fix bad characters from language conversions
public static String replaceMessedUpCharacters(String input) {
// Replace messed up characters with their appropriate counterparts
String replacedString =  input.replaceAll('ÃŸ', 'ß') // German sharp s
.replaceAll('Ł¡','š')
.replaceAll('Å', 'Ł')
.replaceAll('Å','Ł')
.replaceAll('Åº','ź')
.replaceAll('Ł,','ł')
.replaceAll('Ł„','n')
.replaceAll('Ł¼','ż')
.replaceAll('Ł›','ś')
.replaceAll('Łº','ź')
.replaceAll('Ã¤', 'ä') // German umlaut a
.replaceAll('Ã¶', 'ö') // German umlaut o
.replaceAll('Ã¼', 'ü') // German umlaut u
.replaceAll('Ã-', 'Ö') // German
.replaceAll('Ã–', 'Ö') // German
.replaceAll('Å¡', 'š') // Slovak s with caron
.replaceAll('Å¥', 'ť') // Slovak t with caron
.replaceAll('Å¾', 'ž') // Slovak z with caron
.replaceAll('Ä™', 'ę') // Polish e with ogonek
.replaceAll('Ä‡', 'ć') // Polish c with acute
.replaceAll('Å‚', 'ł') // Polish l with stroke
.replaceAll('Ä…', 'ą') // Polish a with ogonek
.replaceAll('Å›', 'ś') // Polish s with acute
.replaceAll('Ã©', 'é') // French e with acute
.replaceAll('Ã¨', 'è') // French e with grave
.replaceAll('Ãª', 'ê') // French e with circumflex
.replaceAll('Ã§', 'ç') // French c with cedilla
.replaceAll('Ã¡', 'á') // Spanish a with acute
.replaceAll('Ã³', 'ó') // Spanish o with acute
.replaceAll('Ãº', 'ú') // Spanish u with acute
.replaceAll('Ã±', 'ñ') // Spanish n with tilde
.replaceAll('Ã£', 'ã') // Portuguese a with tilde
.replaceAll('Ã´', 'ô') // Portuguese o with circumflex
.replaceAll('Ä', 'č') // Czech c with caron
.replaceAll('Å™', 'ř') // Czech r with caron
.replaceAll('Å¯', 'ů') // Czech u with ring above
.replaceAll('Ã§', 'ç') // Flemish c with cedilla
.replaceAll('Ã«', 'ë') // Flemish e with diaeresis
.replaceAll('Ã©', 'é') // Flemish e with acute
.replaceAll('Åº', 'ź')
.replaceAll('Â',' ')
.replaceAll('Ã½','ý')
.replaceAll('Ã','í')
.replaceAll('Å„','ń')
.replaceAll('Å¼','ż')
.replaceAll('Åš','Ś')
.replaceAll('Å»','Ż');


return replacedString;
}
// end replaceMessedUpCharacters
*/
    //new version
    public static String replaceMessedUpCharacters(String input) {
        // Define a map for character replacements
        Map<String, String> replacements = new Map<String, String>{
                'ÃŸ' => 'ß',
                'Å™' => 'ř',
                'Ã§' => 'ç',
                'Åº' => 'ź',
                'Ã¶' => 'ö',
                'Ã¤' => 'ä',
                'Åš' => 'Ś',
                'Ã¼' => 'ü',
                'Åš' => 'Ś',
                'Ã-' => 'Ö',
                'Ã–' => 'Ö',
                'Å¡' => 'š',
                'Å¥' => 'ť',
                'Å¾' => 'ž',
                'Ä™' => 'ę',
                'Ä‡' => 'ć',
                'Å‚' => 'ł',
                'Ä…' => 'ą',
                'Å›' => 'ś',
                'Ã©' => 'é',
                'Ã¨' => 'è',
                'Ãª' => 'ê',
                'Ã¡' => 'á',
                'Ã³' => 'ó',
                'Ãº' => 'ú',
                'Ã±' => 'ñ',
                'Ã£' => 'ã',
                'Ã´' => 'ô',
                'Ä' => 'č',
                'Å¯' => 'ů',
                'Ã«' => 'ë',
                'Ã©' => 'é',
                'Åº' => 'ź',
                'Â' => ' ',
                'Ã½' => 'ý',
                'Å' => 'Ł',
                'Å' => 'Ł',
                'Ã' => 'í',
                'Å„' => 'ń',
                'Å¼' => 'ż',
                'Å»' => 'Ż',
                'Ł„' => 'n',
                'Ł¼' => 'ż',
                'Łº' => 'ź',
                'Ł¡' => 'š',
                'Ł,' => 'ł',
                'Ł›' => 'ś'
                };
                    
                    // Iterate through the map and replace characters
                    for (String source : replacements.keySet()) {
                        input = input.replace(source, replacements.get(source));
                    }
        System.debug('*** Account input *** ' + input);
        return input;
    }
    
    //end new version
    
}