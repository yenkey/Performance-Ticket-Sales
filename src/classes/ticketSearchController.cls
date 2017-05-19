public class ticketSearchController {
    
    public Integer pageNumber;
    public Final integer  pageSize=10;
    public decimal totalPages;
    public consumer__c Consumer;
    public list<Ticket__c> ticketList;
    public list<TicketWrapper> ticketWrapperList{get;set;}
     /*
      for preserving the selected checkboxes
    */
    map<id,ticket__c> selecteTicketMap=new map<id,ticket__c>();
    public boolean hasNext;
    public boolean hasPrevious;
    public transient string PerformanceId;
    public string performanceName{get;set;}
    public string StartDateTime{get;set;}
    public Integer TotalrecordsReturned{get;set;} 
    public boolean error{get;set;}
    public string ErrorString{get;set;}
    public string statusString{get;set;}
    public performance__c  performance{get;set;}
    datetime dtime=system.now();
    set<Id> ConsumerIds=new set<Id>();
    list<string> statuses=new string[]{'Purchased','Reserved'};
    String QueryString;
    User CurrentUser;
    
   // public string debugstring{get;set;}
    
    
    
    public void setPerformanceId(string str)
    {
     if(!string.isEmpty(str))
        str=str.trim();
     PerformanceId=str;
    }
    public string getPerformanceId()
    {
     return performanceId;
    }
   
    public transient boolean selectAll=false;
    public void setselectAll(boolean checkbox)
    {
     selectAll=checkbox;
    }
    public boolean getselectAll()
    {
     return selectAll;
    }
    public Integer getPageNumber()
    {
     return setCon.getPageNumber();
    }
    public void setPageNumber(Integer pnumber)
    {
      pageNumber=pnumber;
    }
    
    public ApexPages.StandardSetController setCon {
        get {
            if(setCon == null) {
                //system.debug('@performanceId '+performanceId);
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(QueryString));
                setCon.setPageSize(pageSize);
                setPageNumber(setCon.getPageNumber());
                //system.debug('--->'+setCon.getRecords());
            }
            return setCon;
        }
        set;
    }
    
    /*
      List that holds the queried tickets
    */
    
    /*
       Constructor for consumer__c Standard controller extension 
    */
    public ticketSearchController(ApexPages.StandardController controller) {
        try{
        Consumer=(consumer__c)controller.getRecord();
        //consumercontroller=controller;
        
        error=false;
        ErrorString='';
        statusString='';
        ticketList=new list<ticket__c>();
        ticketWrapperList=new list<TicketWrapper>();
        currentUser=[select id,name,profile.name
                              from user
                              where id=:userinfo.getUserId()];
        }
        catch(Exception ex)
        {
         Apexpages.addMessage(New apexpages.Message(apexpages.severity.error,ex.getMessage()));
        }               
        
    }
    /*
      For displaying error Messages
    */
    
    public consumer__c getConsumer()
    {
     consumer__c Consumer=[select id,name,
               First_Name__c,Last_Name__c,
               Lifetime_Spend__c,Total_Of_Future_Held__c,
               Total_Of_Future_Purchases__c
               from consumer__c
               where id=:consumer.id];
      return consumer;
    }
    public class ConsumerException extends Exception
    {
     
    }
    /*
       Wrapper class for ticket to display checkboxes
    */
    public class TicketWrapper
    {
     public boolean selected{get;set;}
     public Ticket__c ticket{get;set;}
     ticketWrapper(Ticket__c ticket, boolean selectflag)
      {
       selected=selectflag;
       this.ticket=ticket; 
      }
      ticketWrapper(ticket__c ticket)// method overloading to maintainn the selected tickets
      {
       selected=true;
       this.ticket=ticket; 
      }
    }
    
    public void InitiatorAction()
    {
        try{
            
              //debugstring='Initiator Action';
              if(consumer.id==null)
               Throw new consumerException('Consumer Id is null');
              
              setCon=null;
              statusString='';
              selecteTicketMap.clear();
              ConsumerIds.clear();
              ConsumerIds.add(Consumer.id);
              QueryString='select id,name,status__c,'+
                             'seat__r.Section__c,seat__r.row__c,seat__r.seat_number__c,'+
                             'consumer__c,performance__c,'+
                             'seat__r.venue__c,Seat__r.Venue__r.name,'+
                             'cost__c,Performance__r.Start_DateTime__c '+    
                      ' from ticket__c where Performance__r.Start_DateTime__c >=:dtime '+
                      ' AND Consumer__c IN:ConsumerIds '+
                      ' AND   status__c IN:statuses '+
                      ' order by lastmodifieddate Desc ';
      
              //debugstring+='-->'+string.join(statuses,'-->');
              //debugstring+='-->'+dtime;
              statusString='Showing Purchased/Reserved tickets for future performances'; //for '+consumer.name;
              setCon.First();
              getTicketList(setCon.getRecords());
              TotalrecordsReturned=(setCon.getResultSize());
             //setPageNumber(0);
            }
        catch(QueryException QEx)
         {
           apexpages.addMessage(new apexpages.message(apexpages.severity.error,'Error retrieving tickets'));
         }
        catch(Exception ex)
         {
           apexpages.addMessage(new apexpages.message(apexpages.severity.error,ex.getMessage()));
         }
        
     }
     
    public pageReference searchTickets()
    {
        //debugstring='search tickets';
        try{
      	    if(consumer.id==null)
              {
               Throw new consumerException('Consumer Id is null');
              }
             
           /* if( !( currentUser.Profile.name.equals('*UC-Ticket Sales Agent')
                     || currentUser.Profile.name.equals('System Administrator')) )  
                    {
                     Throw new consumerException('Only sales or an administrator can update a ticket\'s status.');
                    } */
            setCon=null;
            selecteTicketMap.clear();
            error=false;
            statusString='';
            setSelectALL(false);
            setPerformanceId(performanceId);
        
            string performanceQuery='select id,name,start_dateTime__c from performance__c where '+
                                    ' start_dateTime__c>=:dtime And ';
            if(!string.isEmpty(performanceId))
               performanceQuery+=' id=:performanceId'; 
            else if(!string.isEmpty(performanceName)){ 
                string Name_performance=performanceName+'%';
                performanceQuery+=' name like:Name_performance';
              }
            else{
               error=true;
               ErrorString='Please enter performance name to search for tickets';
               reset();  
               return null;
              }
           //debugstring+='---->'+performanceQuery;
           system.debug('@performanceQuery'+performanceQuery);
           performance=database.query(performanceQuery);
           setPerformanceId(performance.id);
           performanceName=performance.name;
           StartDateTime=(performance.start_dateTime__c!=null)?performance.start_dateTime__c.format():' date not found';
           ConsumerIds.add(null);
           consumerIds.add(consumer.id);
           QueryString=   'SELECT name,status__c,'+
                        'seat__r.Section__c,seat__r.row__c,seat__r.seat_number__c,Performance__c,'+
                        'seat__r.venue__c,seat__r.venue__r.name,consumer__c,'+
                        'cost__c,Performance__r.Start_DateTime__c '+ 
                        ' from ticket__c where Performance__r.Start_DateTime__c >=:dtime '+
                        ' AND Consumer__c IN:ConsumerIds '+
                        ' AND  performance__c=:performanceId  '+
                        ' order by lastmodifieddate Desc ';
           statusString='Showing avaiable tickets for furtue performance '+'\''+performance.name+'\''; 
           setCon.First();
           getTicketList(setCon.getRecords());
           setPageNumber(setCon.getPageNumber());
           TotalrecordsReturned=(setCon.getResultSize());
          }
        catch(QueryException Qex)
        {
           error=true;
           if(!string.isEmpty(Qex.getMessage())
              && Qex.getMessage().equals('List has more than 1 row for assignment to SObject')){
              ErrorString='Multiple records found. Use lookup to select one';
            }
            else if(!string.isEmpty(Qex.getMessage())
                    && Qex.getMessage().equals('List has no rows for assignment to SObject')){
             ErrorString='No Records Found.Use lookup to find one';
             }
            else{
              Apexpages.addMessage(new apexpages.Message(apexpages.severity.error,''+Qex.getMessage()));
             }
         
         reset();
         return null;
        }
        catch(Exception ex){
         Apexpages.addMessage(new apexpages.Message(apexpages.severity.error,''+ex.getMessage()));
         reset();
        
         return null;
        
        }
     return null;
    }
    
    public void reset()
    {
     StartDateTime=null;
     ticketList.clear();
     ticketWrapperList.clear();
    }
    
    public pageReference purchaseTickets()
    {
     pageReference pref;
     try{
     	 
     if( !( currentUser.Profile.name.equals('*UC-Ticket Sales Agent')
            || currentUser.Profile.name.equals('System Administrator')) )  
         Throw new consumerException('Only sales or an administrator can update a ticket\'s status.');
           
     gatherSelected();
     boolean preventflag=preventPurchaseorReserve();
      if(preventflag)
         return null;
      
     pref=updateTicketStatusTo('Purchased',consumer.id);
     selecteTicketMap.clear();
     setSelectALL(false);
     setCon=null;
     getTicketList(setCon.getRecords());
    }
     catch(Exception ex)
     {
      ApexPages.addMessage(new apexpages.Message(apexpages.severity.error,ex.getMessage()));
      return null;      
     }
     
     /*
       keeping the user on the same page 
       requerying the records for performance to avoid confusion.
     */
     
      
     return null;
    }
    public pageReference releaseTickets()
    {
    	pageReference pref;
    	try{
    		if( !( currentUser.Profile.name.equals('*UC-Ticket Sales Agent')
                  || currentUser.Profile.name.equals('System Administrator')) )  
               Throw new consumerException('Only sales or an administrator can update a ticket\'s status.');
               
            gatherSelected();
            updateTicketStatusTo(null,null);
            selecteTicketMap.clear();
            setSelectALL(false);
            setCon=null;
            getTicketList(setCon.getRecords());
          
    	   }
    	   catch(Exception Ex)
    	   {
    	     ApexPages.addMessage(new apexpages.Message(apexpages.severity.error,ex.getMessage()));
    	   }
    	     /*
              keeping the user on the same page 
              requerying the records for performance to avoid confusion.
             */
     return pref;
    }
    public pageReference returnTickets()
    {
      pageReference pref;
      try{
      	  if( !( currentUser.Profile.name.equals('*UC-Ticket Sales Agent')
                  || currentUser.Profile.name.equals('System Administrator')) )  
              Throw new consumerException('Only sales or an administrator can update a ticket\'s status.');
              
          gatherSelected();
          updateTicketStatusTo('Returned',null);
          selecteTicketMap.clear();
          setSelectAll(false);
          setCon=null;
          getTicketList(setCon.getRecords());
         // pref=apexpages.currentpage();
          //pref.setRedirect(false);
    	  }
    	  catch(Exception Ex)
    	   {
    	     ApexPages.addMessage(new apexpages.Message(apexpages.severity.error,ex.getMessage()));
    	     
    	   }
    	    /*
              keeping the user on the same page 
              requerying the records for performance to avoid confusion.
             */
     return pref;
    }
    
    public pageReference reserveTickets()
    {
      pageReference pref;
      try{
      	  if( !( currentUser.Profile.name.equals('*UC-Ticket Sales Agent')
                  || currentUser.Profile.name.equals('System Administrator')) )  
              Throw new consumerException('Only sales or an administrator can update a ticket\'s status.');
          gatherSelected();
          boolean preventflag=preventPurchaseorReserve();
     
          if(preventflag)
             return null;
      
          updateTicketStatusTo('Reserved',consumer.id);
          selecteTicketMap.clear();
          setSelectALL(false);
          setCon=null;
          getTicketList(setCon.getRecords());
          //setSelectAll(false);
          //pref=apexpages.currentpage();
          //pref.setRedirect(false);
          
    	   }
    	   catch(Exception Ex)
    	   {
    	     ApexPages.addMessage(new apexpages.Message(apexpages.severity.error,ex.getMessage()));
    	   }
    	     /*
              keeping the user on the same page 
              requerying the records for performance to avoid confusion.
             */
     return pref;
    
    }
    public pageReference redirectToCustomer() 
    {
    	pageReference pref;
    	try{
    	    if(consumer.id==null)
    	     Throw new consumerException('Consumer Id is null');
    	   
           pref= new pageReference('/'+consumer.id);
           
    	}
    	catch(Exception Ex){
    	 ApexPages.addMessage(new apexpages.Message(apexpages.severity.error,ex.getMessage()));
    	}
    	
    	return pref;
    }
    public void next()
    {
        /*
           put the selected records into the map
          */
       
        gatherSelected();
        /*
          return the next set of records unchecked
        */
         setselectAll(false);
         setCon.next();
        /* for creating a checkboxes to the returned set of records*/
         getTicketList(setCon.getRecords());
        
        //set the page number
        pageNumber=setCon.getPageNumber();
    }
    public pageReference previous()
    {
        
        gatherSelected();
        setselectAll(false);
        setCon.Previous();
        getTicketList(setCon.getRecords());
        pageNumber=setCon.getPageNumber();
       
        return null;
    }
    public pageReference first()
    {
        
        gatherSelected();
        setselectAll(false);
        setCon.First();
        getTicketList(setCon.getRecords());
        pageNumber=setCon.getPageNumber();
        return null;
    }
    public pageReference last()
    {
        
        gatherSelected();
        setselectAll(false);
        setCon.Last();
        getTicketList(setCon.getRecords());
        pageNumber=setCon.getPageNumber();
        return null;
    }
    public boolean gethasPrevious()
    {
     return setCon.getHasPrevious();
    }
    public boolean gethasNext()
    {
     return setCon.gethasNext();
    }
    public Decimal gettotalPages()
    {
     Decimal result=math.ceil((setCon.getResultSize()/decimal.valueOf(pageSize)));
     if(result==0)
        result=1;
        
     return result;
    }
    
    public void selectAll()
    {
     setselectAll(selectAll);
     /*
       update the selectedmap when toggling select all between true and false;
     */
     for(ticket__c ticket:(list<ticket__c>)setCon.getRecords())
     {
      if(!selectAll)
      {
       if(selecteTicketMap.containsKey(ticket.id))
          selecteTicketMap.remove(ticket.id);
      }
     }
     getTicketList(setCon.getRecords());
     
    }
    
   
     public void gatherSelected()
     {
        /*
       Add all the selected records to the map to maintain the selection across the navigation.
       Remove the unselected records from the map.
     */
     for(ticketWrapper tw: ticketWrapperList)
     {
      if(tw.selected)
        selecteTicketMap.put(tw.ticket.id,tw.ticket);      
      else if(selecteTicketMap.containsKey(tw.ticket.id))
        selecteTicketMap.remove(tw.ticket.id);
     }
     
     }
    public void getTicketList(list<ticket__c> tickets)
    {
        
       if(ticketList.size()>0)
         ticketlist.clear();
       ticketWrapperList.clear();      
       ticketList.addAll(tickets);
       getselectALL();
       for(Ticket__c tckt: ticketList)
       {
        if(selecteTicketMap.containsKey(tckt.id))
         {
          ticketWrapperList.add(new TicketWrapper(tckt));
         }
        else
          ticketWrapperList.add(new TicketWrapper(tckt,selectALL));
        }
     }
   
    
    public boolean preventPurchaseorReserve()
    {
     boolean preventPurchaseorReserve=false;
     string ticketinfo='';
     
     map<Id,ticket__c> bookedTickets=new map<id,ticket__c>([select id,status__c, 
                                                            seat__r.section__c,
                                                            seat__r.row__c,
                                                            seat__r.seat_number__c,
                                                            seat__r.venue__r.name
                                                            from ticket__c 
                                                            where (status__c='Purchased'
                                                            OR status__c='Reserved')
                                                            And consumer__c!=:consumer.id
                                                            And Id IN:selecteTicketMap.keyset() 
                                                            And performance__r.Start_DateTime__c>=:system.now()]);
       
       
       if(bookedTickets.size()>0)
       {
        Apexpages.AddMessage(new apexpages.Message(apexpages.severity.warning,'Some tickets already purchased or reserved'));
        for(Id ticketId: bookedTickets.keyset())
        {
         ticket__c ticket=bookedTickets.get(ticketId);
         ticketinfo=' Section:'+ticket.seat__r.section__c+' Row:'+
                                     ticket.seat__r.row__c+' Seat Number:'+
                                     ticket.seat__r.seat_number__c+' Venue:'+ticket.seat__r.venue__r.name
                                     +' Status:'+ticket.status__c;
         Apexpages.AddMessage(new apexpages.Message(apexpages.severity.warning,ticketinfo)); 
         preventPurchaseorReserve=true;
         // display the error message only for one record.
         break;
        }
        
       }
     return preventPurchaseorReserve;
    }
    
    public pageReference updateTicketStatusTo(string str,Id Consumer_Id)
    {
    	pageReference pref;
        if(selecteTicketMap.keyset().size()==0){
           apexpages.addMessage(new apexpages.Message(apexpages.severity.Warning,'No selected tickets to update'));
           return pref;
          }
        for(Id ticketId: selecteTicketMap.keyset())
        {
         ticket__c seletedTicket=selecteTicketMap.get(ticketId);
         seletedTicket.status__c=str;
         seletedTicket.consumer__c=Consumer_Id;
         selecteTicketMap.put(seletedTicket.id,seletedTicket);
        }
        
        /*
         For messaging purpose.
        */   
        if(str==null)
           str='Released';
     
        setCon.setSelected(selecteTicketMap.values());
        pref=setCon.save();
    
        if(pref!=null){
        Apexpages.AddMessage(New apexpages.Message(apexpages.severity.Confirm,selecteTicketMap.keyset().size()+' tickets '+str));
        }
     return pref;
    }
    
}