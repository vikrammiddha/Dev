public with sharing class Utility {
	public String getQueryString(String obj){
		SObjectType objToken = Schema.getGlobalDescribe().get(obj);
		DescribeSObjectResult objDef = objToken.getDescribe();
		Map<String, SObjectField> fields = objDef.fields.getMap();
		Set<String> fieldSet = fields.keySet();
		String queryStr='';
		for(String s:fieldSet)
		{
			SObjectField fieldToken = fields.get(s);
			DescribeFieldResult selectedField = fieldToken.getDescribe();
			queryStr = queryStr + selectedField.getName() + ',';
		
		}
		if(queryStr.length() > =1){
			queryStr=queryStr.substring(0, queryStr.length()-1);
		}
		queryStr = 'SELECT '+queryStr+' FROM '+obj;
		return queryStr;
	}
}