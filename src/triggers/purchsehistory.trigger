trigger purchsehistory on Consumer__c (before update) {
	
	
	
  if(trigger.isupdate
     && !purchaseHistoryHandler.getpHupdateFired())
     {  
     	// to prevent recursive firing
     	purchaseHistoryHandler.setpHupdateFired();  
     	
        purchaseHistoryHandler.updatefuturePurchases(trigger.new);
        purchaseHistoryHandler.updatelifetimePurchases(trigger.new);
        purchaseHistoryHandler.updatefutureReservations(trigger.new);
    } 
  
  
}