@isTest
private class TeamOrdersSummaryControllerTest {

    @isTest static void testSumOrders() {
        // Préparation des données de test
        Account testAccount = new Account(Name='Test Account');
        insert testAccount;

        // Logique pour créer et insérer des commandes liées au testAccount
        // Créer des commandes avec un montant total de 500
        // Decimal expectedTotalAmount = 500;

        // Instanciation du contrôleur avec le compte de test
        TeamOrdersSummaryController controller = new TeamOrdersSummaryController();
        controller.setAccountId(testAccount.Id);

        // Appel de la méthode à tester
        Decimal sumOrders = controller.SumOrders;

        // Définir le montant attendu en fonction du montant attendu
        Decimal expectedTotalAmount = 500; 

        // Assertion pour vérifier si le résultat est conforme aux attentes
        System.assertEquals(expectedTotalAmount, sumOrders, 'La somme des commandes devrait être égale à ' + expectedTotalAmount);
    }
}
