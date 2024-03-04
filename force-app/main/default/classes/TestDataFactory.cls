@isTest
public class TestDataFactory {

    // Méthode corrigée pour créer des comptes de test
    public static List<Account> createAccounts(Integer numAccounts) {
        List<Account> accounts = new List<Account>();
        for(Integer i = 0; i < numAccounts; i++) {
            accounts.add(new Account(Name = 'Test Account ' + i));
        }
        insert accounts;
        return accounts; // Ajout de l'instruction de retour manquante
    }

    // Méthode ajustée pour créer un nombre spécifié de commandes pour des comptes
    public static List<Order> createOrdersForAccounts(List<Account> accounts, String status, Integer numOrdersPerAccount) {
        List<Order> orders = new List<Order>();
        for(Account acc : accounts) {
            for(Integer i = 0; i < numOrdersPerAccount; i++) {
                // Assurez-vous d'ajuster les champs nécessaires pour la création de l'objet Order
                orders.add(new Order(AccountId = acc.Id, Status = status));
            }
        }
        insert orders;
        return orders;
    }

    // Autres méthodes de création de données de test selon les besoins...
}

