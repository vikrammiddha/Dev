public class NewAndExistingController {
public Account account {get; private set;}
public NewAndExistingController() {
Id id = ApexPages.currentPage().getParameters().get('id');
account = (id == null) ? new Account() :
[SELECT name, phone, industry FROM account WHERE id = :id];
}
public PageReference save() {
try {
upsert(account);
} catch(System.DMLException e) {
ApexPages.addMessages(e);
return null;
}
// After Save, navigate to the default view page:
return (new ApexPages.StandardController(account)).view();
}
}