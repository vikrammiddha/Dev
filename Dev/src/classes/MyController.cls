public class MyController {
private final Account account;
public MyController() {
account = [select id, name, site from Account where id =
:ApexPages.currentPage().getParameters().get('id')];
}
public Account getAccount() {
return account;
}
public PageReference save() {
update account;
return null;
}
}