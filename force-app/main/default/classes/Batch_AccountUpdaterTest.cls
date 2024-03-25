@isTest
private class Batch_AccountUpdaterTest {

    @testSetup
    static void setupTestData() {
        // Création des comptes de test
        List<Account> testAccounts = TestDataFactory.createAccounts(5);

        // Création des contrats pour les comptes de test 
        TestDataFactory.createContractsForAccounts(testAccounts);

        // Création du produit de test et de l'entrée dans le livre de prix
        Id priceBookEntryId = TestDataFactory.createTestProductAndPriceBookEntry();

        // Création des commandes et des éléments de commande pour les comptes
        Decimal unitPrice = 100; 
        Integer quantityPerOrder = 2; 
        List<Order> orders = TestDataFactory.createOrdersForAccounts(testAccounts, 'Ordered', 1, priceBookEntryId, unitPrice, quantityPerOrder);
    }

    @isTest
    static void testBatchAccountUpdater() {
        // Préparation et exécution du batch
        Test.startTest();
        Batch_AccountUpdater batchInstance = new Batch_AccountUpdater();
        Database.executeBatch(batchInstance);
        Test.stopTest();

        // Vérification que le chiffre d'affaires des comptes a été correctement mis à jour
        List<Account> updatedAccounts = [SELECT Id, Chiffre_d_affaire__c FROM Account];
        for(Account acc : updatedAccounts) {
            System.assertNotEquals(null, acc.Chiffre_d_affaire__c, 'Le chiffre d\'affaire ne devrait pas être null.');
            System.assert(acc.Chiffre_d_affaire__c > 0, 'Le chiffre d\'affaire devrait être supérieur à 0.');
        }
    }
}
