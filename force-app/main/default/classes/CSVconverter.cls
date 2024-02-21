public with sharing class CSVconverter {
    
    //Method to convert JSON response List of Contacts records to CSV content
   /* public static String convertJsonToCsv(String jsonResponse){
        List<Object> entryList =(List<Object>) JSON.deserializeUntyped(jsonResponse);

        List<Map<String, Object>> mapList =new List<Map<String,Object>>();
        Set<String> keySet=new Set<String>();

        for(Object entry:entryList){
           Map<String, Object> entryMap=(Map<String, Object>) entry;

          //excluding attributes key
          entryMap.remove('attributes');
          keySet.addAll(entryMap.keySet());
          mapList.add(entryMap);
        }

        List<String> keys =new List<String>(keySet);
        keys.sort();

        List<List<String>> csvLines=new List<List<String>>();
    //Creating a list of lists to represent CSV rows
    for(Integer i=0; i<mapList.size()+1; i++){
        csvLines.add(new List<String>());

    }
    //populate the first row with column headers
    for(String key:keys){
        csvLines.get(0).add('"'+ key +'"');
        for (Integer i = 1; i < mapList.size(); i++) {
            csvLines.get(i).add('"' + String.valueOf(mapList.get(i - 1).get(key)) + '"');
        }
    }
    //Populate the remaining rows with data
    
    //Build the CSV file content
    String csvFile='';
    for(List<String> csvLine:csvLines){
        String line='';
        for(Integer i=0; i<csvLine.size()-1;i++){
            line+=csvLine.get(i)+',';
        }
        line+=csvLine.get(csvLine.size()-1);
        csvFile+=line+'\n';
    }
    System.debug('Printing csvFile content '+csvFile);
  return csvFile;
 
   
    }*/
}