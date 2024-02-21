/*********************************************************************
* Description      : Class to query VPS Demo Unit Agreement. (repRequest VF)
* Test Class       :
* Author(s)        : Dunte'e Silver
**********************************************************************/
public class documentInfo {

    public static Document document1 {get;set;}
    public static Document document2 {get;set;}

    public documentInfo(ApexPages.StandardController controller){
        document1 = [Select Id From Document Where Name = 'VPS Request Demo Unit Page 1'];
        document2 = [Select Id From Document Where Name = 'VPS Request Demo Unit Page 2'];
    }
}