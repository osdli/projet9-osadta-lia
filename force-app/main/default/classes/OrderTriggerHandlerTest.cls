@isTest
private class OrderTriggerHandlerTest {

    @testSetup
    static void setupTestData() {
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

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

        List<Order> testOrders = new List<Order>();
        for (Integer i = 0; i < 2; i++) {
            Order testOrder = new Order(
                AccountId = testAccount.Id,
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
                UnitPrice = 5000.00
            );
            insert oi;
        }
    }

    @isTest
    static void testBeforeUpdate() {
        // Sélection d'une commande de test à mettre à jour
        Order testOrder = [SELECT Id, TotalAmount, ShipmentCost__c, NetAmount__c FROM Order WHERE Status = 'Draft' LIMIT 1];
        testOrder.ShipmentCost__c = 100.00;
        update testOrder;
        
        // Vérification que NetAmount__c a été correctement mis à jour
        Order updatedOrder = [SELECT Id, NetAmount__c FROM Order WHERE Id = :testOrder.Id];
        Decimal expectedNetAmount = testOrder.TotalAmount - testOrder.ShipmentCost__c;
        
        System.assertEquals(expectedNetAmount, updatedOrder.NetAmount__c, 'Le montant net devrait être correctement recalculé.');
    }

    @isTest
    static void testAfterUpdate() {
        // Mise à jour du statut de toutes les commandes pour déclencher le traitement 'after update'
        List<Order> ordersToUpdate = [SELECT Id, Status FROM Order WHERE Status = 'Draft'];
        for (Order ord : ordersToUpdate) {
            ord.Status = 'Ordered';
        }
        update ordersToUpdate;

        // Vérification que le chiffre d'affaires des comptes a été mis à jour
        Account updatedAccount = [SELECT Id, Chiffre_d_affaire__c FROM Account WHERE Name = 'Test Account' LIMIT 1];
        
        // Le chiffre d'affaires attendu doit être le total des montants des commandes mises à jour.
        Decimal expectedRevenue = 2 * 5000.00; 
        
        System.assertEquals(expectedRevenue, updatedAccount.Chiffre_d_affaire__c, 'Le chiffre d\'affaire de l\'account devrait être mis à jour.');
    }
}
