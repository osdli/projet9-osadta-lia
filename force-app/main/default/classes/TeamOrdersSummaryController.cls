public without sharing class TeamOrdersSummaryController {
    private Id accountId;

    // Setter pour accountId
    public void setAccountId(Id accId) {
        this.accountId = accId;
    }

    public decimal SumOrders{
        
        get{
            if (accountId != null) {
            AggregateResult groupedResults = [SELECT SUM(TotalAmount) total FROM Order WHERE AccountId = :accountId AND Status = 'Ordered'];
			return (decimal)groupedResults.get('total');
            }
            return 0;
        }
        set;
    }
}