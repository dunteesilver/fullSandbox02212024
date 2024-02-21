global with sharing class ChangeLeadOwnerController_Ext {

    public static String leadRec;
    public String getLeadRec() {
        return leadRec;
    }

    public void setLeadRec(String recordId){
        leadRec = recordId;
    }
    public ChangeLeadOwnerController_Ext(ApexPages.StandardController controller) {

    }
/*
    @RemoteAction
    global static List<User> getUserRecs() {
        if(!(Schema.sobjectType.User.fields.Name.isAccessible() && Schema.sobjectType.User.fields.Title.isAccessible())) {
            return null;
        }
        List<User> users = [select Id, Name, Title FROM User WHERE (UserType LIKE 'Standard%' OR UserType LIKE 'Partner%') ORDER BY name ASC];
        return users;
    }

    @RemoteAction
    global static boolean changeOwner(String leadId, String ownerId) {
        if(!(Schema.sobjectType.Lead.fields.OwnerId.isAccessible() && Schema.sobjectType.Lead.fields.Name.isAccessible())){
            return false;
        }
        if (!(Schema.sobjectType.Lead.fields.OwnerId.isUpdateable())){
            return false;
            }
        Lead temp = [select id, Name, OwnerId from Lead where id = :leadId];
        temp.OwnerId = ownerId;
        update (temp);
        return true;
    }
    */
}