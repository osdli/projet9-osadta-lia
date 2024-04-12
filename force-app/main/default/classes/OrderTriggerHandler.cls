public class OrderTriggerHandler {
    
    // Gérer 'before update'
    public static void beforeUpdate(List<Order> orders) {
        for (Order ord : orders) {
            Decimal shipmentCost = ord.ShipmentCost__c != null ? ord.ShipmentCost__c : 0;
            ord.NetAmount__c = ord.TotalAmount - shipmentCost;
        }
    }

    // Gérer 'after update'
    public static void afterUpdate(List<Order> orders) {
        Set<Id> accountIds = new Set<Id>();
        for (Order ord : orders) {
            if(ord.Status == 'Ordered') {
                accountIds.add(ord.AccountId);
            }
        }
        
        if (!accountIds.isEmpty()) {
            updateAccountRevenues(accountIds);
        }
    }

    // Mettre à jour le chiffre d'affaires des comptes
    private static void updateAccountRevenues(Set<Id> accountIds) {
        Map<Id, Decimal> accountRevenues = new Map<Id, Decimal>();
        
        for (AggregateResult ar : [
            SELECT AccountId, SUM(TotalAmount) total 
            FROM Order 
            WHERE AccountId IN :accountIds AND Status = 'Ordered' 
            GROUP BY AccountId
        ]) {
            accountRevenues.put((Id)ar.get('AccountId'), (Decimal)ar.get('total'));
        }

        List<Account> accountsToUpdate = new List<Account>();
        for (Id accId : accountRevenues.keySet()) {
            accountsToUpdate.add(new Account(Id = accId, Chiffre_d_affaire__c = accountRevenues.get(accId)));
        }

        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
        }
    }
}
