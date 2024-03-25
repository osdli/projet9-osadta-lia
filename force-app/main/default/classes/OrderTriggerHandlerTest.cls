@isTest
private class OrderTriggerHandlerTest {
    
    @testSetup
    static void setupTestData() {
        // Création et insertion d'un compte test
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Obtention de l'ID du livre de prix standard
        Id standardPriceBookId = Test.getStandardPricebookId();

        // Création et insertion d'un produit test
        Product2 testProduct = new Product2(Name = 'Test Product', ProductCode = 'TP001', IsActive = true);
        insert testProduct;

        // Création et insertion d'une entrée de livre de prix pour le produit test
        PricebookEntry standardPriceBookEntry = new PricebookEntry(
            Product2Id = testProduct.Id,
            PriceBook2Id = standardPriceBookId,
            UnitPrice = 1000.00,
            IsActive = true
        );
        insert standardPriceBookEntry;

        // Utilisation de TestDataFactory pour créer la commande et l'OrderItem
        TestDataFactory.createOrdersForAccounts(
            new List<Account>{testAccount}, 'Draft', 1, standardPriceBookEntry.Id, 1000.00, 1);
    }

    @isTest
    static void testBeforeUpdate() {
        // Récupération et mise à jour de la commande test
        Order testOrder = [SELECT Id, Status FROM Order LIMIT 1];
        String originalStatus = testOrder.Status;
        testOrder.Status = 'Activated';
        update testOrder;
        
        // Requêter la commande après mise à jour pour vérifier les changements
        Order updatedOrder = [SELECT Id, Status FROM Order WHERE Id = :testOrder.Id];
        
        // Assertions pour vérifier si la mise à jour a réussi
        System.assertNotEquals(originalStatus, updatedOrder.Status, 'Le statut de la commande devrait être mis à jour.');
        System.assertEquals('Activated', updatedOrder.Status, 'Le statut de la commande devrait être maintenant Activated.');
    }

    @isTest
    static void testAfterUpdate() {
        // Récupérer la commande
        Order testOrder = [SELECT Id, Status, AccountId FROM Order LIMIT 1];
        
        // Mise à jour de la commande pour passer au statut 'Ordered'
        testOrder.Status = 'Ordered';
        update testOrder;
        
        // Récupérer les informations à jour de la commande et du compte associé
        Account updatedAccount = [SELECT Id, Chiffre_d_affaire__c FROM Account WHERE Id = :testOrder.AccountId];
        
        // Assertions pour vérifier que le chiffre d'affaire a été mis à jour
        System.assertNotEquals(null, updatedAccount.Chiffre_d_affaire__c, 'Le chiffre d\'affaire ne devrait pas être null.');
        System.assert(updatedAccount.Chiffre_d_affaire__c > 0, 'Le chiffre d\'affaire devrait être supérieur à 0.');
    }
}
