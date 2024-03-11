global class Batch_AccountUpdater implements Database.Batchable<sObject>{

    global Database.QueryLocator start(Database.BatchableContext BC){ 
        // Requêter seulement les comptes qui ont au moins une commande avec le statut 'Ordered'
        String query = 'SELECT Id FROM Account WHERE Id IN (SELECT AccountId FROM Order WHERE Status = \'Ordered\')';
        return Database.getQueryLocator(query);
    }
     
    global void execute(Database.BatchableContext BC, List<Account> scope){
        // Utilisation d'un Set pour les IDs de compte pour éviter les duplicatas
        Set<Id> accountIds = new Map<Id, Account>(scope).keySet();
        
        // Appel à la classe helper pour mettre à jour le chiffre d'affaires
        AccountRevenueHelper.updateAccountRevenues(accountIds);
    }
     
    global void finish(Database.BatchableContext BC){     
        // Code de nettoyage ou de suivi final, si nécessaire
    } 
}
