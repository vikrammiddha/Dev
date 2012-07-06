public class ProductSelectionController {
    
    public String qliId {get;set;}
    public List<QuoteLineItem> qliList {get;set;}
    public List<OpportunityLineItem> oliList {get;set;}
    public Product2 prod {get;set;} 
    public String objType;
    public String objName {get;set;}
    public Opportunity oppObj {get;set;}
    public Quote quoteObj {get;set;}
    public Id inputId;
    public List<ProductWrapper> wrapList {get;set;}
    public List<ProductWrapper> pageProducts {get;set;}
    public Integer pageNumber {get;set;}
    public Integer pageSize {get;set;} 
    public Integer totalPageNumber {get;set;}
    public String firstString {get;set;}
    public String lastString {get;set;}
    public List<QuoteLineItemWrapper> qliWrapper {get;set;}
    public List<OpportunityLineItemWrapper> oliWrapper {get;set;}
    public List<OpportunityLineItem> toBeDeletedOLI = new List<OpportunityLineItem>();
    public List<OpportunityLineItem> toBeInsertedOLI = new List<OpportunityLineItem>();
    public List<OpportunityLineItem> toBeUpdatedOLI = new List<OpportunityLineItem>();
    public List<QuoteLineItem> toBeDeletedQLI = new List<QuoteLineItem>();
    public List<QuoteLineItem> toBeInsertedQLI = new List<QuoteLineItem>();
    public List<QuoteLineItem> toBeUpdatedQLI = new List<QuoteLineItem>();
    public Decimal grandTotal {get;set;}
    
    public ProductSelectionController(){ 
        
    }
    
    public PageReference execute(){
        grandTotal = 0;
        prod = new Product2();
        inputId = ApexPages.currentPage().getParameters().get('Id');
        oliWrapper = new List<OpportunityLineItemWrapper>();
        qliWrapper = new List<QuoteLineItemWrapper>();
        if(inputId != null){
            if(String.valueOf(inputId).startsWith('006')){
                objType = 'Opportunity';
                oliList = [Select q.UnitPrice, q.TotalPrice, q.Opportunity.Name, q.OpportunityId, q.Quantity, q.ListPrice, q.Id, q.Discount,  q.PricebookEntry.Product2.ProductCode ,
                            q.Description,q.PricebookEntry.Product2.UOM__c,q.PricebookEntry.Product2.Description,q.PricebookEntry.UnitPrice From OpportunityLineItem q where OpportunityId =: inputId];
                System.debug('====oliList==='+oliList);         
                if(oliList.size()>0){
                    for(OpportunityLineItem oli : oliList){
                        OpportunityLineItemWrapper wrapObj = new OpportunityLineItemWrapper();
                        wrapObj.newId = String.valueOf(oli.Id);
                        wrapObj.description = oli.PricebookEntry.Product2.Description;
                        wrapObj.productCode = oli.PricebookEntry.Product2.ProductCode;
                        wrapObj.listPrice = oli.PricebookEntry.UnitPrice;
                        wrapObj.li = oli;
                        wrapObj.totalPrice = oli.TotalPrice;
                        oliWrapper.add(wrapObj);
                    }
                }
                oppObj = [select Id,Name,PriceBook2Id from Opportunity where Id = :inputId ];
            }else{
                objType = 'Quote';
                qliList = [Select q.UnitPrice, q.TotalPrice, q.Quote.Name, q.QuoteId, q.Quantity, q.ListPrice, q.Id, q.Discount,  q.PricebookEntry.Product2.ProductCode ,
                            q.Description,q.PricebookEntry.Product2.UOM__c,q.PricebookEntry.Product2.Description,q.PricebookEntry.UnitPrice From QuoteLineItem q where QuoteId =: inputId];
                if(qliList.size()>0){
                    for(QuoteLineItem qli : qliList){
                        QuoteLineItemWrapper wrapObj = new QuoteLineItemWrapper();
                        wrapObj.newId = String.valueOf(qli.Id);
                        wrapObj.description = qli.PricebookEntry.Product2.Description;
                        wrapObj.productCode = qli.PricebookEntry.Product2.ProductCode;
                        wrapObj.listPrice = qli.PricebookEntry.UnitPrice;
                        wrapObj.totalPrice = qli.TotalPrice;
                        wrapObj.li = qli;
                        qliWrapper.add(wrapObj);
                    }
                }           
                quoteObj = [select Id,Name,PriceBook2Id from Quote where Id = :inputId ];           
            }
            
        }   
        wrapList = new List<ProductWrapper>();
        pageNumber = 0;
        pageSize = 25;
        totalPageNumber = 0;
        firstString = '<<First';
        lastString = 'Last>>';
        return null;
    }
    
    public Integer getWrapListSize(){
        if(objType == 'Opportunity'){
            return oliWrapper.size();
        }else{
            return qliWrapper.size();
        }   
    }
    
    public String getObjectName(){
        if(objType == 'Opportunity'){
            return oppObj.Name;
        }
        else
            return quoteObj.Name;
    }
    
    public  PageReference saveAndReturn(){
        performSave();
        PageReference pg = new PageReference('/'+inputId);
        return pg;
    }
    
    public  PageReference quickSave(){
        performSave();
        execute();
        return null;
    }
    
    private void performSave(){
        if(ObjType == 'Opportunity'){
            
            Map<String,OpportunityLineItem> dupCheckOLIMap = new Map<String,OpportunityLineItem>();
            Map<String,OpportunityLineItem> dupCheckOLIInsertMap = new Map<String,OpportunityLineItem>();
            
            
            for(OpportunityLineItemWrapper o : oliWrapper){
                if(o.li.Id != null){
                    if(dupCheckOLIMap.get(o.ProductCode + String.valueOf(o.li.UnitPrice)) == null){
                        dupCheckOLIMap.put(o.ProductCode + String.valueOf(o.li.UnitPrice),o.li);
                    }else{
                        OpportunityLineItem tempOLI = dupCheckOLIMap.get(o.ProductCode + String.valueOf(o.li.UnitPrice));
                        tempOLI.Quantity += o.li.Quantity;
                        dupCheckOLIMap.put(o.ProductCode + String.valueOf(o.li.UnitPrice),tempOLI);
                        toBeDeletedOLI.add(o.li);
                    }
                    //toBeUpdatedOLI.addAll(dupCheckOLIMap.keySet());
                }
                else{
                    if(dupCheckOLIInsertMap.get(o.ProductCode + String.valueOf(o.li.UnitPrice)) == null){
                        dupCheckOLIInsertMap.put(o.ProductCode + String.valueOf(o.li.UnitPrice),o.li);
                    }else{
                        OpportunityLineItem tempOLI = dupCheckOLIInsertMap.get(o.ProductCode + String.valueOf(o.li.UnitPrice));
                        tempOLI.Quantity += o.li.Quantity;
                        dupCheckOLIInsertMap.put(o.ProductCode + String.valueOf(o.li.UnitPrice),tempOLI);
                    }
                    //toBeInsertedOLI.addAll(dupCheckOLIMap.keySet());
                }
            }
            for(String key : dupCheckOLIMap.keySet()){
                if(dupCheckOLIInsertMap.get(key) != null){
                    OpportunityLineItem tempOLI = dupCheckOLIMap.get(key);
                    tempOLI.Quantity += dupCheckOLIInsertMap.get(key).Quantity;
                    dupCheckOLIInsertMap.remove(key);
                }
            }
            
            toBeUpdatedOLI.addAll(dupCheckOLIMap.values());
            toBeInsertedOLI.addAll(dupCheckOLIInsertMap.values());
            
            if(toBeUpdatedOLI.size()>0)
                update toBeUpdatedOLI;
            if(toBeInsertedOLI.size() >0)
                insert  toBeInsertedOLI;
            if(toBeDeletedOLI.size() >0){
                delete toBeDeletedOLI;
            }   
            toBeDeletedOLI.clear();
            toBeUpdatedOLI.clear();
            toBeInsertedOLI.clear();
        }else{
            Map<String,QuoteLineItem> dupCheckQLIMap = new Map<String,QuoteLineItem>();
            Map<String,QuoteLineItem> dupCheckQLIInsertMap = new Map<String,QuoteLineItem>();
            
            
            for(QuoteLineItemWrapper q : qliWrapper){
                if(q.li.Id != null){
                    if(dupCheckQLIMap.get(q.ProductCode + String.valueOf(q.li.UnitPrice)) == null){
                        dupCheckQLIMap.put(q.ProductCode + String.valueOf(q.li.UnitPrice),q.li);
                    }else{
                        QuoteLineItem tempQLI = dupCheckQLIMap.get(q.ProductCode + String.valueOf(q.li.UnitPrice));
                        tempQLI.Quantity += q.li.Quantity;
                        dupCheckQLIMap.put(q.ProductCode + String.valueOf(q.li.UnitPrice),tempQLI);
                        toBeDeletedQLI.add(q.li);
                    }
                    //toBeUpdatedOLI.addAll(dupCheckOLIMap.keySet());
                }
                else{
                    if(dupCheckQLIInsertMap.get(q.ProductCode + String.valueOf(q.li.UnitPrice)) == null){
                        dupCheckQLIInsertMap.put(q.ProductCode + String.valueOf(q.li.UnitPrice),q.li);
                    }else{
                        QuoteLineItem tempQLI = dupCheckQLIInsertMap.get(q.ProductCode + String.valueOf(q.li.UnitPrice));
                        tempQLI.Quantity += q.li.Quantity;
                        dupCheckQLIInsertMap.put(q.ProductCode + String.valueOf(q.li.UnitPrice),tempQLI);
                    }
                    //toBeInsertedOLI.addAll(dupCheckOLIMap.keySet());
                }
            }
            for(String key : dupCheckQLIMap.keySet()){
                if(dupCheckQLIInsertMap.get(key) != null){
                    QuoteLineItem tempQLI = dupCheckQLIMap.get(key);
                    tempQLI.Quantity += dupCheckQLIInsertMap.get(key).Quantity;
                    dupCheckQLIInsertMap.remove(key);
                }
            }
            
            toBeUpdatedQLI.addAll(dupCheckQLIMap.values());
            toBeInsertedQLI.addAll(dupCheckQLIInsertMap.values());
            
            if(toBeUpdatedQLI.size()>0)
                update toBeUpdatedQLI;
            if(toBeInsertedQLI.size() >0)
                insert  toBeInsertedQLI;
            if(toBeDeletedQLI.size() >0){
                delete toBeDeletedQLI;
            }   
            toBeDeletedQLI.clear();
            toBeUpdatedQLI.clear();
            toBeInsertedQLI.clear();
        }
        
    }
    
    public  PageReference cancel(){
        PageReference pg = new PageReference('/' + ApexPages.currentPage().getParameters().get('Id'));
        return pg;
    } 
    
    public class OpportunityLineItemWrapper{
        public String newId {get;set;}
        public String productCode {get;set;}
        public String description {get;set;}
        public Double listPrice {get;set;}
        public Double totalPrice {get;set;}
        public OpportunityLineItem li {get;set;}
        
    }
    
    public class QuoteLineItemWrapper{
        public String newId {get;set;}
        public String productCode {get;set;}
        public String description {get;set;}
        public Double listPrice {get;set;}
        public Double totalPrice {get;set;}
        public QuoteLineItem li {get;set;}
    }
    
    public PageReference deleteQLI(){
        if(qliId != null){
            if(objType == 'Opportunity'){
                List<OpportunityLineItemWrapper> tempList = new List<OpportunityLineItemWrapper>();
                grandTotal = 0;
                for(OpportunityLineItemWrapper o : oliWrapper){
                    if(qliId != o.newId){
                        tempList.add(o);
                        grandTotal += o.totalPrice;
                    }
                }
                oliWrapper.clear();
                oliWrapper.addAll(tempList);
                if(!qliId.startsWith('new')){
                    OpportunityLineItem oDelete = new OpportunityLineItem(Id = (Id)qliId);
                    toBeDeletedOLI.add(oDelete);
                }   
            }
            else{
                List<QuoteLineItemWrapper> tempList = new List<QuoteLineItemWrapper>();
                grandTotal = 0;
                for(QuoteLineItemWrapper q : qliWrapper){
                    if(qliId != q.newId){
                        tempList.add(q);
                        grandTotal += q.totalPrice;
                    }
                }
                qliWrapper.clear();
                qliWrapper.addAll(tempList);
                if(!qliId.startsWith('new')){
                    QuoteLineItem oDelete = new QuoteLineItem(Id = (Id)qliId);
                    toBeDeletedQLI.add(oDelete);
                }
            }
            
        }
        
        return null;
    } 
    
    public PageReference searchProducts(){
        if((prod.ProductCode == null || prod.ProductCode.length() == 0) && (prod.Product_Group__c == null || prod.Product_Group__c.length() == 0)
                && (prod.Product_Type__c == null || prod.Product_Type__c.length() == 0)){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Please enter at least 1 search criteria . '));  
            return null;
        }
        List<PricebookEntry> pbeList = new List<PricebookEntry>();      
        String query = '';
        String searchCriteria = ''; 
        wrapList = new List<ProductWrapper>();
            
        if(prod.ProductCode != null){
            searchCriteria = '(PricebookEntry.Product2.Name like \'' + prod.ProductCode + '%\' OR PricebookEntry.Product2.ProductCode like \'' + prod.ProductCode + '%\')';
        }
        if(prod.Product_Group__c != null){
            searchCriteria += ' and PricebookEntry.Product2.Product_Group__c = \'' + prod.Product_Group__c + '\'';
        }
        if(prod.Product_Type__c != null){
            searchCriteria += ' and PricebookEntry.Product2.Product_Type__c = \'' + prod.Product_Type__c + '\'';
        }
        
        if(searchCriteria.startsWith(' and')){
            searchCriteria = searchCriteria.subString(4,searchCriteria.length());
        }
        
        if(searchCriteria.length() >0){
            String pbId = '';
            if(objType == 'Opportunity'){
                pbID = oppObj.Pricebook2Id;
            }
            else
                pbId = quoteObj.Pricebook2Id;
                
            query += 'SELECT Id,Product2.ProductCode,Product2.Description,Product2.Vol_Disc__c,Product2.UOM__c,Product2.Family,UnitPrice from PricebookEntry ';
            query += 'where '+ searchCriteria + ' and Pricebook2Id=\'' + pbID + '\'  order by Product2.ProductCode';
            System.debug('===query==='+query);
            pbeList = Database.query(query);
            System.debug('===pbeList==='+pbeList.size());
        }
        
        if(pbeList.size() >0){
            for(PricebookEntry pbe : pbeList){
                ProductWrapper obj = new ProductWrapper();
                obj.pbe = pbe;
                obj.isChecked = false;
                wrapList.add(obj);
            }
            BindData(1);
            totalPageNumber = wrapList.size() / pageSize;
            Integer mod = wrapList.size() - (totalPageNumber * pageSize);
            if (mod > 0)
                totalPageNumber++;
        }   
        prod.ProductCode = null;
        prod.Product_Group__c = null;
        prod.Product_Type__c = null;
        System.debug('===wrapList==='+wrapList);
        return null;
    }
    
    public class ProductWrapper{
        public PricebookEntry pbe {get;set;}
        public Boolean isChecked {get;set;}
    }
    
    public PageReference showAll(){
        
        Id pbId = null;
        if(objType == 'Opportunity'){
            pbID = oppObj.Pricebook2Id;
        }
        else
            pbId = quoteObj.Pricebook2Id;
                
        List<PricebookEntry> pbeList = new List<PricebookEntry>();
        pbeList=[SELECT Id,Product2.ProductCode,Product2.Description,Product2.Vol_Disc__c,Product2.UOM__c,Product2.Family,UnitPrice from PricebookEntry where Pricebook2Id =:pbId Order by Product2.ProductCode];   
        wrapList = new List<ProductWrapper>();
        if(pbeList.size() >0){
            for(PricebookEntry pbe : pbeList){
                ProductWrapper obj = new ProductWrapper();
                obj.pbe = pbe;
                obj.isChecked = false;
                wrapList.add(obj);
            }
            BindData(1);
            totalPageNumber = wrapList.size() / pageSize;
            Integer mod = wrapList.size() - (totalPageNumber * pageSize);
            if (mod > 0)
                totalPageNumber++;
        }       
        System.debug('====totalPageNumber==='+totalPageNumber);
        return null;
    }
    
    public PageReference addSelected(){
        if(objType == 'Opportunity'){
            for(ProductWrapper pw: pageProducts){
                if(pw.isChecked){
                    pw.isChecked = false;
                    OpportunityLineItem oli = new OpportunityLineItem();
                    oli.PricebookEntryId = pw.pbe.Id;
                    oli.OpportunityId = oppObj.Id;
                    oli.UnitPrice = pw.pbe.UnitPrice;
                    oli.Quantity = 1;
                    oliList.add(oli);
                    OpportunityLineItemWrapper wrapObj = new OpportunityLineItemWrapper();
                    wrapObj.li = oli;
                    wrapObj.description = pw.pbe.Product2.Description;
                    wrapObj.productCode = pw.pbe.Product2.ProductCode;
                    wrapObj.totalPrice = pw.pbe.UnitPrice;
                    wrapObj.newId = 'newId'+ pw.pbe.Product2.ProductCode;
                    oliWrapper.add(wrapObj);
                    grandTotal += pw.pbe.UnitPrice;
                    System.debug('====oliWrapper size==='+oliWrapper.size());
                }
            }
        }else{
            for(ProductWrapper pw: pageProducts){
                if(pw.isChecked){
                    pw.isChecked = false;
                    QuoteLineItem qli = new QuoteLineItem();
                    qli.PricebookEntryId = pw.pbe.Id;
                    qli.QuoteId = quoteObj.Id;
                    qli.UnitPrice = pw.pbe.UnitPrice;
                    qli.Quantity = 1;
                    QuoteLineItemWrapper wrapObj = new QuoteLineItemWrapper();
                    wrapObj.li = qli;
                    wrapObj.description = pw.pbe.Product2.Description;
                    wrapObj.productCode = pw.pbe.Product2.ProductCode;
                    wrapObj.totalPrice = pw.pbe.UnitPrice;
                    wrapObj.newId = 'newId'+ pw.pbe.Product2.ProductCode;
                    qliWrapper.add(wrapObj);
                    grandTotal += pw.pbe.UnitPrice;
                }
            }
        }
        return null;
    }
    
    public PageReference reset(){
        pageProducts.clear();
        return null;
    }
    
    public PageReference firstBtnClick(){
        BindData(1);
        return null;        
    }
        
    public PageReference lastBtnClick(){
        BindData(totalPageNumber);
        return null;        
    }
    
    /*Decides if Previous button for paginations should be enabled or not.*/
    public Boolean getPreviousButtonEnabled()
    {
        return (pageNumber > 1);
    }
    
    /*Decides if Next button for paginations should be enabled or not.*/
    public Boolean getNextButtonEnabled()
    {
        if (wrapList == null) return false;
        else
            return ((pageNumber * pageSize) <= wrapList.size());
    }
    
    public Boolean getFirstButtonEnabled()
    {
        return (pageNumber > 1);
    }
    
    public Boolean getLastButtonEnabled()
    {
        if (wrapList == null) return false;
        else
            return ((pageNumber * pageSize) <= wrapList.size());
    }
    
    /*helper method for pagination of the asset records.*/
    private void BindData(Integer newPageIndex)
    {
        try
        {
            pageProducts = new List<ProductWrapper>();
            Transient Integer counter = 0;
            Transient Integer min = 0;
            Transient Integer max = 0;
            
            if (newPageIndex > pageNumber && newPageIndex != totalPageNumber)
            {
                min = pageNumber * pageSize;
                max = newPageIndex * pageSize;
            }
            else
            {
                max = newPageIndex * pageSize;
                min = max - pageSize;
            }
            for(ProductWrapper w : wrapList)
            {
                counter++;
                if (counter > min && counter <= max)
                    pageProducts.add(w);
            }
            pageNumber = newPageIndex;
            
        }
        catch(Exception ex)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,ex.getMessage()));
        }
    }
    
    /*Prepares the pagination data on Next button click.*/
    public PageReference nextBtnClick() {
        BindData(pageNumber + 1);
        return null;
    }
    
    /*Prepares the pagination data on Next button click.*/
    public PageReference goToPage() {
        if(pageNumber > totalPageNumber)
            pageNumber=1;
        BindData(pageNumber);
        return null;
    }
    
    public PageReference resetPageSize() {
    totalPageNumber = wrapList.size() / pageSize;
    Integer mod = wrapList.size() - (totalPageNumber * pageSize);
    if (mod > 0)
        totalPageNumber++;  
    BindData(1);
    return null;
    }
    
    /*Prepares the pagination data on Next button click.*/
    public PageReference previousBtnClick() {
        BindData(pageNumber - 1);
        return null;
    }
    
    public List<SelectOption> getPageSizeList() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('25','25'));
        options.add(new SelectOption('50','50'));
        options.add(new SelectOption('75','75'));
        options.add(new SelectOption('100','100'));
        return options;
    }
}