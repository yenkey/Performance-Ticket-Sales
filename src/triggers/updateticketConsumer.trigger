trigger updateticketConsumer on Ticket__c (after insert,after update) {
    
    set<Id> TicketconsumerIds= new set<Id>();
       
    if(!ticketConsumerHandler.getupdateTicketConsumerFired())
    {
      ticketConsumerHandler.setupdateTicketConsumerFired();
     
      
      TicketconsumerIds.addALL(ticketConsumerHandler.getConsumersforupdate(trigger.new));
      if(trigger.isUpdate)
      TicketconsumerIds.addALL(ticketConsumerHandler.getConsumersforupdate(trigger.old));
      
      if(TicketconsumerIds.size()>0)
      update [select id,name from consumer__c where Id IN:TicketconsumerIds];
    }
    
    

}