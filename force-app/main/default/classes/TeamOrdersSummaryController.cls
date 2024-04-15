public without sharing class TeamOrdersSummaryController {
    private Id accountId;
    public Decimal sumOrders {get; set;}

   
    public TeamOrdersSummaryController() {
        // Récupération de l'ID du compte en le lisant depuis l'URL 
        accountId = ApexPages.currentPage().getParameters().get('id');
        // Initialiser sumOrders
        updateSumOrders();
    }

    // Mettre à jour la somme des commandes
    public void updateSumOrders() {
        if (accountId != null) {
            AggregateResult groupedResults = [
                SELECT SUM(TotalAmount) total
                FROM Order
                WHERE AccountId = :accountId AND Status = 'Ordered'
            ];
            sumOrders = (Decimal)groupedResults.get('total');
            // Gérer le cas où aucun résultat n'est trouvé
            if (sumOrders == null) {
                sumOrders = 0;
            }
        } else {
            sumOrders = 0;
        }
    }
}
