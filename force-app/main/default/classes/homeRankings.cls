public class homeRankings {

    private string currentUser;
    private final List<Quota__c> quota;
    private final Decimal ranking;
    private final Decimal pctQuota;
    private final String effectiveMonth;
    private final String quotaId;
    private String quotaName;
    private final Boolean rookie;
    private final Integer rookiesSize;
    private final Integer rookieRank;
    private Decimal wonOppValue;
    private integer wonOppRank;
    private integer convertedLeadRank;
    private integer totalConvertedLeads;
    private integer convertedLeadCount;
    private Integer wonOppSize;
    private Decimal totalOppValue;
    private Date createStart;
    private Date createEnd;
    private Boolean manager;
    private Boolean VP;
    private Boolean rep;
    private String rank1;
    private String rank2;
    private String rank3;
    private String rank1id;
    private String rank2id;
    private String rank3id;
    private Decimal rank1pct;
    private Decimal rank2pct;
    private Decimal rank3pct;
    private String rank1VP;
    private String rank2VP;
    private String rank3VP;
    private String rank1idVP;
    private String rank2idVP;
    private String rank3idVP;
    private Decimal rank1pctVP;
    private Decimal rank2pctVP;
    private Decimal rank3pctVP;
    private String oppRT;
    private String leadRT;
    private LIST<User> currentBU;
    private LIST<Quota__c> subordinateQuotas;

    public homeRankings () {
        currentUser = UserInfo.getUserId();
        wonOppValue = 0;
        totalConvertedLeads = 0;
        convertedLeadRank = 0;
        convertedLeadCount = 0;
        wonOppRank = 0;
        wonOppSize = 0;
        createStart = Date.valueOf(System.Today().year() + '-01-01');
        createEnd = Date.valueOf(System.Today().year() + '-12-31');
        totalOppValue = 0;
        LIST<Territory_User__c> territoryUser;
        Set<Id> allManagers = new Set<Id>();

        currentBU = [SELECT Business_Unit__c FROM User WHERE Id = :currentUser];

        Set<String> o = new Set<String>();
        Set<String> l = new Set<String>();

        if(currentBU[0].Business_Unit__c == 'Anesthesia/Respiratory'){
            o.add('012E0000000R4Cz');
            l.add('012E0000000R4Cx');
        }else if(currentBU[0].Business_Unit__c == 'Vascular'){
            o.add('012E0000000QHTO');
            o.add('012E0000000PS2q');
            o.add('012E0000000PQUt');
            l.add('012E0000000PRGZ');
        }else if(currentBU[0].Business_Unit__c == 'Surgical') {
            o.add('012E0000000R4kk');
            l.add('012E0000000R4Cy');
        }else if(currentBU[0].Business_Unit__c == 'Interventional') {
            o.add('012E0000000RGuR');
            l.add('012E0000000RGu6');
        }


        UserRole currentRole = [SELECT Name FROM UserRole WHERE Id = :UserInfo.getUserRoleId() LIMIT 1];
        
        if( currentRole.name.contains('RSM') ) {
            territoryUser = [SELECT Id, Territory_Master__c FROM Territory_User__c WHERE User__c = :currentUser AND Regional_Manager__c = TRUE limit 1];
            if(territoryUser.size() > 0){
                manager = true;
            }else{
                manager = false;
            }
            VP = false;
            rep = false;
        }else if (currentRole.name.contains('VP') || currentRole.name.contains('Pres') || currentRole.name.contains('Director')) {
            //for(Territory_User__c territoryUserVP :[SELECT Id, Territory_Master__c FROM Territory_User__c WHERE Regional_Manager__c = TRUE]){
            //    allManagers.add(TerritoryUserVP.Territory_Master__c);
            //}
            manager = false;
            VP = true;
            rep = false;
        } else if (currentRole.name.contains('MSR')){
            territoryUser = [SELECT Id, Territory_Master__c FROM Territory_User__c WHERE User__c = :currentUser AND Regional_Manager__c = FALSE limit 1];
            manager = false;
            VP = false;
            rep = true;
        } else {
            manager = false;
            VP = false;
            rep = false;
        }

        if(manager || VP){
            subordinateQuotas = [SELECT Id, Name, Rank_Current_Month__c, YTD_to_Quota__c, Effective_Month__c FROM Quota__c WHERE Territory_Master__c IN :getRoleSubordinateUsers(currentUser, false) ORDER BY Rank_Current_Month__c ASC];
            if(subordinateQuotas.size() >=1){
                rank1 = subordinateQuotas[0].Name;
                rank1id = subordinateQuotas[0].Id;
                rank1pct = subordinateQuotas[0].YTD_to_Quota__c;
            }else{
                rank1 = null;
            }
            if(subordinateQuotas.size() >=2){
                rank2 = subordinateQuotas[1].Name;
                rank2id = subordinateQuotas[1].Id;
                rank2pct = subordinateQuotas[1].YTD_to_Quota__c;
            }else{
                rank2 = null;
            }
            if(subordinateQuotas.size() >=3){
                rank3 = subordinateQuotas[2].Name;
                rank3id = subordinateQuotas[2].Id;
                rank3pct = subordinateQuotas[2].YTD_to_Quota__c;
            }else{
                rank3 = null;
            }
        }
        if(VP){
            subordinateQuotas = [SELECT Id, Name, Rank_Current_Month__c, YTD_to_Quota__c, Effective_Month__c FROM Quota__c WHERE Territory_Master__c IN :getRoleSubordinateUsers(currentUser, true) ORDER BY Rank_Current_Month__c ASC];
            if(subordinateQuotas.size() >=1){
                rank1VP = subordinateQuotas[0].Name;
                rank1idVP = subordinateQuotas[0].Id;
                rank1pctVP = subordinateQuotas[0].YTD_to_Quota__c;
            }else{
                rank1VP = null;
            }
            if(subordinateQuotas.size() >=2){
                rank2VP = subordinateQuotas[1].Name;
                rank2idVP = subordinateQuotas[1].Id;
                rank2pctVP = subordinateQuotas[1].YTD_to_Quota__c;
            }else{
                rank2VP = null;
            }
            if(subordinateQuotas.size() >=3){
                rank3VP = subordinateQuotas[2].Name;
                rank3idVP = subordinateQuotas[2].Id;
                rank3pctVP = subordinateQuotas[2].YTD_to_Quota__c;
            }else{
                rank3VP = null;
            }
        }
        if(!VP && !manager){
            LIST<Opportunity> wonOpportunities = [SELECT Id, Amount FROM Opportunity WHERE isWon = TRUE AND OwnerId= :currentUser AND CloseDate > :createStart AND CloseDate < :createEnd];
            wonOppSize = wonOpportunities.size();

            AggregateResult[] groupedResults = [SELECT OwnerId, SUM(Amount)total FROM Opportunity WHERE isWon = TRUE AND CloseDate > :createStart AND CloseDate < :createEnd AND RecordTypeId IN :o GROUP BY OwnerId ORDER BY SUM(Amount) DESC];
            Integer c = 1;
            if (groupedResults.size() > 0){
                for (AggregateResult ar : groupedResults)  {
                   if(ar.get('OwnerId') == currentUser){
                       wonOppRank = c;
                       wonOppValue = double.valueof(ar.get('total'));
                   }
                   totalOppValue += double.valueof(ar.get('total'));
                   c++;
                }
            }

            AggregateResult[] groupedResultsLeads = [SELECT OwnerId, COUNT(Id)total FROM Lead WHERE isConverted = TRUE AND ConvertedDate > :createStart AND ConvertedDate < :createEnd AND RecordTypeId IN :l GROUP BY OwnerId ORDER BY Count(Id) DESC];
            Integer b = 1;
            if(groupedResultsLeads.size() > 0){
                for (AggregateResult arL : groupedResultsLeads)  {
                   if(arL.get('OwnerId') == currentUser){
                       convertedLeadRank = b;
                       convertedLeadCount = Integer.valueof(arL.get('total'));
                   }
                   totalConvertedLeads += Integer.valueof(arL.get('total'));
                   b++;
                }
            }
        } //non-manager

        if(territoryUser != null && territoryUser.size() > 0){
            //system.debug(territoryUser[0].Territory_Master__c);
            quota = [SELECT Id, Rank_Current_Month__c, YTD_to_Quota__c, Effective_Month__c, Name FROM Quota__c WHERE Territory_Master__c = :territoryUser[0].Territory_Master__c];
            if(quota.size() > 0){
                if([SELECT Id FROM Quota__c WHERE Rookie__c = TRUE AND Territory_Master__c = :territoryUser[0].Territory_Master__c].size() > 0){
                    LIST<Quota__c> rookies = [SELECT Id, Rank_Current_Month__c, Territory_Master__c FROM Quota__c WHERE Rookie__c = TRUE];
                    rookie = true;
                    rookiesSize = rookies.size();
                    Integer i = 1;
                    for(Quota__c r: rookies){
                        if(r.Territory_Master__c == territoryUser[0].Territory_Master__c){
                            rookieRank = i;
                        }
                        i++;
                    }
                }
            }
        }

        //if(VP){
        //    quota = [SELECT Id, Rank_Current_Month__c, YTD_to_Quota__c, Effective_Month__c, Name FROM Quota__c WHERE Territory_Master__c IN :allManagers ORDER BY Rank_Current_Month__c ASC limit 1];
        //}
        if (VP){
            ranking = 1;
        }else if(!rep && !manager) {
            ranking = 99999;
        }else if(quota.size() > 0){
            ranking = quota[0].Rank_Current_Month__c.round();
            pctQuota = quota[0].YTD_to_Quota__c;
            effectiveMonth = quota[0].Effective_Month__c;
            quotaId = quota[0].Id;
            quotaName = quota[0].Name;
        }else{
            ranking = 99999;
        }
    }

    public Decimal getRanking() {
        return ranking;
    }

    public Decimal getPctQuota() {
        return pctQuota;
    }

    public Decimal getWonOppValue() {
        return wonOppValue;
    }

    public Decimal getTotalOppValue() {
        return totalOppValue;
    }

    public Integer getWonOppSize() {
        return wonOppSize;
    }

    public String getEffectiveMonth() {
        return effectiveMonth;
    }

    public String getQuotaId() {
        return QuotaId;
    }

    public String getQuotaName() {
        return quotaName;
    }

    public Boolean getRookie() {
        return rookie;
    }

    public Integer getRookiesSize() {
        return rookiesSize;
    }

    public Integer getRookieRank() {
        return rookieRank;
    }

    public Integer getWonOppRank() {
        return wonOppRank;
    }

    public Integer getConvertedLeadRank() {
        return convertedLeadRank;
    }

    public Integer getTotalConvertedLeads() {
        return totalConvertedLeads;
    }

    public Integer getConvertedLeadCount() {
        return convertedLeadCount;
    }

    public Boolean getManager() {
        return manager;
    }

    public Boolean getVP() {
        return VP;
    }

    public String getRank1() {
        return rank1;
    }

    public String getRank1id() {
        return rank1id;
    }

    public String getRank2() {
        return rank2;
    }

    public String getRank2id() {
        return rank2id;
    }

    public String getRank3() {
        return rank3;
    }

    public String getRank3id() {
        return rank3id;
    }

    public Decimal getRank1pct() {
        return rank1pct;
    }

    public Decimal getRank2pct() {
        return rank2pct;
    }

    public Decimal getRank3pct() {
        return rank3pct;
    }

    public String getRank1VP() {
        return rank1VP;
    }

    public String getRank1idVP() {
        return rank1idVP;
    }

    public String getRank2VP() {
        return rank2VP;
    }

    public String getRank2idVP() {
        return rank2idVP;
    }

    public String getRank3VP() {
        return rank3VP;
    }

    public String getRank3idVP() {
        return rank3idVP;
    }

    public Decimal getRank1pctVP() {
        return rank1pctVP;
    }

    public Decimal getRank2pctVP() {
        return rank2pctVP;
    }

    public Decimal getRank3pctVP() {
        return rank3pctVP;
    }

    public static Set<ID> getRoleSubordinateUsers(Id userId, Boolean Managers) {

        // get requested user's role
        Id roleId = [select UserRoleId from User where Id = :userId].UserRoleId;
        // get all of the roles underneath the user
        Set<Id> allSubRoleIds = getAllSubRoleIds(new Set<ID>{roleId});
        // get all of the ids for the users in those roles
        Map<Id,User> users = new Map<Id, User>([Select Id, Name From User where UserRoleId IN :allSubRoleIds]);



        Set<Id> allTerritories = getRoleSubordinateTerritories(users.keySet(), Managers);
        // return the ids as a set so you can do what you want with them

        //Map<Id,Territory_User__c> terrUsers = new Map<Id, Territory_User__c>([Select Id, Territory_Master__c From Territory_User__c where User__c IN :allTerritories]);

        //Set<Id>


        //return terrUsers.keySet();
        return allTerritories;

    }

    private static Set<ID> getAllSubRoleIds(Set<ID> roleIds) {

        Set<ID> currentRoleIds = new Set<ID>();

        // get all of the roles underneath the passed roles
        for(UserRole userRole :[select Id from UserRole where ParentRoleId IN :roleIds AND ParentRoleID != null]){
            currentRoleIds.add(userRole.Id);
        }
        // go fetch some more rolls!
        if(currentRoleIds.size() > 0)
          currentRoleIds.addAll(getAllSubRoleIds(currentRoleIds));

        return currentRoleIds;

    }

    public static Set<ID> getRoleSubordinateTerritories(Set<ID> subIds, Boolean Managers){
        Set<ID> currentTerritories = new Set<ID>();

        // get all of the roles underneath the passed roles

        for(Territory_User__c terrUsers :[select Id, Territory_Master__c from Territory_User__c where User__c IN :subIds AND Regional_Manager__c = :Managers]){
            currentTerritories.add(terrUsers.Territory_Master__c);
        }

        // go fetch some more rolls!
        if(currentTerritories.size() > 0)
          currentTerritories.addAll(getRoleSubordinateTerritories(currentTerritories, Managers));

        return currentTerritories;
    }

}