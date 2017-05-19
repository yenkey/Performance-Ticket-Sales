public class performanceLookupController
{
    public string SearchPerformance{get;set;}
    public list<performance__c> performanceList{get;set;}
    datetime dtime=system.now();
    public string statusString{get;set;}
    
    public performanceLookupController()        
    {
      SearchPerformance=apexpages.currentpage().getParameters().get('vfinput');
    }
    
    public void lookupforshow()
    {
     string queryStirng='select id,name,venue__c,start_datetime__c from performance__c'+
                        ' where start_datetime__c >=:dtime ';
        if(SearchPerformance!=null)
        {
            string lookupstr=SearchPerformance+'%';
            queryStirng+=' And name like:lookupstr';
        }
        try{
         performanceList=database.query(queryStirng);
         if(performanceList.size()==0)
            statusString='No Records Found To Display';
        }
        catch(QueryException Ex)
        {
         apexpages.addMessage(new apexpages.Message(Apexpages.severity.error,'Error with the query'));
        }
    }
}