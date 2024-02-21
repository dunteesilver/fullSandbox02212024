import { LightningElement, api } from 'lwc';


export default class CustomHyperlinkDataType extends LightningElement {
    @api value;

   handleClick(){

    this.dispatchEvent(new CustomEvent('customcellclick', {
        detail:this.value
    }));
   }
}