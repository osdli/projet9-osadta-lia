@isTest
private class TeamOrdersSummaryControllerTest {

    @isTest static void testSumOrders() {
        // Création d'un compte test
        List<Account> testAccounts = TestDataFactory.createAccounts(1);
        Account testAccount = testAccounts[0];

        // Création d'un produit et d'une entrée de livre de prix
        Id priceBookEntryId = TestDataFactory.createTestProductAndPriceBookEntry();

        // Création de commandes et de leurs éléments pour le compte test avec un montant total de 500
        TestDataFactory.createOrdersForAccounts(
            new List<Account>{testAccount}, 'Ordered', 1, priceBookEntryId, 500.00, 1);

        // Debug: Vérifier le nombre de commandes créées et leur statut
        List<Order> orders = [SELECT Id, Status FROM Order WHERE AccountId = :testAccount.Id];
        System.debug('Orders created: ' + orders.size());
        for (Order ord : orders) {
            System.debug('Order Status: ' + ord.Status);
        }

        // Instanciation du contrôleur avec le compte test
        TeamOrdersSummaryController controller = new TeamOrdersSummaryController();
        controller.setAccountId(testAccount.Id);

        // Récupération de la somme des commandes
        Decimal sumOrders = controller.sumOrders;

        // Debug: Vérifier la somme des commandes calculée
        System.debug('Calculated sumOrders: ' + sumOrders);

        // Vérification de la somme des commandes
        System.assertEquals(500, sumOrders, 'La somme des commandes devrait être égale à 500');
    }
}
