public class AccountRevenueHelper {

    public static void updateAccountRevenues(Set<Id> accountIds) {
        // Calcul du chiffre d'affaires pour chaque compte
        Map<Id, Decimal> accountRevenue = new Map<Id, Decimal>();
        for (AggregateResult ar : [
            SELECT AccountId, SUM(TotalAmount) total 
            FROM Order 
            WHERE AccountId IN :accountIds AND Status = 'Ordered' 
            GROUP BY AccountId
        ]) {
            accountRevenue.put((Id)ar.get('AccountId'), (Decimal)ar.get('total'));
        }

        // Préparation de la liste des comptes à mettre à jour
        List<Account> accountsToUpdate = new List<Account>();
        for (Account acc : [SELECT Id, Chiffre_d_affaire__c FROM Account WHERE Id IN :accountIds]) {
            Decimal revenue = accountRevenue.get(acc.Id);
            acc.Chiffre_d_affaire__c = revenue != null ? revenue : 0;
            accountsToUpdate.add(acc);
        }

        // Mise à jour des comptes en masse
        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
        }
    }
}
