public class purchaseHistoryHandler{
	
	public static boolean pHupdateFired=false;
	public static boolean getpHupdateFired()
	{
	 return pHupdateFired;
	}
	
	public static void setpHupdateFired()
	{
	  pHupdateFired=true;
	}
	public static void reset()
	{
	  pHupdateFired=false;
	}	
	
	public static void updatefutureReservations(list<consumer__c> newlist)
	{
                                          
     list<AggregateResult> FutureReserveAggregate=[select consumer__c,SUM(cost__c) futureReserveSpent
                                          from ticket__c
                                          where status__c='Reserved'
                                          AND performance__r.start_datetime__c>:system.now()
                                          and consumer__c IN:trigger.newmap.keyset()
                                          Group by consumer__c];
    
       for(consumer__c consumer:newlist)
        { 
          consumer.Total_Of_Future_Held__c=0;
          for(AggregateResult AR: FutureReserveAggregate)
          {
            if(AR.get('consumer__c')==consumer.Id)
              {
               Decimal AggrRes=(Decimal)AR.get('futureReserveSpent');
               consumer.Total_Of_Future_Held__c=AggrRes;
              }
          }
        }
	 
	}
	
	public static void updatelifetimePurchases(list<consumer__c> newlist)
	{
		list<AggregateResult> purchseAggregate=[select consumer__c,SUM(cost__c) lifetimespend
                                          from ticket__c
                                          where status__c='Purchased'
                                          and consumer__c IN:trigger.newmap.keyset()
                                          Group by consumer__c];
                                          
        for(consumer__c consumer:newlist)
        { 
          consumer.Lifetime_Spend__c=0;
         for(AggregateResult AR: purchseAggregate)
         {
          if(AR.get('consumer__c')==consumer.Id)
            {
             Decimal AggrRes=(Decimal)AR.get('lifetimespend');
             consumer.Lifetime_Spend__c=AggrRes;
            }
          }
        }
	 }
	
	public static void updatefuturePurchases(list<consumer__c> newlist)
	 {
		
	   list<AggregateResult> FuturepurchseAggregate=[select consumer__c,SUM(cost__c) futurePurchaseSpent
                                                     from ticket__c
                                                     where status__c='Purchased'
                                                     AND performance__r.start_datetime__c>:system.now()
                                                     and consumer__c IN:trigger.newmap.keyset()
                                                     Group by consumer__c];	
		
	                                  
        for(consumer__c consumer:newlist)
          { 
          	consumer.Total_Of_Future_Purchases__c=0;
	       for(AggregateResult AR: FuturepurchseAggregate)
              {
                if(AR.get('consumer__c')==consumer.Id)
                  {
                      Decimal AggrRes=(Decimal)AR.get('futurePurchaseSpent');
                      consumer.Total_Of_Future_Purchases__c=AggrRes;
                  }
               }
           }
	
	  }
   
                                          
}