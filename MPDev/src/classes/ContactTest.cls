public class ContactTest 
{
            public boolean hasError {get;set;}
            public String errorMessage {get;set;} 
            
            public ContactTest(){
                 system.debug('====constructor===');
                 //hasError = true;
            }
            
            
    
            public String getCompanyCalendarMap() 
            {
                system.debug('====getCompanyCalendarMap===');
                //hasError = true;
                errorMessage = 'Contact not found';
                return 'AAAAAAAAAAAA';
            }
}