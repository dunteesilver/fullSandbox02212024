public class userVerify {
    
    public list<user> userList {get;set;}
    public list<string> missList {get;set;}
    public map<String,Boolean> ucheckMap {get;set;}
    public String searchStr{get;set;}
    
    // Alternate Bulk Insert
    public void userCheck(){

        String bulkstr;
        string emailStr;
        ucheckMap = new map<String,Boolean>();
        missList = new list<string>();
        userList = new list<user>();

        List<String> ulist = new List<String>();
        for(String bl : searchStr.split('\n')){
            if(bl != NULL){
                bulkstr = bl.trim();
                bulkstr = bulkstr.toUpperCase();
                ulist.add(bulkstr);
                system.debug('bulkstr: ' + bulkstr);                
                ucheckMap.put(bulkstr, FALSE);                
            }
        }
        system.debug('ulist: ' + ulist);
        userList = [SELECT Title, IsActive, Name, Email FROM User WHERE Email =:ulist];
        if(userList.size() > 0){
            for(user u : userList){
                emailStr = u.Email;
                emailStr = emailStr.toUpperCase();
                ucheckMap.put(emailStr, TRUE);
                system.debug('Removing u.Email: ' + u.Email);
            }
        }
        system.debug('ucheckMap: ' + ucheckMap);
        for(string s : ucheckMap.keySet()){
            if(ucheckMap.get(s) == FALSE){
                missList.add(s);
            }
        }

    }

}