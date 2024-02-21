public class OptOut {
    
    public list<Contact> contactList {get; set;}
    public list<Lead> leadList {get; set;}
    
    public pagereference save(){
        string email = ApexPages.currentPage().getParameters().get('email');
        email = email.replace('%40','@');
        String confirm = ApexPages.currentPage().getParameters().get('econfirm');
        if(email != '' && confirm != ''){
            contactList = [SELECT id, HasOptedOutOfEmail FROM contact WHERE email = :email];
            leadList =  [SELECT id, HasOptedOutOfEmail FROM lead WHERE email = :email];
            list<Contact> updateList = new List<Contact>();
            list<Lead> updateList2 = new List<Lead>();
            
            for (Contact c : contactList){
                Contact updateContact = new Contact(
                    HasOptedOutOfEmail = TRUE,
                    Id = c.Id
                );
                updateList.add(updateContact);
            }
            
            for (Lead l : leadList){
                Lead updateLead = new Lead(
                    HasOptedOutOfEmail = TRUE,
                    Id = l.Id
                );
                updateList2.add(updateLead);
            }
            if(!contactList.isEmpty()){
                update updateList;
            }
            
            if(!leadList.isEmpty()){
                update updateList2;
            }
        }
        PageReference priceLookup = New Pagereference('/OptOut_Confirm');
        priceLookup.setRedirect(true); 
        return priceLookup;
    }
}