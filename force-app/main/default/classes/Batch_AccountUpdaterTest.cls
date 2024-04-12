@isTest
private class Batch_AccountUpdaterTest {
    
    @testSetup
    static void setupTestData() {
        // Création des comptes de test
        List<Account> testAccounts = new List<Account>();
        for (Integer i = 0; i < 5; i++) {
            Account acc = new Account(Name = 'Test Account ' + i);
            testAccounts.add(acc);
        }
        insert testAccounts;

        // Création du produit de test et de l'entrée dans le livre de prix
        Product2 testProduct = new Product2(Name = 'Test Product', ProductCode = 'TP001', IsActive = true);
        insert testProduct;

        Id standardPriceBookId = Test.getStandardPricebookId();
        PricebookEntry standardPriceBookEntry = new PricebookEntry(
            Product2Id = testProduct.Id,
            PriceBook2Id = standardPriceBookId,
            UnitPrice = 25000.00,
            IsActive = true
        );
        insert standardPriceBookEntry;

        // Création des commandes en statut 'Draft'
        List<Order> testOrders = new List<Order>();
        for (Account acc : testAccounts) {
            Order testOrder = new Order(
                AccountId = acc.Id,
                Status = 'Draft',
                EffectiveDate = Date.today(),
                Pricebook2Id = standardPriceBookId
            );
            testOrders.add(testOrder);
        }
        insert testOrders;

        // Créer OrderItems pour chaque commande
        for (Order ord : testOrders) {
            OrderItem oi = new OrderItem(
                OrderId = ord.Id,
                PricebookEntryId = standardPriceBookEntry.Id,
                Quantity = 1,
                UnitPrice = 25000.00
            );
            insert oi;
        }

        // Mise à jour du statut à 'Ordered' après avoir ajouté les produits
        for (Order order : testOrders) {
            order.Status = 'Ordered';
        }
        update testOrders;
    }

    @isTest
    static void testBatchProcessesOnlyAccountsWIthOrderedOrders() {
        Test.startTest();
        Batch_AccountUpdater batchInstance = new Batch_AccountUpdater();
        Database.executeBatch(batchInstance);
        Test.stopTest();

        // Vérification que tous les comptes traités ont le statut de leurs commandes à 'Ordered'
        List<Account> updatedAccounts = [SELECT Id, (SELECT Status FROM Orders) FROM Account];
        for (Account acc : updatedAccounts) {
            for (Order ord : acc.Orders) {
                System.assertEquals('Ordered', ord.Status, 'Toutes les commandes devraient être au statut Ordered.');
            }
        }
    }
}
