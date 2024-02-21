import getTop10Bu from '@salesforce/apex/SalesController.getTop10Bu';
import { LightningElement, api, wire, track } from 'lwc';

export default class AccAllTeleflexTopBU extends LightningElement {
    @api recordId;
    @track finalTopBu=[];
    salesObj;
     salesObjTopBu;
    @track bu;
    @track thisYear;
    @track lastYear;

   @wire(getTop10Bu,{ acctId:'$recordId'})
   wiredInitMethod({ data, error }) {
   
     if (data) {
        console.log('*** Starting getResponse All Teleflex Top 10 BU *** ' );
        this.salesObj=data;
        this.salesObjTopBu=data;
        this.thisYear=this.salesObj.thisYear;
        this.lastYear=this.salesObj.lastYear;
        this.bu=this.salesObjTopBu.bu+' Top 10';
        console.log('*** salesObjTopBuData *** ' + JSON.stringify(data));
        console.log('*** this.salesObjTopBu.bu *** ' + JSON.stringify(this.salesObjTopBu.bu));
                
                var sMapRes = this.salesObj.salesMapTop;
                console.log('*** salesMapTop *** ' + JSON.stringify(sMapRes));
                var matMap = this.salesObj.prodMap;
                console.log('*** salesObj.prodMap *** ' + JSON.stringify(matMap));

                                            
                var key;
                var subPrev;
                var subCurr;
                
                for(let mat in matMap){
                    let keyId='';
                    let material='';
                    let desc='';
                    let cursale=0;
                    let prevsale=0;
                for(key in sMapRes){
                    subPrev = key.substring(0,4);
                    subCurr = key.substring(0,3);
                    console.log('*** key *** ' + key );

                    if(key.indexOf(mat)>=0){
                        material=mat;
                        keyId=key;
                        desc=matMap[mat];
                    if(subPrev == "PYTD"){
                    	console.log('*** subPrev *** ' + subPrev );
                        subPrev = key.substring(9);
                        var subPrevProd = subPrev.slice(0,-8);
                        console.log('*** subPrevProd *** ' + subPrevProd );
                    	prevsale= sMapRes[key];
                        console.log('***prevsale *** ' + JSON.stringify(prevsale) );
                       
                    }
                    else if(subCurr == "YTD"){
                        console.log('*** subCurr *** ' + subCurr );
                        subCurr = key.substring(8);
                        var subCurrProd = subCurr.slice(0,-8);
                        console.log('*** subCurrProd *** ' + subCurrProd );
                    	cursale= sMapRes[key];
                        console.log('***cursale *** ' + JSON.stringify(cursale));
                   }
                }
            } this.finalTopBu.push({
                id:keyId,
                material:material,
                desc:desc,
                prevsale:prevsale,
                cursale:cursale
            });
                        
                } this.finalTopBu.sort((a,b)=>b.cursale-a.cursale);
                console.log('***finalTopBu**** '+JSON.stringify(this.finalTopBu));
                
                
                   
                 console.log('*** Ending getResponse All Teleflex Top 10 *** ' );

                
            }else if (error){
                this.error=error;
                console.log("An error occurred "+error);
            
         }

        } 

}