public class UpdateProductImageCont {
    //Added By Siva on 29th Nov 2018 to provide update image button in this section
    @AuraEnabled
    public static void updateImageUrl(Id recordId) {
        list<Id> mlist = new list<Id>();
        mlist.add(recordId);

        PP_ProductImageFetcher.UpdateProductImageBatchNew(mlist);
    }

}