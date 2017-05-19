@istest
public with sharing class triggertestclass {
	
	static testMethod void testpurchaseHistoryTrigger()
    {
    	
    	// trigger name: purchaseHistory on consumer__c
    	//class: purchaseHistoryHandler
    	create1kTickets();
    	/*
    	 1000 tickets for 1000 seats for a single performance is created
    	  with consumer__c=null
    	*/
    	list<consumer__c> consumerList=new list<consumer__c>();
        for(integer i=0;i<200;i++)
        {
         consumerList.add(new consumer__c(First_Name__c='a'+i,
                                          Last_Name__c='b'+i,
                                          Lifetime_Spend__c=0,
                                          Total_Of_Future_Held__c=0,
                                          Total_Of_Future_Purchases__c=0));
        }
        insert consumerList;
        
        list<consumer__c> insertedconsumerList=[select id,first_name__c,
                                                last_name__c,
                                                Lifetime_Spend__c,
                                                Total_Of_Future_Held__c,
                                                Total_Of_Future_Purchases__c
                                                from consumer__c
                                                ];
                                                
        update  insertedconsumerList;
        purchaseHistoryHandler.reset(); 
         consumer__c consumer=[select id,name,
    	                             First_Name__c,
                                     Last_Name__c,
                                     Lifetime_Spend__c,
                                     Total_Of_Future_Held__c,
                                     Total_Of_Future_Purchases__c
    	                      from consumer__c    	                      
    	                      limit 1]; 
    	list<ticket__c> ticketlist=[select id,name,cost__c,status__c,
    	                            consumer__c
    	                            from ticket__c
    	                            limit 200 ];  
    	                            
    	for(ticket__c ticket: ticketlist) 
    	{
    	 ticket.status__c='Purchased';
    	  ticket.consumer__c=consumer.id;
    	}    
    	update ticketList;  
    	purchaseHistoryHandler.reset(); 
    	
    	list<ticket__c> updatedticketlist=[select id,name,cost__c,status__c,
    	                            consumer__c
    	                            from ticket__c
    	                            limit 200 ];  
    	                            
    	for(ticket__c ticket: updatedticketlist) 
    	{
    	 ticket.status__c='Reserved';
    	  ticket.consumer__c=consumer.id;
    	}    
    	update updatedticketlist;  
    	purchaseHistoryHandler.reset();                                                   
        
                                    
        
                                     
                                                
    	
        
    }
	
	
	static testMethod Void testupdateconsumerTrigger()
    {
    	create1kTickets();
    	/*
    	 1000 tickets for 1000 seats for a single performance is created
    	  with consumer__c=null
    	*/
    	list<ticket__c> ticketList=[select id,name,cost__c,status__c,consumer__c from ticket__c limit 200];
    	system.assertEquals(ticketList.size(),200);
    	for(ticket__c ticket:ticketList)
    	{
    	 system.assertEquals(ticket.cost__c,100);
    	}
    	
    	consumer__c consumer=[select id,name,
    	                             First_Name__c,
                                     Last_Name__c,
                                     Lifetime_Spend__c,
                                     Total_Of_Future_Held__c,
                                     Total_Of_Future_Purchases__c
    	                      from consumer__c
    	                      where first_name__c='a'
    	                      and last_name__c='b' 
    	                      limit 1];
    	system.assertNotEquals(consumer,null); 
    	system.assertEquals(consumer.Lifetime_Spend__c,0);
    	system.assertEquals(consumer.Total_Of_Future_Held__c,0);
    	system.assertEquals(consumer.Total_Of_Future_Purchases__c,0);
    	
    	system.assertEquals(ticketConsumerHandler.updateTicketConsumerFired,true);
    	ticketConsumerHandler.reset();
    	
    	decimal totalTicketsCost=0;
    	for(ticket__c ticket:ticketList)
    	{
         totalTicketsCost+=(ticket.cost__c!=null)?ticket.cost__c:0;
    	 ticket.consumer__c=consumer.id;
    	 ticket.status__c='Purchased';
    	} 
    	system.assertEquals(totalTicketsCost,20000.00);
    	update ticketList;
    	
    	/*list<ticket__c> updatedticketList=[select id,name,cost__c,status__c,consumer__c from ticket__c];
    	system.assertEquals(updatedticketList.size(),200);
    	for(ticket__c ticket:updatedticketList)
    	{
    	 system.assertEquals(ticket.cost__c,100);
    	 system.assertEquals(ticket.consumer__c,consumer.id);
    	 system.assertEquals(ticket.status__c,'Purchased');
    	}*/
    	
    	consumer=[select id,name,
    	                             First_Name__c,
                                     Last_Name__c,
                                     Lifetime_Spend__c,
                                     Total_Of_Future_Held__c,
                                     Total_Of_Future_Purchases__c
    	                      from consumer__c
    	                      where id=:consumer.id];
    	
    	system.assertEquals(consumer.Lifetime_Spend__c,totalTicketsCost);
    	system.assertEquals(consumer.Total_Of_Future_Purchases__c,totalTicketsCost);
    	system.assertEquals(consumer.Total_Of_Future_Held__c,0);
    	
    	system.assertEquals(ticketConsumerHandler.updateTicketConsumerFired,true);
    	ticketConsumerHandler.reset();
    	system.assertEquals(purchaseHistoryHandler.pHupdateFired,true);
    	purchaseHistoryHandler.reset();
    	
    	ticketList=[select id,name,cost__c,status__c,consumer__c from ticket__c limit 200];
    	system.assertEquals(ticketList.size(),200);
    	for(ticket__c ticket:ticketList)
    	{
    	 system.assertEquals(ticket.cost__c,100);
    	}
    	
    	totalTicketsCost=0;
    	for(ticket__c ticket:ticketList)
    	{
         totalTicketsCost+=(ticket.cost__c!=null)?ticket.cost__c:0;
    	 ticket.consumer__c=consumer.id;
    	 ticket.status__c='Reserved';
    	} 
    	update ticketList;
    	
    	consumer=[select id,name,
    	                             First_Name__c,
                                     Last_Name__c,
                                     Lifetime_Spend__c,
                                     Total_Of_Future_Held__c,
                                     Total_Of_Future_Purchases__c
    	                      from consumer__c
    	                      where id=:consumer.id];
    	
    	
    	system.assertEquals(consumer.Lifetime_Spend__c,0);
    	system.assertEquals(consumer.Total_Of_Future_Purchases__c,0);
    	system.assertEquals(consumer.Total_Of_Future_Held__c,totalTicketsCost);
    	
    	                            
    	
    }
    
    
    static void create1kTickets()
    {
     consumer__c consumer=new consumer__c(First_Name__c='a',
                                          Last_Name__c='b',
                                          Lifetime_Spend__c=0,
                                          Total_Of_Future_Held__c=0,
                                          Total_Of_Future_Purchases__c=0);
         insert consumer;
         venue__c venue=new venue__c(name='parkwest-IL',Avg_Show_Cost__c=0,Total_Show_Spend__c=0,Show_Approved__c=null);
         insert venue;
         performance__c performance=new  performance__c(name='Mika', venue__c=venue.id,Start_DateTime__c=system.now().addDays(4));
         insert performance;
         
        //insert seats
        list<seat__C> seatlist= new list<seat__C>();
         for(integer i=0;i<1000;i++)
         {
          seatlist.add(new seat__c(name='seat'+i,Row__c=''+i,Seat_Number__c=i,Section__c=null,Venue__c=venue.Id));
         }
        insert seatlist;
        system.assertEquals(seatlist.size(),1000);
         
         list<ticket__c> ticketList=new list<ticket__c>();
         for(seat__c seat:seatlist)
         {
          ticketList.AddAll(getTickets(performance.id,seat.id,100));
         }
                 
         insert ticketList;
    
    }
    static list<ticket__c> getTickets(Id performanceId,Id seatId,integer cost)
    {
     list<ticket__c> ticketlist= new list<ticket__c>();
     ticketlist.add(new ticket__c(Performance__c=performanceId,
                                     seat__c=seatId,
                                     cost__c=cost,
                                     status__c=null  
                                       ));
        
     return ticketlist;
    }

}