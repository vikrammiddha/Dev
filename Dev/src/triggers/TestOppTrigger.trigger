trigger TestOppTrigger on Opportunity (before insert) {

    Set<Id> accSet = new Set<Id>();
    
    for(Opportunity o : Trigger.new){
      accSet.add(o.accountId);      
    }
    
    List<Account> updateAcc = new List<Account>();
    
    for(Id i : accSet){
        Account acc = new Account(id=i);
        updateAcc.add(acc);
    }
    
    update updateAcc;
}