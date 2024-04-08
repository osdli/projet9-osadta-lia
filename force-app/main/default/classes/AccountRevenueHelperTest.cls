@isTest
private class AccountRevenueHelperTest {

    @testSetup
    static void setupTestData() {
        // Création des comptes de test
        List<Account> testAccounts = TestDataFactory.createAccounts(10);

        // Création des contrats pour les comptes de test
        List<Contract> contracts = TestDataFactory.createContractsForAccounts(testAccounts);

        // Création du produit de test et de l'entrée dans le livre de prix
        Id priceBookEntryId = TestDataFactory.createTestProductAndPriceBookEntry();

        // Création de commandes en tant que brouillon (Draft) pour les comptes
        TestDataFactory.createOrdersForAccounts(testAccounts, 'Draft', 101, priceBookEntryId, 5000.00, 2);

        // Mise à jour des commandes à l'état 'Ordered' si votre processus le permet
        List<Order> draftOrders = [SELECT Id FROM Order WHERE Status = 'Draft' AND AccountId IN :testAccounts];
        for(Order ord : draftOrders) {
            ord.Status = 'Ordered';
            
        }
        update draftOrders; 
    }


    @isTest
    static void testUpdateAccountRevenues() {
        // Récupération d'un des comptes de test insérés par la méthode setupTestData
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        Id testAccountId = testAccount.Id;
        
        // Préparer un montant attendu pour le test
        Decimal expectedRevenueForAccount = 0;
        List<Order> ordersForAccount = [SELECT TotalAmount FROM Order WHERE AccountId = :testAccountId AND Status = 'Ordered'];
        for (Order ord : ordersForAccount) {
            expectedRevenueForAccount += ord.TotalAmount;
        }

        // Exécuter la logique de mise à jour des revenus
        Test.startTest();
        AccountRevenueHelper.updateAccountRevenues(new Set<Id>{testAccountId});
        Test.stopTest();

        // Récupération du compte après la mise à jour pour vérifier le chiffre d'affaires
        testAccount = [SELECT Id, Chiffre_d_affaire__c FROM Account WHERE Id = :testAccountId];

        // Vérification que le chiffre d'affaires est correct
        System.assertEquals(expectedRevenueForAccount, testAccount.Chiffre_d_affaire__c,
            'Le chiffre d\'affaire devrait être mis à jour avec le montant correct des commandes.');
    }
}
