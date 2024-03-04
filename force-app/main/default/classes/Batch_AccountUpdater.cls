global class Batch_AccountUpdater implements Database.Batchable<sObject>{

    global Database.QueryLocator start(Database.BatchableContext BC){ 
        // Requêter seulement les comptes qui ont au moins une commande avec le statut 'Ordered'
        String query = 'SELECT Id FROM Account WHERE Id IN (SELECT AccountId FROM Order WHERE Status = \'Ordered\')';
        return Database.getQueryLocator(query);
    }
     
    global void execute(Database.BatchableContext BC, List<Account> scope){
        // Utilisation d'un Set pour les IDs de compte pour éviter les duplicatas
        Set<Id> accountIds = new Map<Id, Account>(scope).keySet();
 
        // Calcul du chiffre d'affaires pour chaque compte
        Map<Id, Decimal> accountRevenue = new Map<Id, Decimal>();
        for (AggregateResult ar : [SELECT AccountId, SUM(TotalAmount) total FROM Order WHERE AccountId IN :accountIds AND Status = 'Ordered' GROUP BY AccountId]) {
            accountRevenue.put((Id)ar.get('AccountId'), (Decimal)ar.get('total'));
        }
 
        // Mise à jour du chiffre d'affaires sur chaque compte
        List<Account> accountsToUpdate = new List<Account>();
        for(Account acc : scope){
            Decimal revenue = accountRevenue.get(acc.Id);
            if(revenue != null) { // Vérifie si le compte a un chiffre d'affaires calculé
                acc.Chiffre_d_affaire__c = revenue;
                accountsToUpdate.add(acc);
            } else {
                acc.Chiffre_d_affaire__c = 0; // Assigne 0 si aucun chiffre d'affaires n'est trouvé
                accountsToUpdate.add(acc);
            }
        }
        
        // Mise à jour des comptes en masse
        if(!accountsToUpdate.isEmpty()){
            update accountsToUpdate;
        }
    }    
     
    global void finish(Database.BatchableContext BC){     
        // Code de nettoyage ou de suivi final, si nécessaire
    } 
}
