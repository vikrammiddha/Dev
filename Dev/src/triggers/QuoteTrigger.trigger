trigger QuoteTrigger on Quote_new__c (after insert, after update) {
	Quote_new__c quote = Trigger.new[0];
	Id id = quote.Id;
	Boolean isPrimaryQuote = quote.Primary_Quote__c;
	if(isPrimaryQuote == true){
		List<Quote_new__c> qnc = new List<Quote_new__c>();
		for(Quote_new__c qc : [Select q.Primary_Quote__c From Quote_new__c q where id != : id])
		{
			qc.Primary_Quote__c=false;
			qnc.add(qc);
		}	
		update(qnc);
	}
}