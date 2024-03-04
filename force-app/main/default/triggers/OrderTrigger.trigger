trigger OrderTrigger on Order (before update, after update) {
    // Avant la mise à jour - Calcul du montant net pour toutes les commandes
    if (Trigger.isBefore) {
        for (Order ord : Trigger.new) {
            ord.NetAmount__c = ord.TotalAmount - ord.ShipmentCost__c;
        }
    }

    // Après la mise à jour - Mise à jour en masse du chiffre d'affaires des comptes
    if (Trigger.isAfter) {
        // Collecte des identifiants de compte
        Set<Id> accountIds = new Set<Id>();
        for (Order ord : Trigger.new) {
            accountIds.add(ord.AccountId);
        }

        // Préparation de la mise à jour en masse des comptes
        Map<Id, Decimal> accountRevenues = new Map<Id, Decimal>();
        
        // Initialisation des montants pour les comptes concernés
        for (AggregateResult ar : [SELECT AccountId, SUM(TotalAmount) total FROM Order WHERE AccountId IN :accountIds AND Status = 'Closed' GROUP BY AccountId]) {
            accountRevenues.put((Id)ar.get('AccountId'), (Decimal)ar.get('total'));
        }

        List<Account> accountsToUpdate = new List<Account>();
        for (Id accId : accountRevenues.keySet()) {
            accountsToUpdate.add(new Account(Id = accId, Chiffre_d_affaire__c = accountRevenues.get(accId)));
        }

        // Mise à jour en masse
        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
        }
    }
}

