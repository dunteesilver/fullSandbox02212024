import { api, LightningElement, track, wire } from 'lwc';
import initMethod from '@salesforce/apex/SalesController.initMethod';



export default class AccSalesSummaryByBU extends LightningElement {
    prevYear;
    currYear;
    @api recordId;
    @track error;
   
    salesObj;
    @track buListUpdated =[];
          
    @track finalSales=[];
    
    @wire(initMethod,{acctId:'$recordId'})
      wiredInitMethod({ data, error }) {
            if(data){
              this.salesObj=data;
              var today = new Date();
        this.prevYear =today.getFullYear()-1;
        this.currYear = today.getFullYear(); 
        var buTop=this.salesObj.bu;
        var sMapRes = this.salesObj.salesMap;
        this.buListUpdated=this.salesObj.buListFinal;
        console.log('data succesfully loaded '+JSON.stringify(data));
        console.log('***this.buListUpdated***'+JSON.stringify(this.buListUpdated));

        console.log('**printing map with sales**'+JSON.stringify(sMapRes));

        let buList=this.buListUpdated;
        for(var bu in buList){
          let keyId='';
          let buVal ='';
          let currVal=0;
          let preVal=0;

          for( var key in sMapRes){
             if(key.substring(4)===buList[bu]){
              buVal=key.substring(4);
              keyId=key;
             if(key.indexOf(this.prevYear)>=0){
              preVal=sMapRes[keyId];
            }
          else if(key.indexOf(this.currYear)>=0){
            currVal =sMapRes[keyId];
          }
        }
      }
      
      this.finalSales.push(
        {id :keyId, 
        bu:buVal, 
        curVal:currVal, 
        prevVal:preVal, 
        ...(buVal===buTop) ?{isBold:true}:{isBold:false}
        } );
      }
         console.log('*****LWC table***** '+JSON.stringify(this.finalSales));
        
       } else if (error){
          this.error=error;
          console.log("An error occurred "+error);
      
   }
                
       
      }
     
     }