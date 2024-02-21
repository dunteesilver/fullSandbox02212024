import connect2GetOrderDetailsFromSAP from "@salesforce/apex/SAPSoapStubController.connect2GetOrderDetailsFromSAP";
import { api, track} from 'lwc';
import LightningModal from 'lightning/modal';


export default class AccOrderDetails extends LightningModal {
    @api header;
    @api selectedOrderId;
    @api itemsSize;
    @track shippingButtonClicked =false;
    @track shippingInfo;
    @api isModalOpen;
   
    @api orderDetailsData;
   
   
      

handleOkay() {
        this.close('okay');
    }
    
    closeModal() {
        this.dispatchEvent(new CustomEvent('close'));
    }

    shippingDetailsView(){
        this.shippingButtonClicked=!this.shippingButtonClicked;
        this.shippingInfo='Shipping data is displayed';
       

    }
 
}