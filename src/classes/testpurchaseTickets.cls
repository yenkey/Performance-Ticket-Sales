@istest
public class testpurchaseTickets{
     
     static testMethod void testdefault()
     {
        
         createData();
         profile TicketSalesAgentProfile=[select id,name from profile where
                                         name='*UC-Ticket Sales Agent' limit 1];
                                         
        system.AssertNotEquals(TicketSalesAgentProfile,null);
        user salesAgent= new user(Alias = 'standt', Email='salesAgent@testorg.com', 
                                  EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                  LocaleSidKey='en_US', ProfileId = TicketSalesAgentProfile.id, 
                                  TimeZoneSidKey='America/Chicago', UserName='salesAgent@testorg.com');
         
         system.runAs(salesAgent){
         Test.startTest();
         consumer__c testconsumer=[select id,First_Name__c,last_name__c from consumer__c where First_Name__c='a' and last_name__c='b' limit 1 ];
         system.assertEquals(testconsumer.First_Name__c,'a');
         test.setCurrentPage(page.purchaseTickets);
         apexpages.standardController thecontroller= new apexpages.standardController(testconsumer);
         ticketSearchController TSC=new ticketSearchController(thecontroller);
         TSC.InitiatorAction();
         system.assertEquals(TSC.getPageNumber(),1);
         system.assertEquals(TSC.setCon.getRecords().size(),0);
         system.assertEquals(TSC.setCon.gethasNext(),false);
         system.assertEquals(TSC.setCon.gethasPrevious(),false);
         system.assertEquals(TSC.TotalrecordsReturned,0);
         system.assertEquals(TSC.error,false);
         system.assertEquals(TSC.ErrorString,''); 
         performance__c myperfomrance=[select id,name,start_dateTime__c from performance__c
                                       where start_dateTime__c>:system.now()
                                       limit 1];
        
         TSC.setPerformanceId(myperfomrance.id);
         system.assertEquals(TSC.performanceId,myperfomrance.id);
         TSC.getperformanceId();
         TSC.searchTickets();
         //system.assertEquals(TSC.performanceId,null);
         system.assertEquals(TSC.performanceName,myperfomrance.name);
         system.assertEquals(TSC.error,false);
         system.assertEquals(TSC.ErrorString,''); 
         list<ticket__c> myticketlist=[select id,name from ticket__c
                                       where Performance__r.Start_DateTime__c>:system.now()
                                       and Performance__c=:myperfomrance.id];
         system.assertEquals(TSC.TotalrecordsReturned,myticketlist.size());
         system.assertNotEquals(TSC.ticketWrapperList.size(),0);
         for(ticketSearchController.TicketWrapper tw:TSC.ticketWrapperList)
         {
          system.assertEquals(tw.selected,false);
          system.assertEquals(tw.ticket.consumer__c,null);
          system.assertEquals(tw.ticket.status__c,null);
          system.assert(tw.ticket.performance__r.start_dateTime__c>=system.now());
         }
         for(ticketSearchController.TicketWrapper tw:TSC.ticketWrapperList)
         {
          tw.selected=true;
         }
         TSC.purchaseTickets();
         list<ticket__c> consumerTickets=[select id,name,consumer__c,status__c from ticket__c
                                          where Performance__r.Start_DateTime__c>:system.now()
                                          and status__c='Purchased'
                                          and consumer__c=:testconsumer.id
                                         ];
         system.assertEquals(consumerTickets.size(),TSC.ticketWrapperList.size());
         for(ticketSearchController.TicketWrapper tw:TSC.ticketWrapperList)
         {
          system.assertEquals(tw.selected,false);
          system.assertEquals(tw.ticket.consumer__c,testconsumer.id);
          system.assertEquals(tw.ticket.status__c,'Purchased');
          
         }
        for(ticket__c t:consumerTickets)
         {
          
          system.assertEquals(t.consumer__c,testconsumer.id);
          system.assertEquals(t.status__c,'Purchased');
          
         }
         TSC=new ticketSearchController(thecontroller);
         TSC.InitiatorAction();
         list<ticket__c> defaultTickets=[select id,name,consumer__c,status__c from ticket__c
                                          where Performance__r.Start_DateTime__c>:system.now()
                                          and status__c IN ('Purchased','Reserved')
                                          and consumer__c=:testconsumer.id
                                         ];
         system.assertEquals(consumerTickets.size(),TSC.TotalrecordsReturned);
         
         /*TSC.Next();
         for(ticketSearchController.TicketWrapper tw:TSC.ticketWrapperList)
         {
          system.assertEquals(tw.selected,false);
          system.assertEquals(tw.ticket.consumer__c,null);
          system.assertEquals(tw.ticket.status__c,null);
          system.assert(tw.ticket.performance__r.start_dateTime__c>system.now());
         }
         for(ticketSearchController.TicketWrapper tw:TSC.ticketWrapperList)
         {
          tw.selected=true;
         }
         TSC.reserveTickets();
         
         list<ticket__c> consumerreservedTickets=[select id,name,consumer__c,status__c from ticket__c
                                          where Performance__r.Start_DateTime__c>:system.now()
                                          and status__c='Reserved'
                                          and consumer__c=:testconsumer.id
                                         ];
         system.assertEquals(consumerreservedTickets.size(),TSC.ticketWrapperList.size());
         for(ticketSearchController.TicketWrapper tw:TSC.ticketWrapperList)
         {
          system.assertEquals(tw.selected,true);
          system.assertEquals(tw.ticket.consumer__c,testconsumer.id);
          system.assertEquals(tw.ticket.status__c,'Purchased');
          
         }
         TSC.Last();
         TSC.previous();
         TSC.First();*/
         
         Test.stopTest();
        }
    
    }
    
    static testMethod void TestNavigation()
    {
        //test the navigation buttons
        //Next,last,first,previous
        //verify the selected property
        //verify the returned resultset
        
        consumer__c consumer=getConsumer('a','b');
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
        
         list<ticket__c> mytickets=[select id,name from ticket__c
                                    ];
        //verify if the number of tickets inserted is 1000
         system.assertEquals(ticketList.size(),1000);
        
         /* 
             1000 tickets for 1000 seats are inserted for a single performance
        */
        
        /*
          application is targeted at user with profile UC Ticket Sales Agent
         
        */
        profile TicketSalesAgentProfile=[select id,name from profile where
                                         name='*UC-Ticket Sales Agent' limit 1];
                                         
        system.AssertNotEquals(TicketSalesAgentProfile,null);
        user salesAgent= new user(Alias = 'standt', Email='salesAgent@testorg.com', 
                                  EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                  LocaleSidKey='en_US', ProfileId = TicketSalesAgentProfile.id, 
                                  TimeZoneSidKey='America/Chicago', UserName='salesAgent@testorg.com');
        
        
        system.runAs(salesAgent)
        {
        
        List<Apexpages.Message> msgs = ApexPages.getMessages();
        system.assertEquals(msgs.size(),0);
       
         Test.startTest();
         test.setCurrentPage(page.purchaseTickets);
         apexpages.standardController thecontroller= new apexpages.standardController(consumer);
         ticketSearchController TSC=new ticketSearchController(thecontroller);
         TSC.InitiatorAction();
        
        //Check for the pageMessages/ErrorMessages
         msgs = ApexPages.getMessages();
         system.assertEquals(msgs.size(),0);
        
         performance__c myperfomrance=[select id,name,start_dateTime__c from performance__c
                                       where start_dateTime__c>:system.now()
                                       limit 1];
         system.assertEquals(myperfomrance.id,performance.id);
         TSC.setPerformanceId(myperfomrance.id);
         TSC.SearchTickets();
         
        //Check for the pageMessages/ErrorMessages
         msgs = ApexPages.getMessages();
         system.assertEquals(msgs.size(),0);
        //-------------------------------------------------------------------------------------------------
        
        system.assertEquals(TSC.TotalrecordsReturned,mytickets.size());
        system.assertEquals(TSC.gethasprevious(),false);
        system.assertEquals(TSC.error,false);
        system.assertEquals(TSC.errorstring,'');
        
        //test the result set for the query filters
        /*
            No tickets are purchased yet.
            so every ticket searched for a given performance has consumerid=null
            status=null
            startdate>=system.now();
        */
         for(ticketSearchController.TicketWrapper tw:TSC.ticketWrapperList)
          {
           system.assertEquals(tw.selected,false);
           system.assertEquals(tw.ticket.consumer__c,null);
           system.assertEquals(tw.ticket.status__c,null);
           system.assert(tw.ticket.performance__r.start_dateTime__c>=system.now());
          }
         TSC.Next();
         //Check for the pageMessages/ErrorMessages
         msgs = ApexPages.getMessages();
         system.assertEquals(msgs.size(),0);
        
         system.assertEquals(TSC.Setcon.getRecords().size(),TSC.ticketWrapperList.size());
         system.assertEquals(TSC.gethasNext(),true);
         system.assertEquals(TSC.gethasprevious(),true);
         system.assertEquals(TSC.error,false);
         system.assertEquals(TSC.errorstring,'');
        
        
         for(ticketSearchController.TicketWrapper tw:TSC.ticketWrapperList)
          {
           system.assertEquals(tw.selected,false);
           system.assertEquals(tw.ticket.consumer__c,null);
           system.assertEquals(tw.ticket.status__c,null);
           system.assert(tw.ticket.performance__r.start_dateTime__c>=system.now());
          }
        
         TSC.last();
         //Check for the pageMessages/ErrorMessages
         msgs = ApexPages.getMessages();
         system.assertEquals(msgs.size(),0);
        
         system.assertEquals(TSC.gethasNext(),false);
         system.assertEquals(TSC.gethasprevious(),true);
         system.assertEquals(TSC.error,false);
         system.assertEquals(TSC.errorstring,'');
        
         for(ticketSearchController.TicketWrapper tw:TSC.ticketWrapperList)
          {
           system.assertEquals(tw.selected,false);
           system.assertEquals(tw.ticket.consumer__c,null);
           system.assertEquals(tw.ticket.status__c,null);
           system.assert(tw.ticket.performance__r.start_dateTime__c>=system.now());
          }
        
         Tsc.previous();
         //Check for the pageMessages/ErrorMessages
         msgs = ApexPages.getMessages();
         system.assertEquals(msgs.size(),0);
        
         system.assertEquals(TSC.gethasNext(),true);
         system.assertEquals(TSC.gethasprevious(),true);
         system.assertEquals(TSC.error,false);
         system.assertEquals(TSC.errorstring,'');
         for(ticketSearchController.TicketWrapper tw:TSC.ticketWrapperList)
          {
           system.assertEquals(tw.selected,false);
           system.assertEquals(tw.ticket.consumer__c,null);
           system.assertEquals(tw.ticket.status__c,null);
           system.assert(tw.ticket.performance__r.start_dateTime__c>=system.now());
          }
          TSC.first();
          //Check for the pageMessages/ErrorMessages
          msgs = ApexPages.getMessages();
          system.assertEquals(msgs.size(),0);
        
          system.assertEquals(TSC.gethasNext(),true);
          system.assertEquals(TSC.gethasprevious(),false);
          system.assertEquals(TSC.error,false);
          system.assertEquals(TSC.errorstring,'');
          system.assertEquals(TSC.getPageNumber(),1);
          // test for total pages
          system.assertEquals(TSC.TotalrecordsReturned/decimal.valueOf(TSC.pageSize),TSC.gettotalPages());
          TSC.setselectAll(true);
          TSC.selectAll();
          system.assertEquals(TSC.ticketWrapperList.size(),TSC.pageSize);
          for(ticketSearchController.ticketWrapper tw: TSC.ticketWrapperList)
          {
           system.assert(tw.selected);
          }
          TSC.next();
          system.assertEquals(TSC.ticketWrapperList.size(),TSC.pageSize);
          for(ticketSearchController.ticketWrapper tw: TSC.ticketWrapperList)
          {
           system.assert(!tw.selected);
          }
         //Check for the pageMessages/ErrorMessages
           msgs = ApexPages.getMessages();
           system.assertEquals(msgs.size(),0);
           Test.stopTest();
        }
    
    }
    
    static testMethod void TestErrorMessages()
    {
       /*
          datacreation: Required multiple performances with the same name
          
       */
        createData();
        
        consumer__c consumer=getConsumer('a','b');
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
        
         list<ticket__c> mytickets=[select id,name from ticket__c
                                    ];
        
        //verify if the number of tickets inserted is 1000
         system.assertEquals(ticketList.size(),1000);
        
        list<performance__c> multiplePerformances=new list<performance__c>();
        multiplePerformances.add(new performance__c(name='Mika', venue__c=venue.id,Start_DateTime__c=system.now().addDays(5)));
        multiplePerformances.add(new performance__c(name='Mika', venue__c=venue.id,Start_DateTime__c=system.now().addDays(6)));
        multiplePerformances.add(new performance__c(name='Mika', venue__c=venue.id,Start_DateTime__c=system.now().addDays(7)));
        insert multiplePerformances;
        
        
        
        
        /* Multiple performances now exist
           call the searchtickets method by passing performance name instead of id which should give an error message. verify the error message
           call the searChtickets methods by passing performance name which does not exist. verify the error message.
           
        */
        
        
        List<Apexpages.Message> msgs = ApexPages.getMessages();
        system.assertEquals(msgs.size(),0);
        
        profile TicketSalesAgentProfile=[select id,name from profile where
                                         name='*UC-Ticket Sales Agent' limit 1];
                                         
        system.AssertNotEquals(TicketSalesAgentProfile,null);
        user salesAgent= new user(Alias = 'standt', Email='salesAgent@testorg.com', 
                                  EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                  LocaleSidKey='en_US', ProfileId = TicketSalesAgentProfile.id, 
                                  TimeZoneSidKey='America/Chicago', UserName='salesAgent@testorg.com');
       
       system.runAs(salesAgent){
         Test.startTest();
         test.setCurrentPage(page.purchaseTickets);
         apexpages.standardController thecontroller= new apexpages.standardController(consumer);
         ticketSearchController TSC=new ticketSearchController(thecontroller);
         TSC.InitiatorAction();
        
        //Check for the pageMessages/ErrorMessages
         msgs = ApexPages.getMessages();
         system.assertEquals(msgs.size(),0);
        TSC.performanceName='Mika';
        TSC.searchTickets();
         msgs = ApexPages.getMessages();
        system.assertEquals(TSC.performanceId,null);
         system.assertEquals(msgs.size(),0);
        system.assert(TSC.error);
        system.assertEquals(TSC.errorstring,'Multiple records found. Use lookup to select one');
        
        /*
         verify the errormessage for a non existing performance name
            */
        TSC.performanceName='1';
        TSC.searchTickets();
         msgs = ApexPages.getMessages();
        system.assertEquals(TSC.performanceId,null);
         system.assertEquals(msgs.size(),0);
        system.assert(TSC.error);
        system.assertEquals(TSC.errorstring,'No Records Found.Use lookup to find one'); 
        
        /*
          verify the errormessage if performanceName=null and performanceId=null
         */
        TSC.performanceName=null;
        TSC.searchTickets();
         msgs = ApexPages.getMessages();
        system.assertEquals(TSC.performanceId,null);
         system.assertEquals(msgs.size(),0);
        system.assert(TSC.error);
        system.assertEquals(TSC.errorstring,'Please enter performance name to search for tickets');
        Test.stopTest();
       }    
    
    }
    
    Static testMethod void testUnselectedAction()
    {
    	create1ktickets();
    	profile TicketSalesAgentProfile=[select id,name from profile where
                                         name='*UC-Ticket Sales Agent' limit 1];
                                         
        system.AssertNotEquals(TicketSalesAgentProfile,null);
        user salesAgent= new user(Alias = 'standt', Email='salesAgent@testorg.com', 
                                  EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                  LocaleSidKey='en_US', ProfileId = TicketSalesAgentProfile.id, 
                                  TimeZoneSidKey='America/Chicago', UserName='salesAgent@testorg.com');
                                  
     system.runAs(salesAgent)
      {
    	consumer__c consumer=[select id,name from consumer__c limit 1];
    	
    	Test.startTest();
    	test.setCurrentPage(page.purchaseTickets);
         apexpages.standardController thecontroller= new apexpages.standardController(consumer);
         ticketSearchController TSC=new ticketSearchController(thecontroller);
         TSC.InitiatorAction();
        
        //Check for the pageMessages/ErrorMessages
         List<Apexpages.Message> msgs = ApexPages.getMessages();
         system.assertEquals(msgs.size(),0);
        
         performance__c myperfomrance=[select id,name,start_dateTime__c from performance__c
                                       where start_dateTime__c>:system.now()
                                       limit 1];
         system.assertNotEquals(myperfomrance.id,null);
         TSC.setPerformanceId(myperfomrance.id);
       
        //Check for the pageMessages/ErrorMessagen
        TSC.SearchTickets();
        TSC.purchaseTickets();
         
         /* Test the error message if no records are selected
            and any of the actions purchase,reserve,release and return are done
         */
         boolean a=false;
         msgs = ApexPages.getMessages();
         system.assertEquals(msgs.size(),1);
         for(apexpages.Message msg:msgs)
         {
          if (msg.getDetail().equals('No selected tickets to update'))
              a=true;
         }
         system.assert(a);
         
          TSC.reserveTickets();
          boolean b=false;
         msgs = ApexPages.getMessages();
         system.assertEquals(msgs.size(),1);
         for(apexpages.Message msg:msgs)
         {
          if (msg.getDetail().equals('No selected tickets to update'))
              b=true;
         }
         system.assert(b);
          TSC.releaseTickets();
          boolean c=false;
          msgs = ApexPages.getMessages();
         system.assertEquals(msgs.size(),1);
         for(apexpages.Message msg:msgs)
         {
          if (msg.getDetail().equals('No selected tickets to update'))
              c=true;
         }
         system.assert(c);
          
          TSC.returnTickets();
          boolean d=false;
         msgs = ApexPages.getMessages();
         system.assertEquals(msgs.size(),1);
         for(apexpages.Message msg:msgs)
         {
          if (msg.getDetail().equals('No selected tickets to update'))
              d=true;
         }
         system.assert(d);
         
    	
    	Test.stopTest();
     }
    
    }
    Static testMethod void testpurchaseTickets()
    {
         /*
           verify the status of records after calling purchaseTickets()-'Purchased'
              verfity the confirmation msg after the purchse tickets called

        */
       
         
         create1kTickets();
         
         /*
    	  creates a consumer with firstname a and lastname b
    	  creates a venue with name 'parkwest-IL'
    	  creates a performance with name 'Mika'
    	  creates 1000 seats for venue 'parkwest-IL' for  the future performance 'Mika' 
    	  creates 1000 tickets, one ticket for each seat for future performance 'Mika'
    	
    	*/
         
         
        
         list<ticket__c> mytickets=[select id,name from ticket__c
                                    ];
        //verify if the number of tickets inserted is 1000
         system.assertEquals(mytickets.size(),1000);
        
         /* 
             1000 tickets for 1000 seats are inserted for a single performance
        */
        
        List<Apexpages.Message> msgs = ApexPages.getMessages();
        system.assertEquals(msgs.size(),0);
        
        profile TicketSalesAgentProfile=[select id,name from profile where
                                         name='*UC-Ticket Sales Agent' limit 1];
                                         
        system.AssertNotEquals(TicketSalesAgentProfile,null);
        user salesAgent= new user(Alias = 'standt', Email='salesAgent@testorg.com', 
                                  EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                  LocaleSidKey='en_US', ProfileId = TicketSalesAgentProfile.id, 
                                  TimeZoneSidKey='America/Chicago', UserName='salesAgent@testorg.com');
       
        system.runAs(salesAgent)
        {
         Test.startTest();
         consumer__c consumer=[select id,name from consumer__C 
                               where first_name__c='a'
                               and last_name__c='b' limit 1];
         test.setCurrentPage(page.purchaseTickets);
         apexpages.standardController thecontroller= new apexpages.standardController(consumer);
         ticketSearchController TSC=new ticketSearchController(thecontroller);
         TSC.InitiatorAction();
        
        //Check for the pageMessages/ErrorMessages
         msgs = ApexPages.getMessages();
         system.assertEquals(msgs.size(),0);
        
         performance__c myperfomrance=[select id,name,start_dateTime__c from performance__c
                                       where start_dateTime__c>:system.now()
                                       limit 1];
         system.assertNotEquals(myperfomrance.id,null);
         TSC.setPerformanceId(myperfomrance.id);
       
        //Check for the pageMessages/ErrorMessagen
        TSC.SearchTickets();
         msgs = ApexPages.getMessages();
         system.assertEquals(msgs.size(),0);
         /*
           verify if the number of records per page is returned as expected
         */
         system.assertEquals(TSC.ticketWrapperList.size(),TSC.pagesize);
         TSC.setSelectAll(true);
         TSC.selectAll();
        
         system.assert(TSC.ticketWrapperList.size()>0);
        // verify if all the checkboxes are true;
         for(ticketSearchController.ticketWrapper tw:TSC.ticketWrapperList)
         {
         /*verify if all the returned records are selected*/
          system.assert(tw.selected);
         }
        /*
           verify the message for purchaseTickets
         */
         TSC.purchaseTickets();
         TSC.getConsumer();
         msgs = ApexPages.getMessages();
         system.assertNotEquals(msgs.size(),0);
         boolean b=false;
         for(apexpages.Message msg:msgs)
         {
          if (msg.getDetail().contains('tickets Purchased'))
              b=true;
         }
         system.assert(b);
        pageReference pref=TSC.redirectToCustomer();
        system.assertEquals(pref.getURL(),'/'+TSC.consumer.id);
        
         TSC.previous();
         TSC.setSelectAll(true);
         TSC.selectALL();
         TSC.next();
         TSC.Previous();
        /*
          page 1 of  tickets for future performance 'myperfomrance.name' is returned
        */
        Test.stopTest();
       }
    
    }
    static testMethod void testreserveTickets()
    {
           /*   verify the status of records after calling reserveTickets()-'Reserved'
                verfity the confirmation msg after the reserveTickets() is called 
                
           */
           create1kTickets();
         
         /*
    	  creates a consumer with firstname a and lastname b
    	  creates a venue with name 'parkwest-IL'
    	  creates a performance with name 'Mika'
    	  creates 1000 seats for venue 'parkwest-IL' for  the future performance 'Mika' 
    	  creates 1000 tickets, one ticket for each seat for future performance 'Mika'
    	
    	*/
         
         
        
         list<ticket__c> mytickets=[select id,name from ticket__c
                                    ];
        //verify if the number of tickets inserted is 1000
         system.assertEquals(mytickets.size(),1000);
        
         /* 
             1000 tickets for 1000 seats are inserted for a single performance
        */
        
        List<Apexpages.Message> msgs = ApexPages.getMessages();
        system.assertEquals(msgs.size(),0);
        profile TicketSalesAgentProfile=[select id,name from profile where
                                         name='*UC-Ticket Sales Agent' limit 1];
                                         
        system.AssertNotEquals(TicketSalesAgentProfile,null);
        user salesAgent= new user(Alias = 'standt', Email='salesAgent@testorg.com', 
                                  EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                  LocaleSidKey='en_US', ProfileId = TicketSalesAgentProfile.id, 
                                  TimeZoneSidKey='America/Chicago', UserName='salesAgent@testorg.com');
                                  
        system.runAs(salesAgent){
         Test.startTest();
         consumer__c consumer=[select id,name from consumer__C 
                               where first_name__c='a'
                               and last_name__c='b' limit 1];
         test.setCurrentPage(page.purchaseTickets);
         apexpages.standardController thecontroller= new apexpages.standardController(consumer);
         ticketSearchController TSC=new ticketSearchController(thecontroller);
         TSC.InitiatorAction();
        
        //Check for the pageMessages/ErrorMessages
         msgs = ApexPages.getMessages();
         system.assertEquals(msgs.size(),0);
        
         performance__c myperfomrance=[select id,name,start_dateTime__c from performance__c
                                       where start_dateTime__c>:system.now()
                                       limit 1];
         system.assertNotEquals(myperfomrance.id,null);
         TSC.setPerformanceId(myperfomrance.id);
         
         TSC.SearchTickets();
         msgs = ApexPages.getMessages();
         system.assertEquals(msgs.size(),0);
         /*
           verify if the number of records per page is returned as expected
         */
         system.assertEquals(TSC.ticketWrapperList.size(),TSC.pagesize);
         TSC.setSelectAll(true);
         TSC.selectAll();
        
         system.assert(TSC.ticketWrapperList.size()>0);
        // verify if all the checkboxes are true;
         for(ticketSearchController.ticketWrapper tw:TSC.ticketWrapperList)
         {
         /*verify if all the returned records are selected*/
          system.assert(tw.selected);
         }
         
         
         /*
           verify the message for reserveTickets
         */
        TSC.next();
        TSC.setSelectAll(true);
         TSC.selectAll();
         system.assert(TSC.ticketWrapperList.size()>0);
        // verify if all the checkboxes are true;
         for(ticketSearchController.ticketWrapper tw:TSC.ticketWrapperList)
         {
          system.assert(tw.selected);
         }
         TSC.reserveTickets();
         TSC.getConsumer();
         msgs = ApexPages.getMessages();
         system.assertNotEquals(msgs.size(),0);
         boolean c=false;
         for(apexpages.Message msg:msgs)
         {
          if (msg.getDetail().contains('tickets Reserved'))
              c=true;
         }
         system.assert(c);
    
       }
    }
    
    static testMethod void testreleaseTickets()
    {
       
          /* verfiy the status of records after calling releaseTickets();-nul
              verify the confirmation msg after calling releaseTickets()
           */
           create1kTickets();
         
         /*
    	  creates a consumer with firstname a and lastname b
    	  creates a venue with name 'parkwest-IL'
    	  creates a performance with name 'Mika'
    	  creates 1000 seats for venue 'parkwest-IL' for  the future performance 'Mika' 
    	  creates 1000 tickets, one ticket for each seat for future performance 'Mika'
    	
    	*/
         
         
        
         list<ticket__c> mytickets=[select id,name from ticket__c
                                    ];
        //verify if the number of tickets inserted is 1000
         system.assertEquals(mytickets.size(),1000);
        
         /* 
             1000 tickets for 1000 seats are inserted for a single performance
        */
        
        List<Apexpages.Message> msgs = ApexPages.getMessages();
        system.assertEquals(msgs.size(),0);
        
        profile TicketSalesAgentProfile=[select id,name from profile where
                                         name='*UC-Ticket Sales Agent' limit 1];
                                         
        system.AssertNotEquals(TicketSalesAgentProfile,null);
        user salesAgent= new user(Alias = 'standt', Email='salesAgent@testorg.com', 
                                  EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                  LocaleSidKey='en_US', ProfileId = TicketSalesAgentProfile.id, 
                                  TimeZoneSidKey='America/Chicago', UserName='salesAgent@testorg.com');
       system.runAs(salesAgent){
         Test.startTest();
         consumer__c consumer=[select id,name from consumer__C 
                               where first_name__c='a'
                               and last_name__c='b' limit 1];
         test.setCurrentPage(page.purchaseTickets);
         apexpages.standardController thecontroller= new apexpages.standardController(consumer);
         ticketSearchController TSC=new ticketSearchController(thecontroller);
         TSC.InitiatorAction();
        
        //Check for the pageMessages/ErrorMessages
         msgs = ApexPages.getMessages();
         system.assertEquals(msgs.size(),0);
        
         performance__c myperfomrance=[select id,name,start_dateTime__c from performance__c
                                       where start_dateTime__c>:system.now()
                                       limit 1];
         system.assertNotEquals(myperfomrance.id,null);
         TSC.setPerformanceId(myperfomrance.id);
         
         TSC.SearchTickets();
         msgs = ApexPages.getMessages();
         system.assertEquals(msgs.size(),0);
         /*
           verify if the number of records per page is returned as expected
         */
         system.assertEquals(TSC.ticketWrapperList.size(),TSC.pagesize);
         TSC.setSelectAll(true);
         TSC.selectAll();
        
         system.assert(TSC.ticketWrapperList.size()>0);
        // verify if all the checkboxes are true;
         for(ticketSearchController.ticketWrapper tw:TSC.ticketWrapperList)
         {
         /*verify if all the returned records are selected*/
          system.assert(tw.selected);
         }
         
         TSC.next();
         
        TSC.setSelectAll(true);
         TSC.selectAll();
         system.assert(TSC.ticketWrapperList.size()>0);
        // verify if all the checkboxes are true;
         for(ticketSearchController.ticketWrapper tw:TSC.ticketWrapperList)
         {
          system.assert(tw.selected);
         }
         TSC.releaseTickets();
         TSC.getConsumer();
         msgs = ApexPages.getMessages();
         system.assertNotEquals(msgs.size(),0);
         boolean e=false;
         for(apexpages.Message msg:msgs)
         {
          if (msg.getDetail().contains('tickets Released'))
              e=true;
         }
         system.assert(e);
       }  
    }
    
    static testMethod void testreturnTickets()
    {
         /*    verify the status of records after calling return tickets()-returned
              verify the confirmation msg after calling return tickets() method */
              
              create1kTickets();
         
         /*
    	  creates a consumer with firstname a and lastname b
    	  creates a venue with name 'parkwest-IL'
    	  creates a performance with name 'Mika'
    	  creates 1000 seats for venue 'parkwest-IL' for  the future performance 'Mika' 
    	  creates 1000 tickets, one ticket for each seat for future performance 'Mika'
    	
    	*/
         
         
        
         list<ticket__c> mytickets=[select id,name from ticket__c
                                    ];
        //verify if the number of tickets inserted is 1000
         system.assertEquals(mytickets.size(),1000);
        
         /* 
             1000 tickets for 1000 seats are inserted for a single performance
        */
        
        List<Apexpages.Message> msgs = ApexPages.getMessages();
        system.assertEquals(msgs.size(),0);
        
        profile TicketSalesAgentProfile=[select id,name from profile where
                                         name='*UC-Ticket Sales Agent' limit 1];
                                         
        system.AssertNotEquals(TicketSalesAgentProfile,null);
        user salesAgent= new user(Alias = 'standt', Email='salesAgent@testorg.com', 
                                  EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                  LocaleSidKey='en_US', ProfileId = TicketSalesAgentProfile.id, 
                                  TimeZoneSidKey='America/Chicago', UserName='salesAgent@testorg.com');
       system.runAs(salesAgent)
       {
         Test.startTest();
         consumer__c consumer=[select id,name from consumer__C 
                               where first_name__c='a'
                               and last_name__c='b' limit 1];
         test.setCurrentPage(page.purchaseTickets);
         apexpages.standardController thecontroller= new apexpages.standardController(consumer);
         ticketSearchController TSC=new ticketSearchController(thecontroller);
         TSC.InitiatorAction();
        
        //Check for the pageMessages/ErrorMessages
         msgs = ApexPages.getMessages();
         system.assertEquals(msgs.size(),0);
        
         performance__c myperfomrance=[select id,name,start_dateTime__c from performance__c
                                       where start_dateTime__c>:system.now()
                                       limit 1];
         system.assertNotEquals(myperfomrance.id,null);
         TSC.setPerformanceId(myperfomrance.id);
         
         TSC.SearchTickets();
         msgs = ApexPages.getMessages();
         system.assertEquals(msgs.size(),0);
         /*
           verify if the number of records per page is returned as expected
         */
         system.assertEquals(TSC.ticketWrapperList.size(),TSC.pagesize);
         TSC.setSelectAll(true);
         TSC.selectAll();
        
         system.assert(TSC.ticketWrapperList.size()>0);
        // verify if all the checkboxes are true;
         for(ticketSearchController.ticketWrapper tw:TSC.ticketWrapperList)
         {
         /*verify if all the returned records are selected*/
          system.assert(tw.selected);
         }
         
         /*
           verify the message for returnTickets
         */
        TSC.next();
         
        TSC.setSelectAll(true);
         TSC.selectAll();
         system.assert(TSC.ticketWrapperList.size()>0);
        // verify if all the checkboxes are true;
         for(ticketSearchController.ticketWrapper tw:TSC.ticketWrapperList)
         {
          system.assert(tw.selected);
         }
         TSC.returnTickets();
         TSC.getConsumer();
         msgs = ApexPages.getMessages();
         system.assertNotEquals(msgs.size(),0);
         boolean e=false;
         for(apexpages.Message msg:msgs)
         {
          if (msg.getDetail().contains('tickets Returned'))
              e=true;
         }
         system.assert(e);
         
       }
    }
    
    
    static testMethod void testReturntoCustomer()
    {
       /*
          verfiy the pageRef URL after calling back to consumer
       */
       create1ktickets();
        consumer__c consumer=[select id,name from consumer__C 
                               where first_name__c='a'
                               and last_name__c='b' limit 1];
         test.setCurrentPage(page.purchaseTickets);
         apexpages.standardController thecontroller= new apexpages.standardController(consumer);
         ticketSearchController TSC=new ticketSearchController(thecontroller);
         Test.startTest();
         
         system.assertEquals(TSC.redirectToCustomer().getURL(),'/'+consumer.id );
         Test.stopTest();
        
     
    }
    
    static testMethod void testperformanceLookup()
    {
     list<venue__c> venueList=getVenues().values();
     insert venueList;
     system.assertNotEquals(venueList.size(),0);
     list<performance__c> performanceList= new list<performance__c>();
     for(venue__c venue: venueList)
     {
      performanceList.addALL(getperformances(venue.id).values());
     }
     insert performanceList;
     
     list<performance__c> existingperfomances=[select id,name from performance__c];
     system.assert(existingperfomances.size()>0);
        /*
           mika,emblem,wavves,volbeat. Two of each perfomances exist.
        */
        
        profile TicketSalesAgentProfile=[select id,name from profile where
                                         name='*UC-Ticket Sales Agent' limit 1];
                                         
        system.AssertNotEquals(TicketSalesAgentProfile,null);
        user salesAgent= new user(Alias = 'standt', Email='salesAgent@testorg.com', 
                                  EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                  LocaleSidKey='en_US', ProfileId = TicketSalesAgentProfile.id, 
                                  TimeZoneSidKey='America/Chicago', UserName='salesAgent@testorg.com');
     system.runAs(salesAgent){                             
     Test.startTest();
        Test.setCurrentpage(page.performanceLookup);
        apexpages.currentpage().getParameters().put('vfinput','mi');
        performanceLookupController plc=new performanceLookupController();
        system.assertEquals(plc.searchPerformance,'mi');
       
        system.assertEquals(plc.performanceList,null);
        plc.lookupforshow();
        system.assertNotEquals(plc.performanceList.size(),0);
        
        /*
          verify if every performance record returned has name starting with Mi
        */
        for(performance__c p:plc.performanceList)
        {
         system.assert(p.name.startsWith('Mi'));
        }
        /*
          verify if every performance record returned has name starting with Emb
        */
        plc.SearchPerformance='emb';
        plc.lookupforshow();
        for(performance__c p:plc.performanceList)
        {
         system.assert(p.name.startsWith('Emb'));
         system.assert(p.start_datetime__c>=system.now());
        }
        plc.SearchPerformance=null;
        plc.lookupforshow();
        list<performance__c> plist=[select id,name from performance__c];
        system.assertEquals(plist.size(),plc.performanceList.size());
        
        apexpages.currentpage().getParameters().put('vfinput',null);
         plc=new performanceLookupController();
        plc.lookupforshow();
        //list<performance__c> plist=[select id,name from performance__c];
        system.assertEquals(plist.size(),plc.performanceList.size());
        
     Test.stopTest();
     }
    }
   static testMethod void securityTesting()
    {
   	/*
   	 query for different profiles and use runAs method to test the application 
   	 with different user profiles
   	 
   	*/
   	   create1kTickets();
   	   Consumer__c consumer=[select id,name from consumer__c
   	                         limit 1];
   	   profile TicketSalesManagerProfile=[select id,name from profile where
                                         name='*UC-Account Manager' limit 1];
                                         
        system.AssertNotEquals(TicketSalesManagerProfile,null);
        user salesManager= new user(Alias = 'standt', Email='salesManager@testorg.com', 
                                  EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                  LocaleSidKey='en_US', ProfileId = TicketSalesManagerProfile.id, 
                                  TimeZoneSidKey='America/Chicago', UserName='salesManager@testorg.com');
        
        system.runAs(salesManager)
        {
         Test.setCurrentpage(page.purchaseTickets);
         apexpages.standardController thecontroller= new apexpages.standardController(consumer);
         ticketSearchController TSC=new ticketSearchController(thecontroller);
         list<apexPages.Message> msgs = ApexPages.getMessages();
          TSC.InitiatorAction();
        
        //Check for the pageMessages/ErrorMessages
         msgs = ApexPages.getMessages();
         system.assertEquals(msgs.size(),0);
        
         performance__c myperfomrance=[select id,name,start_dateTime__c from performance__c
                                       where start_dateTime__c>:system.now()
                                       limit 1];
         system.assertNotEquals(myperfomrance.id,null);
         TSC.setPerformanceId(myperfomrance.id);
         
         TSC.SearchTickets();
         msgs = ApexPages.getMessages();
         system.assertEquals(msgs.size(),0);
         
         TSC.setSelectAll(true);
         TSC.selectAll();
         
         TSC.purchaseTickets();
         msgs = ApexPages.getMessages();
         system.assertEquals(msgs.size(),1);
         boolean b=false;
         for(apexpages.Message msg:msgs)
         {
          if (msg.getDetail().equals('Only sales or an administrator can update a ticket\'s status.'))
              b=true;
         }
         system.assert(b);
         
         TSC.reserveTickets();
         msgs = ApexPages.getMessages();
         system.assertEquals(msgs.size(),1);
         boolean c=false;
         for(apexpages.Message msg:msgs)
         {
          if (msg.getDetail().equals('Only sales or an administrator can update a ticket\'s status.'))
              c=true;
         }
         system.assert(c);
         
         TSC.releaseTickets();
         msgs = ApexPages.getMessages();
         system.assertEquals(msgs.size(),1);
         boolean d=false;
         for(apexpages.Message msg:msgs)
         {
          if (msg.getDetail().equals('Only sales or an administrator can update a ticket\'s status.'))
              d=true;
         }
         system.assert(d);
         
         TSC.returnTickets();
         msgs = ApexPages.getMessages();
         system.assertEquals(msgs.size(),1);
         boolean e=false;
         for(apexpages.Message msg:msgs)
         {
          if (msg.getDetail().equals('Only sales or an administrator can update a ticket\'s status.'))
              e=true;
         }
         system.assert(e);
         
         
        }
        
   }
   
   static testMethod void preventPurchaseErrorTest()
   {
   
    consumer__c myconsumer1= new consumer__c(First_Name__c='a',
                                       Last_Name__c='b',
                                       Lifetime_Spend__c=0,
                                       Total_Of_Future_Held__c=0,
                                       Total_Of_Future_Purchases__c=0);
    consumer__c myconsumer2= new consumer__c(First_Name__c='c',
                                       Last_Name__c='d',
                                       Lifetime_Spend__c=0,
                                       Total_Of_Future_Held__c=0,
                                       Total_Of_Future_Purchases__c=0);
   
    list<consumer__c> consumerList= new list<consumer__c>();   
    consumerList.add(myconsumer1);
    consumerList.add(myconsumer2);   
    insert consumerList;   
    
    venue__c venue=new venue__c(name='parkwest-IL',Avg_Show_Cost__c=0,Total_Show_Spend__c=0,Show_Approved__c=null);                                                           
    insert venue;
    
    performance__c performance=new performance__c(name='Mika', venue__c=venue.id,Start_DateTime__c=system.now().addDays(1));                                   
    insert performance;
    
    list<seat__c> seatlist=new list<seat__c>();
    for(integer i=0;i<10;i++)
    seatlist.add(new seat__c(name='seat'+i,Row__c=''+i,Seat_Number__c=i,Section__c=null,Venue__c=venue.Id));
    insert seatlist;
    
    list<ticket__c> ticketlist=new list<ticket__c>();
    for(seat__c seat:seatlist)
    {
     ticketlist.add(new ticket__c(Performance__c=performance.Id,
                                     seat__c=seat.Id,
                                     cost__c=100,
                                     status__c=null));
    }
    insert ticketList;
    Test.startTest();
    Test.setCurrentpage(page.purchaseTickets);
         apexpages.standardController thecontroller1= new apexpages.standardController(myconsumer1);
         ticketSearchController TSC1=new ticketSearchController(thecontroller1);
         TSC1.setPerformanceId(performance.id);
         TSC1.searchTickets();
         TSC1.setselectAll(true);
         TSC1.selectAll();
      
         apexpages.standardController thecontroller2= new apexpages.standardController(myconsumer2);
         ticketSearchController TSC2=new ticketSearchController(thecontroller2);
         TSC2.setPerformanceId(performance.id);
         TSC2.searchTickets();
         TSC2.setselectAll(true);
         TSC2.selectAll();
         TSC2.reserveTickets();
         
         list<apexPages.Message> msgs = ApexPages.getMessages();
         system.assertNotEquals(msgs.size(),0);
         boolean z=false;
         for(apexpages.Message msg:msgs)
         {
          if (msg.getDetail().contains('tickets Reserved'))
              z=true;
         }
         system.assert(z);
      
      
      
      
      TSC1.purchaseTickets();
       msgs = ApexPages.getMessages();
      system.assertNotEquals(msgs.size(),0);
      
      boolean a=false;
      for(apexpages.Message msg:msgs)
         {
          if (msg.getDetail().equals('Some tickets already purchased or reserved'))
              a=true;
         }
         system.assert(a);
      
      
         
         
      
    Test.stopTest();     
   }
   static testMethod void additioalTests()
   {
   	create1kTickets();   
    consumer__c consumer=new consumer__c();
    Test.startTest();
    
    
         apexpages.standardController thecontroller= new apexpages.standardController(consumer);
         ticketSearchController TSC=new ticketSearchController(thecontroller); 
         TSC.InitiatorAction();
         
         list<apexPages.Message> msgs = ApexPages.getMessages();
         system.assertNotEquals(msgs.size(),0);
         boolean b=false;
         for(apexpages.Message msg:msgs)
         {
          if (msg.getDetail().equals('Consumer Id is null'))
              b=true;
         }
         system.assert(b);
         
        
         
         TSC=new ticketSearchController(thecontroller); 
         TSC.searchTickets();
         
         msgs = ApexPages.getMessages();
         system.assertNotEquals(msgs.size(),0);
         boolean c=false;
         for(apexpages.Message msg:msgs)
         {
          if (msg.getDetail().equals('Consumer Id is null'))
              c=true;
         }
         system.assert(c);
         
         TSC=new ticketSearchController(thecontroller); 
         TSC.redirectToCustomer();
         
         msgs = ApexPages.getMessages();
         system.assertNotEquals(msgs.size(),0);
         boolean d=false;
         for(apexpages.Message msg:msgs)
         {
          if (msg.getDetail().equals('Consumer Id is null'))
              d=true;
         }
         system.assert(d);
         
         consumer__c myconsumer=[select id,name from consumer__c limit 1];
         system.assertNotEquals(myconsumer,null);
         thecontroller= new apexpages.standardController(myconsumer);
         ticketSearchController TSC1=new ticketSearchController(thecontroller); 
         
         performance__c performance=[select id,name from performance__c limit 1];
         system.assertNotEquals(performance,null);
         TSC1.setPerformanceId(performance.id);
         TSC1.searchTickets();
         system.AssertEquals(TSC1.getselectAll(),false);
         TSC1.setSelectAll(true);
         
         TSC1.selectAll();
         system.AssertEquals(TSC1.getselectAll(),true);
         system.AssertEquals(TSC1.getHasNext(),true);
         TSC1.next();
         system.AssertEquals(TSC1.getselectAll(),false);
         TSC1.previous();
        system.AssertEquals(TSC1.getselectAll(),false);
        TSC1.setselectAll(true);
        TSC1.selectAll();
        TSC1.setselectAll(false);
        TSC1.selectAll();
          
         
         Test.stopTest();
   }
   
   
    
    
    
    static void createData()
    {
        
        // craete consumers
        list<consumer__c> consumerlist= new list<consumer__c>();
        consumerlist.add(getConsumer('a','b'));
        consumerlist.add(getConsumer('c','d'));
        consumerlist.add(getConsumer('e','f'));
        insert consumerlist;
        system.assertNotEquals(consumerlist.size(),0);
        
        map<string,venue__c> venuemap=getVenues();
        insert venuemap.values();
        system.assertNotEquals(venuemap.values().size(),0);
        
        //insert seats
        list<seat__c> seatlist= new list<seat__c>();
        for(venue__c venue:venuemap.values())
        {
         list<seat__c> tempseatlist= getSeats(venue.Id);
         seatlist.addAll(tempseatlist);
        }
        insert seatlist;
        system.assertNotEquals(seatlist.size(),0);
        
        //create performances
        list<performance__c> performancelist= new list<performance__c>();
        for(venue__c venue:venuemap.values())
        { 
         performancelist.addALL(getPerformances(venue.id).values());
        }
        insert performancelist;
        system.assertNotEquals(performancelist.size(),0);
        
        //crateTickets
        list<ticket__c> Ticketlist= new list<Ticket__c>();
        for(performance__c p:performancelist)
        {
         for(seat__c seat:seatlist)
         {
          Ticketlist.addAll(getTickets(p.id,seat.id,100));
         }
         
        }
        insert Ticketlist;
        system.assertNotEquals(Ticketlist.size(),0);
    }
    
  static map<string,venue__c>  getvenues()
    {
     /*
       Create test data
       create 4 venues
     */
      map<string,venue__c> venuemap=new  map<string,venue__c>();
      list<venue__c> venuelist = new list<venue__c>();
        
        venuelist.add(new venue__c(name='parkwest-IL',Avg_Show_Cost__c=0,Total_Show_Spend__c=0,Show_Approved__c=null));
        venuelist.add(new venue__c(name='RivieraTheatre-IL',Avg_Show_Cost__c=0,Total_Show_Spend__c=0,Show_Approved__c=null)); 
        //insert venuelist;
       
      for(venue__c venue:venuelist)
      {
       venuemap.put(venue.name,venue);
      }
        
        return venuemap;
    }
    
    static map<string,performance__c> getPerformances(Id venueId)
    {
       map<string,performance__c> performancemap=new map<string,performance__c>();
       list<performance__c> performancelist=new list<performance__c>();
       performancelist.add(new performance__c(name='Mika', venue__c=venueId,Start_DateTime__c=system.now().addDays(1)));
       performancelist.add(new performance__c(name='Emblem', venue__c=venueId,Start_DateTime__c=system.now().addDays(1)));
       performancelist.add(new performance__c(name='wavves', venue__c=venueId,Start_DateTime__c=system.now().addDays(1)));
       performancelist.add(new performance__c(name='volbeat', venue__c=venueId,Start_DateTime__c=system.now().addDays(1)));
       //insert performancelist;
        
        for(performance__c p:performancelist)
        {
         performancemap.put(p.name,p);
        }
       
       return performancemap;
     }
    
    static list<seat__c> getseats(Id venueId)
    {
      list<seat__c> seatlist=new list<seat__c>();
      for(integer i=0;i<10;i++)  
      {
       seatlist.add(new seat__c(name='seat'+i,Row__c=''+i,Seat_Number__c=i,Section__c=null,Venue__c=venueId));
      }
       return seatlist;
        
    }
    static consumer__c getConsumer(string fname,string lname)
    {
     //map<string,consumer__c> consumermap=new map<string,consumer__c>();
     //list<consumer__c> consumerlist=new list<consumer__c>();
      consumer__c myconsumer= new consumer__c(First_Name__c=fname,
                                       Last_Name__c=lname,
                                       Lifetime_Spend__c=0,
                                       Total_Of_Future_Held__c=0,
                                       Total_Of_Future_Purchases__c=0);
        return myconsumer;
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
    
    static void create1kTickets()
    {
    	/*
    	  creates a consumer with firstname a and lastname b
    	  creates a venue with name 'parkwest-IL'
    	  creates a performance with name 'Mika'
    	  creates 1000 seats for venue 'parkwest-IL' for  the future performance 'Mika' 
    	  creates 1000 tickets, one ticket for each seat for future performance 'Mika'
    	
    	*/
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
    
    

}