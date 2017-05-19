public with sharing class ticketConsumerHandler {
	
	public static boolean updateTicketConsumerFired=false;
	public static boolean getupdateTicketConsumerFired()
	{
	 return updateTicketConsumerFired;
	}
	public static void setupdateTicketConsumerFired()
	{
	  updateTicketConsumerFired=true;
	}
	public static void reset()
	{
	  updateTicketConsumerFired=false;
	}
    
    public static set<Id> getConsumersforupdate(list<ticket__c> ticketList)
	{
     set<Id> Ids_consumers=new set<Id>();
     for(ticket__c ticket:ticketList)
     {
       if(ticket.consumer__c!=null)
       Ids_consumers.add(ticket.consumer__c);
     }
	
	 return Ids_consumers;
	}

}