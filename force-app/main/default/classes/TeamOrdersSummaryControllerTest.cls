@isTest
private class TeamOrdersSummaryControllerTest {

    static Id priceBookEntryId;

    @testSetup
    static void setupTestData() {
        // Création d'un compte test
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Création et insertion d'un produit de test
        Product2 testProduct = new Product2(Name = 'Test Product', IsActive = true);
        insert testProduct;

        // Récupération de l'ID du livre de prix standard
        Id standardPriceBookId = Test.getStandardPricebookId();

        // Création et insertion d'une entrée de livre de prix pour le produit de test
        PricebookEntry standardPriceBookEntry = new PricebookEntry(
            Product2Id = testProduct.Id,
            PriceBook2Id = standardPriceBookId,
            UnitPrice = 5000.00,
            IsActive = true
        );
        insert standardPriceBookEntry;
        priceBookEntryId = standardPriceBookEntry.Id;

        // Création de commandes pour le compte test avec le statut 'Draft'
        TestDataFactory.createOrdersForAccounts(
            new List<Account>{testAccount}, 'Draft', 200, priceBookEntryId, 5000.00, 1);

        // Mettre à jour le statut des commandes à 'Ordered'
        List<Order> ordersToUpdate = [SELECT Id FROM Order WHERE AccountId = :testAccount.Id AND Status = 'Draft'];
        for (Order ord : ordersToUpdate) {
            ord.Status = 'Ordered'; 
        }
        update ordersToUpdate;
    }

    @isTest
static void testSumOrdersWithMultipleOrders() {
    // Vérifier le compte et les commandes
    Account testAccount = [SELECT Id, (SELECT Id FROM Orders) FROM Account WHERE Name = 'Test Account' LIMIT 1];
    System.debug('Number of orders: ' + testAccount.Orders.size()); // Afficher le nombre de commandes trouvées pour déboguer

    Test.setCurrentPageReference(new PageReference('Page.dummyPage'));
    ApexPages.currentPage().getParameters().put('id', testAccount.Id);

    // Instanciation du contrôleur
    TeamOrdersSummaryController controller = new TeamOrdersSummaryController();

    // Le UnitPrice est de 5000.00 pour 200 commandes avec chaque commande ayant un OrderItem au UnitPrice 5000.
    Decimal expectedSum = 200 * 5000.00;
    System.assertEquals(expectedSum, controller.sumOrders, 'La somme des commandes devrait être égale à ' + expectedSum);
}


    @isTest
    static void testSumOrdersWithNoOrders() {

        // Créer un compte supplémentaire sans commandes
        Account anotherTestAccount = new Account(Name = 'Another Test Account');
        insert anotherTestAccount;

        // Simuler l'accès à une page et passer l'ID du nouveau compte comme paramètre d'URL
        Test.setCurrentPageReference(new PageReference('Page.dummyPage'));
        ApexPages.currentPage().getParameters().put('id', anotherTestAccount.Id);

        // Instanciation du contrôleur pour le nouveau compte
        TeamOrdersSummaryController controller = new TeamOrdersSummaryController();

        // Vérification de la somme des commandes
        System.assertEquals(0, controller.sumOrders, 'La somme des commandes pour un compte sans commandes devrait être 0');
    }
}
