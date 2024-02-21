import getTop10 from '@salesforce/apex/SalesController.getTop10';
import { LightningElement, api, track, wire } from 'lwc';

export default class AccAllTeleflexTop10 extends LightningElement {

   @api recordId; 
   salesObj;
   salesObjTop;
   @track matMapArray = [];
   @track thisYear;
   @track lastYear;

   @wire(getTop10,{ acctId:'$recordId'})
   wiredGetTop10Method({ data, error }) {
    if(data){
    
    this.salesObjTop=data;
    var today = new Date();
    this.thisYear= today.getFullYear();
    this.lastYear=today.getFullYear() - 1;
    console.log('*** Starting getResponse All Teleflex Top 10 *** ' );
        var today = new Date();
        var prevYear = today.getFullYear() - 1;
        var currYear = today.getFullYear();
        console.log('*** today *** ' + today );
        console.log('*** prevYear *** ' + prevYear );
        console.log('*** currYear *** ' + currYear );
        var sMapRes = this.salesObjTop.salesMapTop;
                var matMap = this.salesObjTop.prodMap;
                console.log('*** sMapRes *** ' + JSON.stringify(sMapRes) );
                console.log('*** matMap *** ' + JSON.stringify(matMap) );
                          
                
                var key;
                var subPrev;
                var subCurr;
               
                console.log('****sorted mat map*****')
                for(let mat in matMap){
                    let keyId='';
                    let material='';
                    let desc='';
                    let cursale=0;
                    let prevsale=0;
                for(key in sMapRes){
                    subPrev = key.substring(0,4);
                    subCurr = key.substring(0,3);
                    var subPrevProd = subPrev.slice(0,-8);
                    var subCurrProd = subCurr.slice(0,-8);
                                 
                    if(key.indexOf(mat)>=0){
                        material=mat;
                        keyId=key;
                        desc=matMap[mat];
                    if(subPrev == "PYTD"){
                    	console.log('*** subPrev *** ' + subPrev );
                        subPrev = key.substring(9);
                        prevsale=sMapRes[key];
                        console.log('*** subPrevProd *** ' + subPrevProd );
                    	                     
                    }
                    else if(subCurr == "YTD"){
                        console.log('*** subCurr *** ' + subCurr );
                        subCurr = key.substring(8);
                   
                        cursale=sMapRes[key];
                       
                      }
                              }              } 
                              this.matMapArray.push({
                                id:keyId,
                                material:material,
                                desc:desc,
                                cursale:cursale,
                                prevsale:prevsale

                              });
                                }
                                this.matMapArray.sort((a,b)=>b.cursale-a.cursale);
                                
                console.log('***Printing Product*** '+JSON.stringify(this.matMapArray));
                                          
                console.log('*** Ending getResponse All Teleflex Top 10 *** ' );
                
               
            }else if (error){
                this.error=error;
                console.log("An error occurred "+error);
            
         }

        } 


    }