@isTest
private class AccountRevenueHelperTest {

    @testSetup
    static void setupTestData() {
         // Création des comptes de test
    List<Account> testAccounts = TestDataFactory.createAccounts(101);
    
    // Création des contrats pour les comptes de test
    List<Contract> contracts = TestDataFactory.createContractsForAccounts(testAccounts);

    // Création du produit de test et de l'entrée dans le livre de prix
    Id priceBookEntryId = TestDataFactory.createTestProductAndPriceBookEntry();
    System.assertNotEquals(null, priceBookEntryId, 'Le PriceBookEntry n\'a pas été créé.');

    // Vérifier que le PriceBookEntry est bien présent.
    PriceBookEntry pbe = [SELECT Id FROM PriceBookEntry WHERE Id = :priceBookEntryId];
    System.assertNotEquals(null, pbe, 'Le PriceBookEntry n\'a pas été récupéré.');
        // Création de commandes et d'ordres pour les comptes
        TestDataFactory.createOrdersForAccounts(testAccounts, 'Ordered', 10, priceBookEntryId, 5000.00, 2);
    }

    @isTest
    static void testUpdateAccountRevenues() {
        // Récupération des comptes de test insérés par la méthode setupTestData
        List<Account> testAccounts = [SELECT Id FROM Account];
        
        // Préparation des données de test pour la mise à jour des revenus
        Set<Id> accountIds = new Set<Id>();
        for (Account acc : testAccounts) {
            accountIds.add(acc.Id);
        }

        // Exécution de la logique métier à tester
        Test.startTest();
        AccountRevenueHelper.updateAccountRevenues(accountIds);
        Test.stopTest();

        // Vérification des résultats
        List<Account> updatedAccounts = [SELECT Id, Chiffre_d_affaire__c FROM Account WHERE Id IN :accountIds];
        for (Account acc : updatedAccounts) {
            System.assertNotEquals(null, acc.Chiffre_d_affaire__c, 'Le chiffre d\'affaire ne devrait pas être null');
            System.assert(acc.Chiffre_d_affaire__c > 0, 'Le chiffre d\'affaire devrait être mis à jour et supérieur à 0');
        }
    }
    
}
