global class UpdateAccounts implements Database.Batchable<sObject>{
    
   global Database.QueryLocator start(Database.BatchableContext info){ 
       //Requeter seulement les comptes qui ont au moins une commande avec le Status 'Ordered'
       return Database.getQueryLocator('SELECT Id FROM Account');

   }
    
   global void execute(Database.BatchableContext info, List<Account> scope){      
       //list<Order> listOrders =  [SELECT Id, TotalAmount, AccountId FROM Order];
       
		//for(integer i=0; i < scope.size(); i++){
		//	Account myAccount = scope[i];
		//	myAccount.Chiffre_d_affaire__c = 0;
        //  for(integer j=0; j < listOrders.size(); j++){
        //       if(listOrders[j].AccountId == myAccount.Id){
        //   myAccount.Chiffre_d_affaire__c = myAccount.Chiffre_d_affaire__c + listOrders[j].TotalAmount;
        //       }                   
        //  }
       //}
        Map<Id, Decimal> accountRevenue = new Map<Id, Decimal>();
        for (AggregateResult ar : [SELECT AccountId, SUM(TotalAmount) total FROM Order WHERE AccountId IN :scope GROUP BY AccountId]) {
            accountRevenue.put((Id)ar.get('AccountId'), (Decimal)ar.get('total'));
        }

        for(Account acc : scope){
            acc.Chiffre_d_affaire__c = accountRevenue.get(acc.Id) != null ? accountRevenue.get(acc.Id) : 0;
        }

        
        update scope;
    }    
    
   global void finish(Database.BatchableContext info){     
       
   } 
}