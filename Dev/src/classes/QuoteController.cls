public with sharing class QuoteController extends TestController{
    public Quote_new__c quoteObj;
    public List<Pricebook2> priceBook = new List<Pricebook2>();
    List<SelectOption> pbOptions = new List<SelectOption>();
    List<Quote_Line_Item_New__c> qlr = new List<Quote_Line_Item_New__c>();
    Quote_Line_Item_New__c qlrTest = new Quote_Line_Item_New__c();
    public Opportunity opp ;
    public QuoteController (ApexPages.StandardController stdController) {
    	super();
    	system.debug('Entered Debug of Add row method');
		this.quoteObj = (Quote_new__c)stdController.getRecord();
		
    }
    
      
    
	public Opportunity getOpportunity() {
		Id id = null;
		id = ApexPages.currentPage().getParameters().get('id');
		if (id != null){
			opp = [SELECT o.name FROM Opportunity o WHERE id IN (select opportunity__C from quote_new__c where id= :id)];
		} 
		else{
			id = ApexPages.currentPage().getParameters().get('CF00N900000018N9j_lkid');
			opp = [SELECT o.name FROM Opportunity o WHERE id = :id];
		}
		
		
		return opp;
	}
	
	public List<SelectOption> getPriceBooks(){
		priceBook = [Select p.Id,p.Name From Pricebook2 p where p.IsActive=true];
		if (priceBook.Size() >0)
  		{
    	 	for(Pricebook2 p: priceBook)
     		{
				if (p.Name != null)
         		pbOptions.add(new SelectOption(p.Id,p.Name));
     		}
  		 }
		return pbOptions;
	}
	
	public Quote_Line_Item_New__c getQLR(){
		
		try{
			qlrTest = [select name from Quote_Line_Item_New__c];
		}
		catch(Exception e){
			return null;
		}
		
		//qlr.add(new Quote_Line_Item_New__c());
		//qlr.add(new Quote_Line_Item_New__c());
		//qlr.add(new Quote_Line_Item_New__c());
		//qlr.add(new Quote_Line_Item_New__c());
		//qlr.add(new Quote_Line_Item_New__c());
		
		return qlrTest;
	}
	
	public PageReference save() {
	try {
		upsert(quoteObj);
	} catch(System.DMLException e) {
	ApexPages.addMessages(e);
	return null;
	}
	// After Save, navigate to the default view page:
	return (new ApexPages.StandardController(opp)).view();
}
}