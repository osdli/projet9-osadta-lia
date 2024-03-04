/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class Batch_AccountUpdaterTest {

    @isTest
    static void testUpdateAccountWithOver100Orders() {
        // Créer un seul compte de test
        List<Account> testAccounts = TestDataFactory.createAccounts(1);

        // Créer plus de 100 commandes pour le compte de test, avec le statut 'Ordered'
        TestDataFactory.createOrdersForAccounts(testAccounts, 'Ordered', 101); // Assurez-vous d'ajuster la méthode pour accepter le nombre de commandes

        // Exécuter le batch pour mettre à jour le chiffre d'affaires
        Test.startTest();
        Batch_AccountUpdater batch = new Batch_AccountUpdater();
        Id batchJobId = Database.executeBatch(batch);
        Test.stopTest();

        // Vérifier que le chiffre d'affaires a été mis à jour correctement
        Account updatedAccount = [SELECT Chiffre_d_affaire__c FROM Account WHERE Id = :testAccounts[0].Id];
        System.assertNotEquals(0, updatedAccount.Chiffre_d_affaire__c, 'Le chiffre d\'affaire devrait être mis à jour.');
    }
}
