import { LightningElement, api, track, wire } from 'lwc';
import connect2GetOrderHistoryInfoFromSAP from '@salesforce/apex/SAPSoapStubController.connect2GetOrderHistoryInfoFromSAP';
import getAccDetailsById from '@salesforce/apex/SAPSoapStubController.getAccDetailsById';
import AccOrderDetails from 'c/accOrderDetails';
import connect2GetOrderDetailsFromSAP from '@salesforce/apex/SAPSoapStubController.connect2GetOrderDetailsFromSAP';



export default class AccOrderHistory extends LightningElement {

    @api recordId; //The Account Id passed from the page
    @track accountId='';
    @track accountName='';
    @track salesOrg='';
    @track fromDate='';
    @track toDate='';
   
    @track salesOrgOptions;
    @track error;
    @api accCustCode;
    @api isLoaded = false;
    orderReqMap=new Map();
    @track orderHistoryList={};
    @track errorMessage='';
    @track columns=[];
    orderHistoryList={}; //records
   
    pageSizeOptions=[3, 5, 10, 15, 25];
    totalRecords=0;
    @track pageSize=this.pageSizeOptions[0];
    totalPages;
    pageNumber=1;
    @track recordsToDisplay=[];
    @track showDataTable=false;
    @track isLoaded=false;
    @track displayAllOrders=false;

   //Variables to control modal window
   //isModalOpen=false;
   result;
   orderDetMap=new Map();
   selectedOrderId;
   @track orderDetailsList=[];
   itemsSize;
   modalSpinner=false;
   

    //********************************ORDER HISTORY**************************************************//
    //**********************************************************************************************//
    connectedCallback(){
        const today =new Date();
        const thirtyDaysAgo=new Date(today);
        thirtyDaysAgo.setDate(today.getDate()-30);
        // Set fromDate and toDate as ISO formatted strings
        this.fromDate = thirtyDaysAgo.toISOString().slice(0, 10); // Format as "YYYY-MM-DD"
        this.toDate = today.toISOString().slice(0, 10);
        this.accountId=this.recordId;
       
       
    }
    
    //handle displayAllOrders checkbox
    handleCheckboxDisplayAllOrders(event){
        this.displayAllOrders=event.target.checked;
        if(this.displayAllOrders){
            this.fromDate='';
            this.toDate='';
        }
    }
    //user input for FromDate
    handleFromDateChange(event){
        this.fromDate=event.target.value;
    }
    //user input for toDate
    handleToDateChange(event){
        this.toDate=event.target.value;
    }
    //account Name handler
    handleAccName(event) {
        this.accountId = event.detail.value[0];
        console.log('account name from select ', this.accountId);
             
       
    }

       
    @wire(getAccDetailsById,{accId:'$accountId'})
    getAccountDetails({error, data}){
        if(data){
            this.accountName=data.Id;
            console.log('this.accountName from wired', data.Id);
            this.accCustCode=data.SAP_Sold_To__c;
            this.salesOrg=data.Sales_Org__c;
        } else if(error){
            console.error('Error occured while fetching Account details', error);
        }

    }
   
         
   
      //handleButtonClick and fetching order history
    fetchOrderHistory(){ 
     this.showDataTable=true;
     this.isLoaded=true;
     this.orderReqMap.set('accCustCode',this.accCustCode);
     this.orderReqMap.set('salesOrg', this.salesOrg);
     this.orderReqMap.set('fromDate', this.fromDate); 
     this.orderReqMap.set('toDate', this.toDate);  
    
    console.log('orderReqMap ',this.orderReqMap);
   
   
    const orderMapParam={};
    this.orderReqMap.forEach((value, key)=>{
        orderMapParam[key]=value;
    });
   
    const paramJson=JSON.stringify(orderMapParam);
    
    //Calling connect connect2GetOrderHistoryInfoFromSAP from controller
   
        connect2GetOrderHistoryInfoFromSAP({orderReqMap:orderMapParam}
           ).then((result)=>{
            
            this.orderHistoryList=result;
            if(result[0].message==='No data found'){
                this.totalRecords=0;
                } else{
                    this.totalRecords=result.length;
                }   
           // this.pageSize=this.pageSizeOptions[0];
            this.paginationHelper();           
           
            this.errorMessage='';
            console.log('orderHistoryList:', JSON.stringify(this.orderHistoryList));
          
            
                       
        })
        .catch(error=>{
            console.error(' Error while getting order history list : ', error);
            this.errorMessage='An error occured: '+error.message;
            this.showDataTable=false;
           })
           .finally(()=>{
            this.isLoaded=false;

           });
              
        };
        
        get setToTheFirst() {
            return this.pageNumber == 1;
        }
        get setToTheLast() {
            return this.pageNumber == this.totalPages;
        }
    handleRecordsPerPage(event) {
        this.pageSize = event.target.value;
        this.pageNumber=1;
        this.paginationHelper();
    }
    thePrevPage() {
        this.pageNumber = this.pageNumber - 1;
        this.paginationHelper();
    }
    toTheNextPage() {
        this.pageNumber = this.pageNumber + 1;
        this.paginationHelper();
    }
    theFirstPage() {
        this.pageNumber = 1;
        this.paginationHelper();
    }
    theLastPage() {
        this.pageNumber = this.totalPages;
        this.paginationHelper();
    }
    // JS function to handel pagination logic 
    paginationHelper() {
        this.recordsToDisplay = [];
        if(this.totalRecords===0){
            this.pageNumber = 1;
            this.totalPages=1;
             this.columns=[
                {label:'Order ID', fieldName:'message'},
                {label:'Order Number', fieldName:'message'},
                {label:'Order Type', fieldName:'message'},
                {label:'Order Date', fieldName:'message'},
                {label:'Amount', fieldName:'message' },
                {label:'Status',fieldName:'message'},
                {label:'Message', fieldName:'message'},
       
        
        ];
        this.recordsToDisplay.push(this.orderHistoryList[0]);
             
        } else{
            this.columns=[
                {label:'Order ID', fieldName:'bstkd'},
                {label:'Order Number', fieldName:'vbeln', 
                type:'button',
                typeAttributes:{
                    label:{fieldName:'vbeln'},
                    variant:'base',
                    name:'viewDetails',
                title:'View Details'}
                           
           },
      
                {label:'Order Type', fieldName:'auart'},
                {label:'Order Date', fieldName:'audat'},
                {label:'Amount', fieldName:'brtwr' },
                {label:'Status',fieldName:'status'},
                {label:'Message', fieldName:'message'},
                
                ];
        // calculate total pages
        this.totalPages = Math.ceil(this.totalRecords / this.pageSize);
        // set page number 
        if (this.pageNumber <= 1) {
            this.pageNumber = 1;
        } else if (this.pageNumber >= this.totalPages) {
            this.pageNumber = this.totalPages;
        }
        // set records to display on current page 
        for (let i = (this.pageNumber - 1) * this.pageSize; i < this.pageNumber * this.pageSize; i++) {
            if (i === this.totalRecords) {
                break;
            }
            this.recordsToDisplay.push(this.orderHistoryList[i]);
          //  this.showDataTable=false;
        }
    }
}
//********************************END OF ORDER HISTORY**************************************************//
//**************************************************************************************************//


//*********************************ORDER DETAILS***************************************************//
//************************************************************************************************//
 //handling row
 async handleRowAction(event){ 
    const action=event.detail.action;
    const row=event.detail.row;
    if(action.name==='viewDetails'){
        this.modalSpinner=true;
        this.selectedOrderId=row.vbeln;
        console.log('printing order number  => '+this.selectedOrderId);
        console.log('printing accCustCode  => '+this.accCustCode); 
        
       try{ 
           await this.fetchOrderDetails();
        //console.log('Printing orderDetails Lst '+JSON.stringify(this.orderDetailsList));
       } catch(error){
        console.error('Error fetching order details: ', error);
       } finally{
        this.modalSpinner=false;
       }
         this.handleShowModal();
        
    }
}
//handling Modal window
async handleShowModal(){
 this.result=await AccOrderDetails.open({
    size:'medium',
    header:'Order Details',
    //orderDetailsData:this.orderDetailsList,
    selectedOrderId:this.selectedOrderId,
    itemsSize:this.itemsSize,
    
});
 // if modal closed with X button, promise returns result = 'undefined'
 // if modal closed with OK button, promise returns result = 'okay'
console.log('printing result  => '+this.result);

}


fetchOrderDetails(){
    return new Promise((resolve, reject)=>{
    this.orderDetMap.set('orderNum', this.selectedOrderId);
    this.orderDetMap.set('accCustCode', this.accCustCode);
   

    let orderDetParam={};
    this.orderDetMap.forEach((value, key)=>{
        orderDetParam[key]=value;
    });
       
       console.log('Printing order det map '+JSON.stringify(orderDetParam));

        //wiring apex method connect2GetOrderDetailsFromSAP from the Controller
        connect2GetOrderDetailsFromSAP({orderReqMap:orderDetParam}
            ).then((result)=>{
                this.orderDetailsList=result;
                console.log('Printing orderDetailsLst '+JSON.stringify(this.orderDetailsList));
                this.itemsSize =this.orderDetailsList[0].items.length;
                console.log('Printing itemsSize '+this.itemsSize);
                //this.orderDetailsList[0].items.forEach(item =>{
              //      console.log('Printing items '+JSON.stringify(item));
             //   });
                resolve(result);

            })
            .catch(error=>{
                console.error('an error while getting order details list: '+error);
                reject(error);
               
            });

});

}
    
}