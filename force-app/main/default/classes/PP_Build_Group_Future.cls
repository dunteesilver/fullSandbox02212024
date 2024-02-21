public class PP_Build_Group_Future {
    
    public static void Update_Group_Membership(List<Id> newIds){
        system.debug('Welcome to the future! PP_Build_Group_Future.Update_Group_Membership');

        list<GroupMember> addUser = new list<GroupMember>();
        list<GroupMember> removeUser = new list<GroupMember>();

        map<String, Id> gMap = new map<String, Id>();
        for(Group g : [SELECT Name, Id FROM GROUP
                       WHERE Name = 'Pricing Portal'
                       OR Name like '%Division%'
                       OR Name like 'Pricing Tier%'])
        {
            gMap.put(g.Name, g.Id);
            system.debug('g.name:' + g.name + ' g.Id ' + g.id);
        }

        for(Contract_User__c cu : [SELECT User__r.id, Pricing_Portal_Access__c, Pricing_Tier_Access__c, Name,
                                   Division_10__c, Division_20__c, Division_30__c, Division_40__c, Division_50__c, Division_60__c,
                                   CA_Division_10__c, CA_Division_20__c, CA_Division_30__c, CA_Division_40__c, CA_Division_50__c, CA_Division_60__c,
                                   MX_Division_10__c, MX_Division_20__c, MX_Division_30__c, MX_Division_40__c, MX_Division_50__c, MX_Division_60__c,
                                   LA_Division_10__c, LA_Division_20__c, LA_Division_30__c, LA_Division_40__c, LA_Division_50__c, LA_Division_60__c,
                                   CL_Division_10__c, CL_Division_20__c, CL_Division_30__c, CL_Division_40__c, CL_Division_50__c, CL_Division_60__c,
                                   CO_Division_10__c, CO_Division_20__c, CO_Division_30__c, CO_Division_40__c, CO_Division_50__c, CO_Division_60__c,
                                   AU_Division_10__c, AU_Division_20__c, AU_Division_30__c, AU_Division_40__c, AU_Division_50__c, AU_Division_60__c,
                                   NZ_Division_10__c, NZ_Division_20__c, NZ_Division_30__c, NZ_Division_40__c, NZ_Division_50__c, NZ_Division_60__c
                                   FROM Contract_User__c
                                   Where Id IN :newIds])
        {

            //system.debug('List of Groups:' + ' 10: ' + cu.Division_10__c + ' 20: ' + cu.Division_20__c + ' 30: ' + cu.Division_30__c + ' 40: ' + cu.Division_40__c + ' 50: ' + cu.Division_50__c + ' 60: ' + cu.Division_60__c);
            //system.debug('List of Maps:' + ' 10: ' + gMap.get('Division 10') + ' 20: ' + gMap.get('Division 20') + ' 30: ' + gMap.get('Division 30') + ' 40: ' + gMap.get('Division 40') + ' 50: ' + gMap.get('Division 50') + ' 60: ' + gMap.get('Division 60'));
            System.debug('*** cu PP_Build_Group_Futrue class *** ' + cu);
            String uId = cu.User__r.id;
            system.debug('uId: ' + uId);

            system.debug('Contract User Record: ' + cu);
            if(cu.Pricing_Tier_Access__c >= 1){
                GroupMember addGroupMember = new GroupMember(GroupId = gMap.get('Pricing Tier 1 - Rep'), UserOrGroupId = uId);
                addUser.add(addGroupMember);
            }
            else {
                GroupMember removeGroupMember = new GroupMember(GroupId = gMap.get('Pricing Tier 1 - Rep'), UserOrGroupId = uId);
                removeUser.add(removeGroupMember);
            }
            if(cu.Pricing_Tier_Access__c >= 2){
                GroupMember addGroupMember = new GroupMember(GroupId = gMap.get('Pricing Tier 2 - Manager'), UserOrGroupId = uId);
                addUser.add(addGroupMember);
            }
            else {
                GroupMember removeGroupMember = new GroupMember(GroupId = gMap.get('Pricing Tier 2 - Manager'), UserOrGroupId = uId);
                removeUser.add(removeGroupMember);
            }
            if(cu.Pricing_Tier_Access__c >= 3){
                GroupMember addGroupMember = new GroupMember(GroupId = gMap.get('Pricing Tier 3 - Director'), UserOrGroupId = uId);
                addUser.add(addGroupMember);
            }
            else {
                GroupMember removeGroupMember = new GroupMember(GroupId = gMap.get('Pricing Tier 3 - Director'), UserOrGroupId = uId);
                removeUser.add(removeGroupMember);
            }
            if(cu.Pricing_Tier_Access__c >= 4){
                GroupMember addGroupMember = new GroupMember(GroupId = gMap.get('Pricing Tier 4 - VP'), UserOrGroupId = uId);
                addUser.add(addGroupMember);
            }
            else {
                GroupMember removeGroupMember = new GroupMember(GroupId = gMap.get('Pricing Tier 4 - VP'), UserOrGroupId = uId);
                removeUser.add(removeGroupMember);
            }

            // US Division 10
            if(cu.Division_10__c){
                GroupMember addGroupMember = new GroupMember(GroupId = gMap.get('US Division 10'), UserOrGroupId = uId);
                addUser.add(addGroupMember);
            }
            else {
                GroupMember removeGroupMember = new GroupMember(GroupId = gMap.get('US Division 10'), UserOrGroupId = uId);
                removeUser.add(removeGroupMember);
            }
            // US Division 20
            if(cu.Division_20__c){
                GroupMember addGroupMember = new GroupMember(GroupId = gMap.get('US Division 20'), UserOrGroupId = uId);
                addUser.add(addGroupMember);
            }
            else {
                GroupMember removeGroupMember = new GroupMember(GroupId = gMap.get('US Division 20'), UserOrGroupId = uId);
                removeUser.add(removeGroupMember);
            }
            // US Division 30
            if(cu.Division_30__c){
                GroupMember addGroupMember = new GroupMember(GroupId = gMap.get('US Division 30'), UserOrGroupId = uId);
                addUser.add(addGroupMember);
            }
            else {
                GroupMember removeGroupMember = new GroupMember(GroupId = gMap.get('US Division 30'), UserOrGroupId = uId);
                removeUser.add(removeGroupMember);
            }
            // US Division 40
            if(cu.Division_40__c){
                GroupMember addGroupMember = new GroupMember(GroupId = gMap.get('US Division 40'), UserOrGroupId = uId);
                addUser.add(addGroupMember);
            }
            else {
                GroupMember removeGroupMember = new GroupMember(GroupId = gMap.get('US Division 40'), UserOrGroupId = uId);
                removeUser.add(removeGroupMember);
            }
            // US Division 50
            if(cu.Division_50__c){
                GroupMember addGroupMember = new GroupMember(GroupId = gMap.get('US Division 50'), UserOrGroupId = uId);
                addUser.add(addGroupMember);
            }
            else {
                GroupMember removeGroupMember = new GroupMember(GroupId = gMap.get('US Division 50'), UserOrGroupId = uId);
                removeUser.add(removeGroupMember);
            }
            // US Division 60
            if(cu.Division_60__c){
                GroupMember addGroupMember = new GroupMember(GroupId = gMap.get('US Division 60'), UserOrGroupId = uId);
                addUser.add(addGroupMember);
            }
            else {
                GroupMember removeGroupMember = new GroupMember(GroupId = gMap.get('US Division 60'), UserOrGroupId = uId);
                removeUser.add(removeGroupMember);
            }

            // CA Division 10
            if(cu.CA_Division_10__c){
                GroupMember addGroupMember = new GroupMember(GroupId = gMap.get('CA Division 10'), UserOrGroupId = uId);
                addUser.add(addGroupMember);
            }
            else {
                GroupMember removeGroupMember = new GroupMember(GroupId = gMap.get('CA Division 10'), UserOrGroupId = uId);
                removeUser.add(removeGroupMember);
            }
            // CA Division 20
            if(cu.CA_Division_20__c){
                GroupMember addGroupMember = new GroupMember(GroupId = gMap.get('CA Division 20'), UserOrGroupId = uId);
                addUser.add(addGroupMember);
            }
            else {
                GroupMember removeGroupMember = new GroupMember(GroupId = gMap.get('CA Division 20'), UserOrGroupId = uId);
                removeUser.add(removeGroupMember);
            }
            // CA Division 30
            if(cu.CA_Division_30__c){
                GroupMember addGroupMember = new GroupMember(GroupId = gMap.get('CA Division 30'), UserOrGroupId = uId);
                addUser.add(addGroupMember);
            }
            else {
                GroupMember removeGroupMember = new GroupMember(GroupId = gMap.get('CA Division 30'), UserOrGroupId = uId);
                removeUser.add(removeGroupMember);
            }
            // CA Division 40
            if(cu.CA_Division_40__c){
                GroupMember addGroupMember = new GroupMember(GroupId = gMap.get('CA Division 40'), UserOrGroupId = uId);
                addUser.add(addGroupMember);
            }
            else {
                GroupMember removeGroupMember = new GroupMember(GroupId = gMap.get('CA Division 40'), UserOrGroupId = uId);
                removeUser.add(removeGroupMember);
            }
            // CA Division 50
            if(cu.CA_Division_50__c){
                GroupMember addGroupMember = new GroupMember(GroupId = gMap.get('CA Division 50'), UserOrGroupId = uId);
                addUser.add(addGroupMember);
            }
            else {
                GroupMember removeGroupMember = new GroupMember(GroupId = gMap.get('CA Division 50'), UserOrGroupId = uId);
                removeUser.add(removeGroupMember);
            }
            // CA Division 60
            if(cu.CA_Division_60__c){
                GroupMember addGroupMember = new GroupMember(GroupId = gMap.get('CA Division 60'), UserOrGroupId = uId);
                addUser.add(addGroupMember);
            }
            else {
                GroupMember removeGroupMember = new GroupMember(GroupId = gMap.get('CA Division 60'), UserOrGroupId = uId);
                removeUser.add(removeGroupMember);
            }

            // Latin America
            // LA Division 10
            if(cu.LA_Division_10__c){
                GroupMember addGroupMember = new GroupMember(GroupId = gMap.get('LA Division 10'), UserOrGroupId = uId);
                addUser.add(addGroupMember);
            }
            else {
                GroupMember removeGroupMember = new GroupMember(GroupId = gMap.get('LA Division 10'), UserOrGroupId = uId);
                removeUser.add(removeGroupMember);
            }
            // LA Division 20
            if(cu.LA_Division_20__c){
                GroupMember addGroupMember = new GroupMember(GroupId = gMap.get('LA Division 20'), UserOrGroupId = uId);
                addUser.add(addGroupMember);
            }
            else {
                GroupMember removeGroupMember = new GroupMember(GroupId = gMap.get('LA Division 20'), UserOrGroupId = uId);
                removeUser.add(removeGroupMember);
            }
            // LA Division 30
            if(cu.LA_Division_30__c){
                GroupMember addGroupMember = new GroupMember(GroupId = gMap.get('LA Division 30'), UserOrGroupId = uId);
                addUser.add(addGroupMember);
            }
            else {
                GroupMember removeGroupMember = new GroupMember(GroupId = gMap.get('LA Division 30'), UserOrGroupId = uId);
                removeUser.add(removeGroupMember);
            }
            // LA Division 40
            if(cu.LA_Division_40__c){
                GroupMember addGroupMember = new GroupMember(GroupId = gMap.get('LA Division 40'), UserOrGroupId = uId);
                addUser.add(addGroupMember);
            }
            else {
                GroupMember removeGroupMember = new GroupMember(GroupId = gMap.get('LA Division 40'), UserOrGroupId = uId);
                removeUser.add(removeGroupMember);
            }
            // LA Division 50
            if(cu.LA_Division_50__c){
                GroupMember addGroupMember = new GroupMember(GroupId = gMap.get('LA Division 50'), UserOrGroupId = uId);
                addUser.add(addGroupMember);
            }
            else {
                GroupMember removeGroupMember = new GroupMember(GroupId = gMap.get('LA Division 50'), UserOrGroupId = uId);
                removeUser.add(removeGroupMember);
            }
            // LA Division 60
            if(cu.LA_Division_60__c){
                GroupMember addGroupMember = new GroupMember(GroupId = gMap.get('LA Division 60'), UserOrGroupId = uId);
                addUser.add(addGroupMember);
            }
            else {
                GroupMember removeGroupMember = new GroupMember(GroupId = gMap.get('LA Division 60'), UserOrGroupId = uId);
                removeUser.add(removeGroupMember);
            }

            // Mexico
            // MX Division 10
            if(cu.MX_Division_10__c){
                GroupMember addGroupMember = new GroupMember(GroupId = gMap.get('MX Division 10'), UserOrGroupId = uId);
                addUser.add(addGroupMember);
            }
            else {
                GroupMember removeGroupMember = new GroupMember(GroupId = gMap.get('MX Division 10'), UserOrGroupId = uId);
                removeUser.add(removeGroupMember);
            }
            // MX Division 20
            if(cu.MX_Division_20__c){
                GroupMember addGroupMember = new GroupMember(GroupId = gMap.get('MX Division 20'), UserOrGroupId = uId);
                addUser.add(addGroupMember);
            }
            else {
                GroupMember removeGroupMember = new GroupMember(GroupId = gMap.get('MX Division 20'), UserOrGroupId = uId);
                removeUser.add(removeGroupMember);
            }
            // MX Division 30
            if(cu.MX_Division_30__c){
                GroupMember addGroupMember = new GroupMember(GroupId = gMap.get('MX Division 30'), UserOrGroupId = uId);
                addUser.add(addGroupMember);
            }
            else {
                GroupMember removeGroupMember = new GroupMember(GroupId = gMap.get('MX Division 30'), UserOrGroupId = uId);
                removeUser.add(removeGroupMember);
            }
            // MX Division 40
            if(cu.MX_Division_40__c){
                GroupMember addGroupMember = new GroupMember(GroupId = gMap.get('MX Division 40'), UserOrGroupId = uId);
                addUser.add(addGroupMember);
            }
            else {
                GroupMember removeGroupMember = new GroupMember(GroupId = gMap.get('MX Division 40'), UserOrGroupId = uId);
                removeUser.add(removeGroupMember);
            }
            // MX Division 50
            if(cu.MX_Division_50__c){
                GroupMember addGroupMember = new GroupMember(GroupId = gMap.get('MX Division 50'), UserOrGroupId = uId);
                addUser.add(addGroupMember);
            }
            else {
                GroupMember removeGroupMember = new GroupMember(GroupId = gMap.get('MX Division 50'), UserOrGroupId = uId);
                removeUser.add(removeGroupMember);
            }
            // MX Division 60
            if(cu.MX_Division_60__c){
                GroupMember addGroupMember = new GroupMember(GroupId = gMap.get('MX Division 60'), UserOrGroupId = uId);
                addUser.add(addGroupMember);
            }
            else {
                GroupMember removeGroupMember = new GroupMember(GroupId = gMap.get('MX Division 60'), UserOrGroupId = uId);
                removeUser.add(removeGroupMember);
            }

            // Chile
            if(cu.CL_Division_10__c){
                GroupMember addGroupMember = new GroupMember(GroupId = gMap.get('CL Division 10'), UserOrGroupId = uId);
                addUser.add(addGroupMember);
            }
            else {
                GroupMember removeGroupMember = new GroupMember(GroupId = gMap.get('CL Division 10'), UserOrGroupId = uId);
                removeUser.add(removeGroupMember);
            }
            // CL Division 20
            if(cu.CL_Division_20__c){
                GroupMember addGroupMember = new GroupMember(GroupId = gMap.get('CL Division 20'), UserOrGroupId = uId);
                addUser.add(addGroupMember);
            }
            else {
                GroupMember removeGroupMember = new GroupMember(GroupId = gMap.get('CL Division 20'), UserOrGroupId = uId);
                removeUser.add(removeGroupMember);
            }
            // CL Division 30
            if(cu.CL_Division_30__c){
                GroupMember addGroupMember = new GroupMember(GroupId = gMap.get('CL Division 30'), UserOrGroupId = uId);
                addUser.add(addGroupMember);
            }
            else {
                GroupMember removeGroupMember = new GroupMember(GroupId = gMap.get('CL Division 30'), UserOrGroupId = uId);
                removeUser.add(removeGroupMember);
            }
            // CL Division 40
            if(cu.CL_Division_40__c){
                GroupMember addGroupMember = new GroupMember(GroupId = gMap.get('CL Division 40'), UserOrGroupId = uId);
                addUser.add(addGroupMember);
            }
            else {
                GroupMember removeGroupMember = new GroupMember(GroupId = gMap.get('CL Division 40'), UserOrGroupId = uId);
                removeUser.add(removeGroupMember);
            }
            // CL Division 50
            if(cu.CL_Division_50__c){
                GroupMember addGroupMember = new GroupMember(GroupId = gMap.get('CL Division 50'), UserOrGroupId = uId);
                addUser.add(addGroupMember);
            }
            else {
                GroupMember removeGroupMember = new GroupMember(GroupId = gMap.get('CL Division 50'), UserOrGroupId = uId);
                removeUser.add(removeGroupMember);
            }
            // CL Division 60
            if(cu.CL_Division_60__c){
                GroupMember addGroupMember = new GroupMember(GroupId = gMap.get('CL Division 60'), UserOrGroupId = uId);
                addUser.add(addGroupMember);
            }
            else {
                GroupMember removeGroupMember = new GroupMember(GroupId = gMap.get('CL Division 60'), UserOrGroupId = uId);
                removeUser.add(removeGroupMember);
            }

            // Columbia
            if(cu.CO_Division_10__c){
                GroupMember addGroupMember = new GroupMember(GroupId = gMap.get('CO Division 10'), UserOrGroupId = uId);
                addUser.add(addGroupMember);
            }
            else {
                GroupMember removeGroupMember = new GroupMember(GroupId = gMap.get('CO Division 10'), UserOrGroupId = uId);
                removeUser.add(removeGroupMember);
            }
            // CO Division 20
            if(cu.CO_Division_20__c){
                GroupMember addGroupMember = new GroupMember(GroupId = gMap.get('CO Division 20'), UserOrGroupId = uId);
                addUser.add(addGroupMember);
            }
            else {
                GroupMember removeGroupMember = new GroupMember(GroupId = gMap.get('CO Division 20'), UserOrGroupId = uId);
                removeUser.add(removeGroupMember);
            }
            // CO Division 30
            if(cu.CO_Division_30__c){
                GroupMember addGroupMember = new GroupMember(GroupId = gMap.get('CO Division 30'), UserOrGroupId = uId);
                addUser.add(addGroupMember);
            }
            else {
                GroupMember removeGroupMember = new GroupMember(GroupId = gMap.get('CO Division 30'), UserOrGroupId = uId);
                removeUser.add(removeGroupMember);
            }
            // CO Division 40
            if(cu.CO_Division_40__c){
                GroupMember addGroupMember = new GroupMember(GroupId = gMap.get('CO Division 40'), UserOrGroupId = uId);
                addUser.add(addGroupMember);
            }
            else {
                GroupMember removeGroupMember = new GroupMember(GroupId = gMap.get('CO Division 40'), UserOrGroupId = uId);
                removeUser.add(removeGroupMember);
            }
            // CO Division 50
            if(cu.CO_Division_50__c){
                GroupMember addGroupMember = new GroupMember(GroupId = gMap.get('CO Division 50'), UserOrGroupId = uId);
                addUser.add(addGroupMember);
            }
            else {
                GroupMember removeGroupMember = new GroupMember(GroupId = gMap.get('CO Division 50'), UserOrGroupId = uId);
                removeUser.add(removeGroupMember);
            }
            // CO Division 60
            if(cu.CO_Division_60__c){
                GroupMember addGroupMember = new GroupMember(GroupId = gMap.get('CO Division 60'), UserOrGroupId = uId);
                addUser.add(addGroupMember);
            }
            else {
                GroupMember removeGroupMember = new GroupMember(GroupId = gMap.get('CO Division 60'), UserOrGroupId = uId);
                removeUser.add(removeGroupMember);
            }

            //Australia
            if(cu.AU_Division_10__c){
                GroupMember addGroupMember = new GroupMember(GroupId = gMap.get('AU Division 10'), UserOrGroupId = uId);
                addUser.add(addGroupMember);
            }
            else {
                GroupMember removeGroupMember = new GroupMember(GroupId = gMap.get('AU Division 10'), UserOrGroupId = uId);
                removeUser.add(removeGroupMember);
            }
            // AU Division 20
            if(cu.AU_Division_20__c){
                GroupMember addGroupMember = new GroupMember(GroupId = gMap.get('AU Division 20'), UserOrGroupId = uId);
                addUser.add(addGroupMember);
            }
            else {
                GroupMember removeGroupMember = new GroupMember(GroupId = gMap.get('AU Division 20'), UserOrGroupId = uId);
                removeUser.add(removeGroupMember);
            }
            // AU Division 30
            if(cu.AU_Division_30__c){
                GroupMember addGroupMember = new GroupMember(GroupId = gMap.get('AU Division 30'), UserOrGroupId = uId);
                addUser.add(addGroupMember);
            }
            else {
                GroupMember removeGroupMember = new GroupMember(GroupId = gMap.get('AU Division 30'), UserOrGroupId = uId);
                removeUser.add(removeGroupMember);
            }
            // AU Division 40
            if(cu.AU_Division_40__c){
                GroupMember addGroupMember = new GroupMember(GroupId = gMap.get('AU Division 40'), UserOrGroupId = uId);
                addUser.add(addGroupMember);
            }
            else {
                GroupMember removeGroupMember = new GroupMember(GroupId = gMap.get('AU Division 40'), UserOrGroupId = uId);
                removeUser.add(removeGroupMember);
            }
            // AU Division 50
            if(cu.AU_Division_50__c){
                GroupMember addGroupMember = new GroupMember(GroupId = gMap.get('AU Division 50'), UserOrGroupId = uId);
                addUser.add(addGroupMember);
            }
            else {
                GroupMember removeGroupMember = new GroupMember(GroupId = gMap.get('AU Division 50'), UserOrGroupId = uId);
                removeUser.add(removeGroupMember);
            }
            // AU Division 60
            if(cu.AU_Division_60__c){
                GroupMember addGroupMember = new GroupMember(GroupId = gMap.get('AU Division 60'), UserOrGroupId = uId);
                addUser.add(addGroupMember);
            }
            else {
                GroupMember removeGroupMember = new GroupMember(GroupId = gMap.get('AU Division 60'), UserOrGroupId = uId);
                removeUser.add(removeGroupMember);
            }

            //New Zealand
            if(cu.NZ_Division_10__c){
                GroupMember addGroupMember = new GroupMember(GroupId = gMap.get('NZ Division 10'), UserOrGroupId = uId);
                addUser.add(addGroupMember);
            }
            else {
                GroupMember removeGroupMember = new GroupMember(GroupId = gMap.get('NZ Division 10'), UserOrGroupId = uId);
                removeUser.add(removeGroupMember);
            }
            // NZ Division 20
            if(cu.NZ_Division_20__c){
                GroupMember addGroupMember = new GroupMember(GroupId = gMap.get('NZ Division 20'), UserOrGroupId = uId);
                addUser.add(addGroupMember);
            }
            else {
                GroupMember removeGroupMember = new GroupMember(GroupId = gMap.get('NZ Division 20'), UserOrGroupId = uId);
                removeUser.add(removeGroupMember);
            }
            // NZ Division 30
            if(cu.NZ_Division_30__c){
                GroupMember addGroupMember = new GroupMember(GroupId = gMap.get('NZ Division 30'), UserOrGroupId = uId);
                addUser.add(addGroupMember);
            }
            else {
                GroupMember removeGroupMember = new GroupMember(GroupId = gMap.get('NZ Division 30'), UserOrGroupId = uId);
                removeUser.add(removeGroupMember);
            }
            // NZ Division 40
            if(cu.NZ_Division_40__c){
                GroupMember addGroupMember = new GroupMember(GroupId = gMap.get('NZ Division 40'), UserOrGroupId = uId);
                addUser.add(addGroupMember);
            }
            else {
                GroupMember removeGroupMember = new GroupMember(GroupId = gMap.get('NZ Division 40'), UserOrGroupId = uId);
                removeUser.add(removeGroupMember);
            }
            // NZ Division 50
            if(cu.NZ_Division_50__c){
                GroupMember addGroupMember = new GroupMember(GroupId = gMap.get('NZ Division 50'), UserOrGroupId = uId);
                addUser.add(addGroupMember);
            }
            else {
                GroupMember removeGroupMember = new GroupMember(GroupId = gMap.get('NZ Division 50'), UserOrGroupId = uId);
                removeUser.add(removeGroupMember);
            }
            // NZ Division 60
            if(cu.NZ_Division_60__c){
                GroupMember addGroupMember = new GroupMember(GroupId = gMap.get('NZ Division 60'), UserOrGroupId = uId);
                addUser.add(addGroupMember);
            }
            else {
                GroupMember removeGroupMember = new GroupMember(GroupId = gMap.get('NZ Division 60'), UserOrGroupId = uId);
                removeUser.add(removeGroupMember);
            }

            // Pricing Portal
            if(cu.Pricing_Portal_Access__c){
                GroupMember addGroupMember = new GroupMember(GroupId = gMap.get('Pricing Portal'), UserOrGroupId = uId);
                addUser.add(addGroupMember);
            }
            else {
                GroupMember removeGroupMember = new GroupMember(GroupId = gMap.get('Pricing Portal'), UserOrGroupId = uId);
                removeUser.add(removeGroupMember);
            }
            
            system.debug('addUser: ' + addUser);
            system.debug('removeUser: ' + removeUser);

        }

        set<Id> filterUser = new set<Id>();
        for(GroupMember gmset : removeUser){
            filterUser.add(gmset.USERORGROUPID);
        }
        list<GroupMember> deleteGroupMember = new list<GroupMember>();

        for(GroupMember gmout : [SELECT GroupId, USERORGROUPID FROM GroupMember WHERE USERORGROUPID IN :filterUser]){
            for(GroupMember gmin : removeUser){
                if(gmout.GroupId == gmin.GroupId && gmout.USERORGROUPID == gmin.USERORGROUPID){
                    GroupMember removeGroupMember = new GroupMember(
                        Id = gmout.id
                    );
                    system.debug('Immmmmm Here!!!!!!!!!');
                    deleteGroupMember.add(removeGroupMember);
                    system.debug('deleteGroupMember =============================== ' + deleteGroupMember);
                }
            }
        }

        if(addUser.size() > 0){
            insert addUser;
        }
        if(deleteGroupMember.size() > 0){
            delete deleteGroupMember;
        }
    }

    @future
    public static void Update_Group_Membership_Future(List<Id> newIds){
        Update_Group_Membership(newIds);
    }
}