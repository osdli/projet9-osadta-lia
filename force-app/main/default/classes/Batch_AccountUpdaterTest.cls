@isTest
private class Batch_AccountUpdaterTest {

    @isTest
    static void testUpdateAccountWithOver100Orders() {
        // Créer un seul compte de test
        List<Account> testAccounts = TestDataFactory.createAccounts(1);

        // Créer 101 commandes pour le compte de test, avec le statut 'Ordered'
        List<Order> orders = TestDataFactory.createOrdersForAccounts(testAccounts, 'Ordered', 101);

        // Configurer et exécuter le batch de mise à jour
        Test.startTest();
        Batch_AccountUpdater batch = new Batch_AccountUpdater();
        Database.executeBatch(batch);
        Test.stopTest();

        // Vérifier que le chiffre d'affaires du compte a été mis à jour correctement
        Account updatedAccount = [SELECT Id, Chiffre_d_affaire__c FROM Account WHERE Id = :testAccounts[0].Id].get(0);
        System.assertNotEquals(0, updatedAccount.Chiffre_d_affaire__c, 'Le chiffre d\'affaires devrait être mis à jour.');
    }
}
